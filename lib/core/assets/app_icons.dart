/// ============================================================================
/// CATÁLOGO CENTRALIZADO DE ÍCONES — kit neon rosa/roxo/azul (PNG).
///
/// Fonte: `assets/icons/neon/` (pacote metodo_1_dia_icones_neon_completo).
/// Use sempre `AppIcons.x` — nunca caminhos soltos pelo app.
///
/// Treinos: preferir ícone específico → categoria → [workoutPlaceholder].
/// Nunca usar coração como fallback geral.
/// ============================================================================
class AppIcons {
  AppIcons._();

  static const String _nav = 'assets/icons/neon/navegacao/';
  static const String _saude = 'assets/icons/neon/saude/';
  static const String _nutri = 'assets/icons/neon/nutricao/';
  static const String _corrida = 'assets/icons/neon/corrida/';
  static const String _treino = 'assets/icons/neon/treinos/';
  static const String _conquista = 'assets/icons/neon/conquistas/';
  static const String _perfil = 'assets/icons/neon/perfil/';

  // ---- Navegação / sistema ----
  static const String home = '${_nav}icone_neon_de_casa_fitness.png';
  static const String homeAlt = '${_nav}icone_de_casa_neon_em_vidro_3d.png';
  static const String settings = '${_nav}02_configuracoes.png';
  static const String notifications = '${_nav}01_notificacoes.png';
  static const String favorite = '${_nav}03_favoritos.png';
  static const String calendar = '${_nav}icone_neon_de_calendario_com_checkmark.png';
  static const String checklist = '${_nav}icone_neon_de_checklist_em_vidro.png';
  static const String video = '${_nav}icone_neon_de_player_de_video.png';
  static const String search = '${_saude}icone_neon_de_busca_e_pulso.png';

  // ---- Treinos (nav + placeholder) ----
  static const String workout = '${_treino}icone_neon_de_halteres_fitness.png';
  static const String workoutDumbbell = workout;
  static const String workoutPlaceholder =
      '${_treino}icone_fitness_neon_em_vidro_3d.png';
  static const String workoutGoal =
      '${_treino}icone_fitness_neon_com_halter_futurista.png';
  static const String stopwatch = '${_treino}icone_neon_de_cronometro_em_vidro.png';

  // ---- Nutrição / receitas ----
  static const String recipes = '${_nutri}tigela_de_salada_neon_vibrante.png';
  static const String nutrition = recipes;
  static const String food = '${_nutri}icone_neon_de_alimentacao_saudavel.png';
  static const String cameraFood = '${_nutri}icone_neon_de_camera_com_salada.png';
  static const String salad = '${_nutri}icone_neon_de_salada_saudavel.png';
  static const String bowl = '${_nutri}icone_neon_de_bowl_saudavel.png';

  // ---- Saúde / métricas ----
  static const String hydration =
      '${_saude}icone_neon_de_hidratacao_fitness.png';
  static const String water = hydration;
  static const String hydrationGoal =
      '${_saude}garrafa_neon_com_gota_luminosa.png';
  static const String calories = '${_saude}07_calorias.png';
  static const String sleep = '${_saude}08_sono.png';
  static const String weight = '${_saude}09_peso_balanca.png';
  static const String bmiMeasure = '${_saude}06_imc.png';
  static const String meditation =
      '${_saude}icone_neon_de_meditacao_com_fones.png';
  static const String yoga = meditation;
  static const String healthHeart = '${_saude}icone_neon_de_pulso_vital.png';
  static const String pulseSearch = '${_saude}icone_neon_de_busca_cardiaca.png';

  // ---- Corrida / GPS / cardio ----
  static const String running =
      '${_corrida}icone_neon_de_corrida_em_movimento.png';
  static const String gpsRunning = '${_corrida}icone_neon_de_rota_gps.png';
  static const String gps = gpsRunning;
  static const String location = gpsRunning;
  static const String bike =
      '${_corrida}ciclista_neon_em_bicicleta_spinning.png';
  static const String walk = '${_corrida}icone_neon_de_atleta_caminhando.png';
  static const String treadmill = '${_corrida}icone_fitness_neon_na_esteira.png';
  static const String stairs = '${_corrida}icone_neon_de_treino_na_escada.png';
  static const String cardioRun =
      '${_corrida}icone_neon_de_corredor_cardiaco.png';
  /// Apenas cardio genuíno — NÃO usar como fallback de treino.
  static const String cardio =
      '${_corrida}icone_neon_de_corrida_e_saude_cardiaca.png';

  // ---- Progresso / conquistas / premium ----
  static const String progress =
      '${_conquista}icone_neon_de_progresso_fitness.png';
  static const String evolution =
      '${_conquista}icone_neon_de_crescimento_progressivo.png';
  static const String statistics =
      '${_conquista}icone_neon_de_grafico_ascendente.png';
  static const String trophy = '${_conquista}icone_neon_de_trofeu_glorioso.png';
  static const String premium = '${_conquista}coroa_neon_em_icone_premium.png';
  static const String achievement =
      '${_conquista}icone_neon_de_coroa_dourada.png';
  static const String medalRanking = achievement;
  static const String program7Days =
      '${_conquista}icone_neon_de_plano_fitness_7_dias.png';
  static const String audio = meditation;

  // ---- Perfil / comunidade ----
  static const String profile = '${_perfil}icone_neon_de_avatar_feminino.png';
  static const String community = '${_perfil}04_comunidade.png';
  static const String messages = '${_perfil}05_chat_ia.png';
  static const String personal = messages;
  static const String support = messages;
  static const String reminders = '${_perfil}10_lembretes.png';

