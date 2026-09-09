/// Uma refeição/alimento registrado no diário alimentar do dia.
class FoodEntry {
  FoodEntry({
    required this.id,
    required this.name,
    required this.kcal,
    required this.date,
    this.source = FoodEntrySource.manual,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    MealType? mealType,
  }) : mealType = mealType ?? MealTypeInfo.fromHour(date.hour);

  final String id;
  final String name;
  final int kcal;
  final DateTime date;
  final FoodEntrySource source;
  final MealType mealType;

  /// Macros em gramas — 0 quando não estimado (entradas manuais antigas ou
  /// registro rápido sem detalhamento).
  final int protein;
  final int carbs;
  final int fat;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'kcal': kcal,
        'date': date.toIso8601String(),
        'source': source.name,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'mealType': mealType.name,
      };

  static FoodEntry fromMap(Map<String, dynamic> m) => FoodEntry(
        id: m['id'] as String,
        name: m['name'] as String,
        kcal: (m['kcal'] as num).round(),
        date: DateTime.parse(m['date'] as String),
        source: FoodEntrySource.values.firstWhere(
          (s) => s.name == m['source'],
          orElse: () => FoodEntrySource.manual,
        ),
        protein: ((m['protein'] ?? 0) as num).round(),
        carbs: ((m['carbs'] ?? 0) as num).round(),
        fat: ((m['fat'] ?? 0) as num).round(),
        mealType: m['mealType'] != null
            ? MealType.values.firstWhere((t) => t.name == m['mealType'],
                orElse: () => MealType.lancheExtra)
            : null,
      );
}

enum FoodEntrySource { manual, foto }

/// Categoria da refeição no diário — auto-detectada pelo horário do
/// registro (editável depois, se a usuária quiser corrigir).
enum MealType {
  cafeDaManha,
  lancheDaManha,
  almoco,
  lancheDaTarde,
  jantar,
  ceia,
  lancheExtra,
}

extension MealTypeInfo on MealType {
  String get label => switch (this) {
        MealType.cafeDaManha => 'Café da manhã',
        MealType.lancheDaManha => 'Lanche da manhã',
        MealType.almoco => 'Almoço',
        MealType.lancheDaTarde => 'Lanche da tarde',
        MealType.jantar => 'Jantar',
        MealType.ceia => 'Ceia',
        MealType.lancheExtra => 'Lanches extras',
      };

  static MealType fromHour(int hour) {
    if (hour >= 5 && hour < 10) return MealType.cafeDaManha;
    if (hour >= 10 && hour < 12) return MealType.lancheDaManha;
    if (hour >= 12 && hour < 15) return MealType.almoco;
    if (hour >= 15 && hour < 18) return MealType.lancheDaTarde;
    if (hour >= 18 && hour < 21) return MealType.jantar;
    if (hour >= 21 && hour < 23) return MealType.ceia;
    return MealType.lancheExtra;
  }
}

/// Calculadora de meta de água (ml) a partir do peso corporal.
/// Fórmula padrão usada por nutricionistas: ~35ml por kg de peso.
class WaterCalculator {
  WaterCalculator._();

  static const int mlPerGlass = 250;
  static const int mlPerKg = 35;
  static const int defaultGoalMl = 2000; // usado quando não há peso cadastrado
  /// Evita UI travada se o peso vier inválido (ex.: gramas, altura em m).
  static const int minGoalGlasses = 4;
  static const int maxGoalGlasses = 16;

  /// Aceita só pesos corporais plausíveis em kg; caso contrário usa o default.
  static double? sanitizeWeightKg(double? weightKg) {
    if (weightKg == null || weightKg < 20 || weightKg > 300) return null;
    return weightKg;
  }

  static int goalMlFor(double? weightKg) {
    final w = sanitizeWeightKg(weightKg);
    if (w == null) return defaultGoalMl;
    return (w * mlPerKg).round();
  }

  static int goalGlassesFor(double? weightKg) {
    final ml = goalMlFor(weightKg);
    return (ml / mlPerGlass).ceil().clamp(minGoalGlasses, maxGoalGlasses);
  }
}

/// Calculadora de IMC — separada do [AppUser] para permitir simular valores
/// antes de salvar (a usuária digita peso/altura e vê o resultado na hora).
class BmiCalculator {
  BmiCalculator._();

  static double? calculate({required double? weightKg, required double? heightM}) {
    if (weightKg == null || heightM == null || heightM <= 0) return null;
    return weightKg / (heightM * heightM);
  }

  static String categoryFor(double? bmi) {
    if (bmi == null) return '—';
    if (bmi < 18.5) return 'Abaixo do peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    if (bmi < 35) return 'Obesidade grau I';
    if (bmi < 40) return 'Obesidade grau II';
    return 'Obesidade grau III';
  }
}
