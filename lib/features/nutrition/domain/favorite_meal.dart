import 'meal_item.dart';

/// Refeição favorita reutilizável com um toque (Parte B9).
class FavoriteMeal {
  const FavoriteMeal({
    required this.id,
    required this.name,
    required this.items,
    this.createdAt,
  });

  final String id;
  final String name;
  final List<MealItem> items;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'items': items.map((i) => i.toMap()).toList(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory FavoriteMeal.fromMap(Map<String, dynamic> m) {
    final raw = m['items'] as List<dynamic>? ?? [];
    return FavoriteMeal(
      id: m['id'] as String,
      name: (m['name'] ?? '') as String,
      items: raw
          .map((e) => MealItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: m['createdAt'] != null
          ? DateTime.parse(m['createdAt'] as String)
          : null,
    );
  }
}
