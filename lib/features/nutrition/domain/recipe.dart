import 'macro_totals.dart';
import 'meal_item.dart';

class NutritionRecipe {
  const NutritionRecipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.servings,
    this.instructions,
    this.createdAt,
  });

  final String id;
  final String name;
  final List<MealItem> ingredients;
  final int servings;
  final String? instructions;
  final DateTime? createdAt;

  MacroTotals get totalMacros =>
      ingredients.fold(MacroTotals.zero, (sum, i) => sum + i.macros);

  MacroTotals get perServingMacros {
    if (servings <= 0) return totalMacros;
    return totalMacros.scale(1 / servings);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
        'servings': servings,
        'totalMacros': totalMacros.toMap(),
        'perServingMacros': perServingMacros.toMap(),
        if (instructions != null) 'instructions': instructions,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory NutritionRecipe.fromMap(Map<String, dynamic> m) {
    final raw = m['ingredients'] as List<dynamic>? ?? [];
    return NutritionRecipe(
      id: m['id'] as String,
      name: (m['name'] ?? '') as String,
      ingredients: raw
          .map((e) => MealItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      servings: ((m['servings'] ?? 1) as num).round().clamp(1, 999),
      instructions: m['instructions'] as String?,
      createdAt: m['createdAt'] != null
          ? DateTime.parse(m['createdAt'] as String)
          : null,
    );
  }
}
