import '../../personal_trainer/domain/pt_models.dart';
import '../../workouts/domain/treino_catalog_models.dart';
import 'workout_timer_models.dart';

TimerExercise timerExerciseFromConfig(WorkoutExerciseConfig c) {
  final protocol = TimerProtocol.values.firstWhere(
    (p) => p.name == c.timerProtocol,
    orElse: () => c.tempoSegundos > 0
        ? TimerProtocol.countdown
        : (c.metodo.toLowerCase().contains('hiit')
            ? TimerProtocol.hiit
            : TimerProtocol.free),
  );
  final effort = c.effortMode == 'time' || c.tempoSegundos > 0
      ? TimerEffortMode.time
      : TimerEffortMode.reps;
  return TimerExercise(
    id: c.exerciseId,
    name: c.exerciseName,
    series: c.series,
    repsLabel: c.repeticoes,
    workSeconds: c.tempoSegundos,
    restSeconds: c.intervaloSegundos,
    rounds: c.rounds > 0 ? c.rounds : c.series,
    effortMode: effort,
    protocol: protocol,
    autoStart: c.autoStartTimer,
    autoAdvance: c.autoAdvanceNext,
    notes: c.observacoes,
    videoUrl: '',
  );
}

WorkoutTimerBlueprint blueprintFromPlan(WorkoutPlan plan) =>
    WorkoutTimerBlueprint(
      workoutId: plan.id,
      title: plan.name,
      exercises: [
        for (final e in [...plan.exercises]
          ..sort((a, b) => a.order.compareTo(b.order)))
          timerExerciseFromConfig(e),
      ],
      autoStartFirst: plan.exercises.any((e) => e.autoStartTimer),
    );

WorkoutTimerBlueprint blueprintFromCatalog(TreinoCatalogEntry treino) {
  final exercise = parseCatalogExercise(
    id: treino.id,
    name: treino.nome,
    prescricao: treino.prescricao,
    intervalo: treino.intervalo,
    categoria: treino.categoria,
  );
  return WorkoutTimerBlueprint(
    workoutId: treino.id,
    title: treino.nome,
    exercises: [exercise],
    autoStartFirst: false,
  );
}
