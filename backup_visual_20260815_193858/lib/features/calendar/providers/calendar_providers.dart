import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/calendar_models.dart';

class CalendarNotifier extends StateNotifier<List<CalendarEvent>> {
  CalendarNotifier() : super([]) {
    _load();
  }

  static const _key = 'calendar_events_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final parsed = <CalendarEvent>[];
    for (final s in raw) {
      try {
        parsed.add(
            CalendarEvent.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada corrompida descartada */}
    }
    state = parsed;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, state.map((e) => jsonEncode(e.toMap())).toList());
  }

  Future<void> add(CalendarEvent event) async {
    state = [...state, event];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> toggleDone(String id, DateTime day) async {
    final list = state.map((e) {
      if (e.id != id) return e;
      final key = CalendarEvent.dayKey(day);
      final dates = [...e.completedDates];
      dates.contains(key) ? dates.remove(key) : dates.add(key);
      return e.copyWith(completedDates: dates);
    }).toList();
    state = list;
    await _persist();
  }

  /// Todos os eventos (já expandidos por recorrência) que ocorrem no dia.
  List<CalendarEvent> eventsOn(DateTime day) =>
      state.where((e) => e.occursOn(day)).toList()
        ..sort((a, b) {
          final am = (a.hour ?? 0) * 60 + (a.minute ?? 0);
          final bm = (b.hour ?? 0) * 60 + (b.minute ?? 0);
          return am.compareTo(bm);
        });
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, List<CalendarEvent>>((ref) {
  return CalendarNotifier();
});

/// Estatística simples: % de eventos concluídos nos últimos 30 dias.
final calendarCompletionRateProvider = Provider<double>((ref) {
  final events = ref.watch(calendarProvider);
  final now = DateTime.now();
  var total = 0;
  var done = 0;
  for (var i = 0; i < 30; i++) {
    final day = now.subtract(Duration(days: i));
    for (final e in events) {
      if (!e.occursOn(day)) continue;
      total++;
      if (e.isDoneOn(day)) done++;
    }
  }
  if (total == 0) return 0;
  return done / total;
});
