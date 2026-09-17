import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/weekly_challenge_repository.dart';
import '../domain/weekly_challenge_models.dart';

final weeklyChallengeRepositoryProvider =
    Provider<WeeklyChallengeRepository>((ref) => WeeklyChallengeRepository());

final publishedChallengesProvider =
    StreamProvider<List<WeeklyChallenge>>((ref) {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id ?? 'guest';
  return ref.watch(weeklyChallengeRepositoryProvider).watchPublishedForUser(uid);
});

final featuredWeeklyChallengeProvider = Provider<WeeklyChallenge?>((ref) {
  final list = ref.watch(publishedChallengesProvider).valueOrNull ?? const [];
  return ref.watch(weeklyChallengeRepositoryProvider).pickFeatured(list);
});

final myChallengeProgressListProvider =
    StreamProvider<List<WeeklyChallengeProgress>>((ref) {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id ?? 'guest';
  return ref.watch(weeklyChallengeRepositoryProvider).watchMyProgress(uid);
});

final challengeProgressProvider =
    StreamProvider.family<WeeklyChallengeProgress?, String>((ref, challengeId) {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id ?? 'guest';
  return ref
      .watch(weeklyChallengeRepositoryProvider)
      .watchProgress(uid, challengeId);
});

final staffWeeklyChallengesProvider =
    StreamProvider<List<WeeklyChallenge>>((ref) {
  return ref.watch(weeklyChallengeRepositoryProvider).watchAllForStaff();
});

final challengeParticipantsProvider =
    FutureProvider.family<List<WeeklyChallengeProgress>, String>(
        (ref, challengeId) {
  return ref
      .watch(weeklyChallengeRepositoryProvider)
      .fetchParticipants(challengeId);
});

final myChallengeAchievementsProvider = FutureProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  final uid = user?.id ?? 'guest';
  return ref
      .watch(weeklyChallengeRepositoryProvider)
      .unlockedAchievements(uid);
});

String challengeUserId(AppUser? user) =>
    (user?.id.isNotEmpty == true) ? user!.id : 'guest';
