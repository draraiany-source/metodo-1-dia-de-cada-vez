import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/firebase_service.dart';
import 'core/services/feedback_service.dart';
import 'core/services/notifications_service.dart';
import 'core/services/local_reminders_service.dart';
import 'core/services/premium_service.dart';

/// Tela de erro legível exibida caso a inicialização falhe de forma
/// irrecuperável — nunca deixamos a página em branco.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1030),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Não foi possível iniciar o app',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  // Captura global de erros — registrada ANTES de qualquer inicialização
  // assíncrona, para nunca deixar uma exceção silenciosa gerar tela branca.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrintStack(
      stackTrace: details.stack,
      label: details.exceptionAsString(),
    );
  };

  var appStarted = false;

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _installGlobalErrorHandlers();

    // Trava em modo retrato — apenas Android/iOS. No Flutter Web,
    // `SystemChrome.setPreferredOrientations` pode lançar uma exceção
    // (a API de orientação do navegador exige modo fullscreen), e como
    // essa chamada não era protegida, a exceção interrompia o main()
    // ANTES de runApp() ser chamado — causando a tela em branco.
    if (!kIsWeb) {
      try {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } catch (e, s) {
        debugPrint('⚠️  Falha ao travar orientação: $e');
        debugPrintStack(stackTrace: s);
      }
    }

    // Dados de localização (pt_BR) usados pelo Calendário (table_calendar/intl).
    try {
      await initializeDateFormatting('pt_BR', null);
    } catch (e, s) {
      debugPrint('⚠️  Falha ao inicializar dados de data (pt_BR): $e');
      debugPrintStack(stackTrace: s);
    }

    // Inicializa Firebase (com degradação graciosa se não configurado).
    try {
      await FirebaseService.init();
      if (FirebaseService.isReady && AppConfig.billingConfigured) {
        await RevenueCatPremiumService.ensureConfigured();
      }
    } catch (e, s) {
      debugPrint('⚠️  Falha ao inicializar Firebase: $e');
      debugPrintStack(stackTrace: s);
    }

    // Notificações push (FCM). No-op se o Firebase não estiver configurado.
    try {
      await NotificationsService.init();
    } catch (e, s) {
      debugPrint('⚠️  Falha ao inicializar notificações push: $e');
      debugPrintStack(stackTrace: s);
    }

    // Notificações locais agendadas (módulo de Lembretes). O pacote
    // `flutter_local_notifications` não tem implementação para Web, então
    // só inicializamos em Android/iOS — evita exceções de plugin ausente
    // logo na abertura do app.
    if (!kIsWeb) {
      try {
        await LocalRemindersService.init();
      } catch (e, s) {
        debugPrint('⚠️  Falha ao inicializar lembretes locais: $e');
        debugPrintStack(stackTrace: s);
      }
    }

    // Preferências de som e vibração (feedback de conquistas).
    try {
      await FeedbackService.load();
    } catch (e, s) {
      debugPrint('⚠️  Falha ao carregar preferências de feedback: $e');
      debugPrintStack(stackTrace: s);
    }

    runApp(const ProviderScope(child: Metodo1DiaApp()));
    appStarted = true;
  }, (error, stack) {
    debugPrint('ERRO NÃO TRATADO: $error');
    debugPrintStack(stackTrace: stack);
    // Só substitui o app se a falha ocorreu ANTES do runApp.
    // Depois do app rodando (ex.: asset da mascote), NÃO destruímos a UI —
    // isso gerava "Não foi possível iniciar o app" ao tocar em Iniciar treino.
    if (!appStarted) {
      runApp(_StartupErrorApp(error: error));
    }
  });
}

/// Handler de erros não capturados que escapam do binding do Flutter
/// (ex.: erros assíncronos fora de builds/callbacks de widgets).
/// Mantido aqui para diagnóstico contínuo após o app já estar rodando.
void _installGlobalErrorHandlers() {
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('ERRO NÃO TRATADO: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };
}
