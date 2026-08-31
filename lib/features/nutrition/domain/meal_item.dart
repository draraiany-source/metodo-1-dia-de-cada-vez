import 'macro_totals.dart';
import 'nutrition_enums.dart';

/// Um alimento dentro de uma refeição registrada.
class MealItem {
  const MealItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.weightGrams,
    required this.source,
    required this.macros,
    this.foodId,
    this.aiConfidence,
    this.notes,
  });

  final String id;

  /// Referência opcional ao banco (`foods/{foodId}` ou seed local).
  final String? foodId;
  final String name;
  final double quantity;
  final FoodUnit unit;

  /// Peso equivalente em gramas — base para cálculo de macros.
  final double weightGrams;
  final MealItemSource source;
  final MacroTotals macros;
  final AiConfidence? aiConfidence;
  final String? notes;

  MealItem copyWith({
    String? id,
    String? foodId,
    String? name,
    double? quantity,
    FoodUnit? unit,
    double? weightGrams,
    MealItemSource? source,
    MacroTotals? macros,
    AiConfidence? aiConfidence,
    String? notes,
  }) =>
      MealItem(
        id: id ?? this.id,
        foodId: foodId ?? this.foodId,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        weightGrams: weightGrams ?? this.weightGrams,
        source: source ?? this.source,
        macros: macros ?? this.macros,
        aiConfidence: aiConfidence ?? this.aiConfidence,
        notes: notes ?? this.notes,
      );

  /// Confirmação explícita do usuário (Parte A.3).
  MealItem confirmByUser() => copyWith(source: MealItemSource.userConfirmed);

  Map<String, dynamic> toMap() => {
        'id': id,
        if (foodId != null) 'foodId': foodId,
        'name': name,
        'quantity': quantity,
        'unit': unit.name,
        'weightGrams': weightGrams,
        'source': source.name,
        'macros': macros.toMap(),
        if (aiConfidence != null) 'aiConfidence': aiConfidence!.name,
        if (notes != null) 'notes': notes,
      };

  factory MealItem.fromMap(Map<String, dynamic> m) => MealItem(
        id: m['id'] as String,
        foodId: m['foodId'] as String?,
        name: (m['name'] ?? '') as String,
        quantity: ((m['quantity'] ?? 1) as num).toDouble(),
        unit: FoodUnit.values.firstWhere(
          (u) => u.name == m['unit'],
          orElse: () => FoodUnit.gram,
        ),
        weightGrams: ((m['weightGrams'] ?? 0) as num).toDouble(),
        source: MealItemSource.values.firstWhere(
          (s) => s.name == m['source'],
          orElse: () => MealItemSource.manual,
        ),
        macros: MacroTotals.fromMap(
            (m['macros'] as Map<String, dynamic>?) ?? const {}),
        aiConfidence: AiConfidenceX.tryParse(m['aiConfidence'] as String?),
        notes: m['notes'] as String?,
      );
}
