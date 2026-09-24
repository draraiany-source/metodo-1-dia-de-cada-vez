enum AudioCourseCategory {
  mentalidade,
  habitos,
  alimentacao,
  emagrecimento,
  sono,
  ansiedade,
  motivacao,
  autoestima,
  organizacao,
  meditacao,
  respiracao,
  bomDia,
  boaTarde,
  boaNoite,
  antesDoTreino,
  depoisDoTreino,
}

extension AudioCourseCategoryInfo on AudioCourseCategory {
  String get label => switch (this) {
        AudioCourseCategory.mentalidade => 'Mentalidade',
        AudioCourseCategory.habitos => 'Hábitos',
        AudioCourseCategory.alimentacao => 'Alimentação',
        AudioCourseCategory.emagrecimento => 'Emagrecimento',
        AudioCourseCategory.sono => 'Sono',
        AudioCourseCategory.ansiedade => 'Ansiedade',
        AudioCourseCategory.motivacao => 'Motivação',
        AudioCourseCategory.autoestima => 'Autoestima',
        AudioCourseCategory.organizacao => 'Organização',
        AudioCourseCategory.meditacao => 'Meditação',
        AudioCourseCategory.respiracao => 'Respiração',
        AudioCourseCategory.bomDia => 'Bom dia',
        AudioCourseCategory.boaTarde => 'Boa tarde',
        AudioCourseCategory.boaNoite => 'Boa noite',
        AudioCourseCategory.antesDoTreino => 'Antes do treino',
        AudioCourseCategory.depoisDoTreino => 'Depois do treino',
      };
}

/// Um curso em áudio — capa + professor + lista de capítulos.
class AudioCourse {
  const AudioCourse({
    required this.id,
    required this.title,
    required this.teacher,
    required this.category,
    required this.coverUrl,
    required this.chapters,
    this.isPremium = false,
    this.order = 0,
    this.active = true,
  });

  final String id;
  final String title;
  final String teacher;
  final AudioCourseCategory category;
  final String coverUrl;
  final List<AudioChapter> chapters;
  final bool isPremium;
  final int order;
  /// Se `false`, não aparece para alunas (rascunho / teste).
  final bool active;

  Duration get duracaoTotal =>
      chapters.fold(Duration.zero, (sum, c) => sum + c.duration);

  AudioCourse copyWith({
    List<AudioChapter>? chapters,
    bool? active,
    int? order,
  }) {
    return AudioCourse(
      id: id,
      title: title,
      teacher: teacher,
      category: category,
      coverUrl: coverUrl,
      chapters: chapters ?? this.chapters,
      isPremium: isPremium,
      order: order ?? this.order,
      active: active ?? this.active,
    );
  }

  factory AudioCourse.fromMap(String id, Map<String, dynamic> m,
      List<AudioChapter> chapters) {
    return AudioCourse(
      id: id,
      title: (m['title'] ?? '') as String,
      teacher: (m['teacher'] ?? '') as String,
      category: AudioCourseCategory.values.firstWhere(
          (c) => c.name == m['category'],
          orElse: () => AudioCourseCategory.motivacao),
      coverUrl: (m['coverUrl'] ?? '') as String,
      chapters: chapters,
      isPremium: (m['isPremium'] ?? false) as bool,
      order: (m['order'] ?? 0) as int,
      // Documentos antigos sem o campo continuam visíveis (active=true).
      active: (m['active'] ?? true) as bool,
    );
  }
}

/// Um capítulo/faixa dentro de um curso.
class AudioChapter {
  const AudioChapter({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.duration,
    required this.order,
    this.storagePath = '',
  });

  final String id;
  final String title;
  final String audioUrl;
  final Duration duration;
  final int order;
  /// Caminho no Firebase Storage (para substituir/remover o arquivo).
  final String storagePath;

  AudioChapter copyWith({
    String? title,
    String? audioUrl,
    Duration? duration,
    int? order,
    String? storagePath,
  }) {
    return AudioChapter(
      id: id,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  factory AudioChapter.fromMap(String id, Map<String, dynamic> m) {
    return AudioChapter(
      id: id,
      title: (m['title'] ?? '') as String,
      audioUrl: (m['audioUrl'] ?? '') as String,
      duration: Duration(seconds: (m['durationSeconds'] ?? 0) as int),
      order: (m['order'] ?? 0) as int,
      storagePath: (m['storagePath'] ?? '') as String,
    );
  }
}
