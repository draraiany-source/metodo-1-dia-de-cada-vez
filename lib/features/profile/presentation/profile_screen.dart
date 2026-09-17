import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/mascot/mascot_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/quick_access_tile.dart';
import '../../../models/app_user.dart';
import '../../ai_trainer/domain/trainer_engine.dart';
import '../../ai_trainer/providers/ai_trainer_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';

/// Perfil — card de usuária premium + meus dados + menu (sem alterar rotas).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final gam = ref.watch(gamificationProvider);
    final trainerProfile = ref.watch(trainerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onSettingsTap: () => context.push(Routes.settings)),
              const SizedBox(height: 12),
              _ProfileCard(
                  user: user, gam: gam, trainerProfile: trainerProfile),
              const SizedBox(height: 18),
              Text('Meus dados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
              const SizedBox(height: 10),
              _BodyDataCard(user: user, trainerProfile: trainerProfile),
              const SizedBox(height: 14),
              Text('Atalhos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
              const SizedBox(height: 10),
              QuickAccessTile(
                icon: Icons.calendar_today_outlined,
                iconAsset: AppIcons.calendar,
                title: 'Meu plano',
                showChevron: true,
                onTap: () => context.push(Routes.plan),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.flag_outlined,
                iconAsset: AppIcons.goal,
                title: 'Minhas metas',
                showChevron: true,
                onTap: () => context.push(Routes.goals),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.emoji_events_outlined,
                iconAsset: AppIcons.achievement,
                title: 'Meus Desafios',
                subtitle: 'Em andamento e histórico',
                showChevron: true,
                onTap: () => context.push(Routes.myChallenges),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.bookmark_border_rounded,
                iconAsset: AppIcons.favorites,
                title: 'Favoritos',
                showChevron: true,
                onTap: () => context.push(Routes.favorites),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.photo_camera_back_outlined,
                iconAsset: AppIcons.beforeAfter,
                title: 'Fotos',
                subtitle: 'Antes e depois',
                showChevron: true,
                onTap: () => context.push(Routes.progressPhotos),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.straighten,
                iconAsset: AppIcons.bmiMeasure,
                title: 'Medidas',
                showChevron: true,
                onTap: () => context.push(Routes.measurements),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.history,
                iconAsset: AppIcons.progress,
                title: 'Histórico',
                showChevron: true,
                onTap: () => context.push(Routes.history),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.emoji_events_outlined,
                iconAsset: AppIcons.achievement,
                title: 'Conquistas',
                showChevron: true,
                onTap: () => context.push(Routes.gamification),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.workspace_premium_outlined,
                iconAsset: AppIcons.premium,
                title: 'Assinatura',
                subtitle: user.isPremium ? 'Premium ativo' : 'Plano gratuito',
                accent: AppColors.secondary,
                showChevron: true,
                onTap: () => context.push(Routes.premium),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.notifications_outlined,
                iconAsset: AppIcons.notifications,
                title: 'Notificações',
                showChevron: true,
                onTap: () => context.push(Routes.notificationPreferences),
              ),
              const SizedBox(height: 6),
              QuickAccessTile(
                icon: Icons.settings_outlined,
                iconAsset: AppIcons.settings,
                title: 'Configurações',
                showChevron: true,
                onTap: () => context.push(Routes.settings),
              ),
              if (user.isAdmin) ...[
                const SizedBox(height: 6),
                QuickAccessTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Painel Técnico',
                  accent: AppColors.info,
                  showChevron: true,
                  onTap: () => context.push(Routes.admin),
                ),
                const SizedBox(height: 6),
                QuickAccessTile(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Painel da Personal',
                  accent: AppColors.primary,
                  showChevron: true,
                  onTap: () => context.push(Routes.painelPersonal),
                ),
              ],
              if (user.isPersonalTrainer && !user.isAdmin) ...[
                const SizedBox(height: 6),
                QuickAccessTile(
                  icon: Icons.fitness_center_outlined,
                  title: 'Central da Personal',
                  accent: AppColors.secondary,
                  showChevron: true,
                  onTap: () => context.push(Routes.personalTrainer),
                ),
                const SizedBox(height: 6),
                QuickAccessTile(
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Painel de conteúdos',
                  accent: AppColors.primary,
                  showChevron: true,
                  onTap: () => context.push(Routes.painelPersonal),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: AppColors.danger.withOpacity(0.5)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  ref.read(localSessionProvider.notifier).clear();
                  await ref.read(guestSessionProvider.notifier).exit();
                  if (context.mounted) context.go(Routes.login);
                },
                icon: AppIconImage(
                  AppIcons.logout,
                  size: 20,
                  fallbackIcon: Icons.logout_rounded,
                ),
                label: const Text('Sair da conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSettingsTap});
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Perfil',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 26)),
            ),
            PressableScale(
              onTap: onSettingsTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: const AppIconImage(
                  AppIcons.settings,
                  size: 22,
                  fallbackIcon: Icons.settings_outlined,
                  semanticLabel: 'Configurações',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text.rich(
          TextSpan(
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
            children: [
              TextSpan(text: 'Você é '),
              TextSpan(
                text: 'única',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: ' e capaz de tudo!'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard(
      {required this.user, required this.gam, required this.trainerProfile});
  final AppUser user;
  final GamificationState gam;
  final TrainerProfile trainerProfile;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final avatar = wide ? 96.0 : 84.0;

    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(wide ? 16 : 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withOpacity(0.2),
              AppColors.surface,
              AppColors.primary.withOpacity(0.14),
            ],
          ),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.38),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: avatar,
                      height: avatar,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.heroPinkGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: ColoredBox(
                          color: Colors.black,
                          child: (user.photoUrl != null &&
                                  user.photoUrl!.isNotEmpty)
                              ? Image.file(
                                  File(user.photoUrl!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => LiliFitMascot(
                                    pose: MascotePose.perfil,
                                    height: avatar,
                                  ),
                                )
                              : LiliFitMascot(
                                  pose: MascotePose.perfil,
                                  height: avatar,
                                ),
                        ),
                      ),
                    ),
                    if (user.isPremium)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroPinkGradient,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.surface, width: 2),
                          ),
                          child: const AppIconImage(
                            AppIcons.premium,
                            size: 14,
                            fallbackIcon: Icons.workspace_premium,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: wide ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: wide ? 20 : 17,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Objetivo: ${trainerProfile.objetivo.label}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Nível ${trainerProfile.nivel.label}  ·  ${gam.streak} dias de sequência',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PressableScale(
                        onTap: () => context.push(Routes.editProfile),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroPinkGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Editar perfil',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ProfileChip(
                  label: user.isPremium ? 'Premium' : 'Plano free',
                  accent: user.isPremium
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
                if (user.currentWeight != null)
                  _ProfileChip(
                    label: '${user.currentWeight!.toStringAsFixed(1)} kg',
                    accent: AppColors.info,
                  ),
                if (user.height != null)
                  _ProfileChip(
                    label: '${user.height!.toStringAsFixed(2)} m',
                    accent: AppColors.primary,
                  ),
                if (user.goalWeight != null)
                  _ProfileChip(
                    label: 'Meta ${user.goalWeight!.toStringAsFixed(0)} kg',
                    accent: AppColors.secondary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BodyDataCard extends StatelessWidget {
  const _BodyDataCard({required this.user, required this.trainerProfile});
  final AppUser user;
  final TrainerProfile trainerProfile;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData, String?)>[
      (
        'Idade',
        user.age != null ? '${user.age} anos' : '—',
        Icons.cake_outlined,
        null,
      ),
      (
        'Altura',
        user.height != null ? '${user.height!.toStringAsFixed(2)} m' : '—',
        Icons.height_rounded,
        AppIcons.bmiMeasure,
      ),
      (
        'Peso atual',
        user.currentWeight != null
            ? '${user.currentWeight!.toStringAsFixed(1)} kg'
            : '—',
        Icons.monitor_weight_outlined,
        AppIcons.weight,
      ),
      (
        'Meta de peso',
        user.goalWeight != null
            ? '${user.goalWeight!.toStringAsFixed(1)} kg'
            : '—',
        Icons.flag_outlined,
        AppIcons.goal,
      ),
      (
        'IMC',
        user.bmi != null
            ? '${user.bmi!.toStringAsFixed(1)} — ${user.bmiLabel}'
            : '—',
        Icons.monitor_weight_outlined,
        AppIcons.bmiMeasure,
      ),
      (
        'Atividade',
        trainerProfile.nivelAtividade.label,
        Icons.directions_run_rounded,
        AppIcons.running,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth >= 640 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: cols == 3 ? 1.55 : 1.45,
            ),
            itemBuilder: (_, i) {
              final (label, value, icon, asset) = items[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (asset != null)
                      AppIconImage(
                        asset,
                        size: 22,
                        fallbackIcon: icon,
                        semanticLabel: label,
                      )
                    else
                      Icon(icon, size: 18, color: AppColors.secondary),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
