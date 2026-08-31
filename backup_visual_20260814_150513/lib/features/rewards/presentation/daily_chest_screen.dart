import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart' show MascotePose;
import '../domain/daily_chest_models.dart';
import '../providers/daily_chest_providers.dart';

/// Tela do baú diário — o baú "chama" (pulsa/balança) quando disponível;
/// ao tocar, abre com háptica + confete e revela a recompensa.
class DailyChestScreen extends ConsumerStatefulWidget {
  const DailyChestScreen({super.key});

  @override
  ConsumerState<DailyChestScreen> createState() => _DailyChestScreenState();
}

class _DailyChestScreenState extends ConsumerState<DailyChestScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    HapticFeedback.mediumImpact();
    _shake.stop();

    final reward = await ref.read(dailyChestProvider.notifier).claim();
    if (!mounted) return;

    if (reward == null) {
      AppSnack.info(context, 'Você já abriu o baú de hoje. Volte amanhã! ✨');
      setState(() => _opening = false);
      return;
    }

    await CelebrationOverlay.show(
      context,
      title: 'Baú ${reward.rarity.label}! ${reward.rarity.emoji}',
      subtitle: '+${reward.coins} LiliMood  •  +${reward.xp} XP\n'
          'Sua constância rende. Nos vemos amanhã!',
      pose: MascotePose.trofeu,
      buttonLabel: 'Coletar 💜',
    );
    if (mounted) setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    final chest = ref.watch(dailyChestProvider);
    final canOpen = chest.claimable && !_opening && !chest.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Baú diário 🎁')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedLiliMascot(
                    pose: MascotePose.celebrando,
                    height: 150,
                    mood: LiliMood.viva),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  canOpen ? 'Seu baú de hoje está pronto!' : 'Baú já aberto',
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  canOpen
                      ? 'Toque para abrir e receber moedas LiliMood + XP. '
                          'Quanto maior sua sequência, melhores as chances!'
                      : 'Você já coletou hoje. Volte amanhã para manter o ritmo. ✨',
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                GestureDetector(
                  onTap: canOpen ? _open : null,
                  child: AnimatedBuilder(
                    animation: _shake,
                    builder: (_, child) {
                      final angle = canOpen
                          ? math.sin(_shake.value * math.pi * 2) * 0.06
                          : 0.0;
                      return Transform.rotate(angle: angle, child: child);
                    },
                    child: _ChestArt(enabled: canOpen),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (!canOpen && chest.lastReward != null)
                  Text(
                    'Última recompensa: +${chest.lastReward!.coins} LiliMood',
                    style: AppTypography.caption,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChestArt extends StatelessWidget {
  const _ChestArt({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final glow = enabled ? AppColors.secondary : AppColors.textTertiary;
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [glow.withOpacity(.35), AppColors.surface],
        ),
        boxShadow: enabled
            ? [BoxShadow(color: glow.withOpacity(.5), blurRadius: 40)]
            : null,
      ),
      child: Center(
        child: Text('🎁', style: TextStyle(fontSize: enabled ? 84 : 72)),
      ),
    );
  }
}
