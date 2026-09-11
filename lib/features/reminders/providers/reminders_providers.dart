import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/local_reminders_service.dart';
import '../domain/reminder_models.dart';

/// Gerencia os lembretes configurados: persiste localmente e mantém as
/// notificações nativas sincronizadas (agenda ao ativar/editar, cancela ao
/// desativar/remover).
class RemindersNotifier extends StateNotifier<List<Reminder>> {
  RemindersNotifier() : super([]) {
    _load();
  }

  static const _key = 'reminders_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final parsed = <Reminder>[];
    for (final s in raw) {
      try {
        parsed.add(Reminder.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* entrada corrompida descartada */}
    }
    state = parsed;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, state.map((r) => jsonEncode(r.toMap())).toList());
  }

  Future<void> _sync(Reminder r) async {
    if (r.enabled) {
      await LocalRemindersService.scheduleDaily(
        id: r.id,
        title: '${r.category.emoji} ${r.label ?? r.category.label}',
        body: _bodyFor(r.category),
        hour: r.hour,
        minute: r.minute,
      );
    } else {
      await LocalRemindersService.cancel(r.id);
    }
  }

  String _bodyFor(ReminderCategory c) => switch (c) {
        ReminderCategory.agua =>
          'Hora de beber água 💧 Um copo agora ajuda você a chegar à sua meta.',
        ReminderCategory.checkin => 'Como foi seu dia? Faça seu check-in.',
        ReminderCategory.metaDiaria => 'Falta pouco pra bater sua meta hoje!',
        _ => 'Um dia de cada vez — vamos lá!',
      };

  /// Cria (ou atualiza, se já existir uma da mesma categoria+horário) um
  /// lembrete. IDs são derivados da categoria pra manter estabilidade entre
  /// sessões sem precisar de um contador persistido.
  Future<void> upsert({
    required ReminderCategory category,
    required int hour,
    required int minute,
    bool enabled = true,
    String? label,
    int? existingId,
  }) async {
    final id = existingId ?? _newId(category);
    final reminder = Reminder(
      id: id,
      category: category,
      hour: hour,
      minute: minute,
      enabled: enabled,
      label: label,
    );
    final list = [...state];
    final idx = list.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      list[idx] = reminder;
    } else {
      list.add(reminder);
    }
    state = list;
    await _persist();
    await _sync(reminder);
  }

  Future<void> toggle(int id, bool enabled) async {
    final list = state.map((r) {
      if (r.id != id) return r;
      final updated = r.copyWith(enabled: enabled);
      _sync(updated);
      return updated;
    }).toList();
    state = list;
    await _persist();
  }

  Future<void> remove(int id) async {
    await LocalRemindersService.cancel(id);
    state = state.where((r) => r.id != id).toList();
    await _persist();
  }

  // IDs de notificação precisam ser int; usamos o índice da categoria no
  // enum como base (estável) e timestamp como desempate para permitir mais
  // de um lembrete por categoria (ex.: 2 medicamentos diferentes).
  int _newId(ReminderCategory category) {
    final base = category.index * 1000;
    final usedInCategory =
        state.where((r) => r.category == category).length;
    return base + usedInCategory + 1;
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
  return RemindersNotifier();
});
