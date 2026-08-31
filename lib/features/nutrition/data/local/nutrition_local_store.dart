import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_local_keys.dart';

class NutritionLocalStore {
  Future<Map<String, dynamic>?> readJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<List<Map<String, dynamic>>> readJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? [];
    final out = <Map<String, dynamic>>[];
    for (final item in raw) {
      try {
        out.add(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {/* descarta corrompido */}
    }
    return out;
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      items.map(jsonEncode).toList(),
    );
  }

  static String dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static String dailyLogKey(String userId, DateTime day) =>
      NutritionLocalKeys.dailyLog(userId, dayKey(day));
}
