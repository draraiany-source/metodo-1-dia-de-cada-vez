import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/audio_courses/providers/audio_course_providers.dart'
    show audioFavoritesProvider;
import '../../features/recipes/providers/recipe_favorites_providers.dart'
    show recipeFavoritesProvider;
import '../../features/workouts/providers/workout_favorites_providers.dart'
    show workoutFavoritesProvider;

/// Tipos de favorito — UI e toggle unificados.
enum FavoriteKind {
  workout,
  recipe,
  audio,
  meditation,
}

extension FavoriteKindX on FavoriteKind {
  String get prefsKey => switch (this) {
        FavoriteKind.workout => 'workout_favorites',
        FavoriteKind.recipe => 'recipe_favorites',
        FavoriteKind.audio => 'audio_favorites',
        FavoriteKind.meditation => 'meditation_favorites',
      };

  String get label => switch (this) {
        FavoriteKind.workout => 'Treinos',
        FavoriteKind.recipe => 'Receitas',
        FavoriteKind.audio => 'Áudios',
        FavoriteKind.meditation => 'Meditações',
      };
}

/// Fonte única: mesmas chaves SharedPreferences dos notifiers legados +
/// meditações + snapshot. Toggle atualiza a chave e invalida/espelha.
class UnifiedFavoritesNotifier
    extends StateNotifier<Map<FavoriteKind, Set<String>>> {
  UnifiedFavoritesNotifier(this._ref)
      : super({for (final k in FavoriteKind.values) k: <String>{}}) {
    _load();
    // Espelha mudanças dos notifiers legados.
    _ref.listen<Set<String>>(workoutFavoritesProvider, (_, next) {
      state = {...state, FavoriteKind.workout: {...next}};
      _saveSnapshot();
    });
    _ref.listen<Set<String>>(recipeFavoritesProvider, (_, next) {
      state = {...state, FavoriteKind.recipe: {...next}};
      _saveSnapshot();
    });
    _ref.listen<Set<String>>(audioFavoritesProvider, (_, next) {
      state = {...state, FavoriteKind.audio: {...next}};
      _saveSnapshot();
    });
  }

  final Ref _ref;
  static const _snapshotKey = 'unified_favorites_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final next = <FavoriteKind, Set<String>>{
      FavoriteKind.workout:
          (prefs.getStringList(FavoriteKind.workout.prefsKey) ?? []).toSet(),
      FavoriteKind.recipe:
          (prefs.getStringList(FavoriteKind.recipe.prefsKey) ?? []).toSet(),
      FavoriteKind.audio:
          (prefs.getStringList(FavoriteKind.audio.prefsKey) ?? []).toSet(),
      FavoriteKind.meditation:
          (prefs.getStringList(FavoriteKind.meditation.prefsKey) ?? []).toSet(),
    };
    state = next;
    await _saveSnapshot();
  }

  Future<void> _saveSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final snap = <String, List<String>>{
      for (final k in FavoriteKind.values)
        k.name: (state[k] ?? {}).toList()..sort(),
    };
    await prefs.setString(_snapshotKey, jsonEncode(snap));
    // Meditações só existem neste store.
    await prefs.setStringList(
      FavoriteKind.meditation.prefsKey,
      snap[FavoriteKind.meditation.name]!,
    );
  }

  bool isFavorite(FavoriteKind kind, String id) =>
      state[kind]?.contains(id) ?? false;

  Future<void> toggle(FavoriteKind kind, String id) async {
    switch (kind) {
      case FavoriteKind.workout:
        await _ref.read(workoutFavoritesProvider.notifier).toggle(id);
        return;
      case FavoriteKind.recipe:
        await _ref.read(recipeFavoritesProvider.notifier).toggle(id);
        return;
      case FavoriteKind.audio:
        await _ref.read(audioFavoritesProvider.notifier).toggle(id);
        return;
      case FavoriteKind.meditation:
        final set = {...(state[FavoriteKind.meditation] ?? <String>{})};
        set.contains(id) ? set.remove(id) : set.add(id);
        state = {...state, FavoriteKind.meditation: set};
        await _saveSnapshot();
    }
  }

  Future<void> setFavorite(FavoriteKind kind, String id, bool value) async {
    final currently = isFavorite(kind, id);
    if (currently == value) return;
    await toggle(kind, id);
  }

  Set<String> of(FavoriteKind kind) => state[kind] ?? {};
}

final unifiedFavoritesProvider = StateNotifierProvider<
    UnifiedFavoritesNotifier, Map<FavoriteKind, Set<String>>>((ref) {
  return UnifiedFavoritesNotifier(ref);
});

final meditationFavoritesProvider = Provider<Set<String>>((ref) {
  return ref.watch(unifiedFavoritesProvider)[FavoriteKind.meditation] ?? {};
});
