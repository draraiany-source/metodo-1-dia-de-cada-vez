import 'package:flutter/material.dart';

import '../design_system/app_spacing.dart';
import '../theme/app_colors.dart';

/// Banner ilustrativo de módulo — arte decorativa, sem dados reais.
///
/// Use `BoxFit.contain` por padrão para não deformar. Números desenhados
/// na arte NÃO substituem providers/estado do app.
class FeatureIllustrationBanner extends StatelessWidget {
  const FeatureIllustrationBanner({
    super.key,
    required this.assetPath,
    this.height = 160,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.semanticLabel,
  });

  final String assetPath;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.xl);
    // JPEG claros → fundo claro; dark arts → superfície escura.
    final bg = backgroundColor ??
        (assetPath.contains('_dark') || assetPath.contains('dark')
            ? AppColors.surface
            : const Color(0xFFFFF5FB));

    Widget child = ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: bg,
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Image.asset(
            assetPath,
            fit: fit,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );

    if (onTap != null) {
      child = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: child,
        ),
      );
    }

    if (semanticLabel != null) {
      child = Semantics(label: semanticLabel, image: true, child: child);
    }

    return child;
  }
}
