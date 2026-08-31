import '../food_database_repository.dart';
import '../../domain/food_database_models.dart';

class FoodRepository {
  FoodRepository(this._database);

  final FoodDatabaseRepository _database;

  Future<List<FoodItem>> fetchAll() => _database.fetchAll();

  Future<void> create(FoodItem item) => _database.create(item);

  Future<void> delete(String id) => _database.delete(id);
}
