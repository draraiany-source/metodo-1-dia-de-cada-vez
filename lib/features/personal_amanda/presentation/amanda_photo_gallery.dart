import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/amanda_asset_models.dart';
import 'amanda_image.dart';

/// Grade de fotos com placeholders quando ainda não há cadastro.
class AmandaPhotoGallery extends StatelessWidget {
  const AmandaPhotoGallery({
    super.key,
    required this.category,
    this.count = 3,
    this.aspectRatio = 0.82,
    this.fallbacks = const [],
  });

  final AmandaAssetCategory category;
  final int count;
  final double aspectRatio;
  final List<AmandaAssetCategory> fallbacks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final gap = 10.0;
      final n = count.clamp(2, 4);
      final w = (c.maxWidth - gap * (n - 1)) / n;
      return Row(
        children: [
          for (var i = 0; i < n; i++) ...[
            if (i > 0) SizedBox(width: gap),
            SizedBox(
              width: w,
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: AmandaImage(
                  category: category,
                  fallbacks: fallbacks,
                  assetIndex: i,
                  width: w,
                  height: w / aspectRatio,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  fit: BoxFit.cover,
                  placeholderIcon: Icons.add_photo_alternate_outlined,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class AmandaPhotoSection extends StatelessWidget {
  const AmandaPhotoSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12.5, height: 1.35)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class AmandaMainPortrait extends StatelessWidget {
  const AmandaMainPortrait({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final height = (w * 0.95).clamp(220.0, 360.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: AmandaImage(
        category: AmandaAssetCategory.profissional,
        fallbacks: const [
          AmandaAssetCategory.principal,
          AmandaAssetCategory.banner,
        ],
        width: w,
        height: height,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        fit: BoxFit.cover,
        placeholderIcon: Icons.person_outline_rounded,
      ),
    );
  }
}
