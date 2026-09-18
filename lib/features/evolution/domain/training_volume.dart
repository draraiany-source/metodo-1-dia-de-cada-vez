import '../../personal_trainer/domain/pt_models.dart';

/// Regras de volume e progressão de carga.
///
/// Tudo aqui é Dart puro: a UI e o Firestore não entram. Se a conta mudar,
/// os testes em `test/training_volume_test.dart` quebram — e é isso que
/// queremos, em vez de um gráfico mostrando número errado.
class TrainingVolume {
  TrainingVolume._();

  /// Volume de um exercício: carga × reps × séries.
  ///
  /// Devolve null quando qualquer parcela é inválida. Não inventa zero —
  /// zero na UI significaria "treinou sem carga", o que é outra coisa.
  static double? of({
    required double weightKg,
    required int reps,
    required int series,
  }) {
    if (weightKg <= 0 || reps <= 0 || series <= 0) return null;
    return weightKg * reps * series;
  }

  /// Soma só o que dá para calcular. Entradas sem séries/reps são ignoradas,
  /// não zeradas — senão um único registro legado derrubaria o total.
  static double? sum(Iterable<LoadEntry> entradas) {
    var total = 0.0;
    var algum = false;
    for (final e in entradas) {
      final v = e.volumeKg;
      if (v == null) continue;
      total += v;
      algum = true;
    }
    return algum ? total : null;
  }

  /// Primeiro número da prescrição. "12" → 12, "8-12" → 10 (média do intervalo),
  /// "até a falha" → null. Não tenta adivinhar drop-set.
  static int? parseReps(String bruto) {
    final texto = bruto.trim().toLowerCase();
    if (texto.isEmpty) return null;
    final intervalo = RegExp(r'(\d+)\s*[-–—aà]\s*(\d+)').firstMatch(texto);
    if (intervalo != null) {
      final a = int.tryParse(intervalo.group(1)!);
      final b = int.tryParse(intervalo.group(2)!);
      if (a == null || b == null || a <= 0 || b <= 0) return null;
      return ((a + b) / 2).round();
    }
    final unico = RegExp(r'(\d+)').firstMatch(texto);
    if (unico == null) return null;
    final n = int.tryParse(unico.group(1)!);
    return (n != null && n > 0) ? n : null;
  }

  /// "30 kg", "32,5", "8kg" → número. "peso corporal" → null.
  static double? parseWeight(String bruto) {
    final texto = bruto.trim().toLowerCase().replaceAll(',', '.');
    if (texto.isEmpty) return null;
    if (texto.contains('corpo') || texto.contains('livre')) return null;
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(texto);
    if (m == null) return null;
    final n = double.tryParse(m.group(1)!);
    return (n != null && n > 0) ? n : null;
  }

  static String formatKg(double kg, {int decimals = 0}) {
    final texto = decimals == 0
        ? kg.round().toString()
        : kg.toStringAsFixed(decimals).replaceFirst(RegExp(r'\.?0+$'), '');
    final comMilhar = _milhar(texto.replaceAll('.', ','));
    return '$comMilhar kg';
  }

  static String formatVolume(double kg) {
    final inteiro = kg.round();
    return '${_milhar('$inteiro')} kg';
  }

  static String formatPercent(double p) {
    final sinal = p > 0 ? '+' : '';
    final abs = p.abs();
    final texto = abs >= 10 ? abs.round().toString() : abs.toStringAsFixed(1);
    return '$sinal${texto.replaceAll('.', ',')}%';
  }

  static String _milhar(String n) {
    final partes = n.split(',');
    final inteiro = partes[0];
    final buf = StringBuffer();
    for (var i = 0; i < inteiro.length; i++) {
      final restante = inteiro.length - i;
      if (i > 0 && restante % 3 == 0) buf.write('.');
      buf.write(inteiro[i]);
    }
    if (partes.length > 1 && partes[1].isNotEmpty) {
      buf.write(',');
      buf.write(partes[1]);
    }
    return buf.toString();
  }
}

