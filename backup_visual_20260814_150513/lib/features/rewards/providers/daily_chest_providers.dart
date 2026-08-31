import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../gamification/providers/gamification_providers.dart';
import '../domain/daily_chest_models.dart';
import 'rewards_providers.dart';

/// Estado do baú diário.
@immutable
class DailyChestState {
  const DailyChestState({
    this.claimable = false,
    this.lastClaimDay,
    this.lastReward,
    this.loading = true,
  });

  final bool claimable;
  final String? lastClaimDay; // 'YYYY-M-D'
  final ChestReward? lastReward;
  final bool loading;

  DailyChestState copyWith({
    bool? claimable,
    String? lastClaimDay,
    ChestReward? lastReward,
    bool? loading,
  }) =>
      DailyChestState(
        claimable: claimable ?? this.claimable,
        lastClaimDay: lastClaimDay ?? this.lastClaimDay,
        lastReward: lastReward ?? this.lastReward,
        loading: loading ?? this.loading,
      );
}

String _dayKey([DateTime? d]) {
  final n = d ?? DateTime.now();
  return '${n.year}-${n.month}-${n.day}';
}

/// ============================================================================
/// Notifier do baú diário. Local-first: guarda apenas o dia do último resgate;
/// `claimable` = (último resgate != hoje). Ao abrir, credita moedas LiliMood
/// (rewards) e XP (gamification), que já persistem por conta própria.
/// ============================================================================
class DailyChestNotifier extends StateNotifier<DailyChestState> {
  DailyChestNotifier(this._ref) : super(const DailyChestState()) {
    _load();
  }

  final Ref _ref;
  static const _kLastClaim = 'daily_chest_last_claim';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final last = p.getString(_kLastClaim);
    if (!mounted) return;
    state = DailyChestState(
      claimable: last != _dayKey(),
      lastClaimDay: last,
      loading: false,
    );
  }

  /// Abre o baú do dia. Retorna a recompensa, ou null se já foi aberto hoje.
  Future<ChestReward?> claim() async {
    if (state.loading || !state.claimable) return null;

    final streak = _ref.read(gamificationProvider).streak;
    final reward = drawChest(streak: streak);

    _ref.read(rewardsProvider.notifier).earn(reward.coins);
    _ref.read(gamificationProvider.notifier).addXp(reward.xp);

    final hoje = _dayKey();
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLastClaim, hoje);

    if (mounted) {
      state = state.copyWith(
        claimable: false,
        lastClaimDay: hoje,
        lastReward: reward,
      );
    }
    return reward;
  }

  @visibleForTesting
  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kLastClaim);
    if (mounted) {
      state = const DailyChestState(claimable: true, loading: false);
    }
  }
}

final dailyChestProvider =
    StateNotifierProvider<DailyChestNotifier, DailyChestState>((ref) {
  return DailyChestNotifier(ref);
});
