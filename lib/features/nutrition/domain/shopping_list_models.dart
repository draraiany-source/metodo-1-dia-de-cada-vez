import 'food_database_models.dart';

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.bought = false,
    this.quantity = '',
  });

  final String id;
  final String name;
  final FoodCategory category;
  final bool bought;
  final String quantity;

  ShoppingItem copyWith({bool? bought}) => ShoppingItem(
        id: id,
        name: name,
        category: category,
        bought: bought ?? this.bought,
        quantity: quantity,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category.name,
        'bought': bought,
        'quantity': quantity,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> m) => ShoppingItem(
        id: m['id'] as String,
        name: m['name'] as String,
        category: FoodCategory.values.firstWhere((c) => c.name == m['category'],
            orElse: () => FoodCategory.industrializados),
        bought: (m['bought'] ?? false) as bool,
        quantity: (m['quantity'] ?? '') as String,
      );
}
