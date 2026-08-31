import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum CalendarCategory {
  treino,
  corrida,
  alimentacao,
  hidratacao,
  pesagem,
  medicoes,
  desafio,
  curso,
  video,
  receita,
  consulta,
  medicamento,
  meta,
  outro,
}

extension CalendarCategoryInfo on CalendarCategory {
  String get label => switch (this) {
        CalendarCategory.treino => 'Treino',
        CalendarCategory.corrida => 'Corrida',
        CalendarCategory.alimentacao => 'Alimentação',
        CalendarCategory.hidratacao => 'Hidratação',
        CalendarCategory.pesagem => 'Pesagem',
        CalendarCategory.medicoes => 'Medições corporais',
        CalendarCategory.desafio => 'Desafio',
        CalendarCategory.curso => 'Curso',
        CalendarCategory.video => 'Vídeo',
        CalendarCategory.receita => 'Receita',
        CalendarCategory.consulta => 'Consulta',
        CalendarCategory.medicamento => 'Medicamento/Suplemento',
        CalendarCategory.meta => 'Meta',
        CalendarCategory.outro => 'Outro',
      };

  String get emoji => switch (this) {
        CalendarCategory.treino => '🏋️',
        CalendarCategory.corrida => '🏃',
        CalendarCategory.alimentacao => '🍽',
        CalendarCategory.hidratacao => '💧',
        CalendarCategory.pesagem => '⚖',
        CalendarCategory.medicoes => '📏',
        CalendarCategory.desafio => '🏆',
        CalendarCategory.curso => '🎧',
        CalendarCategory.video => '🎥',
        CalendarCategory.receita => '🥗',
        CalendarCategory.consulta => '👩‍⚕️',
        CalendarCategory.medicamento => '💊',
        CalendarCategory.meta => '🎯',
        CalendarCategory.outro => '📌',
      };

  Color get color => switch (this) {
        CalendarCategory.treino => AppColors.primary,
        CalendarCategory.corrida => AppColors.secondary,
        CalendarCategory.alimentacao => AppColors.success,
        CalendarCategory.hidratacao => AppColors.info,
        CalendarCategory.pesagem => AppColors.warning,
        CalendarCategory.medicoes => AppColors.accent,
        CalendarCategory.desafio => AppColors.danger,
        CalendarCategory.curso => AppColors.secondary,
        CalendarCategory.video => AppColors.primary,
        CalendarCategory.receita => AppColors.success,
        CalendarCategory.consulta => AppColors.info,
        CalendarCategory.medicamento => AppColors.danger,
        CalendarCategory.meta => AppColors.warning,
        CalendarCategory.outro => AppColors.textSecondary,
      };
}

enum EventRepeat { nenhuma, diaria, semanal, mensal }

/// Um evento/agenda no calendário — pode ser único ou recorrente.
@immutable
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.hour,
    this.minute,
    this.repeat = EventRepeat.nenhuma,
    this.notes = '',
    this.completedDates = const [],
  });

  final String id;
  final String title;
  final CalendarCategory category;

  /// Data-base do evento (primeira ocorrência, se recorrente).
  final DateTime date;
  final int? hour;
  final int? minute;
  final EventRepeat repeat;
  final String notes;

  /// Datas (yyyy-MM-dd) em que essa ocorrência específica foi concluída —
  /// necessário porque um evento recorrente tem uma "conclusão" por dia.
  final List<String> completedDates;

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isDoneOn(DateTime day) => completedDates.contains(dayKey(day));

  /// Se este evento (considerando recorrência) ocorre no dia [day].
  bool occursOn(DateTime day) {
    final base = DateTime(date.year, date.month, date.day);
    final target = DateTime(day.year, day.month, day.day);
    if (target.isBefore(base)) return false;
    switch (repeat) {
      case EventRepeat.nenhuma:
        return target == base;
      case EventRepeat.diaria:
        return true;
      case EventRepeat.semanal:
        return target.weekday == base.weekday;
      case EventRepeat.mensal:
        return target.day == base.day;
    }
  }

  CalendarEvent copyWith({List<String>? completedDates}) => CalendarEvent(
        id: id,
        title: title,
        category: category,
        date: date,
        hour: hour,
        minute: minute,
        repeat: repeat,
        notes: notes,
        completedDates: completedDates ?? this.completedDates,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category.name,
        'date': date.toIso8601String(),
        'hour': hour,
        'minute': minute,
        'repeat': repeat.name,
        'notes': notes,
        'completedDates': completedDates,
      };

  static CalendarEvent fromMap(Map<String, dynamic> m) => CalendarEvent(
        id: m['id'] as String,
        title: m['title'] as String,
        category:
            CalendarCategory.values.firstWhere((c) => c.name == m['category']),
        date: DateTime.parse(m['date'] as String),
        hour: m['hour'] as int?,
        minute: m['minute'] as int?,
        repeat: EventRepeat.values.firstWhere((r) => r.name == m['repeat'],
            orElse: () => EventRepeat.nenhuma),
        notes: (m['notes'] ?? '') as String,
        completedDates: (m['completedDates'] as List?)?.cast<String>() ?? [],
      );
}
