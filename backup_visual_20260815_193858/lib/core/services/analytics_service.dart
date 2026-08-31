import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';

/// Wrapper de Analytics com degradação graciosa.
///
/// Se o Firebase não estiver configurado (modo local), os métodos viram no-op
/// em vez de lançar exceção — então pode chamar à vontade em qualquer tela.
class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics? get _fa =>
      FirebaseService.isReady ? FirebaseAnalytics.instance : null;

  /// Observer para registrar navegação automaticamente no GoRouter/Navigator.
  static FirebaseAnalyticsObserver? get observer =>
      FirebaseService.isReady
          ? FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
          : null;

  static Future<void> logEvent(String name,
      [Map<String, Object>? params]) async {
    try {
      await _fa?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics logEvent falhou: $e');
    }
  }

  static Future<void> setUser(String uid) async {
    try {
      await _fa?.setUserId(id: uid);
    } catch (e) {
      debugPrint('Analytics setUser falhou: $e');
    }
  }

  static Future<void> logScreen(String screen) async {
    try {
      await _fa?.logScreenView(screenName: screen);
    } catch (e) {
      debugPrint('Analytics logScreen falhou: $e');
    }
  }

  // Eventos de negócio prontos.
  static Future<void> workoutCompleted(String id) =>
      logEvent('workout_completed', {'workout_id': id});
  static Future<void> runFinished(double km) =>
      logEvent('run_finished', {'distance_km': km});
  static Future<void> subscribe(String plan) =>
      logEvent('subscribe', {'plan': plan});
  static Future<void> checkin() => logEvent('daily_checkin');
}
