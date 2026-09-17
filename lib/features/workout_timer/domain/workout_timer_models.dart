import 'package:flutter/foundation.dart';

/// Como o exercício é medido.
enum TimerEffortMode { reps, time }

/// Protocolos de cronômetro suportados.
enum TimerProtocol {
  free,
  countdown,
  rest,
  hiit,
  circuit,
  emom,
  amrap,
}

extension TimerProtocolX on TimerProtocol {
  String get label => switch (this) {
        TimerProtocol.free => 'Cronômetro livre',
        TimerProtocol.countdown => 'Temporizador regressivo',
        TimerProtocol.rest => 'Intervalo de descanso',
        TimerProtocol.hiit => 'HIIT',
        TimerProtocol.circuit => 'Circuito',
        TimerProtocol.emom => 'EMOM',
        TimerProtocol.amrap => 'AMRAP',
      };
}

enum TimerPhase { idle, countdown, work, rest, done }

@immutable
class WorkoutTimerState {
  const WorkoutTimerState({
    required this.blueprint,
    this.exerciseIndex = 0,
    this.setIndex = 0,
    this.roundIndex = 0,
    this.phase = TimerPhase.idle,
    this.remaining = Duration.zero,
    this.phaseTotal = Duration.zero,
    this.running = false,
    this.startedAt,
    this.totalElapsed = Duration.zero,
    this.activeElapsed = Duration.zero,
    this.restElapsed = Duration.zero,
    this.seriesDone = 0,
    this.exercisesDone = 0,
    this.lastBeepSecond = -1,
    this.finished = false,
  });

  final WorkoutTimerBlueprint blueprint;
  final int exerciseIndex;
  final int setIndex;
  final int roundIndex;
  final TimerPhase phase;
  final Duration remaining;
  final Duration phaseTotal;
  final bool running;
  final DateTime? startedAt;
  final Duration totalElapsed;
  final Duration activeElapsed;
  final Duration restElapsed;
  final int seriesDone;
  final int exercisesDone;
  final int lastBeepSecond;
  final bool finished;

  TimerExercise? get current {
    if (exerciseIndex < 0 || exerciseIndex >= blueprint.exercises.length) {
      return null;
    }
    return blueprint.exercises[exerciseIndex];
  }

  double get phaseProgress {
    if (phaseTotal.inMilliseconds <= 0) return 0;
    final done = phaseTotal.inMilliseconds - remaining.inMilliseconds;
    return (done / phaseTotal.inMilliseconds).clamp(0.0, 1.0);
  }

  WorkoutTimerState copyWith({
    int? exerciseIndex,
    int? setIndex,
    int? roundIndex,
    TimerPhase? phase,
    Duration? remaining,
    Duration? phaseTotal,
    bool? running,
    DateTime? startedAt,
    Duration? totalElapsed,
    Duration? activeElapsed,
    Duration? restElapsed,
    int? seriesDone,
    int? exercisesDone,
    int? lastBeepSecond,
    bool? finished,
  }) =>
      WorkoutTimerState(
        blueprint: blueprint,
        exerciseIndex: exerciseIndex ?? this.exerciseIndex,
        setIndex: setIndex ?? this.setIndex,
        roundIndex: roundIndex ?? this.roundIndex,
        phase: phase ?? this.phase,
        remaining: remaining ?? this.remaining,
        phaseTotal: phaseTotal ?? this.phaseTotal,
        running: running ?? this.running,
        startedAt: startedAt ?? this.startedAt,
        totalElapsed: totalElapsed ?? this.totalElapsed,
        activeElapsed: activeElapsed ?? this.activeElapsed,
        restElapsed: restElapsed ?? this.restElapsed,
        seriesDone: seriesDone ?? this.seriesDone,
        exercisesDone: exercisesDone ?? this.exercisesDone,
        lastBeepSecond: lastBeepSecond ?? this.lastBeepSecond,
        finished: finished ?? this.finished,
      );
}

@immutable
class TimerExercise {
  const TimerExercise({
    required this.id,
    required this.name,
    this.series = 3,
    this.repsLabel = '12',
    this.workSeconds = 0,
    this.restSeconds = 60,
    this.rounds = 1,
    this.effortMode = TimerEffortMode.reps,
    this.protocol = TimerProtocol.countdown,
    this.autoStart = false,
    this.autoAdvance = true,
    this.notes = '',
    this.videoUrl = '',
  });

  final String id;
  final String name;
  final int series;
  final String repsLabel;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final TimerEffortMode effortMode;
  final TimerProtocol protocol;
  final bool autoStart;
  final bool autoAdvance;
  final String notes;
  final String videoUrl;

  bool get isTimed =>
      effortMode == TimerEffortMode.time ||
      protocol == TimerProtocol.hiit ||
      protocol == TimerProtocol.emom ||
      protocol == TimerProtocol.amrap ||
      workSeconds > 0;

  int get effectiveRounds => switch (protocol) {
        TimerProtocol.hiit ||
        TimerProtocol.emom ||
        TimerProtocol.amrap =>
          rounds <= 0 ? 8 : rounds,
        _ => series <= 0 ? 1 : series,
      };
}

@immutable
class WorkoutTimerBlueprint {
  const WorkoutTimerBlueprint({
    required this.workoutId,
    required this.title,
    required this.exercises,
    this.autoStartFirst = false,
  });

  final String workoutId;
  final String title;
  final List<TimerExercise> exercises;
  final bool autoStartFirst;
}

