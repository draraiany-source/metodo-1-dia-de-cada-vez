/// Chaves SharedPreferences do módulo Nutrição IA (isoladas do legado).
class NutritionLocalKeys {
  NutritionLocalKeys._();

  static const prefix = 'nutrition_ia_';

  static String dailyLog(String userId, String dateKey) =>
      '${prefix}daily_${userId}_$dateKey';

  static String userGoals(String userId) => '${prefix}goals_$userId';

  static String favoriteMeals(String userId) => '${prefix}favorites_$userId';

  static String recipes(String userId) => '${prefix}recipes_$userId';

  static String waterLog(String userId, String dateKey) =>
      '${prefix}water_${userId}_$dateKey';

  static String syncQueue(String userId) => '${prefix}sync_queue_$userId';
}
