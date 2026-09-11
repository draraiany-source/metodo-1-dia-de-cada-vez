import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../mascot/mascot_sizes.dart';
import 'lily_assets.dart';

/// Widget reutilizável da Lily Fit — nunca corta a personagem.
///
/// Sempre usa [BoxFit.contain], preserva proporção e decodifica com cache
/// adequado para Web/Android.
class LilyImage extends StatelessWidget {
  const LilyImage({
    super.key,
    required this.asset,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.hero = false,
  }) : assert(fit != BoxFit.cover && fit != BoxFit.fill,
            'Não use cover/fill — corta ou distorce a Lily.');

  final String asset;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  /// Quando true, altura = ~42% da tela (com teto [LilySizes.heroMax]).
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final resolvedH = height ??
        (hero
            ? (screenH * 0.42).clamp(MascotSizes.auth, LilySizes.heroMax)
            : LilySizes.medium);

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheH = (resolvedH * dpr * 1.5).round().clamp(128, 2048);

    Widget img = Image.asset(
      asset,
      height: resolvedH,
      width: width,
      fit: fit == BoxFit.cover || fit == BoxFit.fill ? BoxFit.contain : fit,
      alignment: alignment,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      isAntiAlias: true,
      cacheHeight: cacheH,
      semanticLabel: excludeFromSemantics ? null : semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      errorBuilder: (context, error, stack) {
        if (kDebugMode) {
          debugPrint('LilyImage falhou: $asset → $error');
        }
        return SizedBox(
          height: resolvedH,
          width: width ?? resolvedH * 0.7,
          child: const Icon(Icons.person_outline, size: 48),
        );
      },
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (resolvedH * 0.03).clamp(2.0, 12.0),
        vertical: (resolvedH * 0.02).clamp(2.0, 8.0),
      ),
      child: img,
    );
  }
}
