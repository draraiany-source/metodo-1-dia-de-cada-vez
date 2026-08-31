import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../../domain/nutrition_firestore_paths.dart';
import '../../domain/recipe.dart';
import '../local/nutrition_local_keys.dart';
import '../local/nutrition_local_store.dart';

class RecipeRepository {
  RecipeRepository({
    NutritionLocalStore? localStore,
    required this.userId,
  }) : _local = localStore ?? NutritionLocalStore();

  final NutritionLocalStore _local;
  final String userId;

  bool get _firebaseReady => FirebaseService.isReady && userId.isNotEmpty;

  Future<List<NutritionRecipe>> fetchAll() async {
    final key = NutritionLocalKeys.recipes(userId);
    final cached = await _local.readJsonList(key);
    if (cached.isNotEmpty) {
      return cached.map(NutritionRecipe.fromMap).toList();
    }

    if (!_firebaseReady) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .get();
      final list = snap.docs
          .map((d) => NutritionRecipe.fromMap({...d.data(), 'id': d.id}))
          .toList();
      await _local.writeJsonList(key, list.map((r) => r.toMap()).toList());
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(NutritionRecipe recipe) async {
    final key = NutritionLocalKeys.recipes(userId);
    final all = await fetchAll();
    final updated = [...all.where((r) => r.id != recipe.id), recipe];
    await _local.writeJsonList(key, updated.map((r) => r.toMap()).toList());

    if (!_firebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .doc(NutritionFirestorePaths.recipeDoc(userId, recipe.id))
          .set(recipe.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    final key = NutritionLocalKeys.recipes(userId);
    final all = await fetchAll();
    final updated = all.where((r) => r.id != id).toList();
    await _local.writeJsonList(key, updated.map((r) => r.toMap()).toList());

    if (!_firebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .doc(NutritionFirestorePaths.recipeDoc(userId, id))
          .delete();
    } catch (_) {}
  }
}
