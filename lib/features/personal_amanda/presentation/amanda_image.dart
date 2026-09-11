import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/amanda/amanda_photos.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/amanda_asset_models.dart';
import '../providers/amanda_assets_providers.dart';

/// Foto dinâmica da Amanda. Lê o asset ativo da categoria; se não houver,
/// usa o pacote local WebP — nunca a arte da Lily.
class AmandaImage extends ConsumerWidget {
  const AmandaImage({
    super.key,
    this.category = AmandaAssetCategory.principal,
    this.size = 96,
    this.width,
    this.height,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.fallbacks = const [],
    this.assetIndex = 0,
    this.placeholderIcon = Icons.person_rounded,
    this.useLocalFallback = true,
  });

  final AmandaAssetCategory category;
  final double size;
  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final List<AmandaAssetCategory> fallbacks;
  final int assetIndex;
  final IconData placeholderIcon;
  final bool useLocalFallback;

  double get _w => width ?? size;
  double get _h => height ?? size;

  BorderRadius get _radius {
    if (borderRadius != null) return borderRadius!;
    if (shape == BoxShape.circle) return BorderRadius.circular(_w / 2);
    return BorderRadius.circular(18);
  }

  String? _resolveLocal() {
    if (!useLocalFallback) return null;
    final primary = AmandaPhotos.localFor(category.name, index: assetIndex);
    if (primary != null) return primary;
    for (final fb in fallbacks) {
      final path = AmandaPhotos.localFor(fb.name, index: 0);
      if (path != null) return path;
    }
    return AmandaPhotos.profile;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(amandaAssetsProvider);
    final asset = assetsAsync.maybeWhen(
      data: (all) {
        if (assetIndex > 0) {
          return amandaAssetAt(all, category, assetIndex);
        }
        return bestAmandaAssetFor(all, category, fallbacks: fallbacks);
      },
      orElse: () => null,
    );

    if (asset != null && asset.url.isNotEmpty) {
      return ClipRRect(
        borderRadius: _radius,
        child: SizedBox(
          width: _w.isFinite ? _w : null,
          height: _h.isFinite ? _h : null,
          child: CachedNetworkImage(
            imageUrl: asset.url,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
            alignment: Alignment.topCenter,
            placeholder: (_, __) => _placeholder(),
            errorWidget: (_, __, ___) => _localOrPlaceholder(),
          ),
        ),
      );
    }
    return _localOrPlaceholder();
  }

  Widget _localOrPlaceholder() {
    final local = _resolveLocal();
    if (local == null) return _placeholder();
    return ClipRRect(
      borderRadius: _radius,
      child: SizedBox(
        width: _w.isFinite ? _w : null,
        height: _h.isFinite ? _h : null,
        child: Image.asset(
          local,
          width: double.infinity,
          height: double.infinity,
          fit: fit,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width ?? size,
      height: height ?? size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A1224),
            Color(0xFF1A1028),
            Color(0xFF12101C),
          ],
        ),
        borderRadius: _radius,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        placeholderIcon,
        color: AppColors.secondary.withOpacity(0.55),
        size: (_h.isFinite ? (_h * 0.32).clamp(22.0, 56.0) : 40.0),
      ),
    );
  }
}
