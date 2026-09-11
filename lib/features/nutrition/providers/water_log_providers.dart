import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Um gole/registro individual de água no dia.
@immutable
class WaterSip {
  const WaterSip({
    required this.id,
    required this.ml,
    required this.at,
  });

  final String id;
  final int ml;
  final DateTime at;

  Map<String, dynamic> toMap() => {
        'id': id,
        'ml': ml,
        'at': at.toIso8601String(),
      };

  factory WaterSip.fromMap(Map<String, dynamic> m) => WaterSip(
        id: (m['id'] as String?) ??
            'legacy_${m['at']}_${m['ml']}',
        ml: ((m['ml'] ?? 0) as num).round(),
        at: DateTime.tryParse(m['at'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Estado do dia: registros com horário + meta opcional personalizada.
@immutable
class WaterDayState {
  const WaterDayState({
    this.entries = const [],
    this.customGoalMl,
  });

  final List<WaterSip> entries;
  final int? customGoalMl;

  int get totalMl => entries.fold(0, (s, e) => s + e.ml);

  /// Compatível com missões/Home (250 ml ≈ 1 copo).
  int get glassesApprox => (totalMl / 250).round().clamp(0, 99);

  List<WaterSip> get newestFirst {
    final list = [...entries]..sort((a, b) => b.at.compareTo(a.at));
    return list;
  }

  WaterDayState copyWith({
    List<WaterSip>? entries,
    int? customGoalMl,
    bool clearCustomGoal = false,
  }) {
    return WaterDayState(
      entries: entries ?? this.entries,
      customGoalMl: clearCustomGoal ? null : (customGoalMl ?? this.customGoalMl),
    );
  }
}

/// Persistência local por dia (entradas + meta custom).
/// Mantém a chave legada `water_log_Y-M-D` (int de copos) sincronizada
/// para Home/missões/nutrição não quebrarem.
class WaterLogNotifier extends StateNotifier<WaterDayState> {
  WaterLogNotifier() : super(const WaterDayState()) {
    _load();
  }

  DateTime _loadedDay = DateTime.now();

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  static String _entriesKey(DateTime d) => 'water_entries_${_dayKey(d)}';
  static String _glassesKey(DateTime d) => 'water_log_${d.year}-${d.month}-${d.day}';
  static const _goalKey = 'water_goal_ml_override';

  bool get _isSameLocalDay {
    final now = DateTime.now();
    return now.year == _loadedDay.year &&
        now.month == _loadedDay.month &&
        now.day == _loadedDay.day;
  }

  Future<void> _ensureToday() async {
    if (_isSameLocalDay) return;
    await _load();
  }

  /// Recarrega o dia corrente (útil ao retomar o app após meia-noite).
  Future<void> ensureToday() => _ensureToday();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    _loadedDay = DateTime(now.year, now.month, now.day);
    final raw = prefs.getString(_entriesKey(now));
    var entries = <WaterSip>[];
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        entries = list
            .map((e) => WaterSip.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        entries = [];
      }
    }

    // Migração: só tinha contagem de copos → cria registros 250 ml.
    if (entries.isEmpty) {
      final glasses = prefs.getInt(_glassesKey(now)) ?? 0;
      if (glasses > 0) {
        final base = DateTime(now.year, now.month, now.day, 8);
        entries = List.generate(glasses, (i) {
          return WaterSip(
            id: 'migrated_${now.millisecondsSinceEpoch}_$i',
            ml: 250,
            at: base.add(Duration(minutes: i * 45)),
          );
        });
      }
    }

    final goal = prefs.getInt(_goalKey);
    state = WaterDayState(
      entries: entries,
      customGoalMl: goal != null && goal >= 500 ? goal : null,
    );
    await _persistGlassesMirror(prefs);
  }

  Future<void> _persist(SharedPreferences prefs) async {
    final now = DateTime.now();
    await prefs.setString(
      _entriesKey(now),
      jsonEncode(state.entries.map((e) => e.toMap()).toList()),
    );
    if (state.customGoalMl != null) {
      await prefs.setInt(_goalKey, state.customGoalMl!);
    }
    await _persistGlassesMirror(prefs);
  }

  Future<void> _persistGlassesMirror(SharedPreferences prefs) async {
    final now = DateTime.now();
    await prefs.setInt(_glassesKey(now), state.glassesApprox);
  }

  Future<void> addMl(int ml) async {
    if (ml <= 0) return;
    await _ensureToday();
    final sip = WaterSip(
      id: 'w_${DateTime.now().microsecondsSinceEpoch}',
      ml: ml,
      at: DateTime.now(),
    );
    state = state.copyWith(entries: [...state.entries, sip]);
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  Future<void> removeSip(String id) async {
    await _ensureToday();
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  Future<void> setCustomGoalMl(int? ml) async {
    await _ensureToday();
    final prefs = await SharedPreferences.getInstance();
    if (ml == null || ml < 500) {
      await prefs.remove(_goalKey);
      state = state.copyWith(clearCustomGoal: true);
    } else {
      state = state.copyWith(customGoalMl: ml.clamp(500, 8000));
      await prefs.setInt(_goalKey, state.customGoalMl!);
    }
  }

  /// Compat: APIs antigas que ainda setam “copos”.
  Future<void> setGlasses(int glasses) async {
    await _ensureToday();
    final g = glasses.clamp(0, 99);
    final current = state.glassesApprox;
    if (g == current) return;
    if (g > current) {
      final add = g - current;
      for (var i = 0; i < add; i++) {
        await addMl(250);
      }
    } else {
      // Remove os mais recentes até aproximar.
      var entries = [...state.newestFirst];
      var total = state.totalMl;
      final target = g * 250;
      while (total > target && entries.isNotEmpty) {
        total -= entries.first.ml;
        entries = entries.sublist(1);
      }
      state = state.copyWith(entries: entries.reversed.toList());
      final prefs = await SharedPreferences.getInstance();
      await _persist(prefs);
    }
  }

  /// Histórico dos últimos [days] dias (copos aproximados).
  static Future<Map<DateTime, int>> history(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final map = <DateTime, int>{};
    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      map[day] = prefs.getInt(_glassesKey(day)) ?? 0;
    }
    return map;
  }
}

final waterDayProvider =
    StateNotifierProvider<WaterLogNotifier, WaterDayState>((ref) {
  return WaterLogNotifier();
});

/// Compat Home/missões: número de “copos” (≈250 ml).
final waterLogProvider = Provider<int>((ref) {
  return ref.watch(waterDayProvider).glassesApprox;
});
