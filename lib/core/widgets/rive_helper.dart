import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Helper de animação preparado para Rive, com fallback automático em Lottie.
///
/// HOJE: o pacote `rive` está comentado no pubspec e nenhum `.riv` existe,
/// então este helper renderiza o Lottie equivalente — nada quebra.
///
/// PARA ATIVAR RIVE:
/// 1) descomente `rive: ^0.13.20` no pubspec e rode `flutter pub get`;
/// 2) coloque os `.riv` em `assets/rive/`;
/// 3) descomente o import e o bloco marcado abaixo.
///
/// A API pública (`RiveHelper.animation(...)`) não muda — as telas que já
/// usam este helper passam a exibir Rive sem alteração de código.
// import 'package:rive/rive.dart';

class RiveHelper {
  RiveHelper._();

  /// Renderiza uma animação. Passe o caminho do `.riv` e o Lottie de fallback.
  ///
  /// Ex.: `RiveHelper.animation(
  ///        rivePath: AppAnimations.riveStreakFire,
  ///        lottieFallback: AppAnimations.lottieLevelUp,
  ///        size: 120,
  ///      )`
  static Widget animation({
    required String rivePath,
    required String lottieFallback,
    double size = 120,
    bool repeat = true,
  }) {
    // ===== BLOCO RIVE (descomente ao ativar) =====
    // return SizedBox(
    //   width: size,
    //   height: size,
    //   child: RiveAnimation.asset(
    //     rivePath,
    //     fit: BoxFit.contain,
    //   ),
    // );
    // ===== FIM BLOCO RIVE =====

    // Fallback atual: Lottie.
    return Lottie.asset(
      lottieFallback,
      width: size,
      height: size,
      repeat: repeat,
    );
  }
}
