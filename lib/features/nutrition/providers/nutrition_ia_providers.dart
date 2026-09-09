import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/calorie_vision_repository.dart';
import '../data/food_database_repository.dart';
import '../data/meal_photo_storage_service.dart';
import '../data/repositories/favorite_meal_repository.dart';
import '../data/repositories/food_repository.dart';
import '../data/repositories/meal_repository.dart';
import '../data/repositories/nutrition_diary_repository.dart';
import '../data/repositories/recipe_repository.dart';
import '../data/repositories/user_goals_repository.dart';
import '../services/food_search_service.dart';
import '../services/goals_service.dart';
import '../services/meal_ai_service.dart';
import '../services/nutrition_calculation_service.dart';
import '../services/nutrition_sync_service.dart';

String _nutritionUserId(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id ?? 'guest';
}

final nutritionCalculationServiceProvider =
    Provider((_) => NutritionCalculationService());

final goalsServiceProvider = Provider((_) => GoalsService());

final nutritionSyncServiceProvider =
    Provider((_) => const NutritionSyncService());

final foodRepositoryProvider = Provider(
  (ref) => FoodRepository(FoodDatabaseRepository()),
);

final foodSearchServiceProvider = Provider(
  (ref) => FoodSearchService(FoodDatabaseRepository()),
);

final mealAiServiceProvider = Provider(
  (ref) => MealAiService(CalorieVisionRepository()),
);

final mealRepositoryProvider = Provider(
  (ref) => MealRepository(userId: _nutritionUserId(ref)),
);

final nutritionDiaryRepositoryProvider = Provider(
  (ref) => NutritionDiaryRepository(userId: _nutritionUserId(ref)),
);

final mealPhotoStorageServiceProvider = Provider(
  (_) => const MealPhotoStorageService(),
);

final userGoalsRepositoryProvider = Provider(
  (ref) => UserGoalsRepository(userId: _nutritionUserId(ref)),
);

final favoriteMealRepositoryProvider = Provider(
  (ref) => FavoriteMealRepository(userId: _nutritionUserId(ref)),
);

final nutritionRecipeRepositoryProvider = Provider(
  (ref) => RecipeRepository(userId: _nutritionUserId(ref)),
);
