import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/design_system/app_breakpoints.dart';
import '../../../core/mascot/mascot_widget.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../nutrition/providers/water_log_providers.dart';
import 'widgets/continue_journey_card.dart';

/// Home premium — preto + rosa, Lily em destaque, cards proporcionais.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final streak = ref.watch(gamificationProvider).streak;
    final glasses = ref.watch(waterLogProvider);
    const waterGoal = 8;
    final waterLiters = glasses * 0.25;
    final goalProgress =
        ((glasses / waterGoal) * 0.4 + (streak > 0 ? 0.35 : 0.1) + 0.1)
            .clamp(0.0, 1.0);
    final wide = context.isDesktopLayout || context.isTabletLayout;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInUp(child: _TopBar(user: user)),
              const SizedBox(height: 12),
              FadeInUp(
                delayMs: 40,
                child: _HeroBrand(
                  wide: wide,
                  motivationPrefix: 'Pequenas escolhas diárias, grandes ',
                  motivationHighlight: 'transformações!',
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delayMs: 70,
                child: _DailyGoalCard(
                  progress: goalProgress,
                  onOpenPlan: () => context.push(Routes.plan),
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(delayMs: 90, child: SectionHeader(title: 'Resumo de hoje')),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 100,
                child: _SummaryGrid(
                  waterLabel:
                      '${waterLiters.toStringAsFixed(1)} / ${(waterGoal * 0.25).toStringAsFixed(1)} L',
                  waterProgress: (glasses / waterGoal).clamp(0.0, 1.0),
                  streak: streak,
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                delayMs: 120,
                child: _TodayWorkoutCard(
                  onStart: () => context.go(Routes.workouts),
                  onSeeAll: () => context.go(Routes.workouts),
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delayMs: 140,
                child: _TodayNutritionCard(
                  onOpen: () => context.go(Routes.recipes),
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delayMs: 160,
                child: _EvolutionRow(
                  weight: user.currentWeight,
                  lost: user.lostWeight,
                  streak: streak,
                  onOpen: () => context.go(Routes.evolution),
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                  delayMs: 180, child: SectionHeader(title: 'Acesso rápido')),
              const SizedBox(height: 10),
              FadeInUp(delayMs: 200, child: const _QuickGrid()),
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
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá, $first! 👋', style: AppTextStyles.h3()),
              const SizedBox(height: 2),
              Text(
                'Foco  •  Disciplina  •  Consistência',
                style: AppTextStyles.caption(),
              ),
            ],
          ),
        ),
        _IconBtn(
          icon: Icons.notifications_none_rounded,
          badge: unread,
          onTap: () => context.push(Routes.reminders),
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.calendar_today_outlined,
          onTap: () => context.push(Routes.calendar),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap, this.badge = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            if (badge)
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroBrand extends StatelessWidget {
  const _HeroBrand({
    required this.wide,
    required this.motivationPrefix,
    required this.motivationHighlight,
  });
  final bool wide;
  final String motivationPrefix;
  final String motivationHighlight;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final lilyH = (h * (wide ? 0.28 : 0.26)).clamp(180.0, 280.0);

    return AppCard(
      padding: EdgeInsets.fromLTRB(wide ? 22 : 16, 14, 8, 8),
      glow: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: wide ? 5 : 5,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.display(size: wide ? 34 : 28),
                      children: const [
                        TextSpan(text: 'LILY '),
                        TextSpan(
                          text: 'FIT',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Método 1 Dia de Cada Vez',
                    style: AppTextStyles.caption().copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySecondary(),
                      children: [
                        TextSpan(text: motivationPrefix),
                        TextSpan(
                          text: motivationHighlight,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: wide ? 4 : 4,
            child: SizedBox(
              height: lilyH,
              child: const AnimatedLiliMascot(
                pose: MascotePose.padrao,
                mood: LiliMood.viva,
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.progress, required this.onOpenPlan});
  final double progress;
  final VoidCallback onOpenPlan;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meta do dia', style: AppTextStyles.h3()),
                    const SizedBox(height: 4),
                    Text('Treino + Alimentação + Água',
                        style: AppTextStyles.bodySecondary()),
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
                radius: 34,
                lineWidth: 7,
                percent: progress,
                center: Text('$pct%',
                    style: AppTextStyles.caption(color: AppColors.secondary)
                        .copyWith(fontWeight: FontWeight.w800)),
                progressColor: AppColors.secondary,
                backgroundColor: AppColors.surface2,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Ver meu plano', onPressed: onOpenPlan),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.waterLabel,
    required this.waterProgress,
    required this.streak,
  });
  final String waterLabel;
  final double waterProgress;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 720 ? 4 : 2;
      final items = [
        MetricCard(
          label: 'Treino',
          value: 'Completo',
          icon: Icons.fitness_center_rounded,
          iconAsset: AppIcons.workout,
          accent: AppColors.secondary,
          progress: 1,
          onTap: () => context.go(Routes.workouts),
        ),
        MetricCard(
          label: 'Água',
          value: waterLabel,
          icon: Icons.water_drop_rounded,
          iconAsset: AppIcons.hydration,
          accent: AppColors.info,
          progress: waterProgress,
          onTap: () => context.push(Routes.hydration),
        ),
        MetricCard(
          label: 'Calorias',
          value: '—',
          icon: Icons.local_fire_department_rounded,
          iconAsset: AppIcons.calories,
          accent: AppColors.calories,
          progress: 0.4,
          onTap: () => context.push(Routes.nutrition),
        ),
        MetricCard(
          label: 'Foco',
          value: '$streak dias',
          icon: Icons.directions_walk_rounded,
          iconAsset: AppIcons.trophy,
          accent: AppColors.primary,
          progress: (streak / 30).clamp(0.0, 1.0),
          onTap: () => context.push(Routes.streak),
        ),
      ];
      return GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: cols == 4 ? 1.15 : 1.25,
        children: items,
      );
    });
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.onStart, required this.onSeeAll});
  final VoidCallback onStart;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Treino de hoje', actionLabel: 'Ver todos', onAction: onSeeAll),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: Colors.black,
                  child: SizedBox(
                    width: 110,
                    height: 130,
                    child: const LiliFitMascot(
                      pose: MascotePose.halteres,
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Força  •  Corpo todo',
                        style: AppTextStyles.caption(color: AppColors.secondary)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Treino Full Body', style: AppTextStyles.h3()),
                    const SizedBox(height: 4),
                    Text('40 min  ·  Intermediário',
                        style: AppTextStyles.bodySecondary()),
                    const SizedBox(height: 6),
                    Text(
                      'Treino completo para trabalhar todos os grupos musculares.',
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Iniciar treino',
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
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
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: AppIconImage(
                AppIcons.recipes,
                size: 64,
                fallbackIcon: Icons.restaurant_rounded,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nutrição de hoje', style: AppTextStyles.h3()),
                const SizedBox(height: 4),
                Text('Bowl Proteico  ·  380 kcal',
                    style: AppTextStyles.bodySecondary()),
                const SizedBox(height: 4),
                Text(
                  'Saboroso, equilibrado e perfeito para o seu objetivo!',
                  style: AppTextStyles.caption(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ver receita  >',
                  style: AppTextStyles.caption(color: AppColors.secondary)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvolutionRow extends StatelessWidget {
  const _EvolutionRow({
    required this.weight,
    required this.lost,
    required this.streak,
    required this.onOpen,
  });
  final double? weight;
  final double? lost;
  final int streak;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: 'Sua evolução', actionLabel: 'Ver mais', onAction: onOpen),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: weight != null ? '${weight!.toStringAsFixed(1)} kg' : '—',
                label: 'Peso atual',
                icon: Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                value: lost != null
                    ? '${lost! >= 0 ? '-' : '+'}${lost!.abs().toStringAsFixed(1)}'
                    : '—',
                label: 'Diferença',
                icon: Icons.trending_down_rounded,
                accent: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                value: '$streak',
                label: 'Dias de foco',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                value: streak > 0 ? '78%' : '—',
                label: 'Consistência',
                icon: Icons.pie_chart_outline_rounded,
                accent: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData, VoidCallback)>[
      ('Treinos', AppIcons.workout, Icons.fitness_center_rounded,
          () => context.go(Routes.workouts)),
      ('Receitas', AppIcons.recipes, Icons.restaurant_rounded,
          () => context.go(Routes.recipes)),
      ('Evolução', AppIcons.progress, Icons.trending_up_rounded,
          () => context.go(Routes.evolution)),
      ('Água', AppIcons.hydration, Icons.water_drop_rounded,
          () => context.push(Routes.hydration)),
      ('Áudios', AppIcons.audio, Icons.headphones_rounded,
          () => context.push(Routes.audioCourses)),
      ('Suporte', AppIcons.support, Icons.support_agent_rounded,
          () => context.push(Routes.settings)),
    ];

    final cols = context.isDesktopLayout ? 6 : 3;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.92,
      children: [
        for (final it in items)
          AppCard(
            onTap: it.$4,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIconImage(it.$2, size: 40, fallbackIcon: it.$3),
                const SizedBox(height: 8),
                Text(it.$1, style: AppTextStyles.caption(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}
