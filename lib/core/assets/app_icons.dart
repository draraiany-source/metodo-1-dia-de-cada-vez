/// ============================================================================
/// CATÁLOGO CENTRALIZADO DE ÍCONES — Método 1 Dia de Cada Vez.
///
/// Pacote oficial (Cursor): `assets/icons/{navigation,health,actions,mood,
/// achievements,premium}/` — JPG neon preto/lilás/rosa.
///
/// Exercícios específicos de treino continuam em `assets/icons/neon/treinos/`
/// (não há equivalentes no pacote Cursor).
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
  static const String _prem = 'assets/icons/premium/';
  static const String _treino = 'assets/icons/neon/treinos/';

  // ---- Navegação ----
  static const String home = '${_nav}home.jpg';
  static const String homeAlt = home;
  static const String workout = '${_nav}workouts.jpg';
  static const String workoutDumbbell = workout;
  static const String recipes = '${_nav}recipes.jpg';
  static const String nutrition = recipes;
  static const String evolution = '${_nav}evolution.jpg';
  static const String profile = '${_nav}profile.jpg';
  static const String checkin = '${_nav}checkin.jpg';
  static const String diary = '${_nav}diary.jpg';
  static const String photos = '${_nav}photos.jpg';
  static const String gallery = photos;
  static const String measurement = '${_nav}measurements.jpg';
  static const String measurements = measurement;
  static const String history = '${_nav}history.jpg';
  static const String notifications = '${_nav}notifications.jpg';
  static const String settings = '${_nav}settings.jpg';
  static const String premium = '${_nav}premium.jpg';
  static const String subscription = '${_nav}subscription.jpg';

  // ---- Saúde / métricas ----
  static const String running = '${_health}running_gps.jpg';
  static const String gpsRunning = running;
  static const String gps = running;
  static const String water = '${_health}water.jpg';
  static const String hydration = water;
  static const String hydrationGoal = '${_health}hydration_alt.jpg';
  static const String sleep = '${_health}sleep.jpg';
  static const String steps = '${_health}steps.jpg';
  static const String walk = steps;
  static const String weight = '${_health}weight_bmi.jpg';
  static const String bmiMeasure = weight;
  static const String calories = '${_health}calories.jpg';
  static const String camera = '${_health}camera.jpg';
  static const String cameraFood = '${_health}food_ai.jpg';
  static const String food = cameraFood;
  static const String scanner = cameraFood;
  static const String stretching = '${_health}stretching.jpg';
  static const String meditation = '${_health}meditation.jpg';
  static const String yoga = meditation;
  static const String favorite = '${_health}favorite.jpg';
  static const String favorites = favorite;
  static const String search = '${_health}search.jpg';
  static const String filter = search;
  static const String audio = '${_health}audio.jpg';
  static const String calendar = '${_health}calendar.jpg';
  static const String goals = '${_health}goals.jpg';
  static const String goal = goals;
  static const String healthHeart = '${_health}health_fitness.jpg';
  static const String healthFitness = healthHeart;

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
  static const String logout = '${_actions}logout.jpg';
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
  static const String trophy = '${_prem}achievement_trophy.jpg';
  static const String premiumCrown = '${_prem}premium_crown.jpg';
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
  static const String habits = checkin;
  static const String video = play;
  static const String videos = play;
  static const String stopwatch = history;
  static const String timer = history;
  static const String progress = evolution;
  static const String statistics = evolution;
  static const String beforeAfter = photos;
  static const String program7Days = achSevenDay;
  static const String course = program7Days;
  static const String courses = program7Days;
  static const String ebook = diary;
  static const String community = profile;
  static const String messages = profile;
  static const String personal = profile;
  static const String support = profile;
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
      'assets/icons/neon/corrida/icone_neon_de_corrida_e_saude_cardiaca.png';
  static const String workoutPlaceholder =
      'assets/icons/neon/treinos/icone_fitness_neon_em_vidro_3d.png';
  static const String workoutGoal = target;

  // ---- Exercícios específicos (kit neon legado — sem equivalentes no pacote) ----
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

  /// Principais do pacote Cursor (auditoria / pré-cache).
  static const List<String> allCursor = [
    home, workout, recipes, evolution, profile, checkin, diary, photos,
    measurement, history, notifications, settings, premium, subscription,
    running, water, sleep, steps, weight, calories, camera, cameraFood,
    stretching, meditation, favorite, search, audio, calendar, goals,
    healthHeart, hydrationGoal, edit, delete, share, back, add, play, pause,
    upload, location, retry, logout, target,
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
