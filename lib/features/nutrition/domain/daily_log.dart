import 'macro_totals.dart';
import 'meal.dart';
import 'water_log_entry.dart';

class DailyLog {
  const DailyLog({
    required this.date,
    required this.meals,
    required this.water,
    this.syncedAt,
  });

  final DateTime date;
  final List<Meal> meals;
  final WaterLogEntry water;
  final DateTime? syncedAt;

  MacroTotals get foodTotals =>
      meals.fold(MacroTotals.zero, (sum, meal) => sum + meal.totals);

  Map<String, dynamic> toMap() => {
        'date': dayKey(date),
        'meals': meals.map((m) => m.toMap()).toList(),
        'water': water.toMap(),
        'foodTotals': foodTotals.toMap(),
        if (syncedAt != null) 'syncedAt': syncedAt!.toIso8601String(),
      };

  factory DailyLog.fromMap(Map<String, dynamic> m) {
    final rawMeals = m['meals'] as List<dynamic>? ?? [];
    return DailyLog(
      date: _parseDayKey(m['date'] as String? ?? ''),
      meals: rawMeals
          .map((e) => Meal.fromMap(e as Map<String, dynamic>))
          .toList(),
      water: WaterLogEntry.fromMap(
          (m['water'] as Map<String, dynamic>?) ?? const {}),
      syncedAt: m['syncedAt'] != null
          ? DateTime.parse(m['syncedAt'] as String)
          : null,
    );
  }

  static String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static DateTime _parseDayKey(String key) {
    final parts = key.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }
    return DateTime.now();
  }
}
