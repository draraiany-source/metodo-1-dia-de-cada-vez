/// Modelos de domínio simples (treinos, hábitos, corridas, etc.).
library;

class Workout {
  final String id;
  final String title;
  final String emoji;
  final int durationMin;
  final String level; // Iniciante / Intermediário / Avançado
  final int exercises;
  final int? kcal;
  final bool isPremium;
  final List<String> tags;

  /// Foto real do treino (capa), quando cadastrada. `null`/vazio → o card usa
  /// o [emoji] como placeholder. Preparado pra receber conteúdo real sem
  /// precisar de outra migração de modelo depois.
  final String? photoUrl;

  const Workout({
    required this.id,
    required this.title,
    required this.emoji,
    required this.durationMin,
    required this.level,
    this.exercises = 0,
    this.kcal,
    this.isPremium = false,
    this.tags = const [],
    this.photoUrl,
  });

  factory Workout.fromMap(String id, Map<String, dynamic> m) => Workout(
        id: id,
        title: m['title'] ?? '',
        emoji: m['emoji'] ?? '💪',
        durationMin: (m['durationMin'] ?? 0) as int,
        level: m['level'] ?? 'Iniciante',
        exercises: (m['exercises'] ?? 0) as int,
        kcal: m['kcal'] as int?,
        isPremium: (m['isPremium'] ?? false) as bool,
        tags: List<String>.from(m['tags'] ?? const []),
        photoUrl: m['photoUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'emoji': emoji,
        'durationMin': durationMin,
        'level': level,
        'exercises': exercises,
        'kcal': kcal,
        'isPremium': isPremium,
        'tags': tags,
        'photoUrl': photoUrl,
      };
}

class Habit {
  final String id;
  final String title;
  final String emoji;
  bool done;

  Habit({
    required this.id,
    required this.title,
    required this.emoji,
    this.done = false,
  });
}

class RunSession {
  final String id;
  final DateTime date;
  final double distanceKm;
  final Duration duration;
  final double avgPaceMinPerKm;
  final int kcal;

  const RunSession({
    required this.id,
    required this.date,
    required this.distanceKm,
    required this.duration,
    required this.avgPaceMinPerKm,
    required this.kcal,
  });
}

class Achievement {
  final String id;
  final String title;
  final String emoji;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    this.unlocked = false,
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final int goal;
  final int progress;
  final int rewardXp;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    this.progress = 0,
    this.rewardXp = 100,
  });

  double get ratio =>
      goal == 0 ? 0.0 : (progress / goal).clamp(0.0, 1.0).toDouble();
}

class ChatMessage {
  final String text;
  final bool fromUser;
  final DateTime time;

  ChatMessage({required this.text, required this.fromUser, DateTime? time})
      : time = time ?? DateTime.now();
}
