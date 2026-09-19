import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/services/cloud_function_http.dart';
import 'package:metodo_1_dia/features/nutrition/data/calorie_vision_repository.dart';
import 'package:metodo_1_dia/features/nutrition/domain/food_analysis_models.dart';

void main() {
  group('resposta da Function', () {
    test('extrai error sem stack', () {
      expect(
        functionErrorMessage('{"error":"A análise ainda não está configurada."}'),
        'A análise ainda não está configurada.',
      );
      expect(functionErrorMessage('not-json'), isNull);
      expect(functionErrorMessage('{"ok":true}'), isNull);
    });

    test('placeholder antigo da Amanda é rejeitado', () {
      expect(
        looksLikeAmandaPlaceholder(
          'Estou aqui com você 💜 (Amanda em modo básico — configure a chave da OpenAI na Cloud Function para respostas completas.)',
        ),
        isTrue,
      );
      expect(
        looksLikeAmandaPlaceholder('Vamos com calma, um dia de cada vez. 💜'),
        isFalse,
      );
    });
  });

  group('foto da refeição', () {
    test('placeholder 0 kcal continua rejeitado', () {
      final result = NutritionAnalysisResult.fromApiMap({
        'name': 'Refeição',
        'kcal': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'detalhe': 'Chave da OpenAI não configurada',
      });
      expect(result.looksLikePlaceholder, isTrue);
    });

    test('resultado estruturado tem alimento, quantidade e macros', () {
      final result = NutritionAnalysisResult.fromApiMap({
        'foods': [
          {
            'name': 'Arroz',
            'estimated_grams': 150,
            'calories': 195,
            'protein_g': 4,
            'carbs_g': 43,
            'fat_g': 0.4,
            'confidence': 0.8,
          },
        ],
        'detalhe': 'Estimativa a partir da foto.',
      });
      expect(result.looksLikePlaceholder, isFalse);
      expect(result.foods.single.name, 'Arroz');
      expect(result.foods.single.estimatedGrams, 150);
      expect(result.totals.kcal, 195);
      expect(result.totals.proteinG, 4);
      expect(result.notes, 'Estimativa a partir da foto.');
    });

    test('limite de bytes da foto no cliente', () {
      expect(kMaxMealPhotoBytes, 1200 * 1024);
    });
  });
}
