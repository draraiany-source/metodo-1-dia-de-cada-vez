import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pdf_recipes_repository.dart';
import '../domain/pdf_recipe_models.dart';

final pdfRecipesRepositoryProvider = Provider((ref) => PdfRecipesRepository());

final pdfRecipesProvider = FutureProvider<List<PdfRecipe>>((ref) {
  return ref.read(pdfRecipesRepositoryProvider).fetchAll();
});

class PdfRecipeFavoritesNotifier extends StateNotifier<Set<String>> {
  PdfRecipeFavoritesNotifier() : super({}) {
    _load();
  }

  static const _key = 'pdf_recipe_favorites';

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

final pdfRecipeFavoritesProvider =
    StateNotifierProvider<PdfRecipeFavoritesNotifier, Set<String>>((ref) {
  return PdfRecipeFavoritesNotifier();
});
