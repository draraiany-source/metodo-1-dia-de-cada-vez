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
  });

  final String id;
  final String title;
  final String teacher;
  final AudioCourseCategory category;
  final String coverUrl;
  final List<AudioChapter> chapters;
  final bool isPremium;
  final int order;

  Duration get duracaoTotal =>
      chapters.fold(Duration.zero, (sum, c) => sum + c.duration);

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
  });

  final String id;
  final String title;
  final String audioUrl;
  final Duration duration;
  final int order;

  factory AudioChapter.fromMap(String id, Map<String, dynamic> m) {
    return AudioChapter(
      id: id,
      title: (m['title'] ?? '') as String,
      audioUrl: (m['audioUrl'] ?? '') as String,
      duration: Duration(seconds: (m['durationSeconds'] ?? 0) as int),
      order: (m['order'] ?? 0) as int,
    );
  }
}
