import '../domain/nutrition_enums.dart';
import '../domain/user_goals.dart';

class GoalsService {
  static const medicalDisclaimer =
      'Estimativa informativa. Nao substitui orientacao medica ou nutricional.';

  double estimateTmb({
    required double weightKg,
    required double heightCm,
    required int age,
    required String sex,
  }) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    final isFemale = sex.toLowerCase().startsWith('f');
    return isFemale ? base - 161 : base + 5;
  }

  double activityMultiplier(String? level) {
    final key = level?.toLowerCase() ?? '';
    if (key.contains('sedent')) return 1.2;
    if (key.contains('leve')) return 1.375;
    if (key.contains('moderado')) return 1.55;
    if (key.contains('intenso') && key.contains('muito')) return 1.9;
    if (key.contains('intenso')) return 1.725;
    return 1.375;
  }

  UserGoals suggest({
    required double weightKg,
    required double heightCm,
    required int age,
    required String sex,
    required NutritionObjective objective,
    String? activityLevel,
  }) {
    final tmb = estimateTmb(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      sex: sex,
    );
    final get = tmb * activityMultiplier(activityLevel);

    final calories = switch (objective) {
      NutritionObjective.emagrecimento => (get * 0.85).round(),
      NutritionObjective.manutencao => get.round(),
      NutritionObjective.ganhoMassa => (get * 1.12).round(),
    };

    final proteinG = (weightKg * 1.6).round();
    final fatG = (calories * 0.28 / 9).round();
    final carbsG = ((calories - proteinG * 4 - fatG * 9) / 4).round().clamp(50, 9999);
    final waterMl = (weightKg * 35).round();

    return UserGoals(
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      waterMl: waterMl,
      objective: objective,
      updatedAt: DateTime.now(),
      isManualOverride: false,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      sex: sex,
      activityLevel: activityLevel,
    );
  }
}
