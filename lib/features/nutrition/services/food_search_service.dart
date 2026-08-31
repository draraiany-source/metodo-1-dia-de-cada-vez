import '../data/food_database_repository.dart';
import '../domain/food_database_models.dart';

class FoodSearchService {
  FoodSearchService(this._repository);

  final FoodDatabaseRepository _repository;
  List<FoodItem>? _cache;

  Future<List<FoodItem>> search(String query, {int limit = 30}) async {
    final q = query.trim().toLowerCase();
    _cache ??= await _repository.fetchAll();
    if (q.isEmpty) return _cache!.take(limit).toList();

    final scored = <({FoodItem food, int rank})>[];
    for (final food in _cache!) {
      final name = food.name.toLowerCase();
      if (name.contains(q)) {
        scored.add((food: food, rank: name.startsWith(q) ? 0 : 1));
      }
    }
    scored.sort((a, b) => a.rank.compareTo(b.rank));
    return scored.take(limit).map((e) => e.food).toList();
  }

  Future<FoodItem?> findById(String id) async {
    _cache ??= await _repository.fetchAll();
    for (final food in _cache!) {
      if (food.id == id) return food;
    }
    return null;
  }

  void invalidateCache() => _cache = null;
}
