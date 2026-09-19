import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/premium_service.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_models.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

final mySubscriptionProvider = StreamProvider<SubscriptionRecord?>((ref) {
  final uid = ref.watch(currentUserProvider)?.id ?? '';
  return ref.watch(subscriptionRepositoryProvider).watchMine(uid);
});

final studentAccessProvider =
    StreamProvider.family<SubscriptionRecord?, String>((ref, userId) {
  return ref.watch(subscriptionRepositoryProvider).watchMine(userId);
});

final adminSubscriptionsProvider =
    StreamProvider<List<SubscriptionRecord>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).watchAllForAdmin();
});

class EffectiveAccess {
  const EffectiveAccess({
    required this.hasPremium,
    required this.lifecycle,
    required this.subscription,
    this.storePlan,
    this.storeExpiresAt,
  });

  final bool hasPremium;
  final SubscriptionLifecycle lifecycle;
  final SubscriptionRecord? subscription;
  final String? storePlan;
  final DateTime? storeExpiresAt;

  static const free = EffectiveAccess(
    hasPremium: false,
    lifecycle: SubscriptionLifecycle.free,
    subscription: null,
  );
}

bool isContentLocked(WidgetRef ref, bool contentIsPremium) {
  if (!contentIsPremium) return false;
  return !ref.watch(effectiveAccessProvider).hasPremium;
}

final effectiveAccessProvider = Provider<EffectiveAccess>((ref) {
  final user = ref.watch(currentUserProvider);
  final store = ref.watch(premiumStatusProvider);
  final sub = ref.watch(mySubscriptionProvider).valueOrNull;
  if (user == null) return EffectiveAccess.free;

  final fromSub = resolveHasPremiumAccess(
    userFlagPremium: user.isPremium,
    userExpiresAt: store.expiresAt,
    subscription: sub,
    debugUnlock: AppConstants.debugUnlockAllPremiumContent,
  );
  final hasPremium = fromSub || store.isPremium;
  final life = resolveLifecycle(
    userFlagPremium: user.isPremium || store.isPremium,
    userExpiresAt: store.expiresAt,
    subscription: sub,
  );
  return EffectiveAccess(
    hasPremium: hasPremium,
    lifecycle: life,
    subscription: sub,
    storePlan: store.plan,
    storeExpiresAt: store.expiresAt,
  );
});
