import 'nutrition_enums.dart';

class UserGoals {
  const UserGoals({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.waterMl,
    required this.objective,
    required this.updatedAt,
    this.isManualOverride = false,
    this.weightKg,
    this.heightCm,
    this.age,
    this.sex,
    this.activityLevel,
  });

  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int waterMl;
  final NutritionObjective objective;
  final DateTime updatedAt;
  final bool isManualOverride;
  final double? weightKg;
  final double? heightCm;
  final int? age;
  final String? sex;
  final String? activityLevel;

  UserGoals copyWith({
    int? calories,
    int? proteinG,
    int? carbsG,
    int? fatG,
    int? waterMl,
    NutritionObjective? objective,
    DateTime? updatedAt,
    bool? isManualOverride,
    double? weightKg,
    double? heightCm,
    int? age,
    String? sex,
    String? activityLevel,
  }) =>
      UserGoals(
        calories: calories ?? this.calories,
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
        waterMl: waterMl ?? this.waterMl,
        objective: objective ?? this.objective,
        updatedAt: updatedAt ?? this.updatedAt,
        isManualOverride: isManualOverride ?? this.isManualOverride,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        age: age ?? this.age,
        sex: sex ?? this.sex,
        activityLevel: activityLevel ?? this.activityLevel,
      );

  Map<String, dynamic> toMap() => {
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'waterMl': waterMl,
        'objective': objective.name,
        'updatedAt': updatedAt.toIso8601String(),
        'isManualOverride': isManualOverride,
        if (weightKg != null) 'weightKg': weightKg,
        if (heightCm != null) 'heightCm': heightCm,
        if (age != null) 'age': age,
        if (sex != null) 'sex': sex,
        if (activityLevel != null) 'activityLevel': activityLevel,
      };

  factory UserGoals.fromMap(Map<String, dynamic> m) => UserGoals(
        calories: ((m['calories'] ?? 2000) as num).round(),
        proteinG: ((m['proteinG'] ?? 100) as num).round(),
        carbsG: ((m['carbsG'] ?? 200) as num).round(),
        fatG: ((m['fatG'] ?? 65) as num).round(),
        waterMl: ((m['waterMl'] ?? 2000) as num).round(),
        objective: NutritionObjective.values.firstWhere(
          (o) => o.name == m['objective'],
          orElse: () => NutritionObjective.manutencao,
        ),
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        isManualOverride: m['isManualOverride'] as bool? ?? false,
        weightKg: (m['weightKg'] as num?)?.toDouble(),
        heightCm: (m['heightCm'] as num?)?.toDouble(),
        age: (m['age'] as num?)?.round(),
        sex: m['sex'] as String?,
        activityLevel: m['activityLevel'] as String?,
      );
}
