import 'package:flutter/material.dart';

import '../mascot/lily_catalog.dart';
import '../mascot/mascot_widget.dart';
import 'lili_animated.dart';

/// Componente único para exibir a Lily com enquadramento padronizado.
///
/// Use em telas novas em vez de `Image.asset` manual.
/// Garante: `BoxFit.contain`, centro, margem de segurança e pose coerente.
class LilyCharacterWidget extends StatelessWidget {
  const LilyCharacterWidget({
    super.key,
    this.situation = LilySituation.welcome,
    this.height = 200,
    this.mood = LiliMood.viva,
    this.animated = true,
    this.semanticsLabel,
  });

  final LilySituation situation;
  final double height;
  final LiliMood mood;
  final bool animated;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final pose = LilyCatalog.poseFor(situation);
    final primary = LilyCatalog.organizedPath(situation);
    final fallback = LilyCatalog.fallbackAssetFor(situation);
    final label = semanticsLabel ?? LilyCatalog.labelFor(situation);

    final Widget child;
    if (animated) {
      child = AnimatedLiliMascot(
        pose: pose,
        mood: mood,
        height: height,
        fit: BoxFit.contain,
      );
    } else {
      child = Image.asset(
        primary,
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        semanticLabel: label,
        errorBuilder: (_, __, ___) => LiliFitMascot(
          pose: pose,
          height: height,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          assetPath: fallback,
          semanticsLabel: label,
        ),
      );
    }

    return Semantics(
      label: label,
      image: true,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (height * 0.04).clamp(4.0, 12.0),
            vertical: (height * 0.03).clamp(3.0, 10.0),
          ),
          child: child,
        ),
      ),
    );
  }
}
