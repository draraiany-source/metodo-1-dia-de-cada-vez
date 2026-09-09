import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/seed_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/recipe_image_resolver.dart';
import '../../domain/recipe_neon_icons.dart';

/// Capa da receita: rede → ícone neon específico → categoria → placeholder neon.
/// Sem emoji, coração, halter ou imagem de treino.
class RecipeCoverImage extends StatelessWidget {
  const RecipeCoverImage({
    super.key,
    required this.recipe,
    this.fit,
  });

  final Recipe recipe;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final network = RecipeImageResolver.networkUrl(recipe);
    if (network != null) {
      return CachedNetworkImage(
        imageUrl: network,
        fit: fit ?? BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (_, __, ___) => _AssetCover(recipe: recipe, fit: fit),
      );
    }
    return _AssetCover(recipe: recipe, fit: fit);
  }
}

class _AssetCover extends StatelessWidget {
  const _AssetCover({required this.recipe, this.fit});

  final Recipe recipe;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final asset = RecipeImageResolver.assetFor(recipe);
    final contain = RecipeImageResolver.useContainFit(asset);
    final resolvedFit = fit ?? (contain ? BoxFit.contain : BoxFit.cover);

    return ColoredBox(
      color: AppColors.surface2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (contain)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2A1B3D),
                    Color(0xFF1A1228),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(contain ? 10 : 0),
            child: Image.asset(
              asset,
              fit: resolvedFit,
              errorBuilder: (_, __, ___) => Image.asset(
                RecipeNeonIcons.placeholder,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
