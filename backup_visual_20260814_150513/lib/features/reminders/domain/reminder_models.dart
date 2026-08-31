import 'package:flutter/material.dart';

/// Categorias de lembrete previstas no Módulo 20.
enum ReminderCategory {
  agua,
  refeicao,
  registrarAlimentacao,
  corrida,
  treino,
  video,
  audio,
  leitura,
  peso,
  medidas,
  dormir,
  medicamento,
  suplemento,
  metaDiaria,
  checkin,
}

extension ReminderCategoryInfo on ReminderCategory {
  String get label => switch (this) {
        ReminderCategory.agua => 'Beber água',
        ReminderCategory.refeicao => 'Fazer refeição',
        ReminderCategory.registrarAlimentacao => 'Registrar alimentação',
        ReminderCategory.corrida => 'Corrida',
        ReminderCategory.treino => 'Treino',
        ReminderCategory.video => 'Assistir vídeo',
        ReminderCategory.audio => 'Ouvir curso em áudio',
        ReminderCategory.leitura => 'Ler receita/material',
        ReminderCategory.peso => 'Registrar peso',
        ReminderCategory.medidas => 'Atualizar medidas',
        ReminderCategory.dormir => 'Dormir no horário',
        ReminderCategory.medicamento => 'Tomar medicamento',
        ReminderCategory.suplemento => 'Tomar suplemento',
        ReminderCategory.metaDiaria => 'Cumprir meta diária',
        ReminderCategory.checkin => 'Check-in diário',
      };

  String get emoji => switch (this) {
        ReminderCategory.agua => '💧',
        ReminderCategory.refeicao => '🍽',
        ReminderCategory.registrarAlimentacao => '🥗',
        ReminderCategory.corrida => '🏃',
        ReminderCategory.treino => '🏋️',
        ReminderCategory.video => '🎥',
        ReminderCategory.audio => '🎧',
        ReminderCategory.leitura => '📖',
        ReminderCategory.peso => '⚖',
        ReminderCategory.medidas => '📏',
        ReminderCategory.dormir => '😴',
        ReminderCategory.medicamento => '💊',
        ReminderCategory.suplemento => '💉',
        ReminderCategory.metaDiaria => '🔥',
        ReminderCategory.checkin => '📅',
      };
}

/// Um lembrete configurado pela usuária.
@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.category,
    required this.hour,
    required this.minute,
    this.enabled = true,
    this.label,
  });

  /// ID estável usado tanto na persistência quanto no agendamento nativo
  /// (flutter_local_notifications exige um int único por notificação).
  final int id;
  final ReminderCategory category;
  final int hour;
  final int minute;
  final bool enabled;

  /// Rótulo customizado opcional (ex.: nome do medicamento).
  final String? label;

  String get horaFormatada =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Reminder copyWith({int? hour, int? minute, bool? enabled, String? label}) {
    return Reminder(
      id: id,
      category: category,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category.name,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
        'label': label,
      };

  static Reminder fromMap(Map<String, dynamic> m) => Reminder(
        id: m['id'] as int,
        category: ReminderCategory.values
            .firstWhere((c) => c.name == m['category']),
        hour: m['hour'] as int,
        minute: m['minute'] as int,
        enabled: (m['enabled'] ?? true) as bool,
        label: m['label'] as String?,
      );
}
