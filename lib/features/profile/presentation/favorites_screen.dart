import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/domain_models.dart';
import '../../recipes/presentation/recipe_detail_screen.dart';
import '../../recipes/providers/recipe_favorites_providers.dart';
import '../../workouts/presentation/workout_detail_screen.dart';
import '../../workouts/providers/workout_favorites_providers.dart';

/// Favoritos — treinos e receitas marcados nas telas Treinos e
/// Receitas. Reaproveita 100% os providers já criados lá
/// ([workoutFavoritesProvider], [recipeFavoritesProvider]); esta tela só
/// lê e permite remover — nenhum sistema de favoritos novo.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final workoutFavIds = ref.watch(workoutFavoritesProvider);
    final recipeFavIds = ref.watch(recipeFavoritesProvider);
    final workouts =
        SeedData.workouts.where((w) => workoutFavIds.contains(w.id)).toList();
    final recipes =
        SeedData.recipes.where((r) => recipeFavIds.contains(r.id)).toList();

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
                    const Text('Favoritos',
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: _TabButton(
                            label: 'Treinos (${workouts.length})',
                            active: _tab == 0,
                            onTap: () => setState(() => _tab = 0))),
                    Expanded(
                        child: _TabButton(
                            label: 'Receitas (${recipes.length})',
                            active: _tab == 1,
                            onTap: () => setState(() => _tab = 1))),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _tab == 0
                  ? _WorkoutsFavoritesList(workouts: workouts)
                  : _RecipesFavoritesList(recipes: recipes),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: active ? AppColors.heroPinkGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13)),
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
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
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
                                  color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('${w.durationMin} min · ${w.level}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    PressableScale(
                      onTap: () =>
                          ref.read(workoutFavoritesProvider.notifier).toggle(w.id),
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
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r))),
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
                                  color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('${r.durationMin} min · ${r.kcal} kcal',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    PressableScale(
                      onTap: () =>
                          ref.read(recipeFavoritesProvider.notifier).toggle(r.id),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Explorar conteúdos',
                    style:
                        TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
