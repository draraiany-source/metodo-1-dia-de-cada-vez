import '../../domain/daily_log.dart';
import '../../domain/macro_totals.dart';
import '../../domain/user_goals.dart';

/// View model agregado para a tela B1 (dados reais).
///
/// O arquivo permanece em `data/mock/` por compatibilidade de imports;
/// o provider de produção não usa mais dados fictícios.
class NutritionDashboardViewData {
  const NutritionDashboardViewData({
    required this.date,
    required this.goals,
    required this.log,
    this.isMock = false,
  });

  final DateTime date;
  final UserGoals goals;
  final DailyLog log;
  final bool isMock;

  MacroTotals get consumed => log.foodTotals;

  int get remainingKcal => (goals.calories - consumed.kcal).clamp(0, 99999);

  int get remainingProteinG =>
      (goals.proteinG - consumed.proteinG).clamp(0, 99999);

  int get remainingCarbsG => (goals.carbsG - consumed.carbsG).clamp(0, 99999);

  int get remainingFatG => (goals.fatG - consumed.fatG).clamp(0, 99999);

  int get remainingWaterMl =>
      (goals.waterMl - log.water.consumedMl).clamp(0, 99999);

  double get calorieProgress =>
      goals.calories <= 0 ? 0 : consumed.kcal / goals.calories;
}
