import 'macro_totals.dart';
import 'meal_item.dart';
import 'nutrition_enums.dart';
import 'nutrition_models.dart';

class Meal {
  const Meal({
    required this.id,
    required this.mealType,
    required this.recordedAt,
    required this.items,
    this.photoStoragePath,
    this.userConfirmed = false,
    this.notes,
  });

  final String id;
  final MealType mealType;
  final DateTime recordedAt;
  final String? photoStoragePath;
  final List<MealItem> items;
  final bool userConfirmed;
  final String? notes;

  MacroTotals get totals =>
      items.fold(MacroTotals.zero, (sum, item) => sum + item.macros);

  bool get hasUnconfirmedAiItems => items.any(
        (i) =>
            i.source == MealItemSource.iaEstimate ||
            i.source == MealItemSource.iaOnly,
      );

  Meal copyWith({
    String? id,
    MealType? mealType,
    DateTime? recordedAt,
    String? photoStoragePath,
    List<MealItem>? items,
    bool? userConfirmed,
    String? notes,
  }) =>
      Meal(
        id: id ?? this.id,
        mealType: mealType ?? this.mealType,
        recordedAt: recordedAt ?? this.recordedAt,
        photoStoragePath: photoStoragePath ?? this.photoStoragePath,
        items: items ?? this.items,
        userConfirmed: userConfirmed ?? this.userConfirmed,
        notes: notes ?? this.notes,
      );

  Meal confirmByUser() => copyWith(
        userConfirmed: true,
        items: items.map((i) => i.confirmByUser()).toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'mealType': mealType.name,
        'recordedAt': recordedAt.toIso8601String(),
        if (photoStoragePath != null) 'photoStoragePath': photoStoragePath,
        'items': items.map((i) => i.toMap()).toList(),
        'userConfirmed': userConfirmed,
        'totals': totals.toMap(),
        if (notes != null) 'notes': notes,
      };

  factory Meal.fromMap(Map<String, dynamic> m) {
    final rawItems = m['items'] as List<dynamic>? ?? [];
    return Meal(
      id: m['id'] as String,
      mealType: MealType.values.firstWhere(
        (t) => t.name == m['mealType'],
        orElse: () => MealType.lancheExtra,
      ),
      recordedAt: DateTime.parse(m['recordedAt'] as String),
      photoStoragePath: m['photoStoragePath'] as String?,
      items: rawItems
          .map((e) => MealItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      userConfirmed: m['userConfirmed'] as bool? ?? false,
      notes: m['notes'] as String?,
    );
  }
}
