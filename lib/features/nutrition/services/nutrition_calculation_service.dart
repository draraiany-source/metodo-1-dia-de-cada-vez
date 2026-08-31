import '../domain/food_database_models.dart';
import '../domain/macro_totals.dart';
import '../domain/meal_item.dart';
import '../domain/nutrition_enums.dart';

class NutritionCalculationService {
  MacroTotals macrosForFood(FoodItem food, {required double weightGrams}) {
    if (weightGrams <= 0 || food.gramWeight <= 0) return MacroTotals.zero;
    final factor = weightGrams / food.gramWeight;
    return MacroTotals(
      kcal: (food.kcal * factor).round(),
      proteinG: (food.protein * factor).round(),
      carbsG: (food.carbs * factor).round(),
      fatG: (food.fat * factor).round(),
      fiberG: (food.fiber * factor).round(),
    );
  }

  MealItem itemFromFood({
    required FoodItem food,
    required double weightGrams,
    required FoodUnit unit,
    double quantity = 1,
    MealItemSource source = MealItemSource.manual,
    String? id,
  }) {
    return MealItem(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      foodId: food.id,
      name: food.name,
      quantity: quantity,
      unit: unit,
      weightGrams: weightGrams,
      source: source,
      macros: macrosForFood(food, weightGrams: weightGrams),
    );
  }

  double progressRatio(int consumed, int goal) {
    if (goal <= 0) return 0;
    return (consumed / goal).clamp(0.0, 1.5);
  }

  String macroProgressLabel({
    required String nutrient,
    required int consumed,
    required int goal,
  }) {
    if (goal <= 0) return '$nutrient: $consumed';
    final pct = ((consumed / goal) * 100).round();
    return '$pct% da meta de $nutrient';
  }
}
