enum MuscleGroup {
  peito,
  costas,
  ombros,
  biceps,
  triceps,
  pernas,
  quadriceps,
  posterior,
  gluteo,
  panturrilha,
  abdomen,
  lombar,
  cardio,
  alongamento,
  mobilidade,
  funcional,
  hiit,
}

extension MuscleGroupInfo on MuscleGroup {
  String get label => switch (this) {
        MuscleGroup.peito => 'Peito',
        MuscleGroup.costas => 'Costas',
        MuscleGroup.ombros => 'Ombros',
        MuscleGroup.biceps => 'Bíceps',
        MuscleGroup.triceps => 'Tríceps',
        MuscleGroup.pernas => 'Pernas',
        MuscleGroup.quadriceps => 'Quadríceps',
        MuscleGroup.posterior => 'Posterior',
        MuscleGroup.gluteo => 'Glúteo',
        MuscleGroup.panturrilha => 'Panturrilha',
        MuscleGroup.abdomen => 'Abdômen',
        MuscleGroup.lombar => 'Lombar',
        MuscleGroup.cardio => 'Cardio',
        MuscleGroup.alongamento => 'Alongamento',
        MuscleGroup.mobilidade => 'Mobilidade',
        MuscleGroup.funcional => 'Funcional',
        MuscleGroup.hiit => 'HIIT',
      };
}

enum NivelTreino { iniciante, intermediario, avancado }

extension NivelTreinoInfo on NivelTreino {
  String get label => switch (this) {
        NivelTreino.iniciante => 'Iniciante',
        NivelTreino.intermediario => 'Intermediário',
        NivelTreino.avancado => 'Avançado',
      };
}

/// Item do banco de exercícios — biblioteca compartilhada entre todos os
/// personais (cadastrada uma vez, usada em quantos treinos quiser).
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    this.videoUrl = '',
    this.gifUrl = '',
    this.photoUrl = '',
    this.technique = '',
    this.commonMistakes = '',
    this.active = true,
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String description;
  final String videoUrl;
  final String gifUrl;
  final String photoUrl;
  final String technique;
  final String commonMistakes;
  final bool active;

  Map<String, dynamic> toMap() => {
        'name': name,
        'muscleGroup': muscleGroup.name,
        'description': description,
        'videoUrl': videoUrl,
        'gifUrl': gifUrl,
        'photoUrl': photoUrl,
        'technique': technique,
        'commonMistakes': commonMistakes,
        'active': active,
      };

  factory Exercise.fromMap(String id, Map<String, dynamic> m) => Exercise(
        id: id,
        name: (m['name'] ?? '') as String,
        muscleGroup: MuscleGroup.values.firstWhere(
            (g) => g.name == m['muscleGroup'],
            orElse: () => MuscleGroup.funcional),
        description: (m['description'] ?? '') as String,
        videoUrl: (m['videoUrl'] ?? '') as String,
        gifUrl: (m['gifUrl'] ?? '') as String,
        photoUrl: (m['photoUrl'] ?? '') as String,
        technique: (m['technique'] ?? '') as String,
        commonMistakes: (m['commonMistakes'] ?? '') as String,
        active: (m['active'] ?? true) as bool,
      );
}

/// Configuração de um exercício DENTRO de um treino específico (séries,
/// repetições, carga sugerida etc.) — não confundir com [Exercise], que é
/// o item genérico da biblioteca.
class WorkoutExerciseConfig {
  const WorkoutExerciseConfig({
    required this.exerciseId,
    required this.exerciseName,
    required this.series,
    required this.repeticoes,
    this.tempoSegundos = 0,
    this.intervaloSegundos = 60,
    this.carga = '',
    this.metodo = '',
    this.observacoes = '',
    this.order = 0,
  });

