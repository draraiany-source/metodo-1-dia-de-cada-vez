import '../../personal_trainer/domain/pt_models.dart';
import '../../running/data/running_repository.dart';
import '../../workout_timer/domain/workout_timer_models.dart';
import 'training_volume.dart';

enum PersonalRecordKind {
  maiorCarga,
  maisRepeticoes,
  maiorDistancia,
  melhorPace,
  treinoMaisLongo,
  maiorSequencia,
  maisTreinosNaSemana,
}

/// Um recorde pessoal já consolidado para a UI.
class PersonalRecord {
  const PersonalRecord({
    required this.kind,
    required this.label,
    required this.valueLabel,
    this.detail = '',
    this.at,
    this.exerciseName = '',
    this.numericValue = 0,
  });

  final PersonalRecordKind kind;
  final String label;
  final String valueLabel;
  final String detail;
  final DateTime? at;
  final String exerciseName;

  /// Valor cru para comparação (kg, km, minutos, dias, contagem).
  final double numericValue;
}

/// Agrega recordes a partir das fontes que o app já tem.
/// Não cria collection nova: lê `pt_loads`, `running_sessions`,
/// `workout_history` e o streak local.
class PersonalRecordsBoard {
  const PersonalRecordsBoard({required this.items});

  final List<PersonalRecord> items;

  bool get isEmpty => items.isEmpty;

  static PersonalRecordsBoard build({
    List<LoadEntry> cargas = const [],
    List<RunningSession> corridas = const [],
    List<WorkoutSessionRecord> sessoesTimer = const [],
    List<WorkoutSessionLog> sessoesPt = const [],
    int streakAtual = 0,
    int melhorStreak = 0,
  }) {
    final items = <PersonalRecord>[];

    final porExercicio = ExerciseLoadStats.group(cargas);
    ExerciseLoadStats? maisPesado;
    for (final s in porExercicio) {
      if (s.maxWeight == null) continue;
      if (maisPesado == null || s.maxWeight! > maisPesado.maxWeight!) {
        maisPesado = s;
      }
    }
    if (maisPesado != null && maisPesado.maxWeight != null) {
      final quando = maisPesado.cronologico.lastWhere(
        (e) => e.weightKg == maisPesado!.maxWeight,
        orElse: () => maisPesado!.cronologico.last,
      );
      items.add(PersonalRecord(
        kind: PersonalRecordKind.maiorCarga,
        label: 'Maior carga',
        valueLabel: TrainingVolume.formatKg(maisPesado.maxWeight!),
        detail: maisPesado.exerciseName,
        exerciseName: maisPesado.exerciseName,
        at: quando.date,
        numericValue: maisPesado.maxWeight!,
      ));
    }

    ExerciseLoadStats? maisReps;
    for (final s in porExercicio) {
      if (s.maxReps == null) continue;
      if (maisReps == null || s.maxReps! > maisReps.maxReps!) {
        maisReps = s;
      }
    }
    if (maisReps != null && maisReps.maxReps != null) {
      items.add(PersonalRecord(
        kind: PersonalRecordKind.maisRepeticoes,
        label: 'Mais repetições',
        valueLabel: '${maisReps.maxReps} reps',
        detail: maisReps.exerciseName,
        exerciseName: maisReps.exerciseName,
        numericValue: maisReps.maxReps!.toDouble(),
      ));
    }

    RunningSession? maisLonge;
    for (final r in corridas) {
      if (maisLonge == null || r.distanceKm > maisLonge.distanceKm) {
        maisLonge = r;
      }
    }
    if (maisLonge != null && maisLonge.distanceKm > 0) {
      items.add(PersonalRecord(
        kind: PersonalRecordKind.maiorDistancia,
        label: 'Maior distância',
        valueLabel: '${maisLonge.distanceKm.toStringAsFixed(2).replaceAll('.', ',')} km',
        at: maisLonge.date,
        numericValue: maisLonge.distanceKm,
      ));
    }

    // Pace: menor minutos/km, só em corridas de pelo menos 1 km — senão um
    // sprint de 200 m distorce o recorde.
    RunningSession? melhorPace;
    for (final r in corridas) {
      if (r.distanceKm < 1 || r.paceMinPerKm <= 0) continue;
      if (melhorPace == null || r.paceMinPerKm < melhorPace.paceMinPerKm) {
        melhorPace = r;
      }
    }
    if (melhorPace != null) {
      items.add(PersonalRecord(
        kind: PersonalRecordKind.melhorPace,
        label: 'Melhor pace',
        valueLabel: '${_pace(melhorPace.paceMinPerKm)} /km',
        at: melhorPace.date,
        numericValue: melhorPace.paceMinPerKm,
      ));
    }

    Duration? maisLongo;
    DateTime? quandoLongo;
    for (final s in sessoesTimer) {
      if (maisLongo == null || s.totalDuration > maisLongo) {
        maisLongo = s.totalDuration;
        quandoLongo = s.completedAt;
      }
    }
    for (final s in sessoesPt) {
      final min = s.durationMinutes;
      if (min == null || min <= 0) continue;
      final d = Duration(minutes: min);
      if (maisLongo == null || d > maisLongo) {
        maisLongo = d;
        quandoLongo = s.date;
      }
    }
    if (maisLongo != null && maisLongo.inSeconds > 0) {
      items.add(PersonalRecord(
        kind: PersonalRecordKind.treinoMaisLongo,
        label: 'Treino mais longo',
        valueLabel: _duracao(maisLongo),
        at: quandoLongo,
        numericValue: maisLongo.inMinutes.toDouble(),
      ));
    }

    final melhor = melhorStreak > streakAtual ? melhorStreak : streakAtual;
    if (melhor > 0) {
      items.add(PersonalRecord(
        kind: PersonalRecordKind.maiorSequencia,
        label: 'Maior sequência',
        valueLabel: melhor == 1 ? '1 dia' : '$melhor dias',
        numericValue: melhor.toDouble(),
      ));
    }

    final porSemana = <String, int>{};
    void contarDia(DateTime d) {
      final chave = _semanaIso(d);
      porSemana[chave] = (porSemana[chave] ?? 0) + 1;
    }

    for (final s in sessoesTimer) {
      contarDia(s.completedAt);
    }
    for (final s in sessoesPt) {
      contarDia(s.date);
    }
    if (porSemana.isNotEmpty) {
      final max = porSemana.values.reduce((a, b) => a > b ? a : b);
      if (max > 0) {
        items.add(PersonalRecord(
          kind: PersonalRecordKind.maisTreinosNaSemana,
          label: 'Mais treinos numa semana',
          valueLabel: max == 1 ? '1 treino' : '$max treinos',
          numericValue: max.toDouble(),
        ));
      }
    }

    return PersonalRecordsBoard(items: List.unmodifiable(items));
  }

  static String _pace(double minPerKm) {
    final totalSeg = (minPerKm * 60).round();
    final m = totalSeg ~/ 60;
    final s = (totalSeg % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String _duracao(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h <= 0) return '$m min';
    return m == 0 ? '${h}h' : '${h}h ${m.toString().padLeft(2, '0')}';
  }

  /// Chave estável segunda→domingo no fuso local.
  static String _semanaIso(DateTime d) {
    final dia = DateTime(d.year, d.month, d.day);
    final segunda = dia.subtract(Duration(days: dia.weekday - 1));
    return '${segunda.year}-${segunda.month.toString().padLeft(2, '0')}-${segunda.day.toString().padLeft(2, '0')}';
  }
}
