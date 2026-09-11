import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'lily_treino_assets.dart';

/// Imagem de exercício Lily Fit — nunca corta cabeça/mãos/pés/equipamento.
///
/// Sempre [BoxFit.contain]. Preferir [LilyTreinoAssets.resolve] para o asset.
class LilyTreinoImage extends StatelessWidget {
  const LilyTreinoImage({
    super.key,
    required this.asset,
    this.height,
    this.width,
    this.maxHeight,
    this.maxWidth,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.padding,
  }) : assert(
          fit != BoxFit.cover && fit != BoxFit.fill,
          'Não use cover/fill — corta ou distorce a Lily.',
        );

  /// Atalho: resolve pelo nome do exercício.
  factory LilyTreinoImage.forExercise(
    String? exerciseName, {
    Key? key,
    double? height,
    double? width,
    double? maxHeight,
    double? maxWidth,
    Alignment alignment = Alignment.center,
    int genericSeed = 0,
  }) {
    return LilyTreinoImage(
      key: key,
      asset: LilyTreinoAssets.resolve(exerciseName, genericSeed: genericSeed),
      height: height,
      width: width,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      alignment: alignment,
      semanticLabel: exerciseName,
    );
  }

  final String asset;
  final double? height;
  final double? width;
  final double? maxHeight;
  final double? maxWidth;
  final BoxFit fit;
  final Alignment alignment;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final resolvedH = height ??
        (maxHeight != null
            ? null
            : (screen.height * 0.28).clamp(120.0, 320.0));
    final safeFit =
        (fit == BoxFit.cover || fit == BoxFit.fill) ? BoxFit.contain : fit;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheBase = resolvedH ?? maxHeight ?? 280;
    final cacheH = (cacheBase * dpr * 1.4).round().clamp(128, 2048);

    Widget img = Image.asset(
      asset,
      height: resolvedH,
      width: width,
      fit: safeFit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      isAntiAlias: true,
      cacheHeight: cacheH,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stack) {
        if (kDebugMode) {
          debugPrint('LilyTreinoImage falhou: $asset → $error');
        }
        return SizedBox(
          height: resolvedH ?? 160,
          width: width ?? 120,
          child: const Icon(Icons.fitness_center_outlined, size: 40),
        );
      },
    );

    if (maxWidth != null || maxHeight != null) {
      img = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: img,
      );
    }

    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: ((resolvedH ?? 200) * 0.03).clamp(2.0, 12.0),
            vertical: ((resolvedH ?? 200) * 0.02).clamp(2.0, 8.0),
          ),
      child: img,
    );
  }
}