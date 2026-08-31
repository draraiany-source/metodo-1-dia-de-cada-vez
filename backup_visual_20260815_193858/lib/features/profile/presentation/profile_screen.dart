import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/mascot/mascot_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
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
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
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
              const SizedBox(height: 18),
              QuickAccessTile(
                icon: Icons.calendar_today_outlined,
                title: 'Meu plano',
                showChevron: true,
                onTap: () => context.push(Routes.plan),
              ),
              const SizedBox(height: 8),
              QuickAccessTile(
                icon: Icons.flag_outlined,
                title: 'Minhas metas',
                showChevron: true,
                onTap: () => context.push(Routes.goals),
              ),
              const SizedBox(height: 8),
              QuickAccessTile(
                icon: Icons.favorite_border,
                title: 'Favoritos',
                showChevron: true,
                onTap: () => context.push(Routes.favorites),
              ),
              const SizedBox(height: 8),
              QuickAccessTile(
                icon: Icons.history,
                title: 'Histórico',
                showChevron: true,
                onTap: () => context.push(Routes.history),
              ),
              const SizedBox(height: 8),
              QuickAccessTile(
                icon: Icons.emoji_events_outlined,
                title: 'Conquistas',
                showChevron: true,
                onTap: () => context.push(Routes.gamification),
              ),
              const SizedBox(height: 8),
              QuickAccessTile(
                icon: Icons.workspace_premium_outlined,
                title: 'Assinatura',
                subtitle: user.isPremium ? 'Premium ativo' : 'Plano gratuito',
                accent: AppColors.warning,
                showChevron: true,
                onTap: () => context.push(Routes.premium),
              ),
              const SizedBox(height: 8),
              QuickAccessTile(
                icon: Icons.notifications_outlined,
                title: 'Notificações',
                showChevron: true,
                onTap: () => context.push(Routes.notificationPreferences),
              ),
              const SizedBox(height: 8),
              QuickAccessTile(
                icon: Icons.settings_outlined,
                title: 'Configurações',
                showChevron: true,
                onTap: () => context.push(Routes.settings),
              ),
              if (user.isAdmin) ...[
                const SizedBox(height: 8),
                QuickAccessTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Painel administrativo',
                  accent: AppColors.info,
                  showChevron: true,
                  onTap: () => context.push(Routes.admin),
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
                  if (context.mounted) context.go(Routes.login);
                },
                icon: const Icon(Icons.logout_rounded),
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
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text('Perfil',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          Align(
            alignment: Alignment.centerRight,
            child: PressableScale(
              onTap: onSettingsTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.settings_outlined,
                    size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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
    final avatar = wide ? 120.0 : 104.0;

    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(wide ? 20 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withOpacity(0.18),
              AppColors.surface,
              AppColors.primary.withOpacity(0.12),
            ],
          ),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColoredBox(
                    color: Colors.black,
                    child: SizedBox(
                      width: avatar,
                      height: avatar + 16,
                      child: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? Image.file(File(user.photoUrl!), fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => LiliFitMascot(
                                    pose: MascotePose.perfil,
                                    height: avatar + 16,
                                  ))
                          : LiliFitMascot(
                              pose: MascotePose.perfil,
                              height: avatar + 16,
                            ),
                    ),
                  ),
                ),
                if (user.isPremium)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroPinkGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(Icons.workspace_premium,
                          size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
            SizedBox(width: wide ? 18 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: wide ? 22 : 18,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Objetivo: ${trainerProfile.objetivo.label}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nível ${trainerProfile.nivel.label}  ·  🔥 ${gam.streak} dias',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PressableScale(
                    onTap: () => context.push(Routes.editProfile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroPinkGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Editar perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    final items = <(String, String, IconData)>[
      (
        'Idade',
        user.age != null ? '${user.age} anos' : '—',
        Icons.cake_outlined
      ),
      (
        'Altura',
        user.height != null ? '${user.height!.toStringAsFixed(2)} m' : '—',
        Icons.height_rounded
      ),
      (
        'Peso atual',
        user.currentWeight != null
            ? '${user.currentWeight!.toStringAsFixed(1)} kg'
            : '—',
        Icons.monitor_weight_outlined
      ),
      (
        'Meta de peso',
        user.goalWeight != null
            ? '${user.goalWeight!.toStringAsFixed(1)} kg'
            : '—',
        Icons.flag_outlined
      ),
      (
        'IMC',
        user.bmi != null
            ? '${user.bmi!.toStringAsFixed(1)} — ${user.bmiLabel}'
            : '—',
        Icons.favorite_outline_rounded
      ),
      (
        'Atividade',
        trainerProfile.nivelAtividade.label,
        Icons.directions_run_rounded
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
              final (label, value, icon) = items[i];
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
