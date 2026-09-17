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
    this.equipment = '',
    this.level = NivelTreino.iniciante,
    this.defaultSeries = 3,
    this.defaultReps = '12',
    this.observacoes = '',
    this.storageVideoPath = '',
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
  final String equipment;
  final NivelTreino level;
  final int defaultSeries;
  final String defaultReps;
  final String observacoes;
  final String storageVideoPath;
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
        'equipment': equipment,
        'level': level.name,
        'defaultSeries': defaultSeries,
        'defaultReps': defaultReps,
        'observacoes': observacoes,
        'storageVideoPath': storageVideoPath,
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
        equipment: (m['equipment'] ?? '') as String,
        level: NivelTreino.values.firstWhere((l) => l.name == m['level'],
            orElse: () => NivelTreino.iniciante),
        defaultSeries: (m['defaultSeries'] ?? 3) as int,
        defaultReps: (m['defaultReps'] ?? '12') as String,
        observacoes: (m['observacoes'] ?? '') as String,
        storageVideoPath: (m['storageVideoPath'] ?? '') as String,
        active: (m['active'] ?? true) as bool,
      );

  Exercise copyWith({
    String? name,
    MuscleGroup? muscleGroup,
    String? description,
    String? videoUrl,
    String? gifUrl,
    String? photoUrl,
    String? technique,
    String? commonMistakes,
    String? equipment,
    NivelTreino? level,
    int? defaultSeries,
    String? defaultReps,
    String? observacoes,
    String? storageVideoPath,
    bool? active,
  }) =>
      Exercise(
        id: id,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        description: description ?? this.description,
        videoUrl: videoUrl ?? this.videoUrl,
        gifUrl: gifUrl ?? this.gifUrl,
        photoUrl: photoUrl ?? this.photoUrl,
        technique: technique ?? this.technique,
        commonMistakes: commonMistakes ?? this.commonMistakes,
        equipment: equipment ?? this.equipment,
        level: level ?? this.level,
        defaultSeries: defaultSeries ?? this.defaultSeries,
        defaultReps: defaultReps ?? this.defaultReps,
        observacoes: observacoes ?? this.observacoes,
        storageVideoPath: storageVideoPath ?? this.storageVideoPath,
        active: active ?? this.active,
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
    this.intensidade = '',
    this.effortMode = '',
    this.timerProtocol = '',
    this.rounds = 0,
    this.autoStartTimer = false,
    this.autoAdvanceNext = true,
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
  final String intensidade; // leve | moderada | intensa
  /// `reps` ou `time`. Vazio = inferir pelo tempoSegundos.
  final String effortMode;
  /// free | countdown | rest | hiit | circuit | emom | amrap
  final String timerProtocol;
  final int rounds;
  final bool autoStartTimer;
  final bool autoAdvanceNext;

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
        'intensidade': intensidade,
        'effortMode': effortMode,
        'timerProtocol': timerProtocol,
        'rounds': rounds,
        'autoStartTimer': autoStartTimer,
        'autoAdvanceNext': autoAdvanceNext,
      };

  factory WorkoutExerciseConfig.fromMap(Map<String, dynamic> m) =>
      WorkoutExerciseConfig(
        exerciseId: (m['exerciseId'] ?? '') as String,
        exerciseName: (m['exerciseName'] ?? '') as String,
        series: (m['series'] is num) ? (m['series'] as num).round() : 3,
        repeticoes: (m['repeticoes'] ?? '12') as String,
        tempoSegundos:
            (m['tempoSegundos'] is num) ? (m['tempoSegundos'] as num).round() : 0,
        intervaloSegundos: (m['intervaloSegundos'] is num)
            ? (m['intervaloSegundos'] as num).round()
            : 60,
        carga: (m['carga'] ?? '') as String,
        metodo: (m['metodo'] ?? '') as String,
        observacoes: (m['observacoes'] ?? '') as String,
        order: (m['order'] is num) ? (m['order'] as num).round() : 0,
        intensidade: (m['intensidade'] ?? '') as String,
        effortMode: (m['effortMode'] ?? '') as String,
        timerProtocol: (m['timerProtocol'] ?? '') as String,
        rounds: (m['rounds'] is num) ? (m['rounds'] as num).round() : 0,
        autoStartTimer: (m['autoStartTimer'] ?? false) as bool,
        autoAdvanceNext: (m['autoAdvanceNext'] ?? true) as bool,
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
    this.phone = '',
    this.age,
    this.sex = '',
    this.weightKg,
    this.heightM,
    this.level = NivelTreino.iniciante,
    this.notes = '',
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
  final String phone;
  final int? age;
  final String sex; // feminino | masculino | outro | ''
  final double? weightKg;
  final double? heightM;
  final NivelTreino level;
  final String notes;

  Map<String, dynamic> toMap() => {
        'trainerId': trainerId,
        'userId': userId,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'objective': objective,
        'active': active,
        'startDate': startDate.toIso8601String(),
        'phone': phone,
        'age': age,
        'sex': sex,
        'weightKg': weightKg,
        'heightM': heightM,
        'level': level.name,
        'notes': notes,
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
        phone: (m['phone'] ?? '') as String,
        age: (m['age'] as num?)?.toInt(),
        sex: (m['sex'] ?? '') as String,
        weightKg: (m['weightKg'] as num?)?.toDouble(),
        heightM: (m['heightM'] as num?)?.toDouble(),
        level: NivelTreino.values.firstWhere((l) => l.name == m['level'],
            orElse: () => NivelTreino.iniciante),
        notes: (m['notes'] ?? m['observacoes'] ?? '') as String,
      );

  Student copyWith({
    String? userId,
    String? name,
    String? email,
    String? photoUrl,
    String? objective,
    bool? active,
    DateTime? startDate,
    String? phone,
    int? age,
    String? sex,
    double? weightKg,
    double? heightM,
    NivelTreino? level,
    String? notes,
  }) =>
      Student(
        id: id,
        trainerId: trainerId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        objective: objective ?? this.objective,
        active: active ?? this.active,
        startDate: startDate ?? this.startDate,
        phone: phone ?? this.phone,
        age: age ?? this.age,
        sex: sex ?? this.sex,
        weightKg: weightKg ?? this.weightKg,
        heightM: heightM ?? this.heightM,
        level: level ?? this.level,
        notes: notes ?? this.notes,
      );
}

