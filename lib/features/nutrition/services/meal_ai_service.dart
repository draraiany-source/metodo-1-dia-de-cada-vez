import '../data/calorie_vision_repository.dart';
import '../domain/macro_totals.dart';
import '../domain/meal_item.dart';
import '../domain/nutrition_enums.dart';

class MealAiAnalysisResult {
  const MealAiAnalysisResult({
    required this.items,
    this.overallConfidence = AiConfidence.medium,
    this.notes,
  });

  final List<MealItem> items;
  final AiConfidence overallConfidence;
  final String? notes;
}

class MealAiService {
  MealAiService(this._legacyVision);

  final CalorieVisionRepository _legacyVision;

  bool get isAvailable => _legacyVision.isAvailable;

  Future<MealAiAnalysisResult> analyzePhoto(List<int> imageBytes) async {
    final estimate = await _legacyVision.estimate(imageBytes);
    final item = MealItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: estimate.name,
      quantity: 1,
      unit: FoodUnit.portion,
      weightGrams: 100,
      source: MealItemSource.iaEstimate,
      macros: MacroTotals(
        kcal: estimate.kcal,
        proteinG: estimate.protein,
        carbsG: estimate.carbs,
        fatG: estimate.fat,
      ),
      aiConfidence: _mapConfidence(estimate.confidence),
      notes: estimate.detalhe,
    );
    return MealAiAnalysisResult(
      items: [item],
      overallConfidence: item.aiConfidence ?? AiConfidence.medium,
      notes: estimate.detalhe,
    );
  }

  AiConfidence _mapConfidence(String raw) {
    return switch (raw.toLowerCase()) {
      'alta' || 'high' => AiConfidence.high,
      'media' || 'medium' => AiConfidence.medium,
      _ => AiConfidence.low,
    };
  }
}