@immutable
class WorkoutSessionRecord {
  const WorkoutSessionRecord({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.title,
    required this.startedAt,
    required this.completedAt,
    required this.totalDuration,
    required this.activeDuration,
    required this.restDuration,
    required this.exercisesDone,
    required this.exercisesTotal,
    required this.seriesDone,
    required this.percent,
  });

  final String id;
  final String userId;
  final String workoutId;
  final String title;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration totalDuration;
  final Duration activeDuration;
  final Duration restDuration;
  final int exercisesDone;
  final int exercisesTotal;
  final int seriesDone;
  final double percent;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'workoutId': workoutId,
        'title': title,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'totalSeconds': totalDuration.inSeconds,
        'activeSeconds': activeDuration.inSeconds,
        'restSeconds': restDuration.inSeconds,
        'exercisesDone': exercisesDone,
        'exercisesTotal': exercisesTotal,
        'seriesDone': seriesDone,
        'percent': percent,
        'source': 'workout_timer',
      };
}

/// Interpreta prescrição textual do catálogo (ex.: "3 séries de 12", "40s").
TimerExercise parseCatalogExercise({
  required String id,
  required String name,
  String? prescricao,
  String? intervalo,
  String? categoria,
}) {
  final text = '${prescricao ?? ''} ${intervalo ?? ''}'.toLowerCase();
  final hiit = _parseHiit(text);
  if (hiit != null) return hiit.copyWithName(id: id, name: name);

  final series = _firstInt(
        RegExp(r'(\d+)\s*(x|séries|series)').firstMatch(text)?.group(1),
      ) ??
      3;
  final rest = _firstInt(
        RegExp(r'(\d+)\s*(s|seg)').firstMatch(intervalo?.toLowerCase() ?? '')?.group(1),
      ) ??
      (RegExp(r'descanso[:\s]*(\d+)').firstMatch(text) != null
          ? _firstInt(RegExp(r'descanso[:\s]*(\d+)').firstMatch(text)!.group(1))
          : 60);

  final timeMin = _firstInt(
    RegExp(r'(\d+)\s*min').firstMatch(text)?.group(1),
  );
  final timeSec = _firstInt(
    RegExp(r'(\d+)\s*(s|segundos)\b').firstMatch(prescricao?.toLowerCase() ?? '')?.group(1),
  );
  final cardio = (categoria ?? '').toLowerCase().contains('cardio') ||
      name.toLowerCase().contains('bike') ||
      name.toLowerCase().contains('caminhada') ||
      name.toLowerCase().contains('corrida');

  if ((timeMin != null && timeMin >= 2) || cardio) {
    final secs = (timeMin ?? 15) * 60;
    return TimerExercise(
      id: id,
      name: name,
      series: 1,
      repsLabel: '${timeMin ?? 15} min',
      workSeconds: secs,
      restSeconds: 0,
      effortMode: TimerEffortMode.time,
      protocol: TimerProtocol.countdown,
      notes: prescricao ?? '',
    );
  }

  if (timeSec != null && timeSec > 0 && timeSec < 180) {
    return TimerExercise(
      id: id,
      name: name,
      series: series,
      repsLabel: '${timeSec}s',
      workSeconds: timeSec,
      restSeconds: rest ?? 30,
      effortMode: TimerEffortMode.time,
      protocol: TimerProtocol.countdown,
      notes: prescricao ?? '',
    );
  }

  final reps = _firstInt(
        RegExp(r'(\d+)\s*(reps|repet)').firstMatch(text)?.group(1),
      ) ??
      _firstInt(RegExp(r'x\s*(\d+)').firstMatch(text)?.group(1)) ??
      12;

  return TimerExercise(
    id: id,
    name: name,
    series: series,
    repsLabel: '$reps',
    workSeconds: 0,
    restSeconds: rest ?? 60,
    effortMode: TimerEffortMode.reps,
    protocol: TimerProtocol.free,
    notes: prescricao ?? '',
  );
}

TimerExercise? _parseHiit(String text) {
  if (!text.contains('hiit') && !RegExp(r'\d+\s*/\s*\d+').hasMatch(text)) {
    return null;
  }
  if (!text.contains('hiit') && !text.contains('tabata')) return null;
  final wr = RegExp(r'(\d+)\s*(?:s|seg)?\s*/\s*(\d+)').firstMatch(text);
  final work = _firstInt(wr?.group(1)) ?? 40;
  final rest = _firstInt(wr?.group(2)) ?? 20;
  final rounds = _firstInt(
        RegExp(r'(\d+)\s*(rodadas|rounds)').firstMatch(text)?.group(1),
      ) ??
      8;
  return TimerExercise(
    id: 'hiit',
    name: 'HIIT',
    series: rounds,
    repsLabel: '$work/$rest',
    workSeconds: work,
    restSeconds: rest,
    rounds: rounds,
    effortMode: TimerEffortMode.time,
    protocol: TimerProtocol.hiit,
  );
}

extension on TimerExercise {
  TimerExercise copyWithName({required String id, required String name}) =>
      TimerExercise(
        id: id,
        name: name,
        series: series,
        repsLabel: repsLabel,
        workSeconds: workSeconds,
        restSeconds: restSeconds,
        rounds: rounds,
        effortMode: effortMode,
        protocol: protocol,
        autoStart: autoStart,
        autoAdvance: autoAdvance,
        notes: notes,
        videoUrl: videoUrl,
      );
}

int? _firstInt(String? raw) => raw == null ? null : int.tryParse(raw);
