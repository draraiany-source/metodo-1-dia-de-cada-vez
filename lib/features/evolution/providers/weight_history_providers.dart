import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Um registro de peso na linha do tempo de evolução.
class WeightEntry {
  const WeightEntry({required this.date, required this.weight, this.note});
  final DateTime date;
  final double weight;

  /// Observação opcional digitada no momento do registro (ex.: "após o
  /// treino", "em jejum") — mostrada no histórico, nunca obrigatória.
  final String? note;

  Map<String, dynamic> toMap() =>
      {'date': date.toIso8601String(), 'weight': weight, 'note': note};

  static WeightEntry fromMap(Map<String, dynamic> m) => WeightEntry(
        date: DateTime.parse(m['date'] as String),
        weight: (m['weight'] as num).toDouble(),
        note: m['note'] as String?,
      );
}

/// Histórico de peso — persiste localmente (SharedPreferences) e alimenta o
/// gráfico da tela de Acompanhamento.
///
/// **Nota**: em produção com Firebase, o ideal é migrar para a subcoleção
/// `users/{uid}/progress` (já referenciada nos comentários das Fotos de
/// progresso). Fica local por enquanto para não depender de índices/regras
/// novas do Firestore sem validar com você antes.
class WeightHistoryNotifier extends StateNotifier<List<WeightEntry>> {
  WeightHistoryNotifier() : super([]) {
    _load();
  }

  static const _key = 'weight_history';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final parsed = <WeightEntry>[];
    for (final s in raw) {
      try {
        parsed
            .add(WeightEntry.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada corrompida descartada */}
    }
    parsed.sort((a, b) => a.date.compareTo(b.date));
    state = parsed;
  }

  /// [date] permite registrar uma pesagem retroativa (padrão: agora).
  Future<void> add(double weight, {DateTime? date, String? note}) async {
    state = [
      ...state,
      WeightEntry(date: date ?? DateTime.now(), weight: weight, note: note),
    ]..sort((a, b) => a.date.compareTo(b.date));
    await _persist();
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= state.length) return;
    final next = [...state]..removeAt(index);
    state = next;
    await _persist();
  }

  Future<void> removeEntry(WeightEntry entry) async {
    final i = state.indexWhere((e) =>
        e.date == entry.date &&
        e.weight == entry.weight &&
        e.note == entry.note);
    if (i >= 0) await removeAt(i);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, state.map((e) => jsonEncode(e.toMap())).toList());
  }
}

final weightHistoryProvider =
    StateNotifierProvider<WeightHistoryNotifier, List<WeightEntry>>((ref) {
  return WeightHistoryNotifier();
});
