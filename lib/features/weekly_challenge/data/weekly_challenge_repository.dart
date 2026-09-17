import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/weekly_challenge_models.dart';

/// Persistência do Desafio da Semana.
///
/// Com Firebase: `weekly_challenges` + `weekly_challenge_progress`.
/// Sem Firebase / visitante: seed + SharedPreferences (mesmo contrato).
class WeeklyChallengeRepository {
  CollectionReference<Map<String, dynamic>> get _challenges =>
      FirebaseFirestore.instance.collection(AppConstants.cWeeklyChallenges);

  CollectionReference<Map<String, dynamic>> get _progress =>
      FirebaseFirestore.instance
          .collection(AppConstants.cWeeklyChallengeProgress);

  bool get isAvailable => FirebaseService.isReady;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  bool get _canSync => isAvailable && _uid.isNotEmpty;

  static const _kLocalChallenges = 'weekly_challenges_local_v1';
  static const _kLocalProgress = 'weekly_challenge_progress_local_v1';

  Future<List<WeeklyChallenge>> fetchAllForStaff() async {
    if (isAvailable) {
      try {
        final snap = await _challenges.get();
        final list = snap.docs
            .map((d) => WeeklyChallenge.fromMap(d.id, d.data()))
            .toList();
        list.sort((a, b) => b.startDate.compareTo(a.startDate));
        return list;
      } catch (e) {
        debugPrint('weekly_challenges staff fetch: $e');
      }
    }
    return _localChallenges();
  }