  final String exerciseId;
  final String exerciseName; // desnormalizado — evita 1 leitura extra por exercício
  final int series;
  final String repeticoes; // texto livre: "12", "8-12", "até a falha"
  final int tempoSegundos;
  final int intervaloSegundos;
  final String carga; // ex.: "8 kg", "peso corporal"
  final String metodo; // ex.: "bi-set", "drop-set", "piramidal"
  final String observacoes;
  final int order;

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'series': series,
        'repeticoes': repeticoes,
        'tempoSegundos': tempoSegundos,
        'intervaloSegundos': intervaloSegundos,
        'carga': carga,
        'metodo': metodo,
        'observacoes': observacoes,
        'order': order,
      };

  factory WorkoutExerciseConfig.fromMap(Map<String, dynamic> m) =>
      WorkoutExerciseConfig(
        exerciseId: (m['exerciseId'] ?? '') as String,
        exerciseName: (m['exerciseName'] ?? '') as String,
        series: (m['series'] ?? 3) as int,
        repeticoes: (m['repeticoes'] ?? '12') as String,
        tempoSegundos: (m['tempoSegundos'] ?? 0) as int,
        intervaloSegundos: (m['intervaloSegundos'] ?? 60) as int,
        carga: (m['carga'] ?? '') as String,
        metodo: (m['metodo'] ?? '') as String,
        observacoes: (m['observacoes'] ?? '') as String,
        order: (m['order'] ?? 0) as int,
      );
}

