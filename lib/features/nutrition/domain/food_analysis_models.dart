import 'macro_totals.dart';
import 'meal_item.dart';
import 'nutrition_enums.dart';

/// Alimento identificado (ou editado) na análise de refeição por IA.
class FoodAnalysisItem {
  const FoodAnalysisItem({
    required this.id,
    required this.name,
    required this.estimatedGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.confidence = 0.5,
  });

  final String id;
  final String name;
  final double estimatedGrams;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double confidence;

  FoodAnalysisItem copyWith({
    String? id,
    String? name,
    double? estimatedGrams,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
    double? confidence,
  }) =>
      FoodAnalysisItem(
        id: id ?? this.id,
        name: name ?? this.name,
        estimatedGrams: estimatedGrams ?? this.estimatedGrams,
        calories: calories ?? this.calories,
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
        fiberG: fiberG ?? this.fiberG,
        confidence: confidence ?? this.confidence,
      );

  MacroTotals get macros => MacroTotals(
        kcal: calories,
        proteinG: proteinG.round(),
        carbsG: carbsG.round(),
        fatG: fatG.round(),
        fiberG: fiberG.round(),
      );

  MealItem toMealItem({MealItemSource source = MealItemSource.iaEstimate}) {
    return MealItem(
      id: id,
      name: name,
      quantity: estimatedGrams,
      unit: FoodUnit.gram,
      weightGrams: estimatedGrams,
      source: source,
      macros: macros,
      aiConfidence: _confidenceToAi(confidence),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'estimated_grams': estimatedGrams,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'confidence': confidence,
      };

  factory FoodAnalysisItem.fromMap(Map<String, dynamic> m, {String? id}) {
    final confRaw = m['confidence'];
    var conf = 0.5;
    if (confRaw is num) {
      conf = confRaw.toDouble();
      if (conf > 1) conf = conf / 100;
    } else if (confRaw is String) {
      conf = switch (confRaw.toLowerCase()) {
        'alta' || 'high' => 0.85,
        'media' || 'medium' => 0.6,
        _ => 0.35,
      };
    }

    return FoodAnalysisItem(
      id: id ??
          '${DateTime.now().microsecondsSinceEpoch}_${m['name']?.hashCode ?? 0}',
      name: (m['name'] ?? m['food'] ?? 'Alimento').toString(),
      estimatedGrams:
          ((m['estimated_grams'] ?? m['grams'] ?? m['weightGrams'] ?? 100)
                  as num)
              .toDouble(),
      calories: ((m['calories'] ?? m['kcal'] ?? 0) as num).round(),
      proteinG: ((m['protein_g'] ?? m['protein'] ?? 0) as num).toDouble(),
      carbsG: ((m['carbs_g'] ?? m['carbs'] ?? 0) as num).toDouble(),
      fatG: ((m['fat_g'] ?? m['fat'] ?? 0) as num).toDouble(),
      fiberG: ((m['fiber_g'] ?? m['fiber'] ?? 0) as num).toDouble(),
      confidence: conf.clamp(0.0, 1.0),
    );
  }

  static AiConfidence _confidenceToAi(double c) {
    if (c >= 0.75) return AiConfidence.high;
    if (c >= 0.45) return AiConfidence.medium;
    return AiConfidence.low;
  }
}

/// Resultado estruturado da análise de refeição (visão/IA).
class NutritionAnalysisResult {
  const NutritionAnalysisResult({
    required this.foods,
    this.notes,
  });

  final List<FoodAnalysisItem> foods;
  final String? notes;

  MacroTotals get totals =>
      foods.fold(MacroTotals.zero, (sum, f) => sum + f.macros);

  bool get isEmpty => foods.isEmpty;

  NutritionAnalysisResult copyWithFoods(List<FoodAnalysisItem> foods) =>
      NutritionAnalysisResult(foods: foods, notes: notes);

  factory NutritionAnalysisResult.fromApiMap(Map<String, dynamic> data) {
    if (data['foods'] is List) {
      final list = <FoodAnalysisItem>[];
      var i = 0;
      for (final raw in data['foods'] as List) {
        if (raw is! Map) continue;
        list.add(FoodAnalysisItem.fromMap(
          Map<String, dynamic>.from(raw),
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_$i',
        ));
        i++;
      }
      return NutritionAnalysisResult(
        foods: list,
        notes: data['detalhe'] as String? ?? data['notes'] as String?,
      );
    }

    // Compatibilidade com resposta antiga (prato único).
    if (data['name'] != null || data['kcal'] != null) {
      return NutritionAnalysisResult(
        foods: [
          FoodAnalysisItem.fromMap({
            'name': data['name'] ?? 'Refeição',
            'estimated_grams': data['estimated_grams'] ?? 250,
            'calories': data['kcal'] ?? data['calories'] ?? 0,
            'protein_g': data['protein'] ?? data['protein_g'] ?? 0,
            'carbs_g': data['carbs'] ?? data['carbs_g'] ?? 0,
            'fat_g': data['fat'] ?? data['fat_g'] ?? 0,
            'fiber_g': data['fiber'] ?? data['fiber_g'] ?? 0,
            'confidence': data['confidence'] ?? 'media',
          }, id: 'ai_${DateTime.now().millisecondsSinceEpoch}'),
        ],
        notes: data['detalhe'] as String?,
      );
    }

    return const NutritionAnalysisResult(foods: []);
  }
}

/// Entrada persistida no diário (Firestore `nutritionDiary`).
class NutritionDiaryEntry {
  const NutritionDiaryEntry({
    required this.id,
    required this.mealType,
    required this.date,
    required this.createdAt,
    required this.foods,
    required this.totalCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    this.imageUrl,
    this.source = 'ai_food_scan',
  });

  final String id;
  final String mealType;
  final String date;
  final DateTime createdAt;
  final String? imageUrl;
  final String source;
  final List<Map<String, dynamic>> foods;
  final int totalCalories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int fiberG;

  Map<String, dynamic> toFirestore() => {
        'mealType': mealType,
        'date': date,
        'createdAt': createdAt.toIso8601String(),
        if (imageUrl != null) 'imageUrl': imageUrl,
        'source': source,
        'foods': foods,
        'totalCalories': totalCalories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'fiberG': fiberG,
      };
}
