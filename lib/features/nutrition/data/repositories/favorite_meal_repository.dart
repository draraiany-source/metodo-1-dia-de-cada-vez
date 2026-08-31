import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../../domain/favorite_meal.dart';
import '../../domain/nutrition_firestore_paths.dart';
import '../local/nutrition_local_keys.dart';
import '../local/nutrition_local_store.dart';

class FavoriteMealRepository {
  FavoriteMealRepository({
    NutritionLocalStore? localStore,
    required this.userId,
  }) : _local = localStore ?? NutritionLocalStore();

  final NutritionLocalStore _local;
  final String userId;

  bool get _firebaseReady => FirebaseService.isReady && userId.isNotEmpty;

  Future<List<FavoriteMeal>> fetchAll() async {
    final key = NutritionLocalKeys.favoriteMeals(userId);
    final cached = await _local.readJsonList(key);
    if (cached.isNotEmpty) {
      return cached.map(FavoriteMeal.fromMap).toList();
    }

    if (!_firebaseReady) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favoriteMeals')
          .get();
      final list =
          snap.docs.map((d) => FavoriteMeal.fromMap({...d.data(), 'id': d.id})).toList();
      await _local.writeJsonList(key, list.map((f) => f.toMap()).toList());
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(FavoriteMeal favorite) async {
    final key = NutritionLocalKeys.favoriteMeals(userId);
    final all = await fetchAll();
    final updated = [...all.where((f) => f.id != favorite.id), favorite];
    await _local.writeJsonList(key, updated.map((f) => f.toMap()).toList());

    if (!_firebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .doc(NutritionFirestorePaths.favoriteMealDoc(userId, favorite.id))
          .set(favorite.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> delete(String id) async {
    final key = NutritionLocalKeys.favoriteMeals(userId);
    final all = await fetchAll();
    final updated = all.where((f) => f.id != id).toList();
    await _local.writeJsonList(key, updated.map((f) => f.toMap()).toList());

    if (!_firebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .doc(NutritionFirestorePaths.favoriteMealDoc(userId, id))
          .delete();
    } catch (_) {}
  }
}
