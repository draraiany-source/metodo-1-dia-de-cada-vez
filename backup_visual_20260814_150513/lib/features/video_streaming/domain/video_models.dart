enum VideoLevel { iniciante, intermediario, avancado }

extension VideoLevelInfo on VideoLevel {
  String get label => switch (this) {
        VideoLevel.iniciante => 'Iniciante',
        VideoLevel.intermediario => 'Intermediário',
        VideoLevel.avancado => 'Avançado',
      };
}

/// Categorias de vídeo (Módulo 2 do prompt master original).
enum VideoCategory {
  academia,
  casa,
  hiit,
  funcional,
  alongamento,
  mobilidade,
  yoga,
  pilates,
  corrida,
  abdomen,
  gluteos,
  bracos,
  pernas,
  corpoInteiro,
}

extension VideoCategoryInfo on VideoCategory {
  String get label => switch (this) {
        VideoCategory.academia => 'Academia',
        VideoCategory.casa => 'Casa',
        VideoCategory.hiit => 'HIIT',
        VideoCategory.funcional => 'Funcional',
        VideoCategory.alongamento => 'Alongamento',
        VideoCategory.mobilidade => 'Mobilidade',
        VideoCategory.yoga => 'Yoga',
        VideoCategory.pilates => 'Pilates',
        VideoCategory.corrida => 'Corrida',
        VideoCategory.abdomen => 'Abdômen',
        VideoCategory.gluteos => 'Glúteos',
        VideoCategory.bracos => 'Braços',
        VideoCategory.pernas => 'Pernas',
        VideoCategory.corpoInteiro => 'Corpo inteiro',
      };
}

/// Metadados públicos de um vídeo — a URL de streaming em si NÃO fica aqui
/// (fica em `videos/{id}/private/stream`, só acessível via Cloud Function
/// `getVideoUrl`, que valida acesso Premium no servidor). Ver
/// `docs/ARQUITETURA_STREAMING.md` para o desenho completo.
class VideoContent {
  const VideoContent({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.name,
    required this.description,
    required this.teacher,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.level,
    required this.isPremium,
    required this.order,
    required this.active,
    this.publishedAt,
  });

  final String id;
  final VideoCategory category;
  final String subcategory;
  final String name;
  final String description;
  final String teacher;
  final String thumbnailUrl;
  final int durationSeconds;
  final VideoLevel level;
  final bool isPremium;
  final int order;
  final bool active;
  final DateTime? publishedAt;

  factory VideoContent.fromMap(String id, Map<String, dynamic> m) {
    return VideoContent(
      id: id,
      category: VideoCategory.values.firstWhere(
          (c) => c.name == m['category'],
          orElse: () => VideoCategory.corpoInteiro),
      subcategory: (m['subcategory'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      description: (m['description'] ?? '') as String,
      teacher: (m['teacher'] ?? '') as String,
      thumbnailUrl: (m['thumbnailUrl'] ?? '') as String,
      durationSeconds: (m['durationSeconds'] ?? 0) as int,
      level: VideoLevel.values.firstWhere((l) => l.name == m['level'],
          orElse: () => VideoLevel.iniciante),
      isPremium: (m['isPremium'] ?? false) as bool,
      order: (m['order'] ?? 0) as int,
      active: (m['active'] ?? true) as bool,
      publishedAt: m['publishedAt'] != null
          ? DateTime.tryParse(m['publishedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category.name,
        'subcategory': subcategory,
        'name': name,
        'description': description,
        'teacher': teacher,
        'thumbnailUrl': thumbnailUrl,
        'durationSeconds': durationSeconds,
        'level': level.name,
        'isPremium': isPremium,
        'order': order,
        'active': active,
        'publishedAt': (publishedAt ?? DateTime.now()).toIso8601String(),
      };
}
