import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_sign_out.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../audio_courses/domain/audio_course_models.dart';
import '../../audio_courses/providers/audio_course_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../mascot_lili/providers/lili_assets_providers.dart';
import '../../video_streaming/providers/video_providers.dart';
import '../../workouts/providers/treino_catalog_providers.dart';
import 'recipes_cms_screen.dart';

const _meditationCats = {
  AudioCourseCategory.meditacao,
  AudioCourseCategory.respiracao,
  AudioCourseCategory.ansiedade,
  AudioCourseCategory.sono,
};

/// Painel amigável da Personal para gerenciar conteúdos do app
/// (sem precisar do Painel Técnico).
class PersonalCmsHubScreen extends ConsumerWidget {
  const PersonalCmsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final role = resolveUserRole(
      isPersonalTrainer: user.isPersonalTrainer,
      isAdmin: user.isAdmin,
    );
    if (!RolePermissions.of(role).canManageContent) {
      return Scaffold(
        appBar: AppBar(title: const Text('Painel da Personal')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Acesso só para Personal ou Admin Técnico.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final videosAsync = ref.watch(videosAdminListProvider);
    final audiosAsync = ref.watch(audioCoursesProvider);
    final recipesAsync = ref.watch(pdfRecipesAdminStreamProvider);
    final liliAsync = ref.watch(liliAssetsProvider);
    final treinosAsync = ref.watch(treinoCatalogSnapshotProvider);

    String? videoCounts;
    videosAsync.whenData((list) {
      final published = list.where((v) => v.active).length;
      final drafts = list.length - published;
      videoCounts = '$published publicados · $drafts rascunhos';
    });

    String? audioCounts;
    String? meditationCounts;
    audiosAsync.whenData((list) {
      audioCounts = '${list.length} cursos';
      final meds =
          list.where((c) => _meditationCats.contains(c.category)).length;
      meditationCounts = '$meds meditações';
    });

    String? recipeCounts;
    recipesAsync.whenData((list) {
      final active = list.where((r) => r.active).length;
      final draft = list.length - active;
      recipeCounts = '$active publicadas · $draft desativadas';
    });

    String? liliCounts;
    liliAsync.whenData((list) {
      liliCounts = '${list.length} imagens';
    });

    String? treinoCounts;
    treinosAsync.whenData((snap) {
      treinoCounts = '${snap.treinos.length} no catálogo';
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Painel da Personal'),
        actions: [
          if (user.isAdmin)
            IconButton(
              tooltip: 'Painel Técnico',
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => context.push(Routes.admin),
            ),
          IconButton(
            tooltip: 'Sair da conta',
            icon: const Icon(Icons.logout),
            onPressed: () => signOutAndGoToLogin(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.softCardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conteúdos do app',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18),
                ),
                SizedBox(height: 6),
                Text(
                  'Gerencie treinos, vídeos, receitas, áudios e a Lily sem código. '
                  'Toque em Gerenciar para abrir cada área.',
                  style: TextStyle(
                      color: AppColors.textSecondary, height: 1.35, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CmsCard(
            icon: Icons.fitness_center_outlined,
            title: 'Treinos',
            subtitle: treinoCounts ?? 'Catálogo oficial',
            onTap: () => context.push(Routes.personalCmsTreinos),
          ),
          _CmsCard(
            icon: Icons.video_library_outlined,
            title: 'Vídeos',
            subtitle: videoCounts ?? 'Biblioteca de conteúdos',
            onTap: () => context.push(Routes.videosAdmin),
          ),
          _CmsCard(
            icon: Icons.restaurant_menu_outlined,
            title: 'Receitas',
            subtitle: recipeCounts ?? 'Receitas em PDF',
            onTap: () => context.push(Routes.personalCmsRecipes),
          ),
          _CmsCard(
            icon: Icons.headphones_outlined,
            title: 'Áudios',
            subtitle: audioCounts ?? 'Cursos em áudio',
            onTap: () => context.push(Routes.audioCoursesAdmin),
          ),
          _CmsCard(
            icon: Icons.self_improvement_outlined,
            title: 'Meditações',
            subtitle: meditationCounts ?? 'Calma e programas',
            onTap: () => context.push(Routes.personalCmsMeditations),
          ),
          _CmsCard(
            icon: Icons.emoji_events_outlined,
            title: 'Desafio da Semana',
            subtitle: 'Criar, publicar e acompanhar participantes',
            accent: AppColors.secondary,
            onTap: () => context.push(Routes.personalCmsChallenges),
          ),
          _CmsCard(
            icon: Icons.face_retouching_natural,
            title: 'Imagens Lily',
            subtitle: liliCounts ?? 'Poses e animações',
            onTap: () => context.push(Routes.liliAssetsAdmin),
          ),
          const SizedBox(height: 8),
          _CmsCard(
            icon: Icons.photo_camera_outlined,
            title: 'Fotos da Amanda',
            subtitle: 'Capa, perfil e galeria',
            accent: AppColors.secondary,
            onTap: () => context.push(Routes.amandaAssetsAdmin),
          ),
          _CmsCard(
            icon: Icons.badge_outlined,
            title: 'Quem sou eu',
            subtitle: 'Textos e apresentação da Amanda',
            accent: AppColors.secondary,
            onTap: () => context.push(Routes.amandaProfileEdit),
          ),
        ],
      ),
    );
  }
}

class _CmsCard extends StatelessWidget {
  const _CmsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: onTap,
                  child: const Text('Gerenciar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
