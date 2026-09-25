import 'personal_ai_icons.dart';

/// ============================================================================
/// CATÁLOGO CENTRALIZADO DE ÍCONES — Método 1 Dia de Cada Vez.
///
/// Pacote oficial (Cursor): `assets/icons/{navigation,health,actions,mood,
/// achievements,premium}/` — JPG neon preto/lilás/rosa.
///
/// Exercícios específicos de treino continuam em `assets/icons/neon/treinos/`
/// (não há equivalentes no pacote Cursor).
///
/// Personal / Consultoria / IA: [PersonalAiIcons] em `assets/icons/personal-ai/`.
///
/// Use sempre `AppIcons.x` + `AppIconImage` — nunca caminhos soltos.
/// ============================================================================
class AppIcons {
  AppIcons._();

  static const String _nav = 'assets/icons/navigation/';
  static const String _health = 'assets/icons/health/';
  static const String _actions = 'assets/icons/actions/';
  static const String _mood = 'assets/icons/mood/';
  static const String _ach = 'assets/icons/achievements/';
  // Premium pack folder: assets/icons/premium/ (icons referenced via AppIcons.* paths)
  static const String _treino = 'assets/icons/neon/treinos/';
  /// Pacote neon 3D gloss (finalizacao) — PNG em assets/icons/app/.
  static const String _app = 'assets/icons/app/';

  // ---- Navegação ----
  static const String home = '${_app}inicio.jpg';
  static const String homeAlt = home;
  static const String workout = '${_app}treinos.jpg';
  static const String workoutDumbbell = workout;
  static const String recipes = '${_app}receitas.jpg';
  static const String nutrition = recipes;
  static const String evolution = '${_app}evolucao.jpg';
  static const String profile = '${_app}perfil.jpg';
  static const String checkin = '${_app}checkin.jpg';
  static const String diary = '${_app}diario.jpg';
  static const String photos = '${_nav}photos.jpg';
  static const String gallery = photos;
  static const String measurement = '${_nav}measurements.jpg';
  static const String measurements = measurement;
  static const String history = '${_nav}history.jpg';
  static const String notifications = '${_app}notificacoes.jpg';
  static const String settings = '${_app}configuracoes.jpg';
  static const String premium = '${_app}premium.jpg';
  static const String subscription = '${_nav}subscription.jpg';

  // ---- Saúde / métricas ----
  static const String running = '${_app}corrida_gps.jpg';
  static const String gpsRunning = running;
  static const String gps = running;
  static const String water = '${_app}hidratacao.jpg';
  static const String hydration = water;
  static const String hydrationGoal = '${_health}hydration_alt.jpg';

  /// Pacote dedicado da tela Meta de água (neon 3D gloss).
  static const String _hydrationDir = 'assets/icons/app/extras_hidratacao/';
  static const String hydrationProgress =
      '${_hydrationDir}hidratacao_rastreamento.jpg';
  static const String hydrationCheck = '${_hydrationDir}hidratacao_check.jpg';
  static const String hydrationBottle = '${_hydrationDir}hidratacao_garrafa.jpg';
  static const String hydrationGlass = '${_hydrationDir}hidratacao_extra_1.jpg';
  static const String hydrationExtra = hydrationGlass;
  static const String sleep = '${_app}sono.jpg';
  static const String steps = '${_health}steps.jpg';
  static const String walk = steps;
  static const String weight = '${_health}weight_bmi.jpg';
  static const String bmiMeasure = weight;
  static const String calories = '${_health}calories.jpg';
  static const String camera = '${_health}camera.jpg';
  static const String cameraFood = '${_app}analisar_refeicao_ia.jpg';
  static const String food = cameraFood;
  static const String scanner = cameraFood;
  static const String stretching = '${_health}stretching.jpg';
  static const String meditation = '${_app}meditacoes.jpg';
  static const String yoga = meditation;
  static const String favorite = '${_health}favorite.jpg';
  static const String favorites = favorite;
  static const String search = '${_health}search.jpg';
  static const String filter = search;
  static const String audio = '${_health}audio.jpg';
  static const String calendar = '${_health}calendar.jpg';
  static const String goals = '${_app}metas.jpg';
  static const String goal = goals;
  static const String healthHeart = '${_health}health_fitness.jpg';
  static const String healthFitness = '${_app}bem_estar.jpg';
  static const String bemEstar = healthFitness;

