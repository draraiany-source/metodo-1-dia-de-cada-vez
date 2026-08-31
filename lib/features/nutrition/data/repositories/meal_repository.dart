import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../../domain/daily_log.dart';
import '../../domain/meal.dart';
import '../../domain/nutrition_firestore_paths.dart';
import '../../domain/water_log_entry.dart';
import '../local/nutrition_local_store.dart';

class MealRepository {
  MealRepository({
    NutritionLocalStore? localStore,
    required this.userId,
  }) : _local = localStore ?? NutritionLocalStore();

  final NutritionLocalStore _local;
  final String userId;

  bool get _firebaseReady => FirebaseService.isReady && userId.isNotEmpty;

  Future<DailyLog> fetchDailyLog(DateTime day) async {
    final key = NutritionLocalStore.dailyLogKey(userId, day);
    final cached = await _local.readJson(key);
    if (cached != null) {
      return DailyLog.fromMap(cached);
    }

    if (_firebaseReady) {
      try {
        final dateKey = DailyLog.dayKey(day);
        final doc = await FirebaseFirestore.instance
            .doc(NutritionFirestorePaths.dailyLogDoc(userId, dateKey))
            .get();
        if (doc.exists && doc.data() != null) {
          final log = DailyLog.fromMap(doc.data()!);
          await _local.writeJson(key, log.toMap());
          return log;
        }
      } catch (_) {}
    }

    return DailyLog(
      date: DateTime(day.year, day.month, day.day),
      meals: const [],
      water: WaterLogEntry(
        date: DateTime(day.year, day.month, day.day),
        consumedMl: 0,
        goalMl: 2000,
      ),
    );
  }

  Future<void> saveDailyLog(DailyLog log) async {
    final key = NutritionLocalStore.dailyLogKey(userId, log.date);
    await _local.writeJson(key, log.toMap());

    if (!_firebaseReady) return;
    try {
      final dateKey = DailyLog.dayKey(log.date);
      await FirebaseFirestore.instance
          .doc(NutritionFirestorePaths.dailyLogDoc(userId, dateKey))
          .set(log.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> saveMeal(Meal meal) async {
    if (!meal.userConfirmed && meal.hasUnconfirmedAiItems) {
      throw StateError(
        'Refeicao com estimativa de IA deve ser confirmada antes de salvar.',
      );
    }

    final day = DateTime(
      meal.recordedAt.year,
      meal.recordedAt.month,
      meal.recordedAt.day,
    );
    final log = await fetchDailyLog(day);
    final meals = [...log.meals.where((m) => m.id != meal.id), meal];
    await saveDailyLog(
      DailyLog(date: log.date, meals: meals, water: log.water, syncedAt: log.syncedAt),
    );
  }

  Future<void> deleteMeal(String mealId, DateTime day) async {
    final log = await fetchDailyLog(day);
    final meals = log.meals.where((m) => m.id != mealId).toList();
    await saveDailyLog(
      DailyLog(date: log.date, meals: meals, water: log.water, syncedAt: log.syncedAt),
    );
  }
}
