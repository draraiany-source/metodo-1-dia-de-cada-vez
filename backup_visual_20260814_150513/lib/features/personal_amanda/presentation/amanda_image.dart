import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/amanda_asset_models.dart';
import '../providers/amanda_assets_providers.dart';

/// Foto dinâmica da Amanda (Personal Trainer). Busca o asset ativo da
/// categoria pedida; se não houver nenhum cadastrado, mostra um placeholder
/// genérico (avatar com ícone) — **nunca** usa a arte da Lili, que é uma
/// personagem visualmente independente.
class AmandaImage extends ConsumerWidget {
  const AmandaImage({
    super.key,
    this.category = AmandaAssetCategory.principal,
    this.size = 96,
    this.shape = BoxShape.circle,
  });

  final AmandaAssetCategory category;
  final double size;
  final BoxShape shape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(amandaAssetsProvider);
    final asset = assetsAsync.maybeWhen(
      data: (all) => bestAmandaAssetFor(all, category),
      orElse: () => null,
    );

    if (asset != null && asset.url.isNotEmpty) {
      return ClipRRect(
        borderRadius: shape == BoxShape.circle
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: asset.url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(),
          errorWidget: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(16) : null,
      ),
      child: Icon(Icons.fitness_center,
          color: Colors.white, size: size * 0.45),
    );
  }
}
