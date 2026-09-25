from pathlib import Path

# Patch mascot_assets to prefer Lily pack
p = Path(r"lib/core/mascot/mascot_assets.dart")
t = p.read_text(encoding="utf-8")
if "import '../lily/lily_assets.dart';" not in t:
    t = t.replace(
        "import 'mascot_config.dart';",
        "import 'mascot_config.dart';\nimport '../lily/lily_assets.dart';",
    )

# Replace safeNewOverride to map to LilyAssets first
old_override = """  static String? safeNewOverride(MascotPose pose) {
    switch (pose) {
      case MascotePose.celebrando:
      case MascotePose.trofeu:
        return officialCelebratingRing;
      case MascotePose.rainha:
        return lily02Paz;
      case MascotePose.checklist:
        return lily04Apontando;
      case MascotePose.perfil:
        return officialArmsCrossed;
      default:
        return null;
    }
  }"""

new_override = """  /// Preferência: pacote oficial Lily Fit (assets/lily/) — corpo inteiro, HD.
  static String? safeNewOverride(MascotPose pose) {
    switch (pose) {
      case MascotePose.boasVindas:
        return LilyAssets.boasVindas;
      case MascotePose.joinha:
        return LilyAssets.joinha;
      case MascotePose.hidratacao:
        return LilyAssets.tomandoAgua;
      case MascotePose.halteres:
        return LilyAssets.treinoHalteres;
      case MascotePose.forte:
        return LilyAssets.forca;
      case MascotePose.meditacao:
        return LilyAssets.meditacao;
      case MascotePose.trofeu:
        return LilyAssets.trofeu;
      case MascotePose.celebrando:
        return LilyAssets.vitoria;
      case MascotePose.apontando:
        return LilyAssets.apontandoDireita;
      case MascotePose.checklist:
        return LilyAssets.calendarioCheck;
      case MascotePose.padrao:
        return LilyAssets.apresentandoAberta;
      case MascotePose.perfil:
        return LilyAssets.mostrandoApp;
      case MascotePose.coracao:
        return LilyAssets.metaConcluida;
      case MascotePose.triste:
        return LilyAssets.tentarNovamente;
      case MascotePose.rainha:
        return LilyAssets.trofeu;
    }
  }"""

if old_override in t:
    t = t.replace(old_override, new_override)
    print("override updated")
else:
    print("old override not found exactly")

# Make resolve always prefer Lily pack override when available
t = t.replace(
    """  /// Caminho efetivo respeitando a flag de transição.
  static String resolve(MascotPose pose) =>
      MascotConfig.useNewMascot ? newPath(pose) : legacyPath(pose);""",
    """  /// Caminho efetivo: pacote Lily Fit oficial tem prioridade (sem corte).
  static String resolve(MascotPose pose) {
    final lily = safeNewOverride(pose);
    if (lily != null) return lily;
    return MascotConfig.useNewMascot ? newPath(pose) : legacyPath(pose);
  }""",
)

# Extra aliases for running/stretch/nutrition
if "lilyPackRunning" not in t:
    t = t.replace(
        "  static const String officialCelebratingRing =\n      'assets/mascot/extras/lily_celebrating_ring_official.png';\n}",
        """  static const String officialCelebratingRing =
      'assets/mascot/extras/lily_celebrating_ring_official.png';

  // Pacote Lily Fit completo (atalhos)
  static const String lilyPackRunning = LilyAssets.corrida;
  static const String lilyPackStretch = LilyAssets.alongamento;
  static const String lilyPackNutrition = LilyAssets.pratoSaudavel;
  static const String lilyPackPostWorkout = LilyAssets.posTreino;
  static const String lilyPackHydrationReminder = LilyAssets.lembreteHidratacao;
}
""",
    )
    print("extra aliases added")

p.write_text(t, encoding="utf-8")
print("mascot_assets patched")
