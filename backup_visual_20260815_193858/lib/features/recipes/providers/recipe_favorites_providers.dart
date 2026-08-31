import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Favoritos de receita — mesmo padrão local-first já usado em treinos
/// ([WorkoutFavoritesNotifier]) e nas receitas em PDF
/// ([PdfRecipeFavoritesNotifier]): persiste em SharedPreferences, um Set de
/// IDs, sem servidor envolvido. Chave própria porque o espaço de IDs de
/// `SeedData.recipes` é independente do de `PdfRecipe`.
class RecipeFavoritesNotifier extends StateNotifier<Set<String>> {
  RecipeFavoritesNotifier() : super({}) {
    _load();
  }

  static const _key = 'recipe_favorites';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> toggle(String recipeId) async {
    final set = {...state};
    set.contains(recipeId) ? set.remove(recipeId) : set.add(recipeId);
    state = set;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, set.toList());
  }
}

final recipeFavoritesProvider =
    StateNotifierProvider<RecipeFavoritesNotifier, Set<String>>((ref) {
  return RecipeFavoritesNotifier();
});
