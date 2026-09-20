import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/widgets/premium_bottom_nav.dart';
import 'package:metodo_1_dia/features/nutrition/domain/food_analysis_models.dart';
import 'package:metodo_1_dia/features/nutrition/domain/nutrition_models.dart';
import 'package:metodo_1_dia/features/nutrition/providers/water_log_providers.dart';
import 'package:metodo_1_dia/features/weekly_challenge/domain/weekly_challenge_models.dart';

void main() {
  group('calorias por foto', () {
    test('placeholder 0 kcal é rejeitado', () {
      const result = NutritionAnalysisResult(foods: [
        FoodAnalysisItem(
          id: 'x',
          name: 'Refeição',
          estimatedGrams: 250,
          calories: 0,
          proteinG: 0,
          carbsG: 0,
          fatG: 0,
        ),
      ]);
      expect(result.looksLikePlaceholder, isTrue);
    });

    test('refeição real não é placeholder', () {
      const result = NutritionAnalysisResult(foods: [
        FoodAnalysisItem(
          id: 'x',
          name: 'Arroz com frango',
          estimatedGrams: 250,
          calories: 420,
          proteinG: 32,
          carbsG: 40,
          fatG: 10,
        ),
      ]);
      expect(result.looksLikePlaceholder, isFalse);
    });
  });

  group('hidratação', () {
    test('meta personalizada prevalece sobre o peso', () {
      const day = WaterDayState(customGoalMl: 3000);
      expect(day.effectiveGoalMl(70), 3000);
      expect(day.effectiveGoalGlasses(70), greaterThan(0));
    });

    test('sem override usa 35 ml/kg', () {
      const day = WaterDayState();
      expect(day.effectiveGoalMl(70), WaterCalculator.goalMlFor(70));
    });
  });

  group('desafio semanal', () {
    test('dia futuro não é selecionável', () {
      final today = DateTime(2026, 9, 19);
      expect(
        WeeklyChallengeProgress.isSelectableDay(
          DateTime(2026, 9, 20),
          today,
        ),
        isFalse,
      );
      expect(
        WeeklyChallengeProgress.isSelectableDay(
          DateTime(2026, 9, 19),
          today,
        ),
        isTrue,
      );
    });
  });

  group('navegação inferior', () {
    test('nutrition e habits não ficam no Início por engano', () {
      expect(indexForLocation('/nutrition'), 2);
      expect(indexForLocation('/nutrition/calorie-scanner'), 2);
      expect(indexForLocation('/habits'), 0);
      expect(indexForLocation('/home'), 0);
      expect(indexForLocation('/workouts'), 1);
    });
  });
}
