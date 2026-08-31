/// ============================================================================
/// CATÁLOGO CENTRALIZADO DE ÍCONES — arte 3D premium (PNG transparente).
///
/// Preferência pacote 1: `assets/images/icons_3d/` (nomes `*_3d.png`) —
/// treinos / nav já aprovados (NÃO alterar esses arquivos).
///
/// Pacote 2: `assets/images/icons_3d_pack2/` — Home / sistema / UI.
/// Ícones legados (`assets/icons/`) migrados para o pacote 2 quando há
/// equivalente; paths do pacote 1 permanecem intactos.
///
/// Use sempre `AppIcons.x`, nunca caminhos soltos pelo app.
/// ============================================================================
class AppIcons {
  AppIcons._();

  static const String _base = 'assets/icons/';
  static const String _base3d = 'assets/images/icons_3d/';
  static const String _basePack2 = 'assets/images/icons_3d_pack2/';

  // ---- Menu / navegação (pacote 1 — aprovado) ----
  static const String home = '${_base3d}icon_home_3d.png';
  static const String workout = '${_base3d}icon_workout_3d.png';
  static const String workoutDumbbell = workout;
  static const String recipes = '${_base3d}icon_recipes_3d.png';
  static const String progress = '${_base3d}icon_progress_3d.png';
  static const String profile = '${_base3d}icon_profile_3d.png';

  // ---- Métricas / features (pacote 1 — aprovado) ----
  static const String hydration = '${_base3d}icon_water_3d.png';
  static const String calories = '${_base3d}icon_calories_3d.png';
  static const String running = '${_base3d}icon_running_3d.png';
  static const String stopwatch = '${_base3d}icon_stopwatch_3d.png';
  static const String calendar = '${_base3d}icon_calendar_3d.png';
  static const String trophy = '${_base3d}icon_trophy_3d.png';
  static const String healthHeart = '${_base3d}icon_cardio_3d.png';
  static const String meditation = '${_base3d}icon_yoga_3d.png';
  static const String glutes = '${_base3d}icon_glutes_3d.png';
  static const String abs = '${_base3d}icon_abs_3d.png';

  // ---- Pacote 2 (sistema / Home / UI) ----
  static const String audio = '${_basePack2}icon_audio.png';
  static const String bmiMeasure = '${_basePack2}icon_bmi.png';
  static const String cameraFood = '${_basePack2}icon_camera.png';
  static const String checklist = '${_basePack2}icon_habits.png';
  static const String checkin = '${_basePack2}icon_checkin.png';
  static const String community = '${_basePack2}icon_community.png';
  static const String diary = '${_basePack2}icon_diary.png';
  static const String evolution = '${_basePack2}icon_evolution.png';
  static const String beforeAfter = '${_basePack2}icon_before_after.png';
  static const String personal = '${_basePack2}icon_personal.png';
  static const String courses = '${_base}icon_courses.png';
  static const String edit = '${_base}icon_edit.png';
  static const String favorite = '${_basePack2}icon_favorites.png';
  static const String goal = '${_basePack2}icon_goal.png';
  static const String gpsRunning = '${_basePack2}icon_gps.png';
  static const String login = '${_base}icon_login.png';
  static const String logout = '${_base}icon_logout.png';
  static const String medalRanking = '${_basePack2}icon_achievement.png';
  static const String messages = '${_basePack2}icon_support.png';
  static const String notifications = '${_basePack2}icon_notifications.png';
  static const String nutrition = recipes; // bowl 3D premium (pacote 1)
  static const String premium = '${_basePack2}icon_premium.png';
  static const String privacy = '${_basePack2}icon_security.png';
  static const String scanner = '${_base}icon_scanner.png';
  static const String search = '${_basePack2}icon_search.png';
  static const String settings = '${_basePack2}icon_settings.png';
  static const String share = '${_base}icon_share.png';
  static const String shoppingList = '${_base}icon_shopping_list.png';
  static const String sleep = '${_base}icon_sleep.png';
  static const String statistics = '${_basePack2}icon_progress.png';
  static const String streak = '${_basePack2}icon_streak.png';
  static const String support = '${_basePack2}icon_support.png';
  static const String video = '${_basePack2}icon_videos.png';
  static const String weight = '${_basePack2}icon_weight.png';
  static const String play = '${_basePack2}icon_play.png';
  static const String pause = '${_basePack2}icon_pause.png';
  static const String complete = '${_basePack2}icon_complete.png';
  static const String back = '${_basePack2}icon_back.png';
  static const String next = '${_basePack2}icon_next.png';
  static const String filter = '${_basePack2}icon_filter.png';
  static const String gallery = '${_basePack2}icon_gallery.png';
  static const String uploadPhoto = '${_basePack2}icon_upload_photo.png';
  static const String hydrationGoal = '${_basePack2}icon_hydration_goal.png';
  static const String workoutGoal = '${_basePack2}icon_workout_goal.png';
  static const String achievement = '${_basePack2}icon_achievement.png';

  // ---- Apelidos semânticos ----
  static const String camera = cameraFood;
  static const String timer = stopwatch;
  static const String measurement = bmiMeasure;
  static const String medal = medalRanking;
  static const String ranking = medalRanking;
  static const String course = courses;
  static const String food = nutrition;
  static const String location = gpsRunning;
  static const String ebook = courses;
  static const String water = hydration;
  static const String yoga = meditation;
  static const String cardio = healthHeart;
  static const String habits = checklist;
  static const String security = privacy;
  static const String favorites = favorite;
  static const String videos = video;
  static const String gps = gpsRunning;

  /// Todos os caminhos 3D + pacote 2 + legado residual (pré-cache / auditoria).
  static const List<String> all = [
    home, workout, recipes, progress, profile, hydration, calories, running,
    stopwatch, calendar, trophy, healthHeart, meditation, glutes, abs,
    audio, bmiMeasure, cameraFood, checklist, checkin, community, diary,
    evolution, beforeAfter, personal, courses, edit, favorite, goal,
    gpsRunning, login, logout, medalRanking, messages, notifications,
    premium, privacy, scanner, search, settings, share, shoppingList, sleep,
    statistics, streak, support, video, weight, play, pause, complete, back,
    next, filter, gallery, uploadPhoto, hydrationGoal, workoutGoal, achievement,
  ];

  static const List<String> all3d = [
    home, workout, recipes, progress, profile, hydration, calories, running,
    stopwatch, calendar, trophy, healthHeart, meditation, glutes, abs,
  ];

  static const List<String> allPack2 = [
    audio, bmiMeasure, cameraFood, checklist, checkin, community, diary,
    evolution, beforeAfter, personal, favorite, goal, gpsRunning, medalRanking,
    messages, notifications, premium, privacy, search, settings, statistics,
    streak, support, video, weight, play, pause, complete, back, next, filter,
    gallery, uploadPhoto, hydrationGoal, workoutGoal, achievement,
  ];
}
