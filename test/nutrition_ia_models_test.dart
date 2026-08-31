import 'package:flutter_test/flutter_test.dart';

import 'package:metodo_1_dia/features/nutrition/domain/daily_log.dart';
import 'package:metodo_1_dia/features/nutrition/domain/macro_totals.dart';
import 'package:metodo_1_dia/features/nutrition/domain/meal.dart';
import 'package:metodo_1_dia/features/nutrition/domain/meal_item.dart';
import 'package:metodo_1_dia/features/nutrition/domain/nutrition_enums.dart';
import 'package:metodo_1_dia/features/nutrition/domain/nutrition_models.dart';
import 'package:metodo_1_dia/features/nutrition/domain/water_log_entry.dart';
import 'package:metodo_1_dia/features/nutrition/services/goals_service.dart';
import 'package:metodo_1_dia/features/nutrition/services/nutrition_calculation_service.dart';
import 'package:metodo_1_dia/features/nutrition/domain/food_database_models.dart';

void main() {
  test('MealItem confirmByUser altera source para userConfirmed', () {
    const item = MealItem(
      id: '1',
      name: 'Arroz',
      quantity: 1,
      unit: FoodUnit.portion,
      weightGrams: 100,
      source: MealItemSource.iaEstimate,
      macros: MacroTotals(kcal: 130, proteinG: 2, carbsG: 28, fatG: 0),
    );
    expect(item.confirmByUser().source, MealItemSource.userConfirmed);
  });

  test('Meal serializa e desserializa', () {
    final meal = Meal(
      id: 'm1',
      mealType: MealType.almoco,
      recordedAt: DateTime(2026, 8, 30, 12, 30),
      userConfirmed: true,
      items: [
        MealItem(
          id: 'i1',
          name: 'Feijao',
          quantity: 1,
          unit: FoodUnit.portion,
          weightGrams: 100,
          source: MealItemSource.userConfirmed,
          macros: const MacroTotals(kcal: 76, proteinG: 5, carbsG: 14, fatG: 0),
        ),
      ],
    );
    final back = Meal.fromMap(meal.toMap());
    expect(back.id, 'm1');
    expect(back.items.length, 1);
    expect(back.totals.kcal, 76);
  });

  test('DailyLog agrega macros das refeicoes', () {
    final log = DailyLog(
      date: DateTime(2026, 8, 30),
      meals: [
        Meal(
          id: 'a',
          mealType: MealType.cafeDaManha,
          recordedAt: DateTime(2026, 8, 30, 8),
          userConfirmed: true,
          items: [
            MealItem(
              id: '1',
              name: 'Banana',
              quantity: 1,
              unit: FoodUnit.unit,
              weightGrams: 100,
              source: MealItemSource.manual,
              macros: const MacroTotals(kcal: 89),
            ),
          ],
        ),
      ],
      water: WaterLogEntry(
        date: DateTime(2026, 8, 30),
        consumedMl: 500,
        goalMl: 2000,
      ),
    );
    expect(log.foodTotals.kcal, 89);
    expect(DailyLog.fromMap(log.toMap()).foodTotals.kcal, 89);
  });

  test('GoalsService retorna metas dentro de faixa razoavel', () {
    final goals = GoalsService().suggest(
      weightKg: 70,
      heightCm: 165,
      age: 30,
      sex: 'f',
      objective: NutritionObjective.manutencao,
      activityLevel: 'moderado',
    );
    expect(goals.calories, inInclusiveRange(1400, 2800));
    expect(goals.waterMl, greaterThan(1500));
  });

  test('NutritionCalculationService escala macros por peso', () async {
    const food = FoodItem(
      id: 'test',
      name: 'Teste',
      category: FoodCategory.frutas,
      kcal: 100,
      protein: 1,
      carbs: 20,
      fat: 0,
      gramWeight: 100,
    );
    final calc = NutritionCalculationService();
    final half = calc.macrosForFood(food, weightGrams: 50);
    expect(half.kcal, 50);
  });
}
