import 'package:flutter/material.dart';

import '../widgets/lili_widgets.dart' show MascotePose, LiliMascot;
import 'mascot_assets.dart';
import 'mascot_config.dart';
import 'mascot_sizes.dart';

export 'mascot_sizes.dart';
export 'mascot_assets.dart' show MascotAssets, MascotPose;

/// Escala visual da Lili conforme o papel na tela.
enum LiliDisplayRole {
  /// Avatar / chrome (pequeno).
  chrome,

  /// Header ao lado de texto.
  header,

  /// Card / dica / guia (~médio).
  card,

  /// Destaque principal da tela (35–50% da altura útil).
  hero,

  /// Splash, onboarding, conquistas (ainda maior).
  showcase,
}

/// ============================================================================
/// COMPONENTE ÚNICO DA MASCOTE LILI FIT
///
/// Use este widget em vez de tamanhos manuais espalhados.
/// `BoxFit.contain` por padrão — personagem inteira, sem deformar.
/// Sem moldura branca; fundo transparente (ou preto das artes oficiais).
/// ============================================================================
class LiliFitMascot extends StatelessWidget {
  const LiliFitMascot({
    super.key,
    this.pose = MascotePose.padrao,
    this.role = LiliDisplayRole.card,
    this.height,
    this.width,
    this.maxHeight,
    this.maxWidth,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.bottomCenter,
    this.semanticsLabel,
    /// Fração da altura da tela (0.35–0.50 nas telas principais).
    this.heightFraction,
    /// Caminho direto (poses extras: correndo, agachada, notebook…).
    this.assetPath,
    /// Quando true, envolve em preto para artes com fundo opaco.
    this.blackBackdrop = false,
  });

  final MascotePose pose;
  final LiliDisplayRole role;
  final double? height;
  final double? width;
  final double? maxHeight;
  final double? maxWidth;
  final BoxFit fit;
  final Alignment alignment;
  final String? semanticsLabel;
  final double? heightFraction;
  final String? assetPath;
  final bool blackBackdrop;

  double _resolveHeight(BuildContext context) {
    if (height != null) return height!;
    final screenH = MediaQuery.sizeOf(context).height;
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final isTablet = shortest >= 600;

    if (heightFraction != null) {
      return (screenH * heightFraction!).clamp(120.0, 420.0);
    }

    switch (role) {
      case LiliDisplayRole.chrome:
        return isTablet ? MascotSizes.avatar * 1.15 : MascotSizes.avatar;
      case LiliDisplayRole.header:
        return isTablet ? MascotSizes.header * 1.2 : MascotSizes.header;
      case LiliDisplayRole.card:
        return isTablet ? MascotSizes.medium * 1.15 : MascotSizes.medium;
      case LiliDisplayRole.hero:
        final frac = isTablet ? 0.36 : 0.42;
        return (screenH * frac).clamp(MascotSizes.heroMin, MascotSizes.heroMax);
      case LiliDisplayRole.showcase:
        final frac = isTablet ? 0.42 : 0.48;
        return (screenH * frac)
            .clamp(MascotSizes.showcaseMin, MascotSizes.showcaseMax);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _resolveHeight(context);
    final cappedH = maxHeight != null ? h.clamp(0.0, maxHeight!) : h;
    final cappedW = maxWidth;

    Widget image;
    final path = assetPath;
    if (path != null) {
      image = Image.asset(
        path,
        height: cappedH.toDouble(),
        width: cappedW?.toDouble() ?? width,
        fit: fit,
        filterQuality: FilterQuality.high,
        alignment: alignment,
        errorBuilder: (_, __, ___) => LiliMascot(
          pose: pose,
          height: cappedH.toDouble(),
          fit: fit,
        ),
      );
    } else if (!MascotConfig.useNewMascot) {
      image = LiliMascot(pose: pose, height: cappedH.toDouble(), fit: fit);
    } else {
      image = Image.asset(
        MascotAssets.resolve(pose),
        height: cappedH.toDouble(),
        width: cappedW?.toDouble() ?? width,
        fit: fit,
        filterQuality: FilterQuality.high,
        alignment: alignment,
        errorBuilder: (_, __, ___) => LiliMascot(
          pose: pose,
          height: cappedH.toDouble(),
          fit: fit,
        ),
      );
    }

    if (blackBackdrop) {
      image = ColoredBox(color: Colors.black, child: image);
    }

    if (semanticsLabel != null) {
      return Semantics(label: semanticsLabel, image: true, child: image);
    }
    return ExcludeSemantics(child: image);
  }
}

/// Alias legado — redireciona para [LiliFitMascot].
class MascotWidget extends StatelessWidget {
  const MascotWidget({
    super.key,
    this.pose = MascotePose.padrao,
    this.height = 220,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
  });

  final MascotePose pose;
  final double height;
  final BoxFit fit;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return LiliFitMascot(
      pose: pose,
      height: height,
      fit: fit,
      semanticsLabel: semanticsLabel,
      role: LiliDisplayRole.card,
    );
  }
}

/// Alias pedido no brief: `LiliMascot` reutilizável com role/tamanho.
/// (O widget estático de pose continua em `lili_widgets.dart` como [LiliMascot].)
typedef LiliMascotView = LiliFitMascot;
