import 'package:flutter/material.dart';

import '../widgets/lili_widgets.dart';
import 'mascot_assets.dart';
import 'mascot_config.dart';

/// ============================================================================
/// WIDGET CENTRAL DA MASCOTE (§9/§14).
///
/// Ponto único de renderização. Cadeia de fallback garantida — o app NUNCA
/// exibe ícone quebrado por asset ausente:
///
///   useNewMascot == false → [LiliMascot] (camada dinâmica + poses locais
///                            atuais, comportamento idêntico ao de hoje);
///   useNewMascot == true  → nova arte em assets/mascot/png/; se a pose ainda
///                            não tiver arte nova, `errorBuilder` cai
///                            automaticamente no [LiliMascot] legado.
///
/// Uso: `MascotWidget(pose: MascotPose.celebrando, height: 160)`.
/// ============================================================================
class MascotWidget extends StatelessWidget {
  const MascotWidget({
    super.key,
    this.pose = MascotePose.padrao,
    this.height = 220,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
  });

  final MascotPose pose;
  final double height;
  final BoxFit fit;

  /// Descrição para leitores de tela quando a mascote transmite informação.
  /// Se nulo, a imagem é tratada como decorativa (excluída da semântica).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (!MascotConfig.useNewMascot) {
      child = LiliMascot(pose: pose, height: height, fit: fit);
    } else {
      child = Image.asset(
        MascotAssets.newPath(pose),
        height: height,
        fit: fit,
        // Pose nova ausente → fallback silencioso para a arte legada.
        errorBuilder: (_, __, ___) =>
            LiliMascot(pose: pose, height: height, fit: fit),
      );
    }

    if (semanticsLabel != null) {
      return Semantics(label: semanticsLabel, image: true, child: child);
    }
    return ExcludeSemantics(child: child);
  }
}
