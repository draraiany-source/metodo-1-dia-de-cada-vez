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
          (c) => c.name == (m['category'] ?? '').toString(),
          orElse: () => VideoCategory.corpoInteiro),
      subcategory: '${m['subcategory'] ?? ''}',
      name: '${m['name'] ?? ''}',
      description: '${m['description'] ?? ''}',
      teacher: '${m['teacher'] ?? ''}',
      thumbnailUrl: '${m['thumbnailUrl'] ?? ''}',
      durationSeconds: _asInt(m['durationSeconds']),
      level: VideoLevel.values.firstWhere(
          (l) => l.name == (m['level'] ?? '').toString(),
          orElse: () => VideoLevel.iniciante),
      isPremium: _asBool(m['isPremium']),
      order: _asInt(m['order']),
      active: m.containsKey('active') ? _asBool(m['active']) : true,
      publishedAt: _asDate(m['publishedAt']),
    );
  }

  static int _asInt(dynamic v, [int d = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? d;
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = '$v'.toLowerCase();
    return s == 'true' || s == '1';
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
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
