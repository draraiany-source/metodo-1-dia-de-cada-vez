import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favoritos de treino — mesmo padrão local-first já usado nas receitas
/// ([PdfRecipeFavoritesNotifier]): persiste em SharedPreferences, um Set de
/// IDs, sem servidor envolvido.
class WorkoutFavoritesNotifier extends StateNotifier<Set<String>> {
  WorkoutFavoritesNotifier() : super({}) {
    _load();
  }

  static const _key = 'workout_favorites';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> toggle(String workoutId) async {
    final set = {...state};
    set.contains(workoutId) ? set.remove(workoutId) : set.add(workoutId);
    state = set;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, set.toList());
  }
}

final workoutFavoritesProvider =
    StateNotifierProvider<WorkoutFavoritesNotifier, Set<String>>((ref) {
  return WorkoutFavoritesNotifier();
});
