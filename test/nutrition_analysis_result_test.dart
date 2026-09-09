import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/nutrition/domain/food_analysis_models.dart';

void main() {
  group('NutritionAnalysisResult.fromApiMap', () {
    test('parseia foods[] multi-alimento', () {
      final result = NutritionAnalysisResult.fromApiMap({
        'foods': [
          {
            'name': 'Arroz branco',
            'estimated_grams': 120,
            'calories': 156,
            'protein_g': 3.0,
            'carbs_g': 34.0,
            'fat_g': 0.4,
            'fiber_g': 0.5,
            'confidence': 0.86,
          },
          {
            'name': 'Frango grelhado',
            'estimated_grams': 150,
            'calories': 248,
            'protein_g': 40,
            'carbs_g': 0,
            'fat_g': 8,
            'fiber_g': 0,
            'confidence': 0.9,
          },
        ],
      });

      expect(result.foods.length, 2);
      expect(result.totals.kcal, 404);
      expect(result.totals.proteinG, 43);
      expect(result.foods.first.name, 'Arroz branco');
    });

    test('compatibilidade com formato legado', () {
      final result = NutritionAnalysisResult.fromApiMap({
        'name': 'Prato misto',
        'kcal': 500,
        'protein': 30,
        'carbs': 40,
        'fat': 15,
        'confidence': 'media',
      });

      expect(result.foods.length, 1);
      expect(result.totals.kcal, 500);
      expect(result.foods.first.name, 'Prato misto');
    });

    test('lista vazia não quebra', () {
      final result = NutritionAnalysisResult.fromApiMap({'foods': []});
      expect(result.isEmpty, isTrue);
      expect(result.totals.kcal, 0);
    });
  });
}