/// Um treino (A, B, C...) montado pelo personal pra um aluno específico.
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.studentId,
    required this.trainerId,
    required this.name,
    required this.objective,
    required this.level,
    required this.diasSemana,
    required this.exercises,
    required this.createdAt,
    this.active = true,
  });

  final String id;
  final String studentId;
  final String trainerId;
  final String name; // "Treino A - Peito e Tríceps"
  final String objective;
  final NivelTreino level;
  final List<String> diasSemana; // ['SEG','QUA','SEX']
  final List<WorkoutExerciseConfig> exercises;
  final DateTime createdAt;
  final bool active;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'trainerId': trainerId,
        'name': name,
        'objective': objective,
        'level': level.name,
        'diasSemana': diasSemana,
        'exercises': exercises.map((e) => e.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'active': active,
      };

  factory WorkoutPlan.fromMap(String id, Map<String, dynamic> m) =>
      WorkoutPlan(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        trainerId: (m['trainerId'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        objective: (m['objective'] ?? '') as String,
        level: NivelTreino.values.firstWhere((l) => l.name == m['level'],
            orElse: () => NivelTreino.iniciante),
        diasSemana: (m['diasSemana'] as List?)?.cast<String>() ?? [],
        exercises: (m['exercises'] as List? ?? [])
            .map((e) => WorkoutExerciseConfig.fromMap(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
            DateTime.now(),
        active: (m['active'] ?? true) as bool,
      );
}

/// Aluno vinculado a um personal.
class Student {
  const Student({
    required this.id,
    required this.trainerId,
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.objective = '',
    this.active = true,
    required this.startDate,
  });

  final String id;
  final String trainerId;

  /// uid do AppUser correspondente (permite o aluno logar e ver sua área).
  final String userId;
  final String name;
  final String email;
  final String photoUrl;
  final String objective;
  final bool active;
  final DateTime startDate;

  Map<String, dynamic> toMap() => {
        'trainerId': trainerId,
        'userId': userId,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'objective': objective,
        'active': active,
        'startDate': startDate.toIso8601String(),
      };

  factory Student.fromMap(String id, Map<String, dynamic> m) => Student(
        id: id,
        trainerId: (m['trainerId'] ?? '') as String,
        userId: (m['userId'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        photoUrl: (m['photoUrl'] ?? '') as String,
        objective: (m['objective'] ?? '') as String,
        active: (m['active'] ?? true) as bool,
        startDate: DateTime.tryParse(m['startDate'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Avaliação física completa — um "raio-x" do aluno numa data.
class PhysicalAssessment {
  const PhysicalAssessment({
    required this.id,
    required this.studentId,
    required this.date,
    this.weightKg,
    this.heightM,
    this.bodyFatPercent,
    this.muscleMassKg,
    this.circBraco,
    this.circPeitoral,
    this.circCintura,
    this.circAbdomen,
    this.circQuadril,
    this.circCoxa,
    this.circPanturrilha,
    this.observacoes = '',
  });

  final String id;
  final String studentId;
  final DateTime date;
  final double? weightKg;
  final double? heightM;
  final double? bodyFatPercent;
  final double? muscleMassKg;
  final double? circBraco;
  final double? circPeitoral;
  final double? circCintura;
  final double? circAbdomen;
  final double? circQuadril;
  final double? circCoxa;
  final double? circPanturrilha;
  final String observacoes;

  double? get imc => (weightKg != null && heightM != null && heightM! > 0)
      ? weightKg! / (heightM! * heightM!)
      : null;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'heightM': heightM,
        'bodyFatPercent': bodyFatPercent,
        'muscleMassKg': muscleMassKg,
        'circBraco': circBraco,
        'circPeitoral': circPeitoral,
        'circCintura': circCintura,
        'circAbdomen': circAbdomen,
        'circQuadril': circQuadril,
        'circCoxa': circCoxa,
        'circPanturrilha': circPanturrilha,
        'observacoes': observacoes,
      };

  factory PhysicalAssessment.fromMap(String id, Map<String, dynamic> m) =>
      PhysicalAssessment(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        weightKg: (m['weightKg'] as num?)?.toDouble(),
        heightM: (m['heightM'] as num?)?.toDouble(),
        bodyFatPercent: (m['bodyFatPercent'] as num?)?.toDouble(),
        muscleMassKg: (m['muscleMassKg'] as num?)?.toDouble(),
        circBraco: (m['circBraco'] as num?)?.toDouble(),
        circPeitoral: (m['circPeitoral'] as num?)?.toDouble(),
        circCintura: (m['circCintura'] as num?)?.toDouble(),
        circAbdomen: (m['circAbdomen'] as num?)?.toDouble(),
        circQuadril: (m['circQuadril'] as num?)?.toDouble(),
        circCoxa: (m['circCoxa'] as num?)?.toDouble(),
        circPanturrilha: (m['circPanturrilha'] as num?)?.toDouble(),
        observacoes: (m['observacoes'] ?? '') as String,
      );
}

enum FotoTipo { frente, perfil, costas }

class EvolutionPhoto {
  const EvolutionPhoto({
    required this.id,
    required this.studentId,
    required this.date,
    required this.tipo,
    required this.url,
  });

  final String id;
  final String studentId;
  final DateTime date;
  final FotoTipo tipo;
  final String url;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'date': date.toIso8601String(),
        'tipo': tipo.name,
        'url': url,
      };

  factory EvolutionPhoto.fromMap(String id, Map<String, dynamic> m) =>
      EvolutionPhoto(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        tipo: FotoTipo.values.firstWhere((t) => t.name == m['tipo'],
            orElse: () => FotoTipo.frente),
        url: (m['url'] ?? '') as String,
      );
}

/// Registro de carga usada num exercício — histórico completo de progressão.
class LoadEntry {
  const LoadEntry({
    required this.id,
    required this.studentId,
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.weightKg,
  });

  final String id;
  final String studentId;
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final double weightKg;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory LoadEntry.fromMap(String id, Map<String, dynamic> m) => LoadEntry(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        exerciseId: (m['exerciseId'] ?? '') as String,
        exerciseName: (m['exerciseName'] ?? '') as String,
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        weightKg: (m['weightKg'] as num? ?? 0).toDouble(),
      );
}

/// Registro de uma sessão de treino concluída pelo aluno.
class WorkoutSessionLog {
  const WorkoutSessionLog({
    required this.id,
    required this.studentId,
    required this.workoutPlanId,
    required this.workoutName,
    required this.date,
    required this.completedExerciseIds,
  });

  final String id;
  final String studentId;
  final String workoutPlanId;
  final String workoutName;
  final DateTime date;
  final List<String> completedExerciseIds;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'workoutPlanId': workoutPlanId,
        'workoutName': workoutName,
        'date': date.toIso8601String(),
        'completedExerciseIds': completedExerciseIds,
      };

  factory WorkoutSessionLog.fromMap(String id, Map<String, dynamic> m) =>
      WorkoutSessionLog(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        workoutPlanId: (m['workoutPlanId'] ?? '') as String,
        workoutName: (m['workoutName'] ?? '') as String,
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        completedExerciseIds:
            (m['completedExerciseIds'] as List?)?.cast<String>() ?? [],
      );
}
