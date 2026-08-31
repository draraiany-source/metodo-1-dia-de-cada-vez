import '../../domain/daily_log.dart';
import '../../domain/macro_totals.dart';
import '../../domain/meal.dart';
import '../../domain/meal_item.dart';
import '../../domain/nutrition_enums.dart';
import '../../domain/nutrition_models.dart';
import '../../domain/user_goals.dart';
import '../../domain/water_log_entry.dart';

/// Dados mockados do Dashboard B1 (Etapa 2 — sem persistencia real).
class NutritionDashboardMock {
  NutritionDashboardMock._();

  static DateTime todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static UserGoals goals() => UserGoals(
        calories: 2000,
        proteinG: 120,
        carbsG: 220,
        fatG: 65,
        waterMl: 2450,
        objective: NutritionObjective.manutencao,
        updatedAt: DateTime.now(),
        isManualOverride: false,
      );

  static DailyLog dailyLog() {
    final day = todayDate();
    return DailyLog(
      date: day,
      meals: [
        Meal(
          id: 'mock_cafe',
          mealType: MealType.cafeDaManha,
          recordedAt: day.add(const Duration(hours: 7, minutes: 45)),
          userConfirmed: true,
          items: const [
            MealItem(
              id: 'i1',
              name: 'Pao frances',
              quantity: 1,
              unit: FoodUnit.unit,
              weightGrams: 50,
              source: MealItemSource.userConfirmed,
              macros: MacroTotals(kcal: 140, proteinG: 4, carbsG: 28, fatG: 2),
            ),
            MealItem(
              id: 'i2',
              name: 'Cafe com leite',
              quantity: 1,
              unit: FoodUnit.cup,
              weightGrams: 200,
              source: MealItemSource.manual,
              macros: MacroTotals(kcal: 80, proteinG: 4, carbsG: 10, fatG: 3),
            ),
          ],
        ),
        Meal(
          id: 'mock_almoco',
          mealType: MealType.almoco,
          recordedAt: day.add(const Duration(hours: 12, minutes: 30)),
          userConfirmed: true,
          items: const [
            MealItem(
              id: 'i3',
              name: 'Arroz branco',
              quantity: 1,
              unit: FoodUnit.portion,
              weightGrams: 120,
              source: MealItemSource.userConfirmed,
              macros: MacroTotals(kcal: 156, proteinG: 3, carbsG: 34, fatG: 0),
            ),
            MealItem(
              id: 'i4',
              name: 'Feijao carioca',
              quantity: 1,
              unit: FoodUnit.portion,
              weightGrams: 100,
              source: MealItemSource.userConfirmed,
              macros: MacroTotals(kcal: 76, proteinG: 5, carbsG: 14, fatG: 0),
            ),
            MealItem(
              id: 'i5',
              name: 'Peito de frango grelhado',
              quantity: 1,
              unit: FoodUnit.portion,
              weightGrams: 120,
              source: MealItemSource.userConfirmed,
              macros: MacroTotals(kcal: 198, proteinG: 37, carbsG: 0, fatG: 4),
            ),
          ],
        ),
        Meal(
          id: 'mock_lanche',
          mealType: MealType.lancheDaTarde,
          recordedAt: day.add(const Duration(hours: 16)),
          userConfirmed: true,
          items: const [
            MealItem(
              id: 'i6',
              name: 'Iogurte natural',
              quantity: 1,
              unit: FoodUnit.unit,
              weightGrams: 170,
              source: MealItemSource.manual,
              macros: MacroTotals(kcal: 110, proteinG: 6, carbsG: 12, fatG: 3),
            ),
            MealItem(
              id: 'i7',
              name: 'Banana prata',
              quantity: 1,
              unit: FoodUnit.unit,
              weightGrams: 100,
              source: MealItemSource.manual,
              macros: MacroTotals(kcal: 89, proteinG: 1, carbsG: 23, fatG: 0),
            ),
          ],
        ),
      ],
      water: WaterLogEntry(
        date: day,
        consumedMl: 1200,
        goalMl: 2450,
        entries: [
          WaterIntakeEvent(
            ml: 300,
            at: day.add(const Duration(hours: 8)),
          ),
          WaterIntakeEvent(
            ml: 500,
            at: day.add(const Duration(hours: 12)),
          ),
          WaterIntakeEvent(
            ml: 400,
            at: day.add(const Duration(hours: 16)),
          ),
        ],
      ),
    );
  }
}

/// View model agregado para a tela B1.
class NutritionDashboardViewData {
  const NutritionDashboardViewData({
    required this.date,
    required this.goals,
    required this.log,
    this.isMock = true,
  });

  final DateTime date;
  final UserGoals goals;
  final DailyLog log;
  final bool isMock;

  MacroTotals get consumed => log.foodTotals;

  int get remainingKcal => (goals.calories - consumed.kcal).clamp(0, 99999);

  int get remainingProteinG => (goals.proteinG - consumed.proteinG).clamp(0, 99999);

  int get remainingCarbsG => (goals.carbsG - consumed.carbsG).clamp(0, 99999);

  int get remainingFatG => (goals.fatG - consumed.fatG).clamp(0, 99999);

  int get remainingWaterMl =>
      (goals.waterMl - log.water.consumedMl).clamp(0, 99999);

  double get calorieProgress =>
      goals.calories <= 0 ? 0 : consumed.kcal / goals.calories;

  static NutritionDashboardViewData mock() => NutritionDashboardViewData(
        date: NutritionDashboardMock.todayDate(),
        goals: NutritionDashboardMock.goals(),
        log: NutritionDashboardMock.dailyLog(),
      );
}
