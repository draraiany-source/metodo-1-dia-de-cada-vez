import 'app_assets.dart';

/// Catálogo de pareamento **Rive ↔ Lottie**.
///
/// Cada evento aponta para o `.riv` futuro e o Lottie que o substitui hoje.
/// `RiveHelper` usa o Rive quando disponível e cai no Lottie automaticamente.
///
/// As constantes `lottie*` **referenciam** `AppAssets` — não duplicam o caminho.
class AppAnimations {
  AppAnimations._();

  // ---- Lottie (fonte: AppAssets) ----
  static const String lottieLoading = AppAssets.animLoading;
  static const String lottieLevelUp = AppAssets.animLevelUp;
  static const String lottieConfetti = AppAssets.animConfetti;
  static const String lottieXpGain = AppAssets.animXpGain;
  static const String lottieStreakFire = 'assets/animations/streak_fire.json';
  static const String lottieTrophyShine = AppAssets.animTrophyShine;
  static const String lottieMedalUnlock = AppAssets.animMedalUnlock;
  static const String lottieUnlock = AppAssets.animUnlock;

  // ---- Rive (arquivos ainda não existem — ver assets/rive/README.md) ----
  static const String riveLiliIdle = 'assets/rive/lili_idle.riv';
  static const String riveLiliRunning = 'assets/rive/lili_running.riv';
  static const String riveLiliCelebrate = 'assets/rive/lili_celebrate.riv';
  static const String riveStreakFire = 'assets/rive/streak_fire.riv';
  static const String riveLevelUp = 'assets/rive/level_up.riv';
}
