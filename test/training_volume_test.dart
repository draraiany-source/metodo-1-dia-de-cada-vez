import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/evolution/domain/personal_records.dart';
import 'package:metodo_1_dia/features/evolution/domain/training_volume.dart';
import 'package:metodo_1_dia/features/personal_trainer/domain/pt_models.dart';
import 'package:metodo_1_dia/features/running/data/running_repository.dart';
import 'package:metodo_1_dia/features/workout_timer/domain/workout_timer_models.dart';

LoadEntry carga({
  required String id,
  required String nome,
  required DateTime data,
  required double kg,
  String exerciseId = '',
  int? series,
  int? reps,
}) {
  return LoadEntry(
    id: id,
    studentId: 'aluna',
    trainerId: 'pt',
    exerciseId: exerciseId.isEmpty ? nome : exerciseId,
    exerciseName: nome,
    date: data,
    weightKg: kg,
    series: series,
    repeticoes: reps,
  );
}

void main() {
  group('TrainingVolume.of', () {
    test('30 kg × 12 × 4 = 1.440 kg', () {
      expect(
        TrainingVolume.of(weightKg: 30, reps: 12, series: 4),
        1440,
      );
    });

    test('não inventa volume quando falta parcela', () {
      expect(TrainingVolume.of(weightKg: 0, reps: 12, series: 4), isNull);
      expect(TrainingVolume.of(weightKg: 30, reps: 0, series: 4), isNull);
      expect(TrainingVolume.of(weightKg: 30, reps: 12, series: 0), isNull);
    });
  });

  group('TrainingVolume.parseReps', () {
    test('número simples', () {
      expect(TrainingVolume.parseReps('12'), 12);
      expect(TrainingVolume.parseReps(' 8 '), 8);
    });

    test('intervalo usa a média', () {
      expect(TrainingVolume.parseReps('8-12'), 10);
      expect(TrainingVolume.parseReps('8 – 12'), 10);
    });

    test('texto sem número', () {
      expect(TrainingVolume.parseReps('até a falha'), isNull);
      expect(TrainingVolume.parseReps(''), isNull);
    });
  });

  group('TrainingVolume.parseWeight', () {
    test('aceita kg com vírgula brasileira', () {
      expect(TrainingVolume.parseWeight('30 kg'), 30);
      expect(TrainingVolume.parseWeight('32,5'), 32.5);
      expect(TrainingVolume.parseWeight('8kg'), 8);
    });

    test('peso corporal não é carga', () {
      expect(TrainingVolume.parseWeight('peso corporal'), isNull);
      expect(TrainingVolume.parseWeight('livre'), isNull);
    });
  });

  group('TrainingVolume.format', () {
    test('volume com milhar brasileiro', () {
      expect(TrainingVolume.formatVolume(1440), '1.440 kg');
      expect(TrainingVolume.formatVolume(4280), '4.280 kg');
    });

    test('percentual com sinal', () {
      expect(TrainingVolume.formatPercent(33.333), startsWith('+33'));
      expect(TrainingVolume.formatPercent(-10), '-10%');
    });
  });

  group('LoadEntry', () {
    test('volume só existe com séries e reps', () {
      final legado = carga(
        id: '1',
        nome: 'Agachamento',
        data: DateTime(2026, 9, 1),
        kg: 30,
      );
      expect(legado.volumeKg, isNull);

      final completo = carga(
        id: '2',
        nome: 'Agachamento',
        data: DateTime(2026, 9, 1),
        kg: 30,
        series: 4,
        reps: 12,
      );
      expect(completo.volumeKg, 1440);
    });

    test('fromMap tolera documento antigo sem séries', () {
      final v = LoadEntry.fromMap('id', {
        'studentId': 'a',
        'trainerId': 't',
        'exerciseId': 'agach',
        'exerciseName': 'Agachamento',
        'date': '2026-09-01T10:00:00.000',
        'weightKg': 30,
      });
      expect(v.weightKg, 30);
      expect(v.series, isNull);
      expect(v.repeticoes, isNull);
      expect(v.volumeKg, isNull);
      expect(v.toMap().containsKey('series'), isFalse);
    });

    test('round-trip preserva séries e reps novos', () {
      final original = carga(
        id: 'x',
        nome: 'Leg Press',
        data: DateTime(2026, 9, 14, 10),
        kg: 100,
        series: 4,
        reps: 10,
      );
      final volta = LoadEntry.fromMap('x', original.toMap());
      expect(volta.series, 4);
      expect(volta.repeticoes, 10);
      expect(volta.volumeKg, 4000);
    });
  });

  group('WorkoutSessionLog.totalVolumeKg', () {
    test('documento antigo sem volume continua válido', () {
      final log = WorkoutSessionLog.fromMap('s', {
        'studentId': 'a',
        'trainerId': 't',
        'workoutPlanId': 'p',
        'workoutName': 'A',
        'date': '2026-09-01T10:00:00.000',
        'completedExerciseIds': ['1'],
      });
      expect(log.totalVolumeKg, isNull);
      expect(log.toMap().containsKey('totalVolumeKg'), isFalse);
    });
  });

  group('ExerciseLoadStats', () {
    final hist = [
      carga(id: '1', nome: 'Agachamento', data: DateTime(2026, 9, 1), kg: 30),
      carga(id: '2', nome: 'Agachamento', data: DateTime(2026, 9, 5), kg: 32),
      carga(id: '3', nome: 'Agachamento', data: DateTime(2026, 9, 9), kg: 35),
      carga(id: '4', nome: 'Agachamento', data: DateTime(2026, 9, 14), kg: 40),
    ];

    test('última, maior, média e evolução percentual', () {
      final s = ExerciseLoadStats.from(hist);
      expect(s.lastWeight, 40);
      expect(s.maxWeight, 40);
      expect(s.firstWeight, 30);
      expect(s.avgWeight, closeTo(34.25, 0.01));
      expect(s.percentEvolution, closeTo(33.333, 0.01));
    });

    test('não apaga o histórico — a timeline tem os 4 pontos', () {
      final s = ExerciseLoadStats.from(hist);
      expect(s.cronologico.map((e) => e.weightKg), [30, 32, 35, 40]);
    });

    test('recorde novo só depois da linha de base', () {
      expect(
        ExerciseLoadStats.isNewWeightRecord(
          historicoAnterior: const [],
          novaCarga: 40,
        ),
        isFalse,
      );
      expect(
        ExerciseLoadStats.isNewWeightRecord(
          historicoAnterior: hist,
          novaCarga: 40,
        ),
        isFalse,
      );
      expect(
        ExerciseLoadStats.isNewWeightRecord(
          historicoAnterior: hist,
          novaCarga: 42,
        ),
        isTrue,
      );
    });

    test('agrupa por exercício e ignora volume legado na soma', () {
      final misto = [
        ...hist,
        carga(
          id: '5',
          nome: 'Leg Press',
          exerciseId: 'leg',
          data: DateTime(2026, 9, 15),
          kg: 80,
          series: 3,
          reps: 10,
        ),
      ];
      final grupos = ExerciseLoadStats.group(misto);
      expect(grupos.length, 2);
      final leg = grupos.firstWhere((g) => g.exerciseName == 'Leg Press');
      expect(leg.totalVolumeKg, 2400);
      final agach = grupos.firstWhere((g) => g.exerciseName == 'Agachamento');
      expect(agach.totalVolumeKg, isNull);
    });
  });

  group('PersonalRecordsBoard', () {
    test('maior carga e mais reps saem do histórico de cargas', () {
      final board = PersonalRecordsBoard.build(cargas: [
        carga(
          id: '1',
          nome: 'Leg Press',
          data: DateTime(2026, 9, 1),
          kg: 80,
          series: 3,
          reps: 10,
        ),
        carga(
          id: '2',
          nome: 'Leg Press',
          data: DateTime(2026, 9, 10),
          kg: 100,
          series: 3,
          reps: 8,
        ),
        carga(
          id: '3',
          nome: 'Rosca',
          data: DateTime(2026, 9, 10),
          kg: 12,
          series: 3,
          reps: 15,
        ),
      ]);
      final cargaRec = board.items
          .firstWhere((r) => r.kind == PersonalRecordKind.maiorCarga);
      expect(cargaRec.valueLabel, '100 kg');
      expect(cargaRec.exerciseName, 'Leg Press');
      final reps = board.items
          .firstWhere((r) => r.kind == PersonalRecordKind.maisRepeticoes);
      expect(reps.valueLabel, '15 reps');
      expect(reps.exerciseName, 'Rosca');
    });

    test('melhor pace ignora sprints curtos demais', () {
      final board = PersonalRecordsBoard.build(corridas: [
        RunningSession(
          id: 'a',
          date: DateTime(2026, 9, 1),
          distanceKm: 0.2,
          durationSeconds: 40,
          kcal: 10,
        ),
        RunningSession(
          id: 'b',
          date: DateTime(2026, 9, 2),
          distanceKm: 5,
          durationSeconds: 30 * 60,
          kcal: 300,
        ),
      ]);
      final pace = board.items
          .firstWhere((r) => r.kind == PersonalRecordKind.melhorPace);
      expect(pace.valueLabel, '6:00 /km');
      final dist = board.items
          .firstWhere((r) => r.kind == PersonalRecordKind.maiorDistancia);
      expect(dist.numericValue, 5);
    });

    test('treino mais longo olha timer e PT', () {
      final board = PersonalRecordsBoard.build(
        sessoesTimer: [
          WorkoutSessionRecord(
            id: 't',
            userId: 'u',
            workoutId: 'w',
            title: 'HIIT',
            startedAt: DateTime(2026, 9, 1, 10),
            completedAt: DateTime(2026, 9, 1, 10, 20),
            totalDuration: const Duration(minutes: 20),
            activeDuration: const Duration(minutes: 16),
            restDuration: const Duration(minutes: 4),
            exercisesDone: 6,
            exercisesTotal: 6,
            seriesDone: 12,
            percent: 1,
          ),
        ],
        sessoesPt: [
          WorkoutSessionLog(
            id: 'p',
            studentId: 's',
            trainerId: 't',
            workoutPlanId: 'pl',
            workoutName: 'A',
            date: DateTime(2026, 9, 2),
            completedExerciseIds: const ['1'],
            durationMinutes: 42,
          ),
        ],
      );
      final rec = board.items
          .firstWhere((r) => r.kind == PersonalRecordKind.treinoMaisLongo);
      expect(rec.valueLabel, '42 min');
    });

    test('mais treinos na mesma semana', () {
      final semana = DateTime(2026, 9, 14); // segunda
      final board = PersonalRecordsBoard.build(
        sessoesPt: [
          for (var i = 0; i < 4; i++)
            WorkoutSessionLog(
              id: '$i',
              studentId: 's',
              trainerId: 't',
              workoutPlanId: 'p',
              workoutName: 'A',
              date: semana.add(Duration(days: i)),
              completedExerciseIds: const ['1'],
            ),
        ],
      );
      final rec = board.items.firstWhere(
          (r) => r.kind == PersonalRecordKind.maisTreinosNaSemana);
      expect(rec.numericValue, 4);
    });
  });
}
