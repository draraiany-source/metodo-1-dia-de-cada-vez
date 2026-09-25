import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/lili_widgets.dart'
    show LiliMascot, MascotePose;
import '../domain/league_models.dart';
import '../providers/league_providers.dart';

/// ============================================================================
/// LIGAS SEMANAIS (Sprint V36 §3) — competição de constância no estilo
/// Duolingo: o XP da semana decide subir, manter ou cair de liga.
/// ============================================================================
class LeaguesScreen extends ConsumerStatefulWidget {
  const LeaguesScreen({super.key});

  @override
  ConsumerState<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends ConsumerState<LeaguesScreen> {
  bool _celebrationShown = false;

  @override
  Widget build(BuildContext context) {
    final league = ref.watch(leagueProvider);

    // Exibe a transição de liga UMA vez, após o primeiro frame.
    if (!league.loading &&
        !_celebrationShown &&
        (league.justPromoted || league.justDemoted)) {
      _celebrationShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (league.justPromoted) {
          CelebrationOverlay.show(
            context,
            title: 'Você subiu para a ${league.league.label}! '
                '${league.league.emoji}',
            subtitle: 'Sua constância na semana valeu a promoção. '
                'Continue um dia de cada vez!',
          ).then((_) => ref.read(leagueProvider.notifier).acknowledge());
        } else {
          // Rebaixamento: acolher, não punir — sem confete, tom gentil.
          AppSnack.info(
            context,
            'Semana difícil? Tudo bem. Você está na '
            '${league.league.label} ${league.league.emoji} — '
            'recomeçamos juntas, um dia de cada vez. 💜',
          );
          ref.read(leagueProvider.notifier).acknowledge();
        }
      });
    }

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Ligas 🏆'),
      body: SafeArea(
        child: league.loading
            ? const Center(child: SkeletonBox(width: 200, height: 200))
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  FadeInUp(child: _HeroCard(state: league)),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Como funciona',
                      style: AppTypography.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'O XP que você ganha na semana (segunda a domingo) decide '
                    'sua liga. Alcance a meta para subir; a Liga Bronze nunca '
                    'rebaixa — aqui a gente acolhe, não pune.',
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Todas as ligas', style: AppTypography.title),
                  const SizedBox(height: AppSpacing.md),
                  ...League.values.reversed.map((l) => PopIn(
                        delayMs: 80 * (League.values.length - l.index),
                        child: _TierRow(
                          tier: l,
                          current: league.league,
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}

/// Cartão-herói da liga atual: gradiente do tier, mascote, XP semanal com
/// contagem animada e barra de progresso até a próxima liga.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state});
  final LeagueState state;

  @override
  Widget build(BuildContext context) {
    final l = state.league;
    final topo = l == League.diamante;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            l.color.withOpacity(.35),
            AppColors.surface,
          ],
        ),
        border: Border.all(color: l.color.withOpacity(.55)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(l.emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.label, style: AppTypography.h1),
                    Text(
                      topo
                          ? 'Você chegou ao topo. Defenda o diamante! 💎'
                          : 'Faltam ${state.xpToNext} XP para a '
                              '${l.next.label}',
                      style: AppTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
              const Pulse(child: LiliMascot(
                  pose: MascotePose.forte, height: 72)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP da semana', style: AppTypography.caption),
              Text('${state.daysLeftInWeek} dia(s) restantes',
                  style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedCounter(
                value: state.weeklyXp,
                style: AppTypography.display.copyWith(color: l.color),
              ),
              const SizedBox(width: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('XP', style: AppTypography.caption),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: state.progressToNext),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: AppColors.surface2,
                valueColor: AlwaysStoppedAnimation(l.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha da escada de tiers, destacando a liga atual.
class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.current});
  final League tier;
  final League current;

  @override
  Widget build(BuildContext context) {
    final atual = tier == current;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: atual ? tier.color.withOpacity(.14) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: atual
              ? tier.color
              : AppColors.textTertiary.withOpacity(.18),
          width: atual ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(tier.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tier.label, style: AppTypography.title),
                Text(
                  tier == League.diamante
                      ? 'O topo da constância'
                      : 'Suba com ${tier.promoteXp} XP na semana',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          if (atual)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: tier.color.withOpacity(.25),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('VOCÊ',
                  style: AppTypography.caption
                      .copyWith(fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}
