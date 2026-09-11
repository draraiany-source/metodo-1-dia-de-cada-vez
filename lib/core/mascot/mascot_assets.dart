import '../constants/app_assets.dart';
import '../widgets/lili_widgets.dart' show MascotePose;
import 'mascot_config.dart';
import '../lily/lily_assets.dart';

/// Alias em inglês para o enum de poses existente — dá o vocabulário pedido
/// (`MascotPose.celebrating` etc. podem ser adicionados aqui no futuro) sem
/// duplicar enums nem quebrar as 16+ telas que já usam [MascotePose].
typedef MascotPose = MascotePose;

/// ============================================================================
/// CATÁLOGO CENTRAL DE ASSETS DA MASCOTE (§9/§13/§14).
///
/// Resolve o caminho de cada pose em UM lugar, com a cadeia de fallback:
///   nova arte (assets/mascot/png/) → arte legada (assets/images/mascote/).
/// Nenhuma tela deve montar caminhos de mascote manualmente.
/// ============================================================================
class MascotAssets {
  MascotAssets._();

  /// Pasta das novas artes (poses padronizadas, fundo transparente).
  static const String newBasePath = 'assets/mascot/png/';

  /// Nome de arquivo padronizado da NOVA arte para cada pose.
  static String newPoseFile(MascotPose pose) {
    switch (pose) {
      case MascotePose.perfil:
        return 'mascot_profile.png';
      case MascotePose.padrao:
        return 'mascot_default.png';
      case MascotePose.boasVindas:
        return 'mascot_welcome.png';
      case MascotePose.apontando:
        return 'mascot_pointing.png';
      case MascotePose.joinha:
        return 'mascot_thumbs_up.png';
      case MascotePose.hidratacao:
        return 'mascot_hydration.png';
      case MascotePose.checklist:
        return 'mascot_checklist.png';
      case MascotePose.halteres:
        return 'mascot_dumbbell.png';
      case MascotePose.forte:
        return 'mascot_strong.png';
      case MascotePose.meditacao:
        return 'mascot_meditation.png';
      case MascotePose.coracao:
        return 'mascot_heart.png';
      case MascotePose.triste:
        return 'mascot_sad.png';
      case MascotePose.trofeu:
        return 'mascot_trophy.png';
      case MascotePose.celebrando:
        return 'mascot_celebrating.png';
      case MascotePose.rainha:
        return 'mascot_queen.png';
    }
  }