/// Avaliação física completa — um "raio-x" do aluno numa data.
class PhysicalAssessment {
  const PhysicalAssessment({
    required this.id,
    required this.studentId,
    required this.trainerId,
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
  final String trainerId;
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
        'trainerId': trainerId,
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
        trainerId: (m['trainerId'] ?? '') as String,
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

enum FotoTipo { frente, perfil, costas, outras }

class EvolutionPhoto {
  const EvolutionPhoto({
    required this.id,
    required this.studentId,
    required this.trainerId,
    required this.date,
    required this.tipo,
    required this.url,
  });

  final String id;
  final String studentId;
  final String trainerId;
  final DateTime date;
  final FotoTipo tipo;
  final String url;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'trainerId': trainerId,
        'date': date.toIso8601String(),
        'tipo': tipo.name,
        'url': url,
      };

  factory EvolutionPhoto.fromMap(String id, Map<String, dynamic> m) =>
      EvolutionPhoto(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        trainerId: (m['trainerId'] ?? '') as String,
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
    required this.trainerId,
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.weightKg,
  });

  final String id;
  final String studentId;
  final String trainerId;
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final double weightKg;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'trainerId': trainerId,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory LoadEntry.fromMap(String id, Map<String, dynamic> m) => LoadEntry(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        trainerId: (m['trainerId'] ?? '') as String,
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
    required this.trainerId,
    required this.workoutPlanId,
    required this.workoutName,
    required this.date,
    required this.completedExerciseIds,
    this.difficulty = '',
    this.feltPain,
    this.tiredness = '',
    this.feedbackNotes = '',
    this.durationMinutes,
  });

