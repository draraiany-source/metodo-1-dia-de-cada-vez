import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/workout_timer_models.dart';

class WorkoutSessionRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection(AppConstants.cWorkoutHistory);

  bool get _canSync =>
      FirebaseService.isReady && FirebaseAuth.instance.currentUser != null;

  static const _kLocal = 'workout_timer_history_v1';

  Future<void> save(WorkoutSessionRecord record) async {
    if (_canSync) {
      try {
        await _col.add({
          ...record.toMap(),
          'completedAt': Timestamp.fromDate(record.completedAt),
          'startedAt': Timestamp.fromDate(record.startedAt),
        });
        return;
      } catch (e) {
        debugPrint('workout_history save: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocal);
    final list = raw == null ? <dynamic>[] : jsonDecode(raw) as List;
    list.insert(0, {
      ...record.toMap(),
      'id': record.id,
    });
    await prefs.setString(_kLocal, jsonEncode(list.take(80).toList()));
  }

  Future<List<WorkoutSessionRecord>> fetchMine(String userId) async {
    if (_canSync) {
      try {
        final snap = await _col
            .where('userId', isEqualTo: userId)
            .orderBy('completedAt', descending: true)
            .limit(50)
            .get();
        return snap.docs.map(_fromDoc).toList();
      } catch (e) {
        debugPrint('workout_history fetch: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocal);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((m) => _fromMap(Map<String, dynamic>.from(m)))
          .where((r) => r.userId == userId || userId.isEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  WorkoutSessionRecord _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return _fromMap({'id': d.id, ...m});
  }

  WorkoutSessionRecord _fromMap(Map<String, dynamic> m) {
    DateTime date(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse('$v') ?? DateTime.now();
    }

    int secs(String key) {
      final v = m[key];
      if (v is int) return v;
      if (v is num) return v.round();
      return 0;
    }

    return WorkoutSessionRecord(
      id: (m['id'] ?? '') as String,
      userId: (m['userId'] ?? '') as String,
      workoutId: (m['workoutId'] ?? '') as String,
      title: (m['title'] ?? 'Treino') as String,
      startedAt: date(m['startedAt']),
      completedAt: date(m['completedAt']),
      totalDuration: Duration(seconds: secs('totalSeconds')),
      activeDuration: Duration(seconds: secs('activeSeconds')),
      restDuration: Duration(seconds: secs('restSeconds')),
      exercisesDone: secs('exercisesDone'),
      exercisesTotal: secs('exercisesTotal'),
      seriesDone: secs('seriesDone'),
      percent: (m['percent'] is num) ? (m['percent'] as num).toDouble() : 0,
    );
  }
}

final workoutSessionRepositoryProvider =
    Provider<WorkoutSessionRepository>((ref) => WorkoutSessionRepository());

final myWorkoutSessionsProvider =
    FutureProvider<List<WorkoutSessionRecord>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ref
      .watch(workoutSessionRepositoryProvider)
      .fetchMine(user?.id ?? 'guest');
});
