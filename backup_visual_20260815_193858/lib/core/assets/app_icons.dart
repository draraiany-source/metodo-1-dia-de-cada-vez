/// ============================================================================
/// CATÁLOGO CENTRALIZADO DE ÍCONES — arte oficial PNG (transparente, 1024²).
///
/// Os nomes primários batem 1:1 com os arquivos entregues em `assets/icons/`.
/// Abaixo há APELIDOS semânticos (getters) para os nomes pedidos no briefing,
/// evitando caminhos soltos pelo app. Use sempre `AppIcons.x`, nunca a string.
/// ============================================================================
class AppIcons {
  AppIcons._();

  static const String _base = 'assets/icons/';

  // ---- Arquivos oficiais entregues (nome = arquivo) ----
  static const String audio = '${_base}icon_audio.png';
  static const String bmiMeasure = '${_base}icon_bmi_measure.png';
  static const String calendar = '${_base}icon_calendar.png';
  static const String calories = '${_base}icon_calories.png';
  static const String cameraFood = '${_base}icon_camera_food.png';
  static const String checklist = '${_base}icon_checklist.png';
  static const String community = '${_base}icon_community.png';
  static const String courses = '${_base}icon_courses.png';
  static const String edit = '${_base}icon_edit.png';
  static const String favorite = '${_base}icon_favorite.png';
  static const String goal = '${_base}icon_goal.png';
  static const String gpsRunning = '${_base}icon_gps_running.png';
  static const String healthHeart = '${_base}icon_health_heart.png';
  static const String home = '${_base}icon_home.png';
  static const String hydration = '${_base}icon_hydration.png';
  static const String login = '${_base}icon_login.png';
  static const String logout = '${_base}icon_logout.png';
  static const String medalRanking = '${_base}icon_medal_ranking.png';
  static const String meditation = '${_base}icon_meditation.png';
  static const String messages = '${_base}icon_messages.png';
  static const String notifications = '${_base}icon_notifications.png';
  static const String nutrition = '${_base}icon_nutrition.png';
  static const String premium = '${_base}icon_premium.png';
  static const String privacy = '${_base}icon_privacy.png';
  static const String profile = '${_base}icon_profile.png';
  static const String progress = '${_base}icon_progress.png';
  static const String recipes = '${_base}icon_recipes.png';
  static const String running = '${_base}icon_running.png';
  static const String scanner = '${_base}icon_scanner.png';
  static const String search = '${_base}icon_search.png';
  static const String settings = '${_base}icon_settings.png';
  static const String share = '${_base}icon_share.png';
  static const String shoppingList = '${_base}icon_shopping_list.png';
  static const String sleep = '${_base}icon_sleep.png';
  static const String statistics = '${_base}icon_statistics.png';
  static const String stopwatch = '${_base}icon_stopwatch.png';
  static const String streak = '${_base}icon_streak.png';
  static const String support = '${_base}icon_support.png';
  static const String trophy = '${_base}icon_trophy.png';
  static const String video = '${_base}icon_video.png';
  static const String weight = '${_base}icon_weight.png';
  static const String workoutDumbbell = '${_base}icon_workout_dumbbell.png';

  // ---- Apelidos semânticos (nomes do briefing → arquivo existente) ----
  static const String camera = cameraFood;
  static const String timer = stopwatch;
  static const String measurement = bmiMeasure;
  static const String medal = medalRanking;
  static const String ranking = medalRanking;
  static const String course = courses;
  static const String food = nutrition;
  static const String workout = workoutDumbbell;
  static const String location = gpsRunning; // sem ícone dedicado de localização
  static const String ebook = courses; // sem ícone dedicado de e-book (ver relatório)

  /// Lista de todos os caminhos (útil para pré-cache seletivo, se desejado).
  static const List<String> all = [
    audio, bmiMeasure, calendar, calories, cameraFood, checklist, community,
    courses, edit, favorite, goal, gpsRunning, healthHeart, home, hydration,
    login, logout, medalRanking, meditation, messages, notifications, nutrition,
    premium, privacy, profile, progress, recipes, running, scanner, search,
    settings, share, shoppingList, sleep, statistics, stopwatch, streak,
    support, trophy, video, weight, workoutDumbbell,
  ];
}