  final String id;
  final String studentId;
  final String trainerId;
  final String workoutPlanId;
  final String workoutName;
  final DateTime date;
  final List<String> completedExerciseIds;

  /// muito_leve | adequado | dificil | muito_dificil
  final String difficulty;
  final bool? feltPain;

  /// baixo | medio | alto
  final String tiredness;
  final String feedbackNotes;
  final int? durationMinutes;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'trainerId': trainerId,
        'workoutPlanId': workoutPlanId,
        'workoutName': workoutName,
        'date': date.toIso8601String(),
        'completedExerciseIds': completedExerciseIds,
        'difficulty': difficulty,
        'feltPain': feltPain,
        'tiredness': tiredness,
        'feedbackNotes': feedbackNotes,
        'durationMinutes': durationMinutes,
      };

  factory WorkoutSessionLog.fromMap(String id, Map<String, dynamic> m) =>
      WorkoutSessionLog(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        trainerId: (m['trainerId'] ?? '') as String,
        workoutPlanId: (m['workoutPlanId'] ?? '') as String,
        workoutName: (m['workoutName'] ?? '') as String,
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
        completedExerciseIds:
            (m['completedExerciseIds'] as List?)?.cast<String>() ?? [],
        difficulty: (m['difficulty'] ?? '') as String,
        feltPain: m['feltPain'] as bool?,
        tiredness: (m['tiredness'] ?? '') as String,
        feedbackNotes: (m['feedbackNotes'] ?? '') as String,
        durationMinutes: (m['durationMinutes'] as num?)?.toInt(),
      );
}

/// Ficha de anamnese do aluno (editável; 1 documento por aluno).
class StudentAnamnesis {
  const StudentAnamnesis({
    required this.studentId,
    required this.trainerId,
    this.mainObjective = '',
    this.trainingExperience = '',
    this.diseases = '',
    this.injuries = '',
    this.surgeries = '',
    this.limitations = '',
    this.medications = '',
    this.pains = '',
    this.availability = '',
    this.weekDays = const [],
    this.trainingLocation = '',
    this.equipment = '',
    this.notes = '',
    this.updatedAt,
  });

  final String studentId;
  final String trainerId;
  final String mainObjective;
  final String trainingExperience;
  final String diseases;
  final String injuries;
  final String surgeries;
  final String limitations;
  final String medications;
  final String pains;
  final String availability;
  final List<String> weekDays;
  final String trainingLocation;
  final String equipment;
  final String notes;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'trainerId': trainerId,
        'mainObjective': mainObjective,
        'trainingExperience': trainingExperience,
        'diseases': diseases,
        'injuries': injuries,
        'surgeries': surgeries,
        'limitations': limitations,
        'medications': medications,
        'pains': pains,
        'availability': availability,
        'weekDays': weekDays,
        'trainingLocation': trainingLocation,
        'equipment': equipment,
        'notes': notes,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  factory StudentAnamnesis.fromMap(String studentId, Map<String, dynamic>? m) {
    if (m == null || m.isEmpty) {
      return StudentAnamnesis(studentId: studentId, trainerId: '');
    }
    return StudentAnamnesis(
      studentId: studentId,
      trainerId: (m['trainerId'] ?? '') as String,
      mainObjective: (m['mainObjective'] ?? '') as String,
      trainingExperience: (m['trainingExperience'] ?? '') as String,
      diseases: (m['diseases'] ?? '') as String,
      injuries: (m['injuries'] ?? '') as String,
      surgeries: (m['surgeries'] ?? '') as String,
      limitations: (m['limitations'] ?? '') as String,
      medications: (m['medications'] ?? '') as String,
      pains: (m['pains'] ?? '') as String,
      availability: (m['availability'] ?? '') as String,
      weekDays: (m['weekDays'] as List?)?.cast<String>() ?? const [],
      trainingLocation: (m['trainingLocation'] ?? '') as String,
      equipment: (m['equipment'] ?? '') as String,
      notes: (m['notes'] ?? '') as String,
      updatedAt: DateTime.tryParse(m['updatedAt'] as String? ?? ''),
    );
  }
}
