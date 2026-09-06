import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Inicialização centralizada do Firebase.
///
/// Faz "graceful degradation": se as chaves ainda forem placeholders
/// (`REPLACE_ME`), o app **não quebra** — apenas roda em modo offline/local,
/// permitindo desenvolver a UI antes de configurar o Firebase.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool get isReady => _initialized;

  static Future<void> init() async {
    // Detecta placeholders para evitar crash no primeiro run.
    final opts = DefaultFirebaseOptions.currentPlatform;
    if (opts.apiKey == 'REPLACE_ME') {
      debugPrint(
        '⚠️  Firebase não configurado (placeholders). '
        'Rode `flutterfire configure`. App em modo local.',
      );
      return;
    }

    try {
      await Firebase.initializeApp(options: opts);

      // App Check — debug provider em debug; Play Integrity / DeviceCheck em release.
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode
              ? AndroidProvider.debug
              : AndroidProvider.playIntegrity,
          appleProvider:
              kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
        );
      } catch (e) {
        debugPrint('App Check activate falhou (segue sem enforce): $e');
      }

      // Crashlytics não tem suporte ao Flutter Web — no navegador mantemos
      // apenas os handlers globais já registrados em main.dart
      // (FlutterError.onError / PlatformDispatcher.instance.onError).
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      _initialized = true;
      debugPrint('✅ Firebase inicializado.');
    } catch (e, s) {
      debugPrint('❌ Falha ao inicializar Firebase: $e\n$s');
    }
  }
}