/// Estatísticas de um exercício a partir do histórico de [LoadEntry].
///
/// Não substitui o histórico: só agrega. A lista [cronologico] é a fonte
/// que a UI desenha no gráfico e na timeline.
class ExerciseLoadStats {
  const ExerciseLoadStats({
    required this.exerciseId,
    required this.exerciseName,
    required this.cronologico,
    this.lastWeight,
    this.maxWeight,
    this.avgWeight,
    this.firstWeight,
    this.percentEvolution,
    this.totalVolumeKg,
    this.maxReps,
  });

  final String exerciseId;
  final String exerciseName;
  final List<LoadEntry> cronologico;
  final double? lastWeight;
  final double? maxWeight;
  final double? avgWeight;
  final double? firstWeight;

  /// ((última − primeira) / primeira) × 100. Null se não há duas cargas.
  final double? percentEvolution;
  final double? totalVolumeKg;
  final int? maxReps;

  bool get temDados => cronologico.isNotEmpty;

  static ExerciseLoadStats from(List<LoadEntry> entradas) {
    if (entradas.isEmpty) {
      return const ExerciseLoadStats(
        exerciseId: '',
        exerciseName: '',
        cronologico: [],
      );
    }
    final ordenado = [...entradas]
      ..sort((a, b) => a.date.compareTo(b.date));
    final pesos = ordenado.map((e) => e.weightKg).where((w) => w > 0).toList();
    final first = pesos.isEmpty ? null : pesos.first;
    final last = pesos.isEmpty ? null : pesos.last;
    final maxW = pesos.isEmpty ? null : pesos.reduce((a, b) => a > b ? a : b);
    final avg = pesos.isEmpty
        ? null
        : pesos.reduce((a, b) => a + b) / pesos.length;
    double? pct;
    if (first != null && last != null && first > 0 && pesos.length >= 2) {
      pct = ((last - first) / first) * 100;
    }
    int? maxR;
    for (final e in ordenado) {
      final r = e.repeticoes;
      if (r == null) continue;
      if (maxR == null || r > maxR) maxR = r;
    }
    return ExerciseLoadStats(
      exerciseId: ordenado.last.exerciseId,
      exerciseName: ordenado.last.exerciseName,
      cronologico: List.unmodifiable(ordenado),
      lastWeight: last,
      maxWeight: maxW,
      avgWeight: avg,
      firstWeight: first,
      percentEvolution: pct,
      totalVolumeKg: TrainingVolume.sum(ordenado),
      maxReps: maxR,
    );
  }

  /// Agrupa o histórico da aluna por exercício, do mais recentemente
  /// atualizado para o mais antigo.
  static List<ExerciseLoadStats> group(List<LoadEntry> todas) {
    final porId = <String, List<LoadEntry>>{};
    for (final e in todas) {
      final chave =
          e.exerciseId.trim().isNotEmpty ? e.exerciseId : e.exerciseName;
      if (chave.isEmpty) continue;
      porId.putIfAbsent(chave, () => []).add(e);
    }
    final out = porId.values.map(ExerciseLoadStats.from).toList();
    out.sort((a, b) {
      final da = a.cronologico.isEmpty
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : a.cronologico.last.date;
      final db = b.cronologico.isEmpty
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : b.cronologico.last.date;
      return db.compareTo(da);
    });
    return out;
  }

  /// True quando [novaCarga] supera o máximo **já registrado** (não conta
  /// o lançamento atual). A primeira carga de um exercício é linha de base,
  /// não recorde — celebrar aí seria barulho.
  static bool isNewWeightRecord({
    required List<LoadEntry> historicoAnterior,
    required double novaCarga,
  }) {
    if (novaCarga <= 0) return false;
    final anteriores = historicoAnterior
        .map((e) => e.weightKg)
        .where((w) => w > 0)
        .toList();
    if (anteriores.isEmpty) return false;
    final maxAnterior = anteriores.reduce((a, b) => a > b ? a : b);
    return novaCarga > maxAnterior;
  }
}
