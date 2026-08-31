import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';

/// Log seguro: só imprime em debug. `debugPrint` roda também em release,
/// então logs com token/PII vazariam para o logcat/console do dispositivo.
void _log(String msg) {
  if (kDebugMode) debugPrint(msg);
}

/// Handler de mensagens recebidas em segundo plano.
///
/// Precisa ser função top-level (exigência do firebase_messaging).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  _log('📩 Push (background): ${message.messageId}');
}

/// Serviço de notificações push (FCM) com degradação graciosa.
///
/// Se o Firebase não estiver configurado (modo local), todos os métodos viram
/// no-op — o app continua funcionando normalmente sem push.
class NotificationsService {
  NotificationsService._();

  static FirebaseMessaging? get _fm =>
      FirebaseService.isReady ? FirebaseMessaging.instance : null;

  static String? token;

  /// Inicializa o FCM: pede permissão, registra handlers e obtém o token.
  /// Chame depois de `FirebaseService.init()`.
  static Future<void> init() async {
    final fm = _fm;
    if (fm == null) {
      _log('🔕 Notificações: Firebase não configurado — pulando FCM.');
      return;
    }
    try {
      // Permissão (iOS pede explicitamente; Android 13+ também).
      final settings = await fm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _log('🔔 Permissão de push: ${settings.authorizationStatus}');

      // Handler de background (top-level).
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);

      // Foreground: aqui você pode exibir um SnackBar/local notification.
      FirebaseMessaging.onMessage.listen((message) {
        // Não logamos título/corpo: podem conter dados pessoais.
        _log('📩 Push (foreground) recebido: ${message.messageId}');
      });

      // Token do dispositivo (envie ao Firestore para direcionar pushes).
      token = await fm.getToken();
      // O token permite enviar push a este device — nunca logar por inteiro.
      _log(token == null
          ? '🎫 FCM token indisponível'
          : '🎫 FCM token obtido (…${token!.substring(token!.length - 6)})');

      // Atualização de token.
      fm.onTokenRefresh.listen((t) {
        token = t;
        _log('🎫 FCM token atualizado.');
      });
    } catch (e) {
      _log('❌ Falha ao iniciar notificações: $e');
    }
  }

  /// Inscreve o usuário em um tópico (ex.: 'desafios', 'motivacao_diaria').
  static Future<void> subscribe(String topic) async {
    try {
      await _fm?.subscribeToTopic(topic);
    } catch (e) {
      _log('subscribe($topic) falhou: $e');
    }
  }

  static Future<void> unsubscribe(String topic) async {
    try {
      await _fm?.unsubscribeFromTopic(topic);
    } catch (e) {
      _log('unsubscribe($topic) falhou: $e');
    }
  }
}
