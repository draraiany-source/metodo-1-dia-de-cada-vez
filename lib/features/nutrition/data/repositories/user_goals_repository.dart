import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../../domain/nutrition_firestore_paths.dart';
import '../../domain/user_goals.dart';
import '../local/nutrition_local_keys.dart';
import '../local/nutrition_local_store.dart';

class UserGoalsRepository {
  UserGoalsRepository({
    NutritionLocalStore? localStore,
    required this.userId,
  }) : _local = localStore ?? NutritionLocalStore();

  final NutritionLocalStore _local;
  final String userId;

  bool get _firebaseReady => FirebaseService.isReady && userId.isNotEmpty;

  Future<UserGoals?> fetch() async {
    final key = NutritionLocalKeys.userGoals(userId);
    final cached = await _local.readJson(key);
    if (cached != null) return UserGoals.fromMap(cached);

    if (!_firebaseReady) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .doc(NutritionFirestorePaths.nutritionGoalsDoc(userId))
          .get();
      if (!doc.exists || doc.data() == null) return null;
      final goals = UserGoals.fromMap(doc.data()!);
      await _local.writeJson(key, goals.toMap());
      return goals;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(UserGoals goals) async {
    final key = NutritionLocalKeys.userGoals(userId);
    await _local.writeJson(key, goals.toMap());

    if (!_firebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .doc(NutritionFirestorePaths.nutritionGoalsDoc(userId))
          .set(goals.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }
}
