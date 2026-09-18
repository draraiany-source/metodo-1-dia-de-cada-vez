import '../../../core/utils/youtube_url.dart';

enum VideoLevel { iniciante, intermediario, avancado }

extension VideoLevelInfo on VideoLevel {
  String get label => switch (this) {
        VideoLevel.iniciante => 'Iniciante',
        VideoLevel.intermediario => 'Intermediário',
        VideoLevel.avancado => 'Avançado',
      };
}

/// Categorias da **biblioteca de vídeos da Amanda** (conteúdo), não de treino.
///
/// Treino tem a área própria (catálogo de exercícios, séries, carga,
/// cronômetro). Aqui é conteúdo em vídeo: boas-vindas, método, motivação etc.
/// A ordem da enum é a ordem em que os filtros aparecem na tela.
enum VideoCategory {
  boasVindas,
  metodo1Dia,
  motivacao,
  dicasDaAmanda,
  orientacoes,
  habitosSaudaveis,
  desafios,
  treinamento,
  alongamentoMobilidade,
  especiais,
}

extension VideoCategoryInfo on VideoCategory {
  String get label => switch (this) {
        VideoCategory.boasVindas => 'Boas-vindas',
        VideoCategory.metodo1Dia => 'Método 1 Dia de Cada Vez',
        VideoCategory.motivacao => 'Motivação',
        VideoCategory.dicasDaAmanda => 'Dicas da Amanda',
        VideoCategory.orientacoes => 'Orientações',
        VideoCategory.habitosSaudaveis => 'Hábitos saudáveis',
        VideoCategory.desafios => 'Desafios',
        VideoCategory.treinamento => 'Treinamento',
        VideoCategory.alongamentoMobilidade => 'Alongamento e mobilidade',
        VideoCategory.especiais => 'Conteúdos especiais',
      };

  /// Rótulo curto para chips e badges, onde o nome completo estoura a linha.
  String get shortLabel => switch (this) {
        VideoCategory.metodo1Dia => 'Método 1 Dia',
        VideoCategory.alongamentoMobilidade => 'Along. e mobilidade',
        _ => label,
      };
}

/// Valores de `category` gravados antes da biblioteca virar conteúdo (quando as
/// categorias eram tipos de treino). Mantido para que documentos antigos do
/// Firestore continuem carregando em vez de cair todos em uma categoria só.
const Map<String, VideoCategory> kVideoCategoryLegacyAliases = {
  'academia': VideoCategory.treinamento,
  'casa': VideoCategory.treinamento,
  'hiit': VideoCategory.treinamento,
  'funcional': VideoCategory.treinamento,
  'corrida': VideoCategory.treinamento,
  'abdomen': VideoCategory.treinamento,
  'gluteos': VideoCategory.treinamento,
  'bracos': VideoCategory.treinamento,
  'pernas': VideoCategory.treinamento,
  'corpoInteiro': VideoCategory.treinamento,
  'alongamento': VideoCategory.alongamentoMobilidade,
  'mobilidade': VideoCategory.alongamentoMobilidade,
  'yoga': VideoCategory.alongamentoMobilidade,
  'pilates': VideoCategory.alongamentoMobilidade,
};

VideoCategory videoCategoryFromRaw(Object? raw) {
  final key = '${raw ?? ''}'.trim();
  if (key.isEmpty) return VideoCategory.especiais;
  for (final c in VideoCategory.values) {
    if (c.name == key) return c;
  }
  return kVideoCategoryLegacyAliases[key] ?? VideoCategory.especiais;
}

/// Metadados de um vídeo da biblioteca.
///
/// Duas formas de hospedagem convivem:
///
/// - **YouTube** (o caminho usado pela biblioteca da Amanda): a URL fica em
///   [youtubeUrl], no próprio documento público. Use vídeos "Não listados" —
///   "Privado" não reproduz fora da conta do canal.
/// - **Auto-hospedado** (legado): a URL de streaming NÃO fica aqui, e sim em
///   `videos/{id}/private/stream`, acessível só via Cloud Function
///   `getVideoUrl`, que valida Premium no servidor. Ver
///   `docs/ARQUITETURA_STREAMING.md`.
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
    this.youtubeUrl = '',
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

  /// URL do YouTube (vazia quando o vídeo é auto-hospedado/legado).
  final String youtubeUrl;
  final DateTime? publishedAt;

  /// True quando o vídeo toca via YouTube em vez da Cloud Function.
  bool get isYoutube => youtubeVideoId != null;

  String? get youtubeVideoId =>
      youtubeUrl.trim().isEmpty ? null : YoutubeUrl.extractVideoId(youtubeUrl);

  /// A Amanda cadastrou o vídeo mas ainda não colou a URL do YouTube.
  ///
  /// A biblioteca mostra esse card como "em breve" (sem botão de assistir) em
  /// vez de abrir um player que falharia. Vídeos legados auto-hospedados também
  /// caem aqui — e é o comportamento correto hoje, porque o streaming próprio
  /// nunca foi configurado (a URL da Cloud Function ainda é placeholder).
  bool get aguardandoUrl => youtubeVideoId == null;

  /// Capa a usar na UI: a enviada pela Amanda tem prioridade; se não houver,
  /// cai na capa automática do YouTube (funciona com vídeo não listado).
  String get displayThumbnailUrl {
    if (thumbnailUrl.trim().isNotEmpty) return thumbnailUrl.trim();
    return YoutubeUrl.thumbnailUrl(youtubeUrl) ?? '';
  }

  /// "8 min", "45 min", "1 h 05" — vazio quando a duração não foi informada.
  String get durationLabel {
    if (durationSeconds <= 0) return '';
    if (durationSeconds < 60) return '${durationSeconds}s';
    final totalMin = (durationSeconds / 60).round();
    if (totalMin < 60) return '$totalMin min';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')}';
  }

  VideoContent copyWith({
    String? id,
    VideoCategory? category,
    String? subcategory,
    String? name,
    String? description,
    String? teacher,
    String? thumbnailUrl,
    int? durationSeconds,
    VideoLevel? level,
    bool? isPremium,
    int? order,
    bool? active,
    String? youtubeUrl,
    DateTime? publishedAt,
  }) {
    return VideoContent(
      id: id ?? this.id,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      name: name ?? this.name,
      description: description ?? this.description,
      teacher: teacher ?? this.teacher,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      level: level ?? this.level,
      isPremium: isPremium ?? this.isPremium,
      order: order ?? this.order,
      active: active ?? this.active,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  factory VideoContent.fromMap(String id, Map<String, dynamic> m) {
    return VideoContent(
      id: id,
      category: videoCategoryFromRaw(m['category']),
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
      youtubeUrl: '${m['youtubeUrl'] ?? ''}'.trim(),
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
        'youtubeUrl': youtubeUrl,
        'publishedAt': (publishedAt ?? DateTime.now()).toIso8601String(),
      };
}
