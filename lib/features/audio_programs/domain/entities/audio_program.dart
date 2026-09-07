/// Represents a multi-day audio program (e.g. "PROGRAMA 7 DIAS — UM DIA DE CADA VEZ").
/// Designed to be generic so future programs (14 days, 21 days, etc.) reuse the
/// exact same model, screens and Firestore shape.
class AudioProgram {
  final String id;
  final String title;
  final String description;
  final String category;
  final String author;
  final String coverUrl;
  final bool active;
  final bool premium;
  final int totalDays;
  final int orderIndex; // for future: order among multiple programs in a list screen
  final DateTime? createdAt;

  const AudioProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.author,
    required this.coverUrl,
    required this.active,
    required this.premium,
    required this.totalDays,
    this.orderIndex = 0,
    this.createdAt,
  });

  factory AudioProgram.fromMap(String id, Map<String, dynamic> map) {
    return AudioProgram(
      id: id,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      author: (map['author'] ?? '') as String,
      coverUrl: (map['coverUrl'] ?? '') as String,
      active: (map['active'] ?? true) as bool,
      premium: (map['premium'] ?? false) as bool,
      totalDays: (map['totalDays'] ?? 0) as int,
      orderIndex: (map['orderIndex'] ?? 0) as int,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : (map['createdAt'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'author': author,
      'coverUrl': coverUrl,
      'active': active,
      'premium': premium,
      'totalDays': totalDays,
      'orderIndex': orderIndex,
    };
  }
}

/// Represents a single day/audio inside a program.
/// NOTE on premium content: when [premium] is true, [audioUrl] should NOT be
/// trusted/read directly by the client for playback. Follow the same pattern
/// already used for premium videos/content in this app: store the raw path
/// (or omit audioUrl entirely from the public doc) and resolve the real,
/// short-lived playback URL through the existing getContentUrl-style Cloud
/// Function. This keeps this module consistent with the app's server-side
/// premium protection instead of introducing a second, weaker pattern.
class ProgramAudio {
  final String id;
  final int day;
  final int order;
  final String title;
  final String description;
  final String audioUrl; // public/free audios only; premium resolved via Cloud Function
  final String storagePath; // canonical path in Firebase Storage, used to request signed URL
  final String coverUrl;
  final int durationSeconds;
  final bool active;
  final bool premium;

  const ProgramAudio({
    required this.id,
    required this.day,
    required this.order,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.storagePath,
    required this.coverUrl,
    required this.durationSeconds,
    required this.active,
    required this.premium,
  });

  factory ProgramAudio.fromMap(String id, Map<String, dynamic> map) {
    return ProgramAudio(
      id: id,
      day: (map['day'] ?? 0) as int,
      order: (map['order'] ?? 0) as int,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      audioUrl: (map['audioUrl'] ?? '') as String,
      storagePath: (map['storagePath'] ?? '') as String,
      coverUrl: (map['coverUrl'] ?? '') as String,
      durationSeconds: (map['durationSeconds'] ?? 0) as int,
      active: (map['active'] ?? true) as bool,
      premium: (map['premium'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'order': order,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'storagePath': storagePath,
      'coverUrl': coverUrl,
      'durationSeconds': durationSeconds,
      'active': active,
      'premium': premium,
    };
  }
}
