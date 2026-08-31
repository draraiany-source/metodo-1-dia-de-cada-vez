import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_guide.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../providers/daily_chest_providers.dart';
import '../providers/rewards_providers.dart';

class RewardsStoreScreen extends ConsumerStatefulWidget {
  const RewardsStoreScreen({super.key});

  @override
  ConsumerState<RewardsStoreScreen> createState() => _RewardsStoreScreenState();
}

class _RewardsStoreScreenState extends ConsumerState<RewardsStoreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: RewardCategory.values.length, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _redeem(RewardItem item) async {
    final error = ref.read(rewardsProvider.notifier).redeem(item);
    if (!mounted) return;
    if (error == null) {
      await FeedbackService.play(FeedbackEvent.recompensa);
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LiliAnimation(AppAssets.animUnlock, size: 110, repeat: false),
              const AnimatedLiliMascot(
                  pose: MascotePose.celebrando,
                  mood: LiliMood.comemorando,
                  height: MascotSizes.medium),
              const SizedBox(height: 12),
              Text('Você resgatou "${item.title}"! 🎉',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aproveitar')),
          ],
        ),
      );
    } else {
      await FeedbackService.play(FeedbackEvent.erro);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error),
            backgroundColor:
                error.contains('insuficiente') ? AppColors.danger : null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rewardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loja de Recompensas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () => context.push(Routes.rewardsHistory),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            for (final c in RewardCategory.values)
              Tab(text: '${c.emoji} ${c.label}'),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: LiliGuide(mascotHeight: 84, showCta: false),
          ),
          _BalanceHeader(coins: state.coins),
          Consumer(builder: (context, ref, _) {
            final chest = ref.watch(dailyChestProvider);
            if (chest.loading || !chest.claimable) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: PressableScale(
                onTap: () => context.push(Routes.dailyChest),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: AppColors.vibeGradient,
                  ),
                  child: Row(
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 30)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Baú diário disponível!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text('Toque para abrir e ganhar LiliMood + XP',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tab,
                    children: [
                      for (final c in RewardCategory.values)
                        _CategoryList(
                          items: RewardsCatalog.byCategory(c),
                          owned: state.owned,
                          coins: state.coins,
                          onRedeem: _redeem,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Seu saldo',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('$coins moedas',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          const LiliMascot(pose: MascotePose.joinha, height: MascotSizes.header),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.items,
    required this.owned,
    required this.coins,
    required this.onRedeem,
  });

  final List<RewardItem> items;
  final Set<String> owned;
  final int coins;
  final Future<void> Function(RewardItem) onRedeem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Em breve mais itens nesta categoria.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final isOwned = owned.contains(item.id);
        final canAfford = coins >= item.price;
        return FadeInUp(
          delayMs: i * 40,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: isOwned
                  ? Border.all(color: AppColors.success)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                      child: Text(item.emoji,
                          style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item.description,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  isOwned: isOwned,
                  canAfford: canAfford,
                  price: item.price,
                  onTap: () => onRedeem(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isOwned,
    required this.canAfford,
    required this.price,
    required this.onTap,
  });

  final bool isOwned;
  final bool canAfford;
  final int price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isOwned) {
      return const Chip(
        backgroundColor: Colors.transparent,
        side: BorderSide(color: AppColors.success),
        label: Text('Resgatado',
            style: TextStyle(color: AppColors.success, fontSize: 12)),
      );
    }
    // Nota: não envolvemos o botão em PressableScale — dois detectores de
    // gesto sobrepostos podem disparar a ação duas vezes. O háptico vai aqui.
    return ElevatedButton(
      onPressed: canAfford
          ? () {
              FeedbackService.play(FeedbackEvent.toqueLeve);
              onTap();
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canAfford ? AppColors.primary : AppColors.surface2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text('🪙 $price',
          style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}
