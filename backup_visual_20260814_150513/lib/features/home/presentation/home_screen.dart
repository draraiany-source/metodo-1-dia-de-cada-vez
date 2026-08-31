import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/design_system/app_breakpoints.dart';
import '../../../core/mascot/mascot_config.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/home_premium_cards.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/quick_access_tile.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../health_sync/domain/health_models.dart';
import '../../health_sync/providers/health_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import 'widgets/continue_journey_card.dart';
import 'widgets/next_activity_card.dart';

/// Home do aluno — composição premium (não painel de cards vazios).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final streak = ref.watch(gamificationProvider).streak;
    final wide = context.isDesktopLayout;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeInUp(child: _HomeHeader(user: user)),
        const SizedBox(height: 18),

        FadeInUp(
          delayMs: 40,
          child: MotivationalLilyCard(
            title: streak > 0
                ? '$streak dias seguidos!'
                : 'Vamos começar hoje?',
            message: streak > 0
                ? 'Você está pegando fogo 🔥'
                : 'Vamos cuidar de você hoje?',
            pose: streak > 0 ? MascotePose.celebrando : MascotePose.forte,
            mood: streak > 0 ? LiliMood.comemorando : LiliMood.viva,
          ),
        ),
        const SizedBox(height: 14),

        FadeInUp(
          delayMs: 80,
          child: TodayWorkoutHeroCard(
            workoutName: 'Treino A — Pernas e Glúteos',
            durationLabel: '45 min',
            levelLabel: 'Intermediário',
            onStart: () => context.go(Routes.workouts),
          ),
        ),
        const SizedBox(height: 14),

        FadeInUp(
          delayMs: 100,
          child: _CompactSummaryRow(user: user, streak: streak),
        ),
        const SizedBox(height: 14),

        FadeInUp(
          delayMs: 120,
          child: WeeklyGoalCard(
            done: (user.totalWorkouts % 5).clamp(0, 5),
            goal: 5,
          ),
        ),
        const SizedBox(height: 14),

        const FadeInUp(
          delayMs: 140,
          child: PersonalMessageCard(
            authorName: 'Amanda',
            message:
                'Excelente evolução essa semana! Vamos manter o foco 💜',
          ),
        ),
        const SizedBox(height: 14),

        // Continuar jornada (Amanda) — funcionalidade existente preservada.
        const ContinueJourneyCard(),
        const SizedBox(height: 14),

        const NextActivityCard(),

        FadeInUp(
          delayMs: 160,
          child: _sectionTitle(context, 'Acessos rápidos'),
        ),
        const SizedBox(height: 10),
        FadeInUp(
          delayMs: 180,
          child: ResponsiveWrapGrid(
            columns: context.quickAccessColumns,
            childAspectRatio: 1.55,
            children: [
              QuickAccessGridTile(
                emoji: '🏋️',
                title: 'Treinos',
                subtitle: 'Seu plano',
                iconAsset: AppIcons.workout,
                icon: Icons.fitness_center_rounded,
                accent: AppColors.primary,
                onTap: () => context.go(Routes.workouts),
              ),
              QuickAccessGridTile(
                emoji: '💧',
                title: 'Água',
                subtitle: 'Hidratação',
                iconAsset: AppIcons.hydration,
                icon: Icons.water_drop_rounded,
                accent: AppColors.info,
                onTap: () => context.push(Routes.hydration),
              ),
              QuickAccessGridTile(
                emoji: '🔥',
                title: 'Sequência',
                subtitle: '$streak dias',
                iconAsset: AppIcons.streak,
                icon: Icons.local_fire_department_rounded,
                accent: AppColors.warning,
                onTap: () => context.push(Routes.streak),
              ),
              QuickAccessGridTile(
                emoji: '🏃',
                title: 'Corrida',
                subtitle: 'GPS',
                iconAsset: AppIcons.gpsRunning,
                icon: Icons.directions_run_rounded,
                accent: AppColors.secondary,
                onTap: () => context.push(Routes.running),
              ),
              QuickAccessGridTile(
                emoji: '🥗',
                title: 'Receitas',
                subtitle: 'Nutrição',
                iconAsset: AppIcons.recipes,
                icon: Icons.restaurant_rounded,
                accent: AppColors.success,
                onTap: () => context.push(Routes.pdfRecipes),
              ),
              QuickAccessGridTile(
                emoji: '🎧',
                title: 'Áudios',
                subtitle: MascotConfig.name,
                iconAsset: AppIcons.audio,
                icon: Icons.headphones_rounded,
                accent: AppColors.primary,
                onTap: () => context.push(Routes.audioCourses),
              ),
              QuickAccessGridTile(
                emoji: '📅',
                title: 'Calendário',
                subtitle: 'Agenda',
                iconAsset: AppIcons.calendar,
                icon: Icons.calendar_month_rounded,
                accent: AppColors.info,
                onTap: () => context.push(Routes.calendar),
              ),
              QuickAccessGridTile(
                emoji: '🏆',
                title: 'Desafios',
                subtitle: 'Missões',
                icon: Icons.emoji_events_rounded,
                accent: AppColors.warning,
                onTap: () => context.push(Routes.missions),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        FadeInUp(
          delayMs: 200,
          child: _sectionTitle(context, 'Mais recursos'),
        ),
        const SizedBox(height: 10),
        ..._moreAccessTiles(context, user),

        Builder(builder: (context) {
          final snap = ref.watch(healthSummaryProvider);
          if (snap == null) return const SizedBox.shrink();
          const destaques = [
            HealthMetric.passos,
            HealthMetric.caloriasKcal,
            HealthMetric.minutosAtivos,
          ];
          if (!destaques.any(snap.has)) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: QuickAccessTile(
              title: 'Saúde de hoje',
              subtitle: snap.source.label,
              emoji: '❤️',
              icon: Icons.favorite_rounded,
              accent: AppColors.danger,
              showChevron: true,
              onTap: () => context.push(Routes.healthSync),
            ),
          );
        }),

        if (ref.watch(claimableMissionsProvider) > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuickAccessTile(
              title:
                  '${ref.watch(claimableMissionsProvider)} missão(ões) para resgatar',
              subtitle: 'Toque para coletar recompensas',
              emoji: '🎁',
              accent: AppColors.warning,
              showChevron: true,
              onTap: () => context.push(Routes.missions),
            ),
          ),

        if (user.isAdmin)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () => context.push(Routes.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Painel Administrativo'),
            ),
          ),
        if (user.isPersonalTrainer)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilledButton.icon(
              onPressed: () => context.push(Routes.personalTrainer),
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Abrir painel da Personal'),
            ),
          ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: AppPage(
          maxWidth: wide
              ? AppBreakpoints.contentMaxWidthWide
              : AppBreakpoints.contentMaxWidth,
          child: content,
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
    );
  }

  List<Widget> _moreAccessTiles(BuildContext context, AppUser user) {
    final items = <Widget>[
      QuickAccessTile(
        title: 'Hábitos',
        subtitle: 'Checklist diário',
        emoji: '✅',
        iconAsset: AppIcons.checklist,
        icon: Icons.check_circle_rounded,
        accent: AppColors.warning,
        showChevron: true,
        onTap: () => context.go(Routes.habits),
      ),
      QuickAccessTile(
        title: 'Nutrição',
        subtitle: 'Refeições e calorias',
        emoji: '🥗',
        iconAsset: AppIcons.nutrition,
        icon: Icons.restaurant_menu_rounded,
        accent: AppColors.success,
        showChevron: true,
        onTap: () => context.go(Routes.nutrition),
      ),
      QuickAccessTile(
        title: 'Evolução',
        subtitle: 'Peso, medidas e fotos',
        emoji: '📈',
        iconAsset: AppIcons.progress,
        icon: Icons.trending_up_rounded,
        accent: AppColors.primary,
        showChevron: true,
        onTap: () => context.go(Routes.evolution),
      ),
      QuickAccessTile(
        title: 'Personal Trainer',
        subtitle: 'Treinos prescritos',
        emoji: '🏋️',
        icon: Icons.sports_gymnastics_rounded,
        accent: AppColors.secondary,
        showChevron: true,
        onTap: () => context.push(Routes.personalTrainer),
      ),
      QuickAccessTile(
        title: 'Comunidade',
        subtitle: 'Conecte-se',
        emoji: '👥',
        iconAsset: AppIcons.community,
        icon: Icons.groups_rounded,
        accent: AppColors.info,
        showChevron: true,
        onTap: () => context.push(Routes.community),
      ),
      QuickAccessTile(
        title: 'IA Personal',
        subtitle: 'Tire dúvidas',
        emoji: '🤖',
        icon: Icons.smart_toy_rounded,
        accent: AppColors.primary,
        showChevron: true,
        onTap: () => context.push(Routes.aiTrainer),
      ),
      QuickAccessTile(
        title: 'Vídeos & cursos',
        subtitle: 'Biblioteca premium',
        emoji: '🎥',
        iconAsset: AppIcons.video,
        icon: Icons.play_circle_outline_rounded,
        accent: AppColors.primary,
        showChevron: true,
        onTap: () => context.push(Routes.videos),
      ),
      QuickAccessTile(
        title: 'Gamificação',
        subtitle: 'XP, ligas e recompensas',
        emoji: '🏆',
        icon: Icons.emoji_events_outlined,
        accent: AppColors.warning,
        showChevron: true,
        onTap: () => context.push(Routes.gamification),
      ),
      QuickAccessTile(
        title: 'Relatórios',
        subtitle: 'Resumo do progresso',
        emoji: '📊',
        iconAsset: AppIcons.statistics,
        icon: Icons.bar_chart_rounded,
        accent: AppColors.success,
        showChevron: true,
        onTap: () => context.push(Routes.reports),
      ),
    ];

    return [
      for (var i = 0; i < items.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8),
          child: items[i],
        ),
    ];
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = user.name.split(' ').first;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Olá, $firstName',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Vamos cuidar de você hoje?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
        // Lily com presença no topo (não avatar minúsculo).
        const SizedBox(
          width: MascotSizes.header,
          height: MascotSizes.header + 8,
          child: AnimatedLiliMascot(
            pose: MascotePose.perfil,
            mood: LiliMood.viva,
            height: MascotSizes.header,
          ),
        ),
        const SizedBox(width: 8),
        PressableScale(
          onTap: () => context.push(Routes.rewards),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.warning.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${ref.watch(rewardsProvider).coins}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _NotificationBell(
          hasUnread: ref.watch(claimableMissionsProvider) > 0,
          onTap: () => context.push(Routes.reminders),
        ),
        const SizedBox(width: 8),
        PressableScale(
          onTap: () => context.push(Routes.profile),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.35),
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactSummaryRow extends StatelessWidget {
  const _CompactSummaryRow({required this.user, required this.streak});
  final AppUser user;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final lost = user.lostWeight;
    return Row(
      children: [
        Expanded(
          child: CompactStatChip(
            emoji: '🔥',
            value: '$streak',
            label: 'Dias seguidos',
            accent: AppColors.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CompactStatChip(
            emoji: '🏋️',
            value: '${user.totalWorkouts}',
            label: 'Treinos',
            accent: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CompactStatChip(
            emoji: '⚖️',
            value: lost != null ? '-${lost.toStringAsFixed(1)} kg' : '—',
            label: 'Evolução',
            accent: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CompactStatChip(
            emoji: '⭐',
            value: '${user.xp}',
            label: 'Nível ${user.level}',
            accent: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.hasUnread, required this.onTap});
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 22),
          ),
          if (hasUnread)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
