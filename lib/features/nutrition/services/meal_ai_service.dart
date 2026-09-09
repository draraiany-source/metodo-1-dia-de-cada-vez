import '../data/calorie_vision_repository.dart';
import '../domain/food_analysis_models.dart';
import '../domain/meal_item.dart';
import '../domain/nutrition_enums.dart';

class MealAiAnalysisResult {
  const MealAiAnalysisResult({
    required this.items,
    required this.analysis,
    this.overallConfidence = AiConfidence.medium,
    this.notes,
  });

  final List<MealItem> items;
  final NutritionAnalysisResult analysis;
  final AiConfidence overallConfidence;
  final String? notes;
}

class MealAiService {
  MealAiService(this._vision);

  final CalorieVisionRepository _vision;

  bool get isAvailable => _vision.isAvailable;

  Future<MealAiAnalysisResult> analyzePhoto(List<int> imageBytes) async {
    final analysis = await _vision.analyzeMeal(imageBytes);
    final items = analysis.foods
        .map((f) => f.toMealItem(source: MealItemSource.iaEstimate))
        .toList();

    AiConfidence overall = AiConfidence.medium;
    if (items.isEmpty) {
      overall = AiConfidence.low;
    } else if (items.every((i) => i.aiConfidence == AiConfidence.high)) {
      overall = AiConfidence.high;
    } else if (items.any((i) => i.aiConfidence == AiConfidence.low)) {
      overall = AiConfidence.low;
    }

    return MealAiAnalysisResult(
      items: items,
      analysis: analysis,
      overallConfidence: overall,
      notes: analysis.notes,
    );
  }
}
