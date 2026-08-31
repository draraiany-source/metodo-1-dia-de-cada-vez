import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/food_database_repository.dart';
import '../domain/food_database_models.dart';

final foodDatabaseRepositoryProvider =
    Provider((ref) => FoodDatabaseRepository());

final foodDatabaseProvider = FutureProvider<List<FoodItem>>((ref) {
  return ref.read(foodDatabaseRepositoryProvider).fetchAll();
});
