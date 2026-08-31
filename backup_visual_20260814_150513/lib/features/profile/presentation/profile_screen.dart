import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
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

/// ============================================================================
/// PERFIL
///
/// Card principal + "Meus dados" (IMC calculado de verdade a partir do
/// cadastro real) + menu completo. Cada item do menu abre uma tela própria
/// e funcional — nada de placeholder sem ação.
/// ============================================================================
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final gam = ref.watch(gamificationProvider);
    final trainerProfile = ref.watch(trainerProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            _Header(onSettingsTap: () => context.push(Routes.settings)),
            const SizedBox(height: 16),
            _ProfileCard(user: user, gam: gam, trainerProfile: trainerProfile),
            const SizedBox(height: 20),
            Text('Meus dados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _BodyDataCard(user: user, trainerProfile: trainerProfile),
            const SizedBox(height: 20),
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
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () => _sair(context, ref),
              icon: const Icon(Icons.logout),
              label: Text(
                ref.watch(guestSessionProvider) && ref.watch(currentUserProvider) == null
                    ? 'Sair do modo visitante'
                    : 'Sair da conta',
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sair(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
        ],
      ),
    );
    if (confirmar != true) return;

    await ref.read(authRepositoryProvider).signOut();
    ref.read(localSessionProvider.notifier).clear();
    // Também encerra a sessão de visitante, se houver — sem isso, uma
    // visitante que tocasse em "Sair" continuaria autenticada pelo GoRouter.
    await ref.read(guestSessionProvider.notifier).exit();
    if (context.mounted) context.go(Routes.login);
  }
}

// ============================================================================
// CABEÇALHO
// ============================================================================
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
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
          Align(
            alignment: Alignment.centerRight,
            child: PressableScale(
              onTap: onSettingsTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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

// ============================================================================
// CARD PRINCIPAL
// ============================================================================
class _ProfileCard extends StatelessWidget {
  const _ProfileCard(
      {required this.user, required this.gam, required this.trainerProfile});
  final AppUser user;
  final GamificationState gam;
  final TrainerProfile trainerProfile;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withOpacity(0.10),
              AppColors.surface,
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                        ? Image.file(File(user.photoUrl!), fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const LiliMascot(
                                pose: MascotePose.perfil, height: 72))
                        : const LiliMascot(pose: MascotePose.perfil, height: 72),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.star, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Objetivo: ${trainerProfile.objetivo.label}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  Text('Nível ${trainerProfile.nivel.label.toLowerCase()} · 🔥 ${gam.streak} dias',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  const SizedBox(height: 10),
                  PressableScale(
                    onTap: () => context.push(Routes.editProfile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroPinkGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Editar perfil',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
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

// ============================================================================
// MEUS DADOS
// ============================================================================
class _BodyDataCard extends StatelessWidget {
  const _BodyDataCard({required this.user, required this.trainerProfile});
  final AppUser user;
  final TrainerProfile trainerProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        children: [
          _row('Idade', user.age != null ? '${user.age} anos' : '—'),
          _row('Altura', user.height != null ? '${user.height!.toStringAsFixed(2)} m' : '—'),
          _row('Peso atual',
              user.currentWeight != null ? '${user.currentWeight!.toStringAsFixed(1)} kg' : '—'),
          _row('Meta de peso',
              user.goalWeight != null ? '${user.goalWeight!.toStringAsFixed(1)} kg' : '—'),
          _row('IMC', user.bmi != null ? '${user.bmi!.toStringAsFixed(1)} — ${user.bmiLabel}' : '—',
              highlight: user.bmi != null),
          _row('Objetivo', trainerProfile.objetivo.label),
          _row('Nível de atividade', trainerProfile.nivelAtividade.label),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: highlight ? AppColors.success : Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
