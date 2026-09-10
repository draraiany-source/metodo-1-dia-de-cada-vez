import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/favorites/unified_favorites.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/domain_models.dart';
import '../../audio_courses/domain/audio_course_models.dart';
import '../../audio_courses/providers/audio_course_providers.dart';
import '../../audio_programs/data/repositories/audio_program_repository_impl.dart';
import '../../audio_programs/domain/entities/audio_program.dart';
import '../../audio_programs/providers/audio_program_providers.dart';
import '../../recipes/presentation/recipe_detail_screen.dart';
import '../../recipes/providers/recipe_favorites_providers.dart';
import '../../workouts/presentation/workout_detail_screen.dart';
import '../../workouts/providers/workout_favorites_providers.dart';

/// Meus favoritos — fonte única via [unifiedFavoritesProvider]
/// (espelha treinos/receitas/áudios + meditações).
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _tab = 0;

  static const _meditationCats = {
    AudioCourseCategory.meditacao,
    AudioCourseCategory.respiracao,
    AudioCourseCategory.ansiedade,
    AudioCourseCategory.sono,
  };

  @override
  Widget build(BuildContext context) {
    // Garante store unificado ativo (espelha notifiers legados).
    ref.watch(unifiedFavoritesProvider);

    final workoutFavIds = ref.watch(workoutFavoritesProvider);
    final recipeFavIds = ref.watch(recipeFavoritesProvider);
    final audioFavIds = ref.watch(audioFavoritesProvider);
    final meditationFavIds = ref.watch(meditationFavoritesProvider);

    final workouts =
        SeedData.workouts.where((w) => workoutFavIds.contains(w.id)).toList();
    final recipes =
        SeedData.recipes.where((r) => recipeFavIds.contains(r.id)).toList();

    final coursesAsync = ref.watch(audioCoursesProvider);
    final courses = coursesAsync.valueOrNull ?? const <AudioCourse>[];
    final audios = courses
        .where((c) =>
            audioFavIds.contains(c.id) && !_meditationCats.contains(c.category))
        .toList();
    final meditations = courses
        .where((c) =>
            (meditationFavIds.contains(c.id) || audioFavIds.contains(c.id)) &&
            _meditationCats.contains(c.category))
        .toList();

    final programFavs = ref
            .watch(programProgressProvider(kPrograma7DiasId))
            .valueOrNull
            ?.favoriteAudioIds ??
        const <String>{};
    final programAudios =
        ref.watch(programAudiosProvider(kPrograma7DiasId)).valueOrNull ?? [];
    final programFavList =
        programAudios.where((a) => programFavs.contains(a.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('Meus favoritos',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PressableScale(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip('Treinos', workouts.length, 0),
                    _chip('Receitas', recipes.length, 1),
                    _chip('Áudios', audios.length + programFavList.length, 2),
                    _chip('Meditações', meditations.length, 3),
                  ],
                ),
              ),
            ),
            Expanded(
              child: switch (_tab) {
                0 => _WorkoutsFavoritesList(workouts: workouts),
                1 => _RecipesFavoritesList(recipes: recipes),
                2 => _AudioFavoritesList(
                    courses: audios,
                    programItems: programFavList,
                  ),
                _ => _MeditationFavoritesList(courses: meditations),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int count, int index) {
    final active = _tab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PressableScale(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: active ? AppColors.heroPinkGradient : null,
            color: active ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$label ($count)',
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutsFavoritesList extends ConsumerWidget {
  const _WorkoutsFavoritesList({required this.workouts});
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (workouts.isEmpty) return const _EmptyFavorites();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: workouts.length,
      itemBuilder: (context, i) {
        final w = workouts[i];
        return FadeInUp(
          delayMs: i * 40,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => WorkoutDetailScreen(workout: w))),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child:
                              Text(w.emoji, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          Text('${w.durationMin} min · ${w.level}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    PressableScale(
                      onTap: () => ref
                          .read(unifiedFavoritesProvider.notifier)
                          .toggle(FavoriteKind.workout, w.id),
                      child: const FavoriteAssetIcon(active: true, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecipesFavoritesList extends ConsumerWidget {
  const _RecipesFavoritesList({required this.recipes});
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recipes.isEmpty) return const _EmptyFavorites();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: recipes.length,
      itemBuilder: (context, i) {
        final r = recipes[i];
        return FadeInUp(
          delayMs: i * 40,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: r))),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child:
                              Text(r.emoji, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          Text('${r.durationMin} min · ${r.kcal} kcal',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    PressableScale(
                      onTap: () => ref
                          .read(unifiedFavoritesProvider.notifier)
                          .toggle(FavoriteKind.recipe, r.id),
                      child: const FavoriteAssetIcon(active: true, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AudioFavoritesList extends ConsumerWidget {
  const _AudioFavoritesList({
    required this.courses,
    required this.programItems,
  });
  final List<AudioCourse> courses;
  final List<ProgramAudio> programItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (courses.isEmpty && programItems.isEmpty) {
      return const _EmptyFavorites();
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        for (var i = 0; i < programItems.length; i++)
          _FavTile(
            title: programItems[i].title,
            subtitle: 'Programa 7 Dias · Dia ${programItems[i].day}',
            onOpen: () => context.push(
              '/audio-programs/$kPrograma7DiasId/play/${programItems[i].id}',
            ),
            onUnfav: () => ref
                .read(audioProgramRepositoryProvider)
                .toggleFavorite(
                    kPrograma7DiasId, programItems[i].id, false),
          ),
        for (var i = 0; i < courses.length; i++)
          _FavTile(
            title: courses[i].title,
            subtitle: courses[i].category.label,
            onOpen: () => context.push(Routes.audioCourses),
            onUnfav: () => ref
                .read(unifiedFavoritesProvider.notifier)
                .toggle(FavoriteKind.audio, courses[i].id),
          ),
      ],
    );
  }
}

class _MeditationFavoritesList extends ConsumerWidget {
  const _MeditationFavoritesList({required this.courses});
  final List<AudioCourse> courses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (courses.isEmpty) return const _EmptyFavorites();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: courses.length,
      itemBuilder: (context, i) {
        final c = courses[i];
        return _FavTile(
          title: c.title,
          subtitle: c.category.label,
          onOpen: () => context.push(Routes.meditations),
          onUnfav: () {
            ref
                .read(unifiedFavoritesProvider.notifier)
                .toggle(FavoriteKind.meditation, c.id);
            if (ref.read(audioFavoritesProvider).contains(c.id)) {
              ref
                  .read(unifiedFavoritesProvider.notifier)
                  .toggle(FavoriteKind.audio, c.id);
            }
          },
        );
      },
    );
  }
}

class _FavTile extends StatelessWidget {
  const _FavTile({
    required this.title,
    required this.subtitle,
    required this.onOpen,
    required this.onUnfav,
  });

  final String title;
  final String subtitle;
  final VoidCallback onOpen;
  final VoidCallback onUnfav;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.headphones_rounded,
                    color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              PressableScale(
                onTap: onUnfav,
                child: const FavoriteAssetIcon(active: true, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LiliMascot(pose: MascotePose.triste, height: 100),
            const SizedBox(height: 16),
            const Text('Você ainda não adicionou favoritos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            PressableScale(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Explorar conteúdos',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
