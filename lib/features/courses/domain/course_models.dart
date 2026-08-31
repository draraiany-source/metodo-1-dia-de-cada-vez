enum CourseCategory {
  treino,
  nutricao,
  mentalidade,
  corrida,
  yoga,
  pilates,
  geral,
}

extension CourseCategoryInfo on CourseCategory {
  String get label => switch (this) {
        CourseCategory.treino => 'Treino',
        CourseCategory.nutricao => 'Nutrição',
        CourseCategory.mentalidade => 'Mentalidade',
        CourseCategory.corrida => 'Corrida',
        CourseCategory.yoga => 'Yoga',
        CourseCategory.pilates => 'Pilates',
        CourseCategory.geral => 'Geral',
      };
}

enum LessonType { video, audio, pdf, texto }

/// Uma aula dentro de um módulo — só metadados aqui; a URL do conteúdo
/// (quando video/audio/pdf) mora em `courses/{id}/private/lessons`,
/// resolvida pela Cloud Function `getContentUrl`.
class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.title,
    required this.type,
    this.durationSeconds = 0,
    this.order = 0,
  });

  final String id;
  final String title;
  final LessonType type;
  final int durationSeconds;
  final int order;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'durationSeconds': durationSeconds,
        'order': order,
      };

  factory CourseLesson.fromMap(Map<String, dynamic> m) => CourseLesson(
        id: (m['id'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        type: LessonType.values.firstWhere((t) => t.name == m['type'],
            orElse: () => LessonType.video),
        durationSeconds: (m['durationSeconds'] ?? 0) as int,
        order: (m['order'] ?? 0) as int,
      );
}

class CourseModule {
  const CourseModule(
      {required this.title, required this.lessons, this.order = 0});
  final String title;
  final List<CourseLesson> lessons;
  final int order;

  Map<String, dynamic> toMap() => {
        'title': title,
        'lessons': lessons.map((l) => l.toMap()).toList(),
        'order': order,
      };

  factory CourseModule.fromMap(Map<String, dynamic> m) => CourseModule(
        title: (m['title'] ?? '') as String,
        lessons: (m['lessons'] as List? ?? [])
            .map((l) => CourseLesson.fromMap(l as Map<String, dynamic>))
            .toList(),
        order: (m['order'] ?? 0) as int,
      );
}

/// Curso completo — metadados + estrutura de módulos/aulas, tudo público
/// (só metadados leves; nenhuma URL de arquivo grande aqui).
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.instructor,
    required this.coverUrl,
    required this.description,
    required this.modules,
    required this.isPremium,
    required this.order,
    required this.active,
  });

  final String id;
  final String title;
  final CourseCategory category;
  final String instructor;
  final String coverUrl;
  final String description;
  final List<CourseModule> modules;
  final bool isPremium;
  final int order;
  final bool active;

  int get totalLessons =>
      modules.fold(0, (sum, m) => sum + m.lessons.length);

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category.name,
        'instructor': instructor,
        'coverUrl': coverUrl,
        'description': description,
        'modules': modules.map((m) => m.toMap()).toList(),
        'isPremium': isPremium,
        'order': order,
        'active': active,
      };

  factory Course.fromMap(String id, Map<String, dynamic> m) => Course(
        id: id,
        title: (m['title'] ?? '') as String,
        category: CourseCategory.values.firstWhere(
            (c) => c.name == m['category'],
            orElse: () => CourseCategory.geral),
        instructor: (m['instructor'] ?? '') as String,
        coverUrl: (m['coverUrl'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        modules: (m['modules'] as List? ?? [])
            .map((mo) => CourseModule.fromMap(mo as Map<String, dynamic>))
            .toList(),
        isPremium: (m['isPremium'] ?? false) as bool,
        order: (m['order'] ?? 0) as int,
        active: (m['active'] ?? true) as bool,
      );
}
