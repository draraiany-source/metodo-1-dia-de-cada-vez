import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metodo_1_dia/core/providers/lili_guide_provider.dart';
import 'package:metodo_1_dia/features/gamification/providers/gamification_providers.dart';
import 'package:metodo_1_dia/features/health_sync/providers/health_providers.dart';
import 'package:metodo_1_dia/features/missions/providers/missions_providers.dart';
import 'package:metodo_1_dia/features/rewards/providers/rewards_providers.dart';

Future<void> settleProviders(ProviderContainer container) async {
  container.read(gamificationProvider);
  container.read(rewardsProvider);
  container.read(missionsProvider);

  for (var i = 0; i < 100; i++) {
    await Future<void>.delayed(Duration.zero);
    final ready = !container.read(gamificationProvider).loading &&
        !container.read(rewardsProvider).loading &&
        !container.read(missionsProvider).loading;
    if (ready) break;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<void> settleLiliGuide(ProviderContainer container) async {
  await settleProviders(container);
  container.read(liliGuideProvider);

  for (var i = 0; i < 100; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!container.read(healthSyncProvider).loading &&
        !container.read(healthSyncProvider).syncing) {
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

Future<void> flushAsyncWork() async {
  await Future<void>.delayed(const Duration(milliseconds: 30));
  await Future<void>.delayed(Duration.zero);
}
