import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/design_system/app_breakpoints.dart';
import '../../../core/design_system/app_shadows.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/mascot/mascot_widget.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../nutrition/providers/water_log_providers.dart';
import 'widgets/continue_journey_card.dart';

/// Home do aluno — estrutura das referências, tema claro rosa/lilás.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final streak = ref.watch(gamificationProvider).streak;
    final glasses = ref.watch(waterLogProvider);
    const waterGoal = 8;
    final waterLiters = (glasses * 0.25).clamp(0.0, 99.0);
    final goalProgress = ((glasses / waterGoal) * 0.35 +
            (streak > 0 ? 0.35 : 0.15) +
            0.15)
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInUp(child: _TopBar(user: user)),
              const SizedBox(height: 8),
              FadeInUp(
                delayMs: 40,
                child: _BrandHero(
                  motivation:
                      'Pequenas escolhas diárias, grandes transformações!',
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delayMs: 80,
                child: _DailyGoalCard(
                  progress: goalProgress,
                  summary: 'Treino + Alimentação + Água',
                  onOpenPlan: () => context.push(Routes.plan),
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                delayMs: 100,
                child: _SectionLabel('Resumo de hoje'),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 120,
                child: _TodaySummaryRow(
                  workoutDone: user.totalWorkouts > 0,
                  waterLabel: '${waterLiters.toStringAsFixed(1)} / 2,0 L',
                  caloriesLabel: '—',
                  stepsLabel: '—',
                  streak: streak,
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                delayMs: 140,
                child: _TodayWorkoutCard(
                  onStart: () => context.go(Routes.workouts),
                  onSeeAll: () => context.go(Routes.workouts),
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delayMs: 160,
                child: _TodayNutritionCard(
                  onOpen: () => context.go(Routes.recipes),
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delayMs: 180,
                child: _HydrationTeaser(
                  glasses: glasses,
                  goal: waterGoal,
                  onOpen: () => context.push(Routes.hydration),
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delayMs: 200,
                child: _EvolutionTeaser(
                  weightLabel: user.currentWeight != null
                      ? '${user.currentWeight!.toStringAsFixed(1)} kg'
                      : '—',
                  lostLabel: user.lostWeight != null
                      ? '${user.lostWeight! >= 0 ? '-' : '+'}${user.lostWeight!.abs().toStringAsFixed(1)} kg'
                      : '—',
                  streak: streak,
                  onOpen: () => context.go(Routes.evolution),
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                delayMs: 220,
                child: _SectionLabel('Acesso rápido'),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 240,
                child: _QuickAccessGrid(streak: streak),
              ),
              const SizedBox(height: 14),
              const ContinueJourneyCard(),
              if (user.isAdmin) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push(Routes.admin),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Painel Administrativo'),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── pieces ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = user.name.split(' ').first;
    final unread = ref.watch(claimableMissionsProvider) > 0;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.surface2,
          child: Text(
            first.isNotEmpty ? first[0].toUpperCase() : 'A',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $first! 👋',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Foco  •  Disciplina  •  Consistência',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary.withOpacity(0.95),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          badge: unread,
          onTap: () => context.push(Routes.reminders),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.calendar_today_outlined,
          onTap: () => context.push(Routes.calendar),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              if (badge)
                Positioned(
                  top: 8,
                  right: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero({required this.motivation});
  final String motivation;

  @override
  Widget build(BuildContext context) {
    final lilyH = (MediaQuery.sizeOf(context).height * 0.22)
        .clamp(150.0, 210.0);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -0.6,
                        ),
                        children: [
                          TextSpan(
                            text: 'LILY ',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text: 'FIT',
                            style: TextStyle(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MÉTODO 1 DIA DE CADA VEZ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.primaryDark.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      motivation,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: lilyH * 0.72,
              height: lilyH,
              child: const AnimatedLiliMascot(
                pose: MascotePose.padrao,
                mood: LiliMood.viva,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({
    required this.progress,
    required this.summary,
    required this.onOpenPlan,
  });
  final double progress;
  final String summary;
  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meta do dia',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      summary,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.surface2,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              CircularPercentIndicator(
                radius: 36,
                lineWidth: 7,
                percent: progress,
                center: Text(
                  '$pct%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
                progressColor: AppColors.secondary,
                backgroundColor: AppColors.surface2,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpenPlan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
              child: const Text(
                'Ver meu plano  >',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryRow extends StatelessWidget {
  const _TodaySummaryRow({
    required this.workoutDone,
    required this.waterLabel,
    required this.caloriesLabel,
    required this.stepsLabel,
    required this.streak,
  });
  final bool workoutDone;
  final String waterLabel;
  final String caloriesLabel;
  final String stepsLabel;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            iconAsset: AppIcons.workout,
            fallback: Icons.fitness_center_rounded,
            label: 'Treino',
            value: workoutDone ? 'Ativo' : 'Pendente',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStat(
            iconAsset: AppIcons.hydration,
            fallback: Icons.water_drop_rounded,
            label: 'Água',
            value: waterLabel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStat(
            iconAsset: AppIcons.calories,
            fallback: Icons.local_fire_department_rounded,
            label: 'Calorias',
            value: caloriesLabel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStat(
            iconAsset: AppIcons.streak,
            fallback: Icons.directions_walk_rounded,
            label: 'Foco',
            value: '$streak d',
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.iconAsset,
    required this.fallback,
    required this.label,
    required this.value,
  });
  final String iconAsset;
  final IconData fallback;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          AppIconImage(iconAsset, size: 32, fallbackIcon: fallback),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.onStart, required this.onSeeAll});
  final VoidCallback onStart;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionLabel('Treino de hoje')),
              TextButton(
                onPressed: onSeeAll,
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 92,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                clipBehavior: Clip.antiAlias,
                child: const LiliFitMascot(
                  pose: MascotePose.halteres,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePink,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: const Text(
                        'Força  •  Corpo todo',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Treino Full Body',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '40 min  ·  Intermediário',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Treino completo para trabalhar todos os grupos musculares.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'Iniciar treino',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayNutritionCard extends StatelessWidget {
  const _TodayNutritionCard({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: const Center(
              child: AppIconImage(
                AppIcons.recipes,
                size: 40,
                fallbackIcon: Icons.restaurant_rounded,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nutrição de hoje',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Receitas e plano alimentar',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onOpen,
                  child: const Text(
                    'Ver receitas  >',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationTeaser extends StatelessWidget {
  const _HydrationTeaser({
    required this.glasses,
    required this.goal,
    required this.onOpen,
  });
  final int glasses;
  final int goal;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final pct = (glasses / goal).clamp(0.0, 1.0);
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 72,
              height: 88,
              child: AnimatedLiliMascot(
                pose: MascotePose.hidratacao,
                mood: LiliMood.respirando,
                height: 88,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hidratação',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$glasses / $goal copos',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      backgroundColor: AppColors.surface2,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _EvolutionTeaser extends StatelessWidget {
  const _EvolutionTeaser({
    required this.weightLabel,
    required this.lostLabel,
    required this.streak,
    required this.onOpen,
  });
  final String weightLabel;
  final String lostLabel;
  final int streak;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: _SectionLabel('Sua evolução')),
              TextButton(
                onPressed: onOpen,
                child: const Text(
                  'Ver mais',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _EvoCell(
                icon: AppIcons.weight,
                fallback: Icons.monitor_weight_outlined,
                label: 'Peso atual',
                value: weightLabel,
              ),
              _EvoCell(
                icon: AppIcons.bmiMeasure,
                fallback: Icons.straighten_rounded,
                label: 'Diferença',
                value: lostLabel,
              ),
              _EvoCell(
                icon: AppIcons.streak,
                fallback: Icons.local_fire_department_rounded,
                label: 'Dias de foco',
                value: '$streak',
              ),
              _EvoCell(
                icon: AppIcons.progress,
                fallback: Icons.trending_up_rounded,
                label: 'Constância',
                value: streak > 0 ? 'Ativa' : '—',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvoCell extends StatelessWidget {
  const _EvoCell({
    required this.icon,
    required this.fallback,
    required this.label,
    required this.value,
  });
  final String icon;
  final IconData fallback;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AppIconImage(icon, size: 30, fallbackIcon: fallback),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final items = <_QuickItem>[
      _QuickItem('Treinos', AppIcons.workout, Icons.fitness_center_rounded,
          () => context.go(Routes.workouts)),
      _QuickItem('Receitas', AppIcons.recipes, Icons.restaurant_rounded,
          () => context.go(Routes.recipes)),
      _QuickItem('Evolução', AppIcons.progress, Icons.trending_up_rounded,
          () => context.go(Routes.evolution)),
      _QuickItem('Água', AppIcons.hydration, Icons.water_drop_rounded,
          () => context.push(Routes.hydration)),
      _QuickItem('Áudios', AppIcons.audio, Icons.headphones_rounded,
          () => context.push(Routes.audioCourses)),
      _QuickItem('Hábitos', AppIcons.checklist, Icons.check_circle_rounded,
          () => context.push(Routes.habits)),
    ];

    final cols = context.isDesktopLayout ? 6 : 3;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: [
        for (final it in items)
          InkWell(
            onTap: it.onTap,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.soft,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIconImage(it.asset, size: 34, fallbackIcon: it.fallback),
                  const SizedBox(height: 8),
                  Text(
                    it.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickItem {
  const _QuickItem(this.label, this.asset, this.fallback, this.onTap);
  final String label;
  final String asset;
  final IconData fallback;
  final VoidCallback onTap;
}
