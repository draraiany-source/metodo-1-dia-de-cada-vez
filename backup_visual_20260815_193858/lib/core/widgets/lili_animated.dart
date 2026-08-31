import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mascot/mascot_sizes.dart';
import 'lili_widgets.dart';

/// Estados vivos da mascote.
///
/// **Nota de implementação**: estas animações são feitas em Flutter puro sobre
/// as poses PNG existentes — não dependem de arquivos Rive. Quando você exportar
/// os `.riv` do editor Rive, o `RiveHelper` assume e estas viram fallback.
enum LiliMood {
  /// Respiração sutil, contínua. Padrão para telas paradas.
  respirando,

  /// Respirando + piscadas periódicas (troca sutil de escala vertical).
  viva,

  /// Pulinho de comemoração (para conquistas).
  comemorando,

  /// Balanço rítmico simulando passada.
  correndo,

  /// Balanço lento e suave (meditação, calma).
  calma,

  /// Sem animação (uso em listas/avatares pequenos).
  estatica,
}

/// Mascote animada. Envolve [LiliMascot] com um "sopro de vida".
///
/// ```dart
/// AnimatedLiliMascot(pose: MascotePose.celebrando, mood: LiliMood.comemorando)
/// ```
class AnimatedLiliMascot extends StatefulWidget {
  const AnimatedLiliMascot({
    super.key,
    required this.pose,
    this.mood = LiliMood.respirando,
    this.height = MascotSizes.medium,
    this.fit = BoxFit.contain,
  });

  final MascotePose pose;
  final LiliMood mood;
  final double height;
  final BoxFit fit;

  @override
  State<AnimatedLiliMascot> createState() => _AnimatedLiliMascotState();
}

class _AnimatedLiliMascotState extends State<AnimatedLiliMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  Duration get _duration => switch (widget.mood) {
        LiliMood.respirando => const Duration(milliseconds: 3200),
        LiliMood.viva => const Duration(milliseconds: 3600),
        LiliMood.comemorando => const Duration(milliseconds: 900),
        LiliMood.correndo => const Duration(milliseconds: 600),
        LiliMood.calma => const Duration(milliseconds: 5000),
        LiliMood.estatica => const Duration(milliseconds: 1),
      };

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _duration);
    if (widget.mood != LiliMood.estatica) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant AnimatedLiliMascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _c.duration = _duration;
      if (widget.mood == LiliMood.estatica) {
        _c.stop();
      } else if (!_c.isAnimating) {
        _c.repeat();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascot = LiliMascot(
      pose: widget.pose,
      height: widget.height,
      fit: widget.fit,
    );
    if (widget.mood == LiliMood.estatica) return mascot;

    // Acessibilidade: se a usuária ativou "reduzir movimento" no sistema,
    // não animamos (e paramos o controller para poupar bateria). A Lili
    // continua visível, apenas estática.
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      if (_c.isAnimating) _c.stop();
      return mascot;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value; // 0..1
        final onda = math.sin(t * 2 * math.pi); // -1..1

        switch (widget.mood) {
          case LiliMood.respirando:
          case LiliMood.calma:
            // Peito sobe/desce: escala vertical mínima + leve subida.
            return Transform.translate(
              offset: Offset(0, -onda * 2),
              child: Transform.scale(
                scaleY: 1 + onda * 0.012,
                scaleX: 1 - onda * 0.004,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            );

          case LiliMood.viva:
            // Respiração + "piscada": achata rapidíssimo perto do fim do ciclo.
            final piscando = t > 0.92 && t < 0.96;
            return Transform.translate(
              offset: Offset(0, -onda * 2),
              child: Transform.scale(
                scaleY: (1 + onda * 0.012) * (piscando ? 0.985 : 1.0),
                scaleX: 1 - onda * 0.004,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            );

          case LiliMood.comemorando:
            // Pulinho com squash & stretch (princípio clássico de animação).
            final pulo = math.sin(t * math.pi); // 0..1..0
            final squash = 1 - (pulo * 0.06);
            return Transform.translate(
              offset: Offset(0, -pulo * 14),
              child: Transform.rotate(
                angle: onda * 0.03,
                child: Transform.scale(
                  scaleY: 1 + pulo * 0.05,
                  scaleX: squash,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );

          case LiliMood.correndo:
            // Balanço rítmico + leve inclinação para frente.
            return Transform.translate(
              offset: Offset(onda * 3, -(onda.abs()) * 5),
              child: Transform.rotate(
                angle: onda * 0.05,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            );

          case LiliMood.estatica:
            return child!;
        }
      },
      child: mascot,
    );
  }
}
