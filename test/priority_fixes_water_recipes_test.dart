import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/constants/seed_data.dart';
import 'package:metodo_1_dia/features/nutrition/domain/nutrition_models.dart';
import 'package:metodo_1_dia/features/recipes/domain/recipe_image_resolver.dart';

void main() {
  group('WaterCalculator', () {
    test('usa meta padrão sem peso', () {
      expect(WaterCalculator.goalGlassesFor(null), 8);
      expect(WaterCalculator.goalMlFor(null), 2000);
    });

    test('rejeita peso inválido (gramas / altura)', () {
      expect(WaterCalculator.sanitizeWeightKg(72000), isNull);
      expect(WaterCalculator.sanitizeWeightKg(1.65), isNull);
      expect(WaterCalculator.goalGlassesFor(72000), 8);
    });

    test('limita copos entre 4 e 16', () {
      expect(WaterCalculator.goalGlassesFor(40), inInclusiveRange(4, 16));
      expect(WaterCalculator.goalGlassesFor(120), inInclusiveRange(4, 16));
    });
  });

  group('RecipeImageResolver', () {
    test('todas as receitas do seed têm asset', () {
      for (final r in SeedData.recipes) {
        final asset = RecipeImageResolver.assetFor(r);
        expect(asset, isNotEmpty, reason: r.id);
      }
    });

    test('assets por id são únicos entre si', () {
      final assets = SeedData.recipes
          .map((r) => RecipeImageResolver.assetFor(r))
          .toList();
      expect(assets.toSet().length, assets.length);
    });
  });
}
