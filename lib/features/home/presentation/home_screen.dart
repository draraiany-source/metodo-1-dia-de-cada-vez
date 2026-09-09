import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/design_system/app_breakpoints.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/seed_data.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../core/widgets/quick_access_tile.dart';
import '../../../models/app_user.dart';
import '../../../models/domain_models.dart';
import '../../auth/providers/auth_providers.dart';
import '../../ai_trainer/domain/trainer_engine.dart';
import '../../ai_trainer/providers/ai_trainer_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../nutrition/providers/food_log_providers.dart';
import '../../nutrition/providers/water_log_providers.dart';
import '../../personal_amanda/presentation/amanda_photo_banner.dart';
import '../../workouts/presentation/workout_category_visual.dart';
import 'widgets/continue_journey_card.dart';

/// Home compacta — atalhos premium, mesma identidade da tela de Treinos.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final gamification = ref.watch(gamificationProvider);
    final streak = gamification.streak;
    final glasses = ref.watch(waterLogProvider);
    const waterGoal = 8;
    final waterLiters = glasses * 0.25;
    final todayKcal = ref.watch(todayKcalProvider);
    final metaKcal = ref.watch(trainerProfileProvider).metaCalorica.round();
    final profile = ref.watch(trainerProfileProvider);
    final treinoFeito =
        ref.watch(missionsProvider).progressOf('d_treino').current >= 1;
    final goalProgress =
        ((glasses / waterGoal) * 0.4 + (streak > 0 ? 0.35 : 0.1) + 0.1)
            .clamp(0.0, 1.0);
    final wide = context.isDesktopLayout || context.isTabletLayout;
    final todayWorkout = SeedData.dailyRecommended(
      nivelLabel: profile.nivel.label,
      boostTag: _boostTagFor(profile.objetivo),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeInUp(child: _TopBar(user: user)),
              const SizedBox(height: 10),
              const FadeInUp(child: AmandaHomeBanner()),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 30,
                child: _HeroBrand(
                  wide: wide,
                  motivationPrefix: 'Pequenas escolhas diárias, grandes ',
                  motivationHighlight: 'transformações!',
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 50,
                child: _StreakXpRow(
                  streak: streak,
                  level: gamification.level,
                  xpInLevel: gamification.xpInLevel,
                  onStreak: () => AppNavigation.open(context, Routes.streak),
                  onXp: () =>
                      AppNavigation.open(context, Routes.gamification),
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 70,
                child: _SummaryGrid(
                  waterLabel:
                      '${waterLiters.toStringAsFixed(1)} / ${(waterGoal * 0.25).toStringAsFixed(1)} L',
                  waterProgress: (glasses / waterGoal).clamp(0.0, 1.0),
                  streak: streak,
                  treinoLabel: treinoFeito ? 'Feito' : 'Pendente',
                  treinoProgress: treinoFeito ? 1.0 : 0.15,
                  caloriesLabel: metaKcal > 0
                      ? '$todayKcal / $metaKcal'
                      : '$todayKcal kcal',
                  caloriesProgress: metaKcal > 0
                      ? (todayKcal / metaKcal).clamp(0.0, 1.0)
                      : 0.2,
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 90,
                child: _TodayWorkoutCard(
                  workout: todayWorkout,
                  onStart: () => AppNavigation.open(context, Routes.workouts),
                  onSeeAll: () => AppNavigation.open(context, Routes.workouts),
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 100,
                child: _TodayNutritionCard(
                  onOpen: () => AppNavigation.open(context, Routes.recipes),
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delayMs: 110,
                child: _DailyGoalCard(
                  progress: goalProgress,
                  onOpenPlan: () => AppNavigation.open(context, Routes.plan),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delayMs: 115,
                child: _Programa7DiasHomeCard(
                  onOpen: () => AppNavigation.open(
                    context,
                    '/audio-programs/programa_7_dias_um_dia_de_cada_vez',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                  delayMs: 120, child: SectionHeader(title: 'Acesso rápido')),
              const SizedBox(height: 6),
              FadeInUp(delayMs: 130, child: const _QuickGrid()),
              const SizedBox(height: 12),
              const ContinueJourneyCard(),
              if (user.isAdmin) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => AppNavigation.open(context, Routes.admin),
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

String _boostTagFor(Objetivo objetivo) => switch (objetivo) {
      Objetivo.emagrecer => 'Cardio',
      Objetivo.tonificar => 'Força',
      Objetivo.ganharMassa => 'Força',
      Objetivo.saude => 'Mobilidade',
    };

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
          radius: 20,
          backgroundColor: AppColors.surface2,
          child: Text(
            first.isNotEmpty ? first[0].toUpperCase() : 'A',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá, $first! 👋',
                  style: AppTextStyles.h3().copyWith(fontSize: 18)),
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
          iconAsset: AppIcons.notifications,
          badge: unread,
          onTap: () => AppNavigation.open(context, Routes.reminders),
        ),
        const SizedBox(width: 8),
        _IconBtn(
          icon: Icons.calendar_today_outlined,
          iconAsset: AppIcons.calendar,
          onTap: () => AppNavigation.open(context, Routes.calendar),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.iconAsset,
    this.badge = false,
  });
  final IconData icon;
  final String? iconAsset;
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
            if (iconAsset != null)
              AppIconImage(
                iconAsset!,
                size: 22,
                fallbackIcon: icon,
              )
            else
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
    final lilyH = (h * (wide ? 0.16 : 0.14)).clamp(112.0, 150.0);

    return AppCard(
      padding: EdgeInsets.fromLTRB(wide ? 18 : 12, 10, 4, 2),
      glow: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.display(size: wide ? 28 : 24),
                      children: const [
                        TextSpan(text: 'LILY '),
                        TextSpan(
                          text: 'FIT',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Método 1 Dia de Cada Vez',
                    style: AppTextStyles.caption().copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySecondary().copyWith(fontSize: 12.5),
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
            flex: 4,
            child: SizedBox(
              height: lilyH,
              child: AnimatedLiliMascot(
                pose: MascotePose.padrao,
                mood: LiliMood.viva,
                height: lilyH,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakXpRow extends StatelessWidget {
  const _StreakXpRow({
    required this.streak,
    required this.level,
    required this.xpInLevel,
    required this.onStreak,
    required this.onXp,
  });

  final int streak;
  final int level;
  final int xpInLevel;
  final VoidCallback onStreak;
  final VoidCallback onXp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HomeShortcutCard(
            title: 'Sequência',
            subtitle: '$streak dias de foco',
            iconAsset: AppIcons.streak,
            icon: Icons.local_fire_department_rounded,
            accent: AppColors.secondary,
            onTap: onStreak,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: HomeShortcutCard(
            title: 'Nível $level',
            subtitle: '$xpInLevel / 1000 XP',
            iconAsset: AppIcons.trophy,
            icon: Icons.workspace_premium_rounded,
            accent: AppColors.primary,
            onTap: onXp,
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 26,
            lineWidth: 6,
            percent: progress,
            center: Text('$pct%',
                style: AppTextStyles.caption(color: AppColors.secondary)
                    .copyWith(fontWeight: FontWeight.w800, fontSize: 11)),
            progressColor: AppColors.secondary,
            backgroundColor: AppColors.surface2,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta do dia', style: AppTextStyles.title().copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text('Treino + Alimentação + Água',
                    style: AppTextStyles.caption()),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surface2,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onOpenPlan,
            child: Text(
              'Plano',
              style: AppTextStyles.caption(color: AppColors.secondary)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ),
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
    required this.treinoLabel,
    required this.treinoProgress,
    required this.caloriesLabel,
    required this.caloriesProgress,
  });
  final String waterLabel;
  final double waterProgress;
  final int streak;
  final String treinoLabel;
  final double treinoProgress;
  final String caloriesLabel;
  final double caloriesProgress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 720 ? 4 : 2;
      return ResponsiveWrapGrid(
        columns: cols,
        spacing: 8,
        runSpacing: 8,
        children: [
          _CompactStat(
            label: 'Treino',
            value: treinoLabel,
            iconAsset: AppIcons.workout,
            icon: Icons.fitness_center_rounded,
            accent: AppColors.secondary,
            progress: treinoProgress,
            onTap: () => AppNavigation.open(context, Routes.workouts),
          ),
          _CompactStat(
            label: 'Água',
            value: waterLabel,
            iconAsset: AppIcons.hydration,
            icon: Icons.water_drop_rounded,
            accent: AppColors.info,
            progress: waterProgress,
            onTap: () => AppNavigation.open(context, Routes.hydration),
          ),
          _CompactStat(
            label: 'Calorias',
            value: caloriesLabel,
            iconAsset: AppIcons.calories,
            icon: Icons.local_fire_department_rounded,
            accent: AppColors.calories,
            progress: caloriesProgress,
            onTap: () => AppNavigation.open(context, Routes.nutrition),
          ),
          _CompactStat(
            label: 'Sequência',
            value: '$streak dias',
            iconAsset: AppIcons.streak,
            icon: Icons.local_fire_department_rounded,
            accent: AppColors.primary,
            progress: (streak / 30).clamp(0.0, 1.0),
            onTap: () => AppNavigation.open(context, Routes.streak),
          ),
        ],
      );
    });
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.iconAsset,
    this.progress,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? iconAsset;
  final Color accent;
  final double? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          AppIconImage(
            iconAsset ?? AppIcons.home,
            size: 28,
            fallbackIcon: icon,
            semanticLabel: label,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.caption().copyWith(fontSize: 10.5)),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title().copyWith(fontSize: 12.5),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0, 1),
                      minHeight: 3,
                      backgroundColor: AppColors.surface2,
                      color: accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({
    required this.workout,
    required this.onStart,
    required this.onSeeAll,
  });
  final Workout workout;
  final VoidCallback onStart;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onStart,
      padding: const EdgeInsets.all(12),
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: WorkoutCoverImage(
                    workout: workout,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    fallbackIconSize: 40,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TREINO DO DIA',
                        style: AppTextStyles.caption(color: AppColors.secondary)
                            .copyWith(
                                fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                    const SizedBox(height: 2),
                    Text(workout.title, style: AppTextStyles.title()),
                    const SizedBox(height: 2),
                    Text(
                        '${workout.durationMin} min  ·  ${workout.level}  ·  ${workout.exercises} exercícios',
                        style: AppTextStyles.caption()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Começar treino',
            icon: Icons.play_arrow_rounded,
            iconAsset: AppIcons.play,
            height: 46,
            onPressed: onStart,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Ver todos os treinos',
                style: AppTextStyles.caption(color: AppColors.secondary)
                    .copyWith(fontWeight: FontWeight.w800),
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
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 68,
              height: 68,
              child: Image.asset(
                AppAssets.illustReceitasFit,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surface2,
                  alignment: Alignment.center,
                  child: const AppIconImage(
                    AppIcons.recipes,
                    size: 40,
                    fallbackIcon: Icons.restaurant_rounded,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RECEITA DO DIA',
                    style: AppTextStyles.caption(color: AppColors.secondary)
                        .copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text('Bowl Proteico Fit', style: AppTextStyles.title()),
                const SizedBox(height: 2),
                Text('380 kcal  ·  18 min  ·  Fácil',
                    style: AppTextStyles.caption()),
              ],
            ),
          ),
          Text(
            'Ver  >',
            style: AppTextStyles.caption(color: AppColors.secondary)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context) {
    final items = <({
      String title,
      String subtitle,
      String icon,
      IconData fallback,
      Color accent,
      VoidCallback onTap,
    })>[
      (
        title: 'Treinos',
        subtitle: 'Força, cardio e mais',
        icon: AppIcons.workout,
        fallback: Icons.fitness_center_rounded,
        accent: AppColors.secondary,
        onTap: () => AppNavigation.open(context, Routes.workouts),
      ),
      (
        title: 'Corrida GPS',
        subtitle: 'Acompanhe em tempo real',
        icon: AppIcons.gps,
        fallback: Icons.directions_run_rounded,
        accent: AppColors.info,
        onTap: () => AppNavigation.open(context, Routes.running),
      ),
      (
        title: 'Premium',
        subtitle: 'Desbloqueie o método completo',
        icon: AppIcons.premium,
        fallback: Icons.workspace_premium_rounded,
        accent: AppColors.warning,
        onTap: () => AppNavigation.open(context, Routes.premium),
      ),
      (
        title: 'Vídeos',
        subtitle: 'Treinos em vídeo',
        icon: AppIcons.videos,
        fallback: Icons.play_circle_rounded,
        accent: AppColors.hotPink,
        onTap: () => AppNavigation.open(context, Routes.videos),
      ),
      (
        title: 'Hábitos',
        subtitle: 'Sua rotina diária',
        icon: AppIcons.habits,
        fallback: Icons.checklist_rounded,
        accent: AppColors.primary,
        onTap: () => AppNavigation.open(context, Routes.habits),
      ),
      (
        title: 'Check-in',
        subtitle: 'Marque o dia de hoje',
        icon: AppIcons.checkin,
        fallback: Icons.event_available_rounded,
        accent: AppColors.hotPink,
        onTap: () => AppNavigation.open(context, Routes.checkin),
      ),
      (
        title: 'Diário',
        subtitle: 'Registre como se sente',
        icon: AppIcons.diary,
        fallback: Icons.menu_book_rounded,
        accent: AppColors.primaryDark,
        onTap: () => AppNavigation.open(context, Routes.diary),
      ),
      (
        title: 'Comunidade',
        subtitle: 'Conecte-se com outras',
        icon: AppIcons.community,
        fallback: Icons.groups_rounded,
        accent: AppColors.accent,
        onTap: () => AppNavigation.open(context, Routes.community),
      ),
      (
        title: 'Sequência',
        subtitle: 'Dias de consistência',
        icon: AppIcons.streak,
        fallback: Icons.local_fire_department_rounded,
        accent: AppColors.secondary,
        onTap: () => AppNavigation.open(context, Routes.streak),
      ),
      (
        title: 'Receitas',
        subtitle: 'Alimentação do método',
        icon: AppIcons.recipes,
        fallback: Icons.restaurant_rounded,
        accent: AppColors.success,
        onTap: () => AppNavigation.open(context, Routes.recipes),
      ),
      (
        title: 'Progresso',
        subtitle: 'Peso, medidas e fotos',
        icon: AppIcons.progress,
        fallback: Icons.trending_up_rounded,
        accent: AppColors.primary,
        onTap: () => AppNavigation.open(context, Routes.evolution),
      ),
      (
        title: 'Perfil',
        subtitle: 'Dados e preferências',
        icon: AppIcons.profile,
        fallback: Icons.person_rounded,
        accent: AppColors.secondary,
        onTap: () => AppNavigation.open(context, Routes.profile),
      ),
      (
        title: 'Água',
        subtitle: 'Meta de hidratação',
        icon: AppIcons.hydration,
        fallback: Icons.water_drop_rounded,
        accent: AppColors.info,
        onTap: () => AppNavigation.open(context, Routes.hydration),
      ),
      (
        title: 'Áudios',
        subtitle: 'Meditações e 7 dias',
        icon: AppIcons.program7Days,
        fallback: Icons.headphones_rounded,
        accent: AppColors.primaryDark,
        onTap: () => AppNavigation.open(context, Routes.audiosMeditations),
      ),
      (
        title: 'Meu Treino',
        subtitle: 'Plano do personal',
        icon: AppIcons.personal,
        fallback: Icons.fitness_center_rounded,
        accent: AppColors.hotPink,
        onTap: () => AppNavigation.open(context, Routes.personalTrainer),
      ),
      (
        title: 'Personal',
        subtitle: 'Quem Sou Eu',
        icon: AppIcons.personal,
        fallback: Icons.sports_gymnastics_rounded,
        accent: AppColors.secondary,
        onTap: () => AppNavigation.open(context, Routes.amandaProfile),
      ),
      (
        title: 'Metas',
        subtitle: 'Objetivos do método',
        icon: AppIcons.goal,
        fallback: Icons.flag_rounded,
        accent: AppColors.warning,
        onTap: () => AppNavigation.open(context, Routes.goals),
      ),
      (
        title: 'Configurações',
        subtitle: 'Preferências do app',
        icon: AppIcons.settings,
        fallback: Icons.settings_rounded,
        accent: AppColors.textSecondary,
        onTap: () => AppNavigation.open(context, Routes.settings),
      ),
    ];

    return ResponsiveWrapGrid(
      columns: context.quickAccessColumns,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final it in items)
          HomeShortcutCard(
            title: it.title,
            subtitle: it.subtitle,
            iconAsset: it.icon,
            icon: it.fallback,
            accent: it.accent,
            onTap: it.onTap,
          ),
      ],
    );
  }
}

class _Programa7DiasHomeCard extends StatelessWidget {
  final VoidCallback onOpen;

  const _Programa7DiasHomeCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColors.brandGradient,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRAMA 7 DIAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Um Dia de Cada Vez',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Amanda Lopes · Foco e disciplina',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
