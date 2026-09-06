class NutritionFirestorePaths {
  NutritionFirestorePaths._();

  static const String foods = 'foods';

  // Firestore exige path com nº par de segmentos (col/doc/col/doc).
  static String nutritionGoalsDoc(String uid) =>
      'users/$uid/nutritionGoals/current';

  static String dailyLogDoc(String uid, String dateKey) =>
      'users/$uid/dailyLogs/$dateKey';

  static String dailyMealDoc(String uid, String dateKey, String mealId) =>
      'users/$uid/dailyLogs/$dateKey/meals/$mealId';

  static String favoriteMealDoc(String uid, String id) =>
      'users/$uid/favoriteMeals/$id';

  static String recipeDoc(String uid, String id) => 'users/$uid/recipes/$id';

  static String waterLogDoc(String uid, String dateKey) =>
      'users/$uid/waterLogs/$dateKey';

  static String mealPhoto(String uid, String mealId) =>
      'users/$uid/mealPhotos/$mealId.jpg';

  static const legacyFoodDatabase = 'food_database';
}