  /// Poses cujo PNG padronizado ainda carrega arte de sprite sheet (pés no
  /// topo, duplicata lateral ou wrap) após o crop automático — redireciona
  /// para um asset limpo conhecido.
  /// Preferência: pacote oficial Lily Fit (assets/lily/) — corpo inteiro, HD.
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
  }

  /// Caminho da nova arte para a pose (com override seguro quando necessário).
  static String newPath(MascotPose pose) =>
      safeNewOverride(pose) ?? (newBasePath + newPoseFile(pose));

  /// Caminho da arte LEGADA (Lili Fit) — fallback garantido, arquivos reais.
  static String legacyPath(MascotPose pose) {
    switch (pose) {
      case MascotePose.perfil:
        return AppAssets.mascotePerfil;
      case MascotePose.padrao:
        return AppAssets.mascotePadrao;
      case MascotePose.boasVindas:
        return AppAssets.mascoteBoasVindas;
      case MascotePose.apontando:
        return AppAssets.mascoteApontando;
      case MascotePose.joinha:
        return AppAssets.mascoteJoinha;
      case MascotePose.hidratacao:
        return AppAssets.mascoteHidratacao;
      case MascotePose.checklist:
        return AppAssets.mascoteChecklist;
      case MascotePose.halteres:
        return AppAssets.mascoteHalteres;
      case MascotePose.forte:
        return AppAssets.mascoteForte;
      case MascotePose.meditacao:
        return AppAssets.mascoteMeditacao;
      case MascotePose.coracao:
        return AppAssets.mascoteCoracao;
      case MascotePose.triste:
        return AppAssets.mascoteTriste;
      case MascotePose.trofeu:
        return AppAssets.mascoteTrofeu;
      case MascotePose.celebrando:
        return AppAssets.mascoteCelebrando;
      case MascotePose.rainha:
        return AppAssets.mascoteRainha;
    }
  }

  /// Caminho efetivo: pacote Lily Fit oficial tem prioridade (sem corte).
  static String resolve(MascotPose pose) {
    final lily = safeNewOverride(pose);
    if (lily != null) return lily;
    return MascotConfig.useNewMascot ? newPath(pose) : legacyPath(pose);
  }

  // ==========================================================================
  // POSES EXTRAS da arte oficial (não mapeadas no enum de 15 poses).
  // Acesso centralizado — use direto onde a pose fizer sentido.
  // ==========================================================================
  static const String squat = 'assets/mascot/png/mascot_squat.png';
  static const String running = 'assets/mascot/png/mascot_running.png';
  static const String dumbbellSeated =
      'assets/mascot/png/mascot_dumbbell_seated.png';
  static const String notebook = 'assets/mascot/extras/mascot_notebook.png';
  static const String calendar = 'assets/mascot/extras/mascot_calendar.png';
  static const String healthyFood =
      'assets/mascot/extras/mascot_healthy_food.png';
  static const String mealPrep = 'assets/mascot/extras/mascot_meal_prep.png';
  static const String progress = 'assets/mascot/extras/mascot_progress.png';
  static const String thinking = 'assets/mascot/extras/mascot_thinking.png';
  static const String medal = 'assets/mascot/extras/mascot_medal.png';
  static const String promo = 'assets/mascot/extras/mascot_promo.png';

  // Numeração oficial (lily_fit) — espelho das poses 01–10.
  static const String lily01Joinha = 'assets/images/lily_fit/01_lili_fit_joinha.png';
  static const String lily02Paz = 'assets/images/lily_fit/02_lili_fit_paz.png';
  static const String lily03Bracos =
      'assets/images/lily_fit/03_lili_fit_bracos_cruzados.png';
  static const String lily04Apontando =
      'assets/images/lily_fit/04_lili_fit_apontando.png';
  static const String lily05Correndo =
      'assets/images/lily_fit/05_lili_fit_correndo.png';
  static const String lily06Agachada =
      'assets/images/lily_fit/06_lili_fit_agachada.png';
  static const String lily07Shaker =
      'assets/images/lily_fit/07_lili_fit_shaker.png';
  static const String lily08Notebook =
      'assets/images/lily_fit/08_lili_fit_notebook.png';
  static const String lily09Halter =
      'assets/images/lily_fit/09_lili_fit_halter.png';
  static const String lily10Comemorando =
      'assets/images/lily_fit/10_lili_fit_comemorando.png';

  /// Lily oficiais limpas (uploads do cliente, alpha real + crop).
  static const String officialArmsCrossed =
      'assets/mascot/extras/lily_arms_crossed_official.png';
  static const String officialThumbsUp =
      'assets/mascot/extras/lily_thumbs_up_official.png';
  static const String officialPeace =
      'assets/mascot/extras/lily_peace_official.png';
  static const String officialRunning =
      'assets/mascot/extras/lily_running_official.png';
  static const String officialCelebratingRing =
      'assets/mascot/extras/lily_celebrating_ring_official.png';

  // Pacote Lily Fit completo (atalhos)
  static const String lilyPackRunning = LilyAssets.corrida;
  static const String lilyPackStretch = LilyAssets.alongamento;
  static const String lilyPackNutrition = LilyAssets.pratoSaudavel;
  static const String lilyPackPostWorkout = LilyAssets.posTreino;
  static const String lilyPackHydrationReminder = LilyAssets.lembreteHidratacao;
}