  Stream<List<WeeklyChallenge>> watchAllForStaff() {
    if (!isAvailable) {
      return Stream.fromFuture(_localChallenges());
    }
    return _challenges.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => WeeklyChallenge.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
      return list;
    });
  }

  Future<List<WeeklyChallenge>> fetchPublishedForUser(String userId) async {
    final all = isAvailable
        ? await () async {
            try {
              final snap = await _challenges
                  .where('status', whereIn: ['published', 'archived']).get();
              return snap.docs
                  .map((d) => WeeklyChallenge.fromMap(d.id, d.data()))
                  .toList();
            } catch (e) {
              debugPrint('weekly_challenges published fetch: $e');
              return await _localChallenges();
            }
          }()
        : await _localChallenges();

    final visible = all.where((c) => c.visibleTo(userId)).toList();
    if (visible.isEmpty) return [WeeklyChallenge.seedCurrent()];
    visible.sort((a, b) => b.startDate.compareTo(a.startDate));
    return visible;
  }

  Stream<List<WeeklyChallenge>> watchPublishedForUser(String userId) {
    if (!isAvailable) {
      return Stream.fromFuture(fetchPublishedForUser(userId));
    }
    return _challenges.snapshots().asyncMap((_) => fetchPublishedForUser(userId));
  }

  WeeklyChallenge? pickFeatured(List<WeeklyChallenge> list) {
    final active = list.where((c) => c.isActive).toList();
    if (active.isNotEmpty) {
      active.sort((a, b) => b.startDate.compareTo(a.startDate));
      return active.first;
    }
    final upcoming = list.where((c) => c.isScheduled).toList();
    if (upcoming.isNotEmpty) {
      upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
      return upcoming.first;
    }
    return list.isEmpty ? WeeklyChallenge.seedCurrent() : list.first;
  }

  Future<WeeklyChallenge?> getById(String id) async {
    if (isAvailable) {
      try {
        final doc = await _challenges.doc(id).get();
        if (doc.exists && doc.data() != null) {
          return WeeklyChallenge.fromMap(doc.id, doc.data()!);
        }
      } catch (e) {
        debugPrint('weekly_challenges get: $e');
      }
    }
    final local = await _localChallenges();
    return local.cast<WeeklyChallenge?>().firstWhere(
          (c) => c?.id == id,
          orElse: () => WeeklyChallenge.seedCurrent().id == id
              ? WeeklyChallenge.seedCurrent()
              : null,
        );
  }

  Future<String> saveChallenge(WeeklyChallenge challenge, {bool asNew = false}) async {
    if (!isAvailable) {
      final list = await _localChallenges();
      final id = challenge.id.isEmpty || asNew
          ? 'local_${DateTime.now().millisecondsSinceEpoch}'
          : challenge.id;
      final saved = challenge.copyWith(
        createdAt: challenge.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final next = [
        ...list.where((c) => c.id != id),
        WeeklyChallenge.fromMap(id, {
          ...saved.toMap(),
          'startDate': saved.startDate.toIso8601String(),
          'endDate': saved.endDate.toIso8601String(),
          'createdAt': saved.createdAt?.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'status': saved.status.name,
          'category': saved.category.name,
          'audience': saved.audience.name,
          'completionMode': saved.completionMode.name,
        }),
      ];
      // fromMap expects Timestamp or String — ISO strings work.
      await _persistLocalChallenges([
        for (final c in next)
          if (c.id == id)
            WeeklyChallenge(
              id: id,
              title: saved.title,
              shortDescription: saved.shortDescription,
              fullDescription: saved.fullDescription,
              rules: saved.rules,
              objective: saved.objective,
              category: saved.category,
              startDate: saved.startDate,
              endDate: saved.endDate,
              requiredDays: saved.requiredDays,
              totalDays: saved.totalDays,
              motivationalMessage: saved.motivationalMessage,
              rewardTitle: saved.rewardTitle,
              rewardXp: saved.rewardXp,
              rewardCoins: saved.rewardCoins,
              status: saved.status,
              imageUrl: saved.imageUrl,
              lilyAsset: saved.lilyAsset,
              audience: saved.audience,
              targetUserIds: saved.targetUserIds,
              completionMode: saved.completionMode,
              minWorkoutMinutes: saved.minWorkoutMinutes,
              createdBy: saved.createdBy,
              createdAt: saved.createdAt,
              updatedAt: DateTime.now(),
            )
          else
            c,
      ]);
      return id;
    }

    final data = challenge.toMap();
    if (challenge.id.isEmpty || asNew) {
      final ref = await _challenges.add(data);
      return ref.id;
    }
    await _challenges.doc(challenge.id).set(data, SetOptions(merge: true));
    return challenge.id;
  }

  Future<void> deleteChallenge(String id) async {
    if (isAvailable) {
      await _challenges.doc(id).delete();
      return;
    }
    final list = await _localChallenges();
    await _persistLocalChallenges(list.where((c) => c.id != id).toList());
  }

  Future<String?> uploadCover(String challengeId, List<int> bytes, String ext) async {
    if (!isAvailable) return null;
    final path =
        'weekly_challenges/$challengeId/cover_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: ext == 'png' ? 'image/png' : 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  Future<WeeklyChallengeProgress?> fetchProgress(
      String userId, String challengeId) async {
    final docId = WeeklyChallengeProgress.docId(userId, challengeId);
    if (_canSync) {
      try {
        final doc = await _progress.doc(docId).get();
        if (!doc.exists || doc.data() == null) return null;
        return WeeklyChallengeProgress.fromMap(doc.id, doc.data()!);
      } catch (e) {
        debugPrint('challenge progress fetch: $e');
      }
    }
    return _localProgressOf(userId, challengeId);
  }

  Stream<WeeklyChallengeProgress?> watchProgress(
      String userId, String challengeId) {
    final docId = WeeklyChallengeProgress.docId(userId, challengeId);
    if (!_canSync) {
      return Stream.fromFuture(_localProgressOf(userId, challengeId));
    }
    return _progress.doc(docId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return WeeklyChallengeProgress.fromMap(doc.id, doc.data()!);
    });
  }

  Future<List<WeeklyChallengeProgress>> fetchMyProgress(String userId) async {
    if (_canSync) {
      try {
        final snap = await _progress.where('userId', isEqualTo: userId).get();
        return snap.docs
            .map((d) => WeeklyChallengeProgress.fromMap(d.id, d.data()))
            .toList();
      } catch (e) {
        debugPrint('my challenge progress: $e');
      }
    }
    return _localAllProgress(userId);
  }

  Stream<List<WeeklyChallengeProgress>> watchMyProgress(String userId) {
    if (!_canSync) {
      return Stream.fromFuture(_localAllProgress(userId));
    }
    return _progress
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WeeklyChallengeProgress.fromMap(d.id, d.data()))
            .toList());
  }

  Future<List<WeeklyChallengeProgress>> fetchParticipants(
      String challengeId) async {
    if (isAvailable) {
      try {
        final snap =
            await _progress.where('challengeId', isEqualTo: challengeId).get();
        return snap.docs
            .map((d) => WeeklyChallengeProgress.fromMap(d.id, d.data()))
            .toList();
      } catch (e) {
        debugPrint('challenge participants: $e');
      }
    }
    return [];
  }

  Future<WeeklyChallengeProgress> join({
    required WeeklyChallenge challenge,
    required String userId,
    String displayName = '',
  }) async {
    final existing = await fetchProgress(userId, challenge.id);
    if (existing != null &&
        existing.status != ParticipationStatus.notStarted) {
      return existing;
    }
    final progress = WeeklyChallengeProgress(
      id: WeeklyChallengeProgress.docId(userId, challenge.id),
      userId: userId,
      challengeId: challenge.id,
      status: ParticipationStatus.inProgress,
      days: const [],
      startedAt: DateTime.now(),
      displayName: displayName,
    );
    await _saveProgress(progress);
    await _bumpParticipantCount(challenge.id, 1);
    return progress;
  }

  /// Marca (ou desmarca) um dia. Retorna o progresso atualizado e se acabou
  /// de concluir o desafio nesta ação.
  Future<(WeeklyChallengeProgress, bool justCompleted)> toggleDay({
    required WeeklyChallenge challenge,
    required String userId,
    required DateTime day,
    required bool completed,
    String source = 'manual',
    String displayName = '',
  }) async {
    var progress = await fetchProgress(userId, challenge.id) ??
        WeeklyChallengeProgress(
          id: WeeklyChallengeProgress.docId(userId, challenge.id),
          userId: userId,
          challengeId: challenge.id,
          status: ParticipationStatus.inProgress,
          days: const [],
          startedAt: DateTime.now(),
          displayName: displayName,
        );
    if (progress.status == ParticipationStatus.notStarted) {
      progress = progress.copyWith(
        status: ParticipationStatus.inProgress,
        startedAt: DateTime.now(),
      );
      await _bumpParticipantCount(challenge.id, 1);
    }

    final key = WeeklyChallengeProgress.dateKeyOf(day);
    final nextDays = [
      ...progress.days.where((d) => d.dateKey != key),
      ChallengeDayEntry(dateKey: key, completed: completed, source: source),
    ];
    var next = progress.copyWith(
      days: nextDays,
      lastActivityAt: DateTime.now(),
      displayName: displayName.isNotEmpty ? displayName : progress.displayName,
    );

    final wasCompleted = progress.status == ParticipationStatus.completed;
    var justCompleted = false;
    if (next.completedCount >= challenge.requiredDays && !wasCompleted) {
      justCompleted = true;
      next = next.copyWith(
        status: ParticipationStatus.completed,
        completedAt: DateTime.now(),
      );
    } else if (challenge.hasEnded &&
        next.completedCount < challenge.requiredDays &&
        next.status == ParticipationStatus.inProgress) {
      next = next.copyWith(status: ParticipationStatus.failed);
    }

    await _saveProgress(next);
    return (next, justCompleted);
  }

  /// Integração com o cronômetro: se o treino atingir o critério, marca o dia.
  Future<(WeeklyChallengeProgress, bool justCompleted)?> recordWorkout({
    required String userId,
    required Duration duration,
    String displayName = '',
  }) async {
    final list = await fetchPublishedForUser(userId);
    final featured = pickFeatured(list);
    if (featured == null || !featured.isActive) return null;
    final progress = await fetchProgress(userId, featured.id);
    if (progress == null ||
        progress.status == ParticipationStatus.notStarted) {
      return null;
    }
    if (featured.completionMode == ChallengeCompletionMode.manual) {
      return null;
    }
    final minutes = duration.inMinutes;
    final qualifies = switch (featured.completionMode) {
      ChallengeCompletionMode.workout => minutes >= 1,
      ChallengeCompletionMode.workoutMinutes =>
        minutes >= featured.minWorkoutMinutes,
      ChallengeCompletionMode.workoutCount => minutes >= 1,
      ChallengeCompletionMode.manual => false,
    };
    if (!qualifies) return null;
    return toggleDay(
      challenge: featured,
      userId: userId,
      day: DateTime.now(),
      completed: true,
      source: 'workout_timer',
      displayName: displayName,
    );
  }

  Future<List<String>> unlockedAchievements(String userId) async {
    final all = await fetchMyProgress(userId);
    final completed = all
        .where((p) => p.status == ParticipationStatus.completed)
        .toList()
      ..sort((a, b) =>
          (a.completedAt ?? DateTime(2000)).compareTo(b.completedAt ?? DateTime(2000)));
    final ids = <String>{};
    if (completed.isNotEmpty) ids.add(ChallengeAchievementDef.primeiro.id);
    if (completed.length >= 5) ids.add(ChallengeAchievementDef.cinco.id);
    if (completed.length >= 10) ids.add(ChallengeAchievementDef.dez.id);
    if (completed.any((p) => p.achievementId == ChallengeAchievementDef.constancia.id ||
        true)) {
      // Constância: qualquer desafio concluído já desbloqueia o selo base.
      if (completed.isNotEmpty) {
        ids.add(ChallengeAchievementDef.constancia.id);
      }
    }
    if (_hasThreeInARow(completed)) {
      ids.add(ChallengeAchievementDef.tresSemanas.id);
    }
    return ids.toList();
  }

  List<ChallengeAchievementDef> evaluateNewAchievements({
    required List<WeeklyChallengeProgress> all,
    required WeeklyChallengeProgress justFinished,
    required WeeklyChallenge challenge,
  }) {
    final completed = all
        .where((p) =>
            p.status == ParticipationStatus.completed || p.id == justFinished.id)
        .toList();
    final unlocked = <ChallengeAchievementDef>[];
    if (completed.length == 1) unlocked.add(ChallengeAchievementDef.primeiro);
    if (justFinished.completedCount >= challenge.requiredDays) {
      unlocked.add(ChallengeAchievementDef.constancia);
    }
    if (completed.length == 5) unlocked.add(ChallengeAchievementDef.cinco);
    if (completed.length == 10) unlocked.add(ChallengeAchievementDef.dez);
    if (_hasThreeInARow(completed)) {
      unlocked.add(ChallengeAchievementDef.tresSemanas);
    }
    return unlocked;
  }

  Future<void> _saveProgress(WeeklyChallengeProgress progress) async {
    if (_canSync) {
      await _progress
          .doc(progress.id)
          .set(progress.toMap(), SetOptions(merge: true));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalProgress);
    final map = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    map[progress.id] = {
      'userId': progress.userId,
      'challengeId': progress.challengeId,
      'status': progress.status.name,
      'days': progress.days.map((d) => d.toMap()).toList(),
      'startedAt': progress.startedAt?.toIso8601String(),
      'completedAt': progress.completedAt?.toIso8601String(),
      'achievementId': progress.achievementId,
      'achievementTitle': progress.achievementTitle,
      'displayName': progress.displayName,
      'completedCount': progress.completedCount,
    };
    await prefs.setString(_kLocalProgress, jsonEncode(map));
  }

  Future<void> _bumpParticipantCount(String challengeId, int delta) async {
    if (!isAvailable) return;
    try {
      await _challenges.doc(challengeId).set({
        'participantCount': FieldValue.increment(delta),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> refreshCompletionPercent(String challengeId) async {
    if (!isAvailable) return;
    final parts = await fetchParticipants(challengeId);
    if (parts.isEmpty) return;
    final done =
        parts.where((p) => p.status == ParticipationStatus.completed).length;
    await _challenges.doc(challengeId).set({
      'completionPercent': (done / parts.length) * 100,
      'participantCount': parts.length,
    }, SetOptions(merge: true));
  }

  bool _hasThreeInARow(List<WeeklyChallengeProgress> completed) {
    if (completed.length < 3) return false;
    final dates = completed
        .map((p) => p.completedAt)
        .whereType<DateTime>()
        .toList()
      ..sort();
    if (dates.length < 3) return false;
    for (var i = 2; i < dates.length; i++) {
      final a = dates[i - 2];
      final b = dates[i - 1];
      final c = dates[i];
      final g1 = b.difference(a).inDays;
      final g2 = c.difference(b).inDays;
      if (g1 <= 10 && g2 <= 10) return true;
    }
    return false;
  }

  Future<List<WeeklyChallenge>> _localChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalChallenges);
    if (raw == null) return [WeeklyChallenge.seedCurrent()];
    try {
      final list = (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((e) => WeeklyChallenge.fromMap(
                (e['id'] ?? '') as String,
                Map<String, dynamic>.from(e),
              ))
          .toList();
      return list.isEmpty ? [WeeklyChallenge.seedCurrent()] : list;
    } catch (_) {
      return [WeeklyChallenge.seedCurrent()];
    }
  }

  Future<void> _persistLocalChallenges(List<WeeklyChallenge> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kLocalChallenges,
      jsonEncode([
        for (final c in list)
          {
            'id': c.id,
            'title': c.title,
            'shortDescription': c.shortDescription,
            'fullDescription': c.fullDescription,
            'rules': c.rules,
            'objective': c.objective,
            'category': c.category.name,
            'startDate': c.startDate.toIso8601String(),
            'endDate': c.endDate.toIso8601String(),
            'requiredDays': c.requiredDays,
            'totalDays': c.totalDays,
            'motivationalMessage': c.motivationalMessage,
            'rewardTitle': c.rewardTitle,
            'rewardXp': c.rewardXp,
            'rewardCoins': c.rewardCoins,
            'status': c.status.name,
            'imageUrl': c.imageUrl,
            'lilyAsset': c.lilyAsset,
            'audience': c.audience.name,
            'targetUserIds': c.targetUserIds,
            'completionMode': c.completionMode.name,
            'minWorkoutMinutes': c.minWorkoutMinutes,
            'createdBy': c.createdBy,
          }
      ]),
    );
  }

  Future<WeeklyChallengeProgress?> _localProgressOf(
      String userId, String challengeId) async {
    final all = await _localAllProgress(userId);
    final id = WeeklyChallengeProgress.docId(userId, challengeId);
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<List<WeeklyChallengeProgress>> _localAllProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalProgress);
    if (raw == null) return [];
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.entries
          .map((e) => WeeklyChallengeProgress.fromMap(
                e.key,
                Map<String, dynamic>.from(e.value as Map),
              ))
          .where((p) => p.userId == userId || userId.isEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
