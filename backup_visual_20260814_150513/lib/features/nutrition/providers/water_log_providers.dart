import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Copos de água bebidos hoje — persistido localmente por dia (mesma ideia
/// do diário alimentar), pra alimentar Dashboard e Relatórios com dado real
/// em vez de estado efêmero da tela.
class WaterLogNotifier extends StateNotifier<int> {
  WaterLogNotifier() : super(0) {
    _load();
  }

  static String _keyFor(DateTime d) => 'water_log_${d.year}-${d.month}-${d.day}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_keyFor(DateTime.now())) ?? 0;
  }

  Future<void> setGlasses(int glasses) async {
    state = glasses;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFor(DateTime.now()), glasses);
  }

  /// Histórico dos últimos [days] dias (hoje incluso), mais antigo primeiro.
  static Future<Map<DateTime, int>> history(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final map = <DateTime, int>{};
    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      map[day] = prefs.getInt(_keyFor(day)) ?? 0;
    }
    return map;
  }
}

final waterLogProvider = StateNotifierProvider<WaterLogNotifier, int>((ref) {
  return WaterLogNotifier();
});
