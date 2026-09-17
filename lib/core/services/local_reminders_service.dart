import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../config/app_config.dart';

void _log(String msg) {
  if (kDebugMode) debugPrint(msg);
}

/// Serviço de notificações LOCAIS agendadas (diferente do [NotificationsService],
/// que cuida de push remoto via FCM). Usado pelo módulo de Lembretes para
/// tocar às horas configuradas pela usuária, mesmo sem internet.
///
/// Degrada graciosamente: se a plataforma negar permissão, os métodos viram
/// no-op e o resto do app continua funcionando normalmente.
class LocalRemindersService {
  LocalRemindersService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      // `flutter_local_notifications` não possui implementação para Web —
      // evita exceções de plugin ausente. As telas de Lembretes continuam
      // funcionando normalmente com os métodos abaixo virando no-op.
      _log('🔕 Lembretes locais: indisponível no Web.');
      return;
    }
    tz_data.initializeTimeZones();
    // Sem detectar o timezone nativo (evita dependência extra); o app usa
    // o fuso local do dispositivo, o que é suficiente para lembretes diários.

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    try {
      await _plugin.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(AndroidNotificationChannel(
        AppConfig.androidNotificationChannelId,
        AppConfig.androidNotificationChannelName,
        importance: Importance.high,
      ));
      await androidImpl?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _initialized = true;
    } catch (e) {
      _log('❌ LocalRemindersService.init falhou: $e');
    }
  }

  /// Agenda uma notificação diária recorrente no horário [hour]:[minute].
  /// [id] deve ser único e estável por lembrete (reagendar usa o mesmo id).
  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConfig.androidNotificationChannelId,
            AppConfig.androidNotificationChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // repete todo dia
      );
    } catch (e) {
      _log('❌ Falha ao agendar lembrete "$title": $e');
    }
  }

  static Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (_) {/* ignora se já não existir */}
  }

  /// Notificação imediata (ex.: progresso do desafio, treino em segundo plano).
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();
    if (!_initialized) return;
    try {
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConfig.androidNotificationChannelId,
            AppConfig.androidNotificationChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      _log('❌ Falha ao exibir notificação "$title": $e');
    }
  }

  /// Agenda uma notificação única. Datas no passado são ignoradas.
  static Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_initialized) await init();
    if (!_initialized) return;
    if (when.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      return;
    }
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConfig.androidNotificationChannelId,
            AppConfig.androidNotificationChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      _log('❌ Falha ao agendar notificação única "$title": $e');
    }
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
