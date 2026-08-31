/// Registro do check-in diário — visão rápida de hábitos do dia.
class CheckinEntry {
  const CheckinEntry({
    required this.date,
    required this.dormiuBem,
    required this.humor, // 0..4 (mesmo padrão de emoji do Diário)
    required this.energia, // 1..5
    required this.aguaCopos,
    this.peso,
    required this.treinou,
    required this.correu,
    required this.alimentacaoSaudavel,
    required this.cumpriuMeta,
    this.observacoes = '',
  });

  final DateTime date;
  final bool dormiuBem;
  final int humor;
  final int energia;
  final int aguaCopos;
  final double? peso;
  final bool treinou;
  final bool correu;
  final bool alimentacaoSaudavel;
  final bool cumpriuMeta;
  final String observacoes;

  /// Pontuação simples (0-100) — cada hábito positivo soma pontos.
  /// Usada como referência rápida e pra alimentar a gamificação.
  int get pontuacao {
    var pts = 0;
    if (dormiuBem) pts += 15;
    pts += (energia / 5 * 15).round();
    pts += (humor / 4 * 15).round();
    if (aguaCopos >= 6) pts += 15;
    if (treinou) pts += 15;
    if (correu) pts += 10;
    if (alimentacaoSaudavel) pts += 10;
    if (cumpriuMeta) pts += 5;
    return pts.clamp(0, 100);
  }

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'dormiuBem': dormiuBem,
        'humor': humor,
        'energia': energia,
        'aguaCopos': aguaCopos,
        'peso': peso,
        'treinou': treinou,
        'correu': correu,
        'alimentacaoSaudavel': alimentacaoSaudavel,
        'cumpriuMeta': cumpriuMeta,
        'observacoes': observacoes,
      };

  static CheckinEntry fromMap(Map<String, dynamic> m) => CheckinEntry(
        date: DateTime.parse(m['date'] as String),
        dormiuBem: (m['dormiuBem'] ?? false) as bool,
        humor: (m['humor'] ?? 2) as int,
        energia: (m['energia'] ?? 3) as int,
        aguaCopos: (m['aguaCopos'] ?? 0) as int,
        peso: m['peso'] == null ? null : (m['peso'] as num).toDouble(),
        treinou: (m['treinou'] ?? false) as bool,
        correu: (m['correu'] ?? false) as bool,
        alimentacaoSaudavel: (m['alimentacaoSaudavel'] ?? false) as bool,
        cumpriuMeta: (m['cumpriuMeta'] ?? false) as bool,
        observacoes: (m['observacoes'] ?? '') as String,
      );

  static bool mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
