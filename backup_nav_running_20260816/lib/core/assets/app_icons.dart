/// ============================================================================
/// CATÁLOGO CENTRALIZADO DE ÍCONES — arte 3D premium (PNG transparente).
///
/// Preferência: `assets/images/icons_3d/` (nomes `*_3d.png`).
/// Fallback legado: `assets/icons/` para ícones ainda não migrados.
/// Use sempre `AppIcons.x`, nunca caminhos soltos pelo app.
/// ============================================================================
class AppIcons {
  AppIcons._();

  static const String _base = 'assets/icons/';
  static const String _base3d = 'assets/images/icons_3d/';

  // ---- Menu / navegação (3D) ----
  static const String home = '${_base3d}icon_home_3d.png';
  static const String workout = '${_base3d}icon_workout_3d.png';
  static const String workoutDumbbell = workout;
  static const String recipes = '${_base3d}icon_recipes_3d.png';
  static const String progress = '${_base3d}icon_progress_3d.png';
  static const String profile = '${_base3d}icon_profile_3d.png';

  // ---- Métricas / features (3D) ----
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

  // ---- Restante (legado assets/icons — ainda em uso) ----
  static const String audio = '${_base}icon_audio.png';
  static const String bmiMeasure = '${_base}icon_bmi_measure.png';
  static const String cameraFood = '${_base}icon_camera_food.png';
  static const String checklist = '${_base}icon_checklist.png';
  static const String community = '${_base}icon_community.png';
  static const String courses = '${_base}icon_courses.png';
  static const String edit = '${_base}icon_edit.png';
  static const String favorite = '${_base}icon_favorite.png';
  static const String goal = '${_base}icon_goal.png';
  static const String gpsRunning = '${_base}icon_gps_running.png';
  static const String login = '${_base}icon_login.png';
  static const String logout = '${_base}icon_logout.png';
  static const String medalRanking = '${_base}icon_medal_ranking.png';
  static const String messages = '${_base}icon_messages.png';
  static const String notifications = '${_base}icon_notifications.png';
  static const String nutrition = recipes; // bowl 3D premium
  static const String premium = '${_base}icon_premium.png';
  static const String privacy = '${_base}icon_privacy.png';
  static const String scanner = '${_base}icon_scanner.png';
  static const String search = '${_base}icon_search.png';
  static const String settings = '${_base}icon_settings.png';
  static const String share = '${_base}icon_share.png';
  static const String shoppingList = '${_base}icon_shopping_list.png';
  static const String sleep = '${_base}icon_sleep.png';
  static const String statistics = '${_base}icon_statistics.png';
  static const String streak = '${_base}icon_streak.png';
  static const String support = '${_base}icon_support.png';
  static const String video = '${_base}icon_video.png';
  static const String weight = '${_base}icon_weight.png';

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

  /// Todos os caminhos 3D + legado (pré-cache / auditoria).
  static const List<String> all = [
    home, workout, recipes, progress, profile, hydration, calories, running,
    stopwatch, calendar, trophy, healthHeart, meditation, glutes, abs,
    audio, bmiMeasure, cameraFood, checklist, community, courses, edit,
    favorite, goal, gpsRunning, login, logout, medalRanking, messages,
    notifications, premium, privacy, scanner, search, settings, share,
    shoppingList, sleep, statistics, streak, support, video, weight,
  ];

  static const List<String> all3d = [
    home, workout, recipes, progress, profile, hydration, calories, running,
    stopwatch, calendar, trophy, healthHeart, meditation, glutes, abs,
  ];
}
