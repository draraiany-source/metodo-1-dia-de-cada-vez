import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/nutrition_models.dart';

/// Diário alimentar do dia — soma de calorias e lista de itens.
/// Persiste localmente (SharedPreferences), guardado por dia, no mesmo
/// padrão de chave usado pelas Missões (evita duplicar lógica de "hoje").
class FoodLogNotifier extends StateNotifier<List<FoodEntry>> {
  FoodLogNotifier() : super([]) {
    _load();
  }

  static String _keyFor(DateTime d) =>
      'food_log_${d.year}-${d.month}-${d.day}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyFor(DateTime.now())) ?? [];
    final parsed = <FoodEntry>[];
    for (final s in raw) {
      try {
        parsed.add(FoodEntry.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada corrompida descartada */}
    }
    state = parsed;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyFor(DateTime.now()),
      state.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  Future<void> add(String name, int kcal,
      {FoodEntrySource source = FoodEntrySource.manual,
      int protein = 0,
      int carbs = 0,
      int fat = 0,
      MealType? mealType}) async {
    final entry = FoodEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      kcal: kcal,
      date: DateTime.now(),
      source: source,
      protein: protein,
      carbs: carbs,
      fat: fat,
      mealType: mealType,
    );
    state = [...state, entry];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  /// Remove todos os registros de hoje pertencentes a [type] — usado para
  /// "desmarcar" uma refeição do plano (o card de Meu Plano funciona como
  /// um toggle sobre o mesmo diário alimentar já existente).
  Future<void> removeMealType(MealType type) async {
    state = state.where((e) => e.mealType != type).toList();
    await _persist();
  }
}

final foodLogProvider =
    StateNotifierProvider<FoodLogNotifier, List<FoodEntry>>((ref) {
  return FoodLogNotifier();
});

/// Total de calorias já registradas hoje.
final todayKcalProvider = Provider<int>((ref) {
  final entries = ref.watch(foodLogProvider);
  return entries.fold<int>(0, (sum, e) => sum + e.kcal);
});

/// Total de macros (proteína/carbo/gordura, em gramas) registrados hoje.
final todayMacrosProvider = Provider<(int protein, int carbs, int fat)>((ref) {
  final entries = ref.watch(foodLogProvider);
  return (
    entries.fold<int>(0, (s, e) => s + e.protein),
    entries.fold<int>(0, (s, e) => s + e.carbs),
    entries.fold<int>(0, (s, e) => s + e.fat),
  );
});

/// Histórico de calorias dos últimos [days] dias (hoje incluso).
/// Lê diretamente das chaves diárias do SharedPreferences (mesmo padrão de
/// [FoodLogNotifier._keyFor]) sem precisar carregar tudo em memória.
Future<Map<DateTime, int>> foodKcalHistory(int days) async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final map = <DateTime, int>{};
  for (var i = days - 1; i >= 0; i--) {
    final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final key = FoodLogNotifier._keyFor(day);
    final raw = prefs.getStringList(key) ?? [];
    var total = 0;
    for (final s in raw) {
      try {
        total += (jsonDecode(s) as Map<String, dynamic>)['kcal'] as int;
      } catch (_) {/* entrada corrompida ignorada */}
    }
    map[day] = total;
  }
  return map;
}