  // ---- Ações ----
  static const String edit = '${_actions}edit.jpg';
  static const String delete = '${_actions}delete.jpg';
  static const String share = '${_actions}share.jpg';
  static const String back = '${_actions}back.jpg';
  static const String add = '${_actions}add.jpg';
  static const String play = '${_actions}play.jpg';
  static const String pause = '${_actions}pause.jpg';
  static const String upload = '${_actions}upload.jpg';
  static const String uploadPhoto = upload;
  static const String location = '${_actions}location_map.jpg';
  static const String retry = '${_actions}retry_refresh.jpg';
  static const String refresh = retry;
  static const String logout = '${_app}sair.jpg';
  static const String target = '${_actions}target.jpg';

  // ---- Humor / check-in ----
  static const String moodSad = '${_mood}sad.jpg';
  static const String moodSleepy = '${_mood}sleepy.jpg';
  static const String moodNeutral = '${_mood}neutral.jpg';
  static const String moodHappy = '${_mood}happy.jpg';
  static const String moodCalm = '${_mood}calm.jpg';
  static const String moodVeryHappy = '${_mood}very_happy.jpg';
  static const String moodWink = '${_mood}wink.jpg';
  static const String moodSurprised = '${_mood}surprised.jpg';
  static const String moodDetermined = '${_mood}determined.jpg';

  /// Ordem alinhada ao check-in (0..4): muito bem → cansada.
  static const List<String> moodCheckin = [
    moodVeryHappy,
    moodHappy,
    moodNeutral,
    moodSad,
    moodSleepy,
  ];

  // ---- Premium / conquistas genéricas ----
  static const String trophy = '${_app}desafios.jpg';
  static const String desafios = trophy;
  static const String challenges = trophy;
  static const String premiumCrown = '${_app}premium.jpg';
  static const String achievement = trophy;
  static const String medalRanking = trophy;
  static const String medal = trophy;
  static const String ranking = trophy;
  static const String streak = '${_ach}streak_7_days.jpg';

  // ---- Emblemas (achievements) ----
  static const String achStreak7 = '${_ach}streak_7_days.jpg';
  static const String achStreak30 = '${_ach}streak_30_days.jpg';
  static const String achStreak60 = '${_ach}streak_60_days.jpg';
  static const String achStreak100 = '${_ach}streak_100_days.jpg';
  static const String achWorkouts25 = '${_ach}workouts_25.jpg';
  static const String achWorkouts50 = '${_ach}workouts_50.jpg';
  static const String achWorkouts100 = '${_ach}workouts_100.jpg';
  static const String achWeightLoss5 = '${_ach}weight_loss_5kg.jpg';
  static const String achWeightLoss10 = '${_ach}weight_loss_10kg.jpg';
  static const String achWeightGoal = '${_ach}weight_goal.jpg';
  static const String achFirstRun = '${_ach}first_run.jpg';
  static const String achRun5k = '${_ach}run_5km.jpg';
  static const String achRun10k = '${_ach}run_10km.jpg';
  static const String achHydration = '${_ach}hydration_achievement.jpg';
  static const String achFirstWorkout = '${_ach}first_workout.jpg';
  static const String achHabits = '${_ach}habits_goal.jpg';
  static const String achWeightProgress = '${_ach}weight_progress.jpg';
  static const String achDailyWater = '${_ach}daily_water_goal.jpg';
  static const String achWeeklyWorkout = '${_ach}weekly_workout_goal.jpg';
  static const String achSevenDay = '${_ach}seven_day_goal.jpg';
  static const String achThirtyDay = '${_ach}thirty_day_goal.jpg';
  static const String achPerfectWeek = '${_ach}perfect_week.jpg';

