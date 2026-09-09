import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/personal_trainer/domain/pt_models.dart';

void main() {
  group('Exercise library model', () {
    test('serializa campos de vídeo/equipamento/nível', () {
      const e = Exercise(
        id: 'ex1',
        name: 'Supino',
        muscleGroup: MuscleGroup.peito,
        description: 'Peito',
        videoUrl: 'https://youtube.com/watch?v=abc123',
        equipment: 'Barra',
        level: NivelTreino.intermediario,
        defaultSeries: 4,
        defaultReps: '8-10',
      );
      final map = e.toMap();
      final back = Exercise.fromMap('ex1', map);
      expect(back.videoUrl, contains('youtube'));
      expect(back.equipment, 'Barra');
      expect(back.level, NivelTreino.intermediario);
      expect(back.defaultSeries, 4);
    });
  });

  group('WorkoutExerciseConfig', () {
    test('mantém ordem, carga e descanso', () {
      const c = WorkoutExerciseConfig(
        exerciseId: 'e1',
        exerciseName: 'Agachamento',
        series: 3,
        repeticoes: '12',
        tempoSegundos: 40,
        intervaloSegundos: 90,
        carga: '40 kg',
        observacoes: 'Joelho alinhado',
        order: 2,
      );
      final back = WorkoutExerciseConfig.fromMap(c.toMap());
      expect(back.tempoSegundos, 40);
      expect(back.intervaloSegundos, 90);
      expect(back.order, 2);
      expect(back.carga, '40 kg');
    });
  });

  group('WorkoutPlan', () {
    test('preserva dias e exercícios', () {
      final plan = WorkoutPlan(
        id: 'p1',
        studentId: 's1',
        trainerId: 't1',
        name: 'Treino A',
        objective: 'Hipertrofia',
        level: NivelTreino.iniciante,
        diasSemana: const ['SEG', 'QUA'],
        exercises: const [
          WorkoutExerciseConfig(
            exerciseId: 'e1',
            exerciseName: 'Remada',
            series: 3,
            repeticoes: '10',
          ),
        ],
        createdAt: DateTime(2026, 1, 1),
      );
      final back = WorkoutPlan.fromMap('p1', plan.toMap());
      expect(back.name, 'Treino A');
      expect(back.diasSemana, ['SEG', 'QUA']);
      expect(back.exercises, hasLength(1));
      expect(back.active, isTrue);
    });
  });
}