  // ---- Exercícios específicos (treinos) ----
  static const String exAbs = '${_treino}icone_neon_de_abdominais_futurista.png';
  static const String abs = exAbs;
  static const String exAbsAlt =
      '${_treino}icone_fitness_neon_com_abdomen_esculpido.png';
  static const String glutes =
      '${_treino}icone_neon_de_hip_thrust_com_barra.png';
  static const String exSquat =
      '${_treino}icone_fitness_neon_em_agachamento.png';
  static const String exSquatBar =
      '${_treino}icone_neon_de_agachamento_com_barra.png';
  static const String exSquatSumo =
      '${_treino}icone_fitness_neon_com_agachamento_sumo.png';
  static const String exHipThrust =
      '${_treino}icone_fitness_neon_hip_thrust_dramatico.png';
  static const String exLegPress =
      '${_treino}icone_fitness_neon_de_leg_press.png';
  static const String exLegExtension =
      '${_treino}icone_neon_de_extensao_de_pernas.png';
  static const String exLegCurl = '${_treino}icone_neon_de_mesa_flexora.png';
  static const String exLunge =
      '${_treino}icone_neon_de_lunge_com_halteres.png';
  static const String exCalf =
      '${_treino}icone_neon_de_elevacao_de_panturrilha.png';
  static const String exLegRaise =
      '${_treino}icone_neon_de_elevacao_de_pernas.png';
  static const String exCurl =
      '${_treino}icone_fitness_neon_com_rosca_direta.png';
  static const String exArm =
      '${_treino}icone_fitness_neon_com_braco_musculoso.png';
  static const String exTriceps =
      '${_treino}icone_neon_de_triceps_na_polia.png';
  static const String exTricepsExt =
      '${_treino}extensao_de_triceps_neon_na_academia.png';
  static const String exLateralRaise =
      '${_treino}icone_neon_de_elevacao_lateral.png';
  static const String exBench =
      '${_treino}icone_neon_de_supino_fitness.png';
  static const String exBenchDb =
      '${_treino}icone_fitness_neon_de_supino_com_halteres.png';
  static const String exRow =
      '${_treino}icone_neon_de_remada_com_halter.png';
  static const String exRowLow =
      '${_treino}icone_neon_de_remada_baixa_fitness.png';
  static const String exPulldown =
      '${_treino}icone_neon_de_puxada_na_maquina.png';
  static const String exBack = '${_treino}icone_neon_de_treino_de_costas.png';
  static const String exKickback =
      '${_treino}icone_neon_de_kickback_na_polia.png';
  static const String exKettlebell =
      '${_treino}icone_neon_de_swing_com_kettlebell.png';
  static const String exPushup =
      '${_treino}icone_neon_de_flexao_atletica.png';
  static const String exPlank =
      '${_treino}icone_neon_de_prancha_fitness.png';
  static const String exBurpee = '${_treino}burpee_em_prancha_neon.png';
  static const String exJumpingJack =
      '${_treino}icone_neon_de_polichinelo_fitness.png';
  static const String exStretch =
      '${_treino}icone_neon_de_alongamento_fitness.png';
  static const String exStretchAlt =
      '${_treino}icone_neon_de_alongamento_feminino.png';
  static const String exTorso = '${_treino}icone_neon_de_torso_atletico.png';
  static const String exFunctional =
      '${_treino}icone_fitness_neon_em_movimento.png';

  // ---- Apelidos / aliases (compatibilidade com telas existentes) ----
  static const String camera = cameraFood;
  static const String timer = stopwatch;
  static const String measurement = bmiMeasure;
  static const String medal = medalRanking;
  static const String ranking = medalRanking;
  static const String course = program7Days;
  static const String courses = program7Days;
  static const String ebook = program7Days;
  static const String habits = checklist;
  static const String security = settings;
  static const String privacy = settings;
  static const String favorites = favorite;
  static const String videos = video;
  static const String diary = checklist;
  static const String checkin = calendar;
  static const String goal = evolution;
  static const String beforeAfter = evolution;
  static const String streak = trophy;
  static const String play = video;
  static const String pause = stopwatch;
  static const String complete = checklist;
  static const String back = home;
  static const String next = evolution;
  static const String filter = search;
  static const String gallery = cameraFood;
  static const String uploadPhoto = cameraFood;
  static const String edit = settings;
  static const String login = profile;
  static const String logout = settings;
  static const String share = community;
  static const String shoppingList = food;
  static const String scanner = cameraFood;

  /// Lista para pré-cache / auditoria (principais + exercícios).
  static const List<String> all = [
    home, settings, notifications, favorite, calendar, checklist, video,
    search, workout, workoutPlaceholder, workoutGoal, stopwatch, recipes,
    food, cameraFood, hydration, calories, sleep, weight, bmiMeasure,
    meditation, running, gpsRunning, bike, walk, treadmill, stairs, cardio,
    progress, evolution, statistics, trophy, premium, achievement,
    program7Days, profile, community, messages, reminders,
    exAbs, glutes, exSquat, exSquatBar, exSquatSumo, exHipThrust, exLegPress,
    exLegExtension, exLegCurl, exLunge, exCalf, exLegRaise, exCurl, exArm,
    exTriceps, exTricepsExt, exLateralRaise, exBench, exBenchDb, exRow,
    exRowLow, exPulldown, exBack, exKickback, exKettlebell, exPushup, exPlank,
    exBurpee, exJumpingJack, exStretch, exTorso, exFunctional,
  ];

  static const List<String> all3d = all;
}