  // ---- Compat / aliases (telas existentes) ----
  static const String checklist = checkin;
  static const String habits = '${_app}habitos.jpg';
  static const String habitos = habits;
  static const String video = '${_app}videos.jpg';
  static const String videos = video;
  static const String stopwatch = history;
  static const String timer = history;
  static const String progress = evolution;
  static const String statistics = evolution;
  static const String beforeAfter = photos;
  static const String program7Days = achSevenDay;
  static const String course = program7Days;
  static const String courses = program7Days;
  static const String ebook = diary;
  static const String community = '${_app}comunidade.jpg';
  static const String messages = '${_app}suporte.jpg';
  static const String personal = profile;

  /// Pacote visual Personal / Consultoria / IA (não substitui [personal]).
  static const String chatAmanda = PersonalAiIcons.chatAmanda;
  static const String agendaConsultoria = PersonalAiIcons.agendaConsultoria;
  static const String areaPersonal = PersonalAiIcons.areaPersonal;
  static const String anamnese = PersonalAiIcons.anamnese;
  static const String analisarIA = PersonalAiIcons.analisarIA;
  static const String assistenteIA = PersonalAiIcons.assistenteIA;
  static const String insightsIA = PersonalAiIcons.insightsIA;
  static const String sugestaoResposta = PersonalAiIcons.sugestaoResposta;
  static const String resumoConversa = PersonalAiIcons.resumoConversa;
  static const String pontosAtencao = PersonalAiIcons.pontosAtencao;
  static const String support = '${_app}suporte.jpg';
  static const String help = '${_app}ajuda.jpg';
  static const String ajuda = help;
  static const String reminders = notifications;
  static const String security = settings;
  static const String privacy = settings;
  static const String login = profile;
  static const String complete = checkin;
  static const String next = evolution;
  static const String shoppingList = recipes;
  static const String salad = recipes;
  static const String bowl = recipes;
  static const String pulseSearch = search;
  static const String bike = running;
  static const String treadmill = running;
  static const String stairs = steps;
  static const String cardioRun = running;
  /// Cardio genuíno — ícone neon legado (não confundir com favorito/coração).
  static const String cardio =
      'assets/icons/neon/corrida/icone_neon_de_corrida_e_saude_cardiaca.jpg';
  static const String workoutPlaceholder =
      'assets/icons/neon/treinos/icone_fitness_neon_em_vidro_3d.jpg';
  static const String workoutGoal = target;

