enum FoodCategory {
  frutas,
  verduras,
  legumes,
  carnes,
  peixes,
  frango,
  ovos,
  laticinios,
  bebidas,
  industrializados,
  doces,
  fastFood,
  suplementos,
  graosECereais,
}

extension FoodCategoryInfo on FoodCategory {
  String get label => switch (this) {
        FoodCategory.frutas => 'Frutas',
        FoodCategory.verduras => 'Verduras',
        FoodCategory.legumes => 'Legumes',
        FoodCategory.carnes => 'Carnes',
        FoodCategory.peixes => 'Peixes',
        FoodCategory.frango => 'Frango',
        FoodCategory.ovos => 'Ovos',
        FoodCategory.laticinios => 'Laticínios',
        FoodCategory.bebidas => 'Bebidas',
        FoodCategory.industrializados => 'Industrializados',
        FoodCategory.doces => 'Doces',
        FoodCategory.fastFood => 'Fast-food',
        FoodCategory.suplementos => 'Suplementos',
        FoodCategory.graosECereais => 'Grãos e cereais',
      };
}

/// Um alimento do banco — a "medida caseira" é o que aparece pra usuária
/// (ex.: "1 fatia", "1 copo"); [gramWeight] é o peso real em gramas que
/// corresponde a essa medida, usado pra escalar os macros se a porção
/// registrada for diferente.
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sodiumMg = 0,
    this.sugar = 0,
    this.servingSize = '100g',
    this.householdMeasure = '',
    this.gramWeight = 100,
  });

  final String id;
  final String name;
  final FoodCategory category;

  /// Todos os valores nutricionais abaixo são referentes a [servingSize]
  /// (por padrão, 100g).
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sodiumMg;
  final int sugar;
  final String servingSize;
  final String householdMeasure; // "1 fatia (25g)", "1 copo (200ml)"...
  final int gramWeight;

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category.name,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sodiumMg': sodiumMg,
        'sugar': sugar,
        'servingSize': servingSize,
        'householdMeasure': householdMeasure,
        'gramWeight': gramWeight,
      };

  factory FoodItem.fromMap(String id, Map<String, dynamic> m) => FoodItem(
        id: id,
        name: (m['name'] ?? '') as String,
        category: FoodCategory.values.firstWhere(
            (c) => c.name == m['category'],
            orElse: () => FoodCategory.industrializados),
        kcal: (m['kcal'] ?? 0) as int,
        protein: (m['protein'] ?? 0) as int,
        carbs: (m['carbs'] ?? 0) as int,
        fat: (m['fat'] ?? 0) as int,
        fiber: (m['fiber'] ?? 0) as int,
        sodiumMg: (m['sodiumMg'] ?? 0) as int,
        sugar: (m['sugar'] ?? 0) as int,
        servingSize: (m['servingSize'] ?? '100g') as String,
        householdMeasure: (m['householdMeasure'] ?? '') as String,
        gramWeight: (m['gramWeight'] ?? 100) as int,
      );
}
