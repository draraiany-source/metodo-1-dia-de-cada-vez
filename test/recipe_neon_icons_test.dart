import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/constants/seed_data.dart';
import 'package:metodo_1_dia/features/recipes/domain/recipe_image_resolver.dart';
import 'package:metodo_1_dia/features/recipes/domain/recipe_neon_icons.dart';

void main() {
  group('RecipeNeonIcons', () {
    test('pacote tem 40 ícones', () {
      expect(RecipeNeonIcons.all.length, 40);
    });

    test('arquivos PNG existem no disco', () {
      for (final path in RecipeNeonIcons.all) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });
  });

  group('RecipeImageResolver', () {
    test('todas as receitas do seed têm asset neon', () {
      for (final r in SeedData.recipes) {
        final asset = RecipeImageResolver.assetFor(r);
        expect(asset, startsWith('assets/images/recipes/neon/'),
            reason: r.id);
        expect(asset.contains('heart') || asset.contains('halter'), isFalse);
      }
    });

    test('assets por id são únicos entre si', () {
      final assets = SeedData.recipes
          .map((r) => RecipeImageResolver.assetFor(r))
          .toList();
      expect(assets.toSet().length, assets.length);
    });

    test('12 específicas + 1 fallback documentado', () {
      expect(SeedData.recipes.length, 13);
      expect(RecipeImageResolver.specificMatchIds.length, 12);
      expect(RecipeImageResolver.needsSpecificPhoto.length, 1);
      expect(RecipeImageResolver.needsSpecificPhoto.first.recipeId,
          'shake_chocolate');
    });
  });
}