  // ---- Exercícios específicos (kit neon legado — sem equivalentes no pacote) ----
  static const String exAbs = '${_treino}icone_neon_de_abdominais_futurista.jpg';
  static const String abs = exAbs;
  static const String exAbsAlt =
      '${_treino}icone_fitness_neon_com_abdomen_esculpido.jpg';
  static const String glutes =
      '${_treino}icone_neon_de_hip_thrust_com_barra.jpg';
  static const String exSquat =
      '${_treino}icone_fitness_neon_em_agachamento.jpg';
  static const String exSquatBar =
      '${_treino}icone_neon_de_agachamento_com_barra.jpg';
  static const String exSquatSumo =
      '${_treino}icone_fitness_neon_com_agachamento_sumo.jpg';
  static const String exHipThrust =
      '${_treino}icone_fitness_neon_hip_thrust_dramatico.jpg';
  static const String exLegPress =
      '${_treino}icone_fitness_neon_de_leg_press.jpg';
  static const String exLegExtension =
      '${_treino}icone_neon_de_extensao_de_pernas.jpg';
  static const String exLegCurl = '${_treino}icone_neon_de_mesa_flexora.jpg';
  static const String exLunge =
      '${_treino}icone_neon_de_lunge_com_halteres.jpg';
  static const String exCalf =
      '${_treino}icone_neon_de_elevacao_de_panturrilha.jpg';
  static const String exLegRaise =
      '${_treino}icone_neon_de_elevacao_de_pernas.jpg';
  static const String exCurl =
      '${_treino}icone_fitness_neon_com_rosca_direta.jpg';
  static const String exArm =
      '${_treino}icone_fitness_neon_com_braco_musculoso.jpg';
  static const String exTriceps =
      '${_treino}icone_neon_de_triceps_na_polia.jpg';
  static const String exTricepsExt =
      '${_treino}extensao_de_triceps_neon_na_academia.jpg';
  static const String exLateralRaise =
      '${_treino}icone_neon_de_elevacao_lateral.jpg';
  static const String exBench =
      '${_treino}icone_neon_de_supino_fitness.jpg';
  static const String exBenchDb =
      '${_treino}icone_fitness_neon_de_supino_com_halteres.jpg';
  static const String exRow =
      '${_treino}icone_neon_de_remada_com_halter.jpg';
  static const String exRowLow =
      '${_treino}icone_neon_de_remada_baixa_fitness.jpg';
  static const String exPulldown =
      '${_treino}icone_neon_de_puxada_na_maquina.jpg';
  static const String exBack = '${_treino}icone_neon_de_treino_de_costas.jpg';
  static const String exKickback =
      '${_treino}icone_neon_de_kickback_na_polia.jpg';
  static const String exKettlebell =
      '${_treino}icone_neon_de_swing_com_kettlebell.jpg';
  static const String exPushup =
      '${_treino}icone_neon_de_flexao_atletica.jpg';
  static const String exPlank =
      '${_treino}icone_neon_de_prancha_fitness.jpg';
  static const String exBurpee = '${_treino}burpee_em_prancha_neon.jpg';
  static const String exJumpingJack =
      '${_treino}icone_neon_de_polichinelo_fitness.jpg';
  static const String exStretch =
      '${_treino}icone_neon_de_alongamento_fitness.jpg';
  static const String exStretchAlt =
      '${_treino}icone_neon_de_alongamento_feminino.jpg';
  static const String exTorso = '${_treino}icone_neon_de_torso_atletico.jpg';
  static const String exFunctional =
      '${_treino}icone_fitness_neon_em_movimento.jpg';

  /// Principais do pacote Cursor (auditoria / pré-cache).
  static const List<String> allCursor = [
    home, workout, recipes, evolution, profile, checkin, diary, photos,
    measurement, history, notifications, settings, premium, subscription,
    running, water, sleep, steps, weight, calories, camera, cameraFood,
    stretching, meditation, favorite, search, audio, calendar, goals,
    healthHeart, hydrationGoal, edit, delete, share, back, add, play, pause,
    upload, location, retry, logout, target,
    hydrationProgress, hydrationCheck, hydrationBottle, hydrationGlass,
    moodSad, moodSleepy, moodNeutral, moodHappy, moodCalm, moodVeryHappy,
    moodWink, moodSurprised, moodDetermined,
    trophy, premiumCrown, achStreak7, achStreak30, achStreak60, achStreak100,
    achWorkouts25, achWorkouts50, achWorkouts100, achWeightLoss5,
    achWeightLoss10, achWeightGoal, achFirstRun, achRun5k, achRun10k,
    achHydration, achFirstWorkout, achHabits, achWeightProgress,
    achDailyWater, achWeeklyWorkout, achSevenDay, achThirtyDay, achPerfectWeek,
  ];

  static const List<String> all = [
    ...allCursor,
    exAbs, glutes, exSquat, exSquatBar, exSquatSumo, exHipThrust, exLegPress,
    exLegExtension, exLegCurl, exLunge, exCalf, exLegRaise, exCurl, exArm,
    exTriceps, exTricepsExt, exLateralRaise, exBench, exBenchDb, exRow,
    exRowLow, exPulldown, exBack, exKickback, exKettlebell, exPushup, exPlank,
    exBurpee, exJumpingJack, exStretch, exTorso, exFunctional,
  ];

  static const List<String> all3d = all;

  /// Mapa id de conquista (seed) → asset do pacote Cursor.
  static String forAchievementId(String id) {
    return switch (id) {
      'primeiro_treino' => achFirstWorkout,
      'sete_dias' => achStreak7,
      'primeira_corrida' => achFirstRun,
      'dez_treinos' => achWorkouts25,
      'meta_peso' => achWeightGoal,
      'cinco_km' => achRun5k,
      _ => trophy,
    };
  }
}
