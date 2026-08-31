import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/firebase_service.dart';

/// Uma sessão de corrida concluída.
class RunningSession {
  const RunningSession({
    required this.id,
    required this.date,
    required this.distanceKm,
    required this.durationSeconds,
    required this.kcal,
  });

  final String id;
  final DateTime date;
  final double distanceKm;
  final int durationSeconds;
  final int kcal;

  double get paceMinPerKm =>
      distanceKm > 0 ? (durationSeconds / 60) / distanceKm : 0;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'distanceKm': distanceKm,
        'durationSeconds': durationSeconds,
        'kcal': kcal,
      };

  static RunningSession fromMap(String id, Map<String, dynamic> m) =>
      RunningSession(
        id: id,
        date: DateTime.parse(m['date'] as String),
        distanceKm: (m['distanceKm'] as num).toDouble(),
        durationSeconds: (m['durationSeconds'] as num).toInt(),
        kcal: (m['kcal'] as num).toInt(),
      );
}

/// Persiste sessões de corrida — Firestore (`running_sessions`, já coberto
/// pelas regras de segurança existentes) quando disponível, com fallback
/// local (SharedPreferences) no modo sem Firebase. A Cloud Function
/// `onRunningSessionCreated` já existente incrementa `totalKm` no perfil
/// automaticamente quando salva no Firestore.
class RunningRepository {
  bool get _remote => FirebaseService.isReady;
  static const _localKey = 'running_sessions_local';

  Future<void> save(String userId, RunningSession session) async {
    if (_remote) {
      try {
        await FirebaseFirestore.instance.collection('running_sessions').add({
          'userId': userId,
          ...session.toMap(),
        });
        return;
      } catch (_) {/* cai pro fallback local abaixo */}
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_localKey) ?? [];
    list.add(jsonEncode(session.toMap()));
    await prefs.setStringList(_localKey, list);
  }

  Future<List<RunningSession>> fetchAll(String userId) async {
    if (_remote) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('running_sessions')
            .where('userId', isEqualTo: userId)
            .orderBy('date', descending: true)
            .get();
        return snap.docs
            .map((d) => RunningSession.fromMap(d.id, d.data()))
            .toList();
      } catch (_) {/* cai pro fallback local abaixo */}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_localKey) ?? [];
    final list = <RunningSession>[];
    for (final s in raw) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        list.add(RunningSession.fromMap(
            DateTime.parse(m['date'] as String).toIso8601String(), m));
      } catch (_) {/* entrada corrompida descartada */}
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
