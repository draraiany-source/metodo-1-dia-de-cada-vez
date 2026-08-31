import 'package:flutter/foundation.dart';

/// Tipos de dado de saúde que o app sincroniza.
enum HealthMetric {
  passos,
  distanciaKm,
  caloriasKcal,
  frequenciaCardiaca,
  pesoKg,
  imc,
  treinos,
  minutosAtivos,
  hidratacaoMl,
}

extension HealthMetricX on HealthMetric {
  String get label => switch (this) {
        HealthMetric.passos => 'Passos',
        HealthMetric.distanciaKm => 'Distância',
        HealthMetric.caloriasKcal => 'Calorias',
        HealthMetric.frequenciaCardiaca => 'Freq. cardíaca',
        HealthMetric.pesoKg => 'Peso',
        HealthMetric.imc => 'IMC',
        HealthMetric.treinos => 'Treinos',
        HealthMetric.minutosAtivos => 'Tempo ativo',
        HealthMetric.hidratacaoMl => 'Hidratação',
      };

  String get emoji => switch (this) {
        HealthMetric.passos => '👟',
        HealthMetric.distanciaKm => '📍',
        HealthMetric.caloriasKcal => '🔥',
        HealthMetric.frequenciaCardiaca => '❤️',
        HealthMetric.pesoKg => '⚖️',
        HealthMetric.imc => '📊',
        HealthMetric.treinos => '💪',
        HealthMetric.minutosAtivos => '⏱️',
        HealthMetric.hidratacaoMl => '💧',
      };

  String get unidade => switch (this) {
        HealthMetric.passos => 'passos',
        HealthMetric.distanciaKm => 'km',
        HealthMetric.caloriasKcal => 'kcal',
        HealthMetric.frequenciaCardiaca => 'bpm',
        HealthMetric.pesoKg => 'kg',
        HealthMetric.imc => '',
        HealthMetric.treinos => 'treinos',
        HealthMetric.minutosAtivos => 'min',
        HealthMetric.hidratacaoMl => 'ml',
      };

  /// Nem toda plataforma expõe todas as métricas.
  bool get podeNaoEstarDisponivel =>
      this == HealthMetric.frequenciaCardiaca ||
      this == HealthMetric.hidratacaoMl;
}

/// Origem dos dados.
enum HealthSource { healthConnect, googleFit, appleHealth, manual }

extension HealthSourceX on HealthSource {
  String get label => switch (this) {
        HealthSource.healthConnect => 'Health Connect',
        HealthSource.googleFit => 'Google Fit',
        HealthSource.appleHealth => 'Apple Health',
        HealthSource.manual => 'Registros manuais',
      };
}

/// Status da permissão de acesso aos dados de saúde.
enum HealthPermission { naoSolicitada, concedida, negada, indisponivel }

/// Um "retrato" dos dados de saúde de um dia.
@immutable
class HealthSnapshot {
  const HealthSnapshot({
    required this.date,
    required this.source,
    this.valores = const {},
  });

  final DateTime date;
  final HealthSource source;

  /// métrica -> valor (double). Ausente = não disponível na plataforma.
  final Map<HealthMetric, double> valores;

  double? get(HealthMetric m) => valores[m];

  bool has(HealthMetric m) => valores.containsKey(m);

  /// Formata o valor para exibição.
  String formatted(HealthMetric m) {
    final v = valores[m];
    if (v == null) return '—';
    final texto = switch (m) {
      HealthMetric.passos ||
      HealthMetric.caloriasKcal ||
      HealthMetric.frequenciaCardiaca ||
      HealthMetric.minutosAtivos ||
      HealthMetric.hidratacaoMl ||
      HealthMetric.treinos =>
        v.round().toString(),
      HealthMetric.distanciaKm => v.toStringAsFixed(2),
      HealthMetric.pesoKg => v.toStringAsFixed(1),
      HealthMetric.imc => v.toStringAsFixed(1),
    };
    final u = m.unidade;
    return u.isEmpty ? texto : '$texto $u';
  }

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'source': source.name,
        'valores': valores.map((k, v) => MapEntry(k.name, v)),
      };

  static HealthSnapshot fromMap(Map<String, dynamic> m) => HealthSnapshot(
        date: DateTime.parse(m['date'] as String),
        source: HealthSource.values.byName(m['source'] as String),
        valores: (m['valores'] as Map).map((k, v) => MapEntry(
              HealthMetric.values.byName(k as String),
              (v as num).toDouble(),
            )),
      );
}

/// Resultado de uma tentativa de sincronização.
@immutable
class SyncResult {
  const SyncResult({
    required this.ok,
    this.snapshot,
    this.error,
    this.metricasIndisponiveis = const [],
  });

  final bool ok;
  final HealthSnapshot? snapshot;
  final String? error;
  final List<HealthMetric> metricasIndisponiveis;
}
