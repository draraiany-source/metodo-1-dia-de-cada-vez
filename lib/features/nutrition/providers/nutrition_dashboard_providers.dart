import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/mock/nutrition_dashboard_mock.dart';
import '../domain/daily_log.dart';
import '../domain/nutrition_enums.dart';
import '../domain/user_goals.dart';
import '../domain/water_log_entry.dart';
import 'nutrition_ia_providers.dart';

UserGoals _fallbackGoals(Ref ref) {
  final user = ref.watch(currentUserProvider);
  final weight = user?.currentWeight;
  final heightM = user?.height;
  final age = user?.age;
  if (weight != null && heightM != null && age != null && age > 0) {
    return ref.read(goalsServiceProvider).suggest(
          weightKg: weight,
          heightCm: heightM * 100,
          age: age,
          sex: 'f',
          objective: NutritionObjective.manutencao,
        );
  }
  return UserGoals(
    calories: 2000,
    proteinG: 100,
    carbsG: 200,
    fatG: 65,
    waterMl: 2000,
    objective: NutritionObjective.manutencao,
    updatedAt: DateTime.now(),
    isManualOverride: false,
  );
}

/// Dashboard B1 — dados reais (local + Firestore via repositórios).
final nutritionDashboardProvider =
    FutureProvider.autoDispose<NutritionDashboardViewData>((ref) async {
  final meals = ref.watch(mealRepositoryProvider);
  final goalsRepo = ref.watch(userGoalsRepositoryProvider);

  final now = DateTime.now();
  final day = DateTime(now.year, now.month, now.day);

  final log = await meals.fetchDailyLog(day);
  final savedGoals = await goalsRepo.fetch();
  final goals = savedGoals ?? _fallbackGoals(ref);

  // Alinha a meta de água do log com a meta atual do perfil.
  final alignedLog = log.water.goalMl == goals.waterMl
      ? log
      : DailyLog(
          date: log.date,
          meals: log.meals,
          water: WaterLogEntry(
            date: log.water.date,
            consumedMl: log.water.consumedMl,
            goalMl: goals.waterMl,
            entries: log.water.entries,
          ),
          syncedAt: log.syncedAt,
        );

  return NutritionDashboardViewData(
    date: day,
    goals: goals,
    log: alignedLog,
    isMock: false,
  );
});
