import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/checkin_models.dart';

/// Histórico completo de check-ins — persistido localmente (mesmo padrão do
/// Diário). Mantém tudo, não só o dia atual, pra alimentar estatísticas e o
/// calendário.
class CheckinNotifier extends StateNotifier<List<CheckinEntry>> {
  CheckinNotifier() : super([]) {
    _load();
  }

  static const _key = 'checkin_history';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final parsed = <CheckinEntry>[];
    for (final s in raw) {
      try {
        parsed
            .add(CheckinEntry.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada corrompida descartada */}
    }
    parsed.sort((a, b) => b.date.compareTo(a.date));
    state = parsed;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, state.map((e) => jsonEncode(e.toMap())).toList());
  }

  /// Salva o check-in de hoje, substituindo um já existente no mesmo dia
  /// (evita duplicar caso a usuária refaça o check-in).
  Future<void> salvar(CheckinEntry entry) async {
    final list = state
        .where((e) => !CheckinEntry.mesmoDia(e.date, entry.date))
        .toList()
      ..add(entry);
    list.sort((a, b) => b.date.compareTo(a.date));
    state = list;
    await _persist();
  }

  bool get feitoHoje =>
      state.any((e) => CheckinEntry.mesmoDia(e.date, DateTime.now()));
}

final checkinProvider =
    StateNotifierProvider<CheckinNotifier, List<CheckinEntry>>((ref) {
  return CheckinNotifier();
});

/// Check-in de hoje, se já tiver sido feito.
final todayCheckinProvider = Provider<CheckinEntry?>((ref) {
  final list = ref.watch(checkinProvider);
  for (final e in list) {
    if (CheckinEntry.mesmoDia(e.date, DateTime.now())) return e;
  }
  return null;
});
