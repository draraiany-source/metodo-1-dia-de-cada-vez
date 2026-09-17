import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/lily/lily_assets.dart';

/// Categorias que a Personal pode escolher sem alterar código.
enum WeeklyChallengeCategory {
  treino,
  caminhada,
  corrida,
  passos,
  hidratacao,
  alimentacao,
  receitas,
  sono,
  meditacao,
  disciplina,
  constancia,
  reducaoAcucar,
  frutasVerduras,
  alongamento,
  autocuidado,
  combinado,
}

extension WeeklyChallengeCategoryX on WeeklyChallengeCategory {
  String get label => switch (this) {
        WeeklyChallengeCategory.treino => 'Treino',
        WeeklyChallengeCategory.caminhada => 'Caminhada',
        WeeklyChallengeCategory.corrida => 'Corrida',
        WeeklyChallengeCategory.passos => 'Passos',
        WeeklyChallengeCategory.hidratacao => 'Hidratação',
        WeeklyChallengeCategory.alimentacao => 'Alimentação saudável',
        WeeklyChallengeCategory.receitas => 'Receitas',
        WeeklyChallengeCategory.sono => 'Sono',
        WeeklyChallengeCategory.meditacao => 'Meditação',
        WeeklyChallengeCategory.disciplina => 'Disciplina',
        WeeklyChallengeCategory.constancia => 'Constância',
        WeeklyChallengeCategory.reducaoAcucar => 'Redução de açúcar',
        WeeklyChallengeCategory.frutasVerduras => 'Frutas e verduras',
        WeeklyChallengeCategory.alongamento => 'Alongamento',
        WeeklyChallengeCategory.autocuidado => 'Autocuidado',
        WeeklyChallengeCategory.combinado => 'Combinação de hábitos',
      };

  String get emoji => switch (this) {
        WeeklyChallengeCategory.treino => '💪',
        WeeklyChallengeCategory.caminhada => '🚶',
        WeeklyChallengeCategory.corrida => '🏃',
        WeeklyChallengeCategory.passos => '👟',
        WeeklyChallengeCategory.hidratacao => '💧',
        WeeklyChallengeCategory.alimentacao => '🥗',
        WeeklyChallengeCategory.receitas => '👩‍🍳',
        WeeklyChallengeCategory.sono => '😴',
        WeeklyChallengeCategory.meditacao => '🧘',
        WeeklyChallengeCategory.disciplina => '🎯',
        WeeklyChallengeCategory.constancia => '🔥',
        WeeklyChallengeCategory.reducaoAcucar => '🍓',
        WeeklyChallengeCategory.frutasVerduras => '🥦',
        WeeklyChallengeCategory.alongamento => '🤸',
        WeeklyChallengeCategory.autocuidado => '💜',
        WeeklyChallengeCategory.combinado => '✨',
      };

  String get lilyAsset => switch (this) {
        WeeklyChallengeCategory.treino => LilyAssets.treinoHalteres,
        WeeklyChallengeCategory.caminhada => LilyAssets.corrida,
        WeeklyChallengeCategory.corrida => LilyAssets.corrida,
        WeeklyChallengeCategory.passos => LilyAssets.corrida,
        WeeklyChallengeCategory.hidratacao => LilyAssets.tomandoAgua,
        WeeklyChallengeCategory.alimentacao => LilyAssets.pratoSaudavel,
        WeeklyChallengeCategory.receitas => LilyAssets.pratoSaudavel,
        WeeklyChallengeCategory.sono => LilyAssets.meditacao,
        WeeklyChallengeCategory.meditacao => LilyAssets.meditacao,
        WeeklyChallengeCategory.disciplina => LilyAssets.forca,
        WeeklyChallengeCategory.constancia => LilyAssets.calendarioCheck,
        WeeklyChallengeCategory.reducaoAcucar => LilyAssets.pratoSaudavel,
        WeeklyChallengeCategory.frutasVerduras => LilyAssets.pratoSaudavel,
        WeeklyChallengeCategory.alongamento => LilyAssets.alongamento,
        WeeklyChallengeCategory.autocuidado => LilyAssets.joinha,
        WeeklyChallengeCategory.combinado => LilyAssets.apresentandoAberta,
      };
}

enum WeeklyChallengeStatus { draft, published, archived }

extension WeeklyChallengeStatusX on WeeklyChallengeStatus {
  String get label => switch (this) {
        WeeklyChallengeStatus.draft => 'Rascunho',
        WeeklyChallengeStatus.published => 'Publicado',
        WeeklyChallengeStatus.archived => 'Arquivado',
      };
}

/// Como o progresso do dia é contabilizado.
enum ChallengeCompletionMode {
  /// A aluna marca o dia manualmente.
  manual,

  /// Conta treino registrado (qualquer duração).
  workout,

  /// Conta treino com duração mínima (minutos).
  workoutMinutes,

  /// Conta quantidade de treinos na semana.
  workoutCount,
}

extension ChallengeCompletionModeX on ChallengeCompletionMode {
  String get label => switch (this) {
        ChallengeCompletionMode.manual => 'Marcar o dia manualmente',
        ChallengeCompletionMode.workout => 'Treino concluído no dia',
        ChallengeCompletionMode.workoutMinutes =>
          'Treino com tempo mínimo',
        ChallengeCompletionMode.workoutCount => 'Quantidade de treinos',
      };
}

enum ChallengeAudience { all, specific }

extension ChallengeAudienceX on ChallengeAudience {
  String get label => switch (this) {
        ChallengeAudience.all => 'Todas as alunas',
        ChallengeAudience.specific => 'Alunas específicas (futuro)',
      };
}

enum ParticipationStatus { notStarted, inProgress, completed, failed }

extension ParticipationStatusX on ParticipationStatus {
  String get label => switch (this) {
        ParticipationStatus.notStarted => 'Não iniciado',
        ParticipationStatus.inProgress => 'Em andamento',
        ParticipationStatus.completed => 'Concluído',
        ParticipationStatus.failed => 'Não concluído',
      };
}

@immutable
class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.rules,
    required this.objective,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.requiredDays,
    required this.totalDays,
    required this.motivationalMessage,
    required this.rewardTitle,
    required this.rewardXp,
    required this.rewardCoins,
    required this.status,
    this.imageUrl = '',
    this.lilyAsset = '',
    this.audience = ChallengeAudience.all,
    this.targetUserIds = const [],
    this.completionMode = ChallengeCompletionMode.manual,
    this.minWorkoutMinutes = 30,
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
    this.participantCount = 0,
    this.completionPercent = 0,
  });

  final String id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final String rules;
  final String objective;
  final WeeklyChallengeCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final int requiredDays;
  final int totalDays;
  final String motivationalMessage;
  final String rewardTitle;
  final int rewardXp;
  final int rewardCoins;
  final WeeklyChallengeStatus status;
  final String imageUrl;
  final String lilyAsset;
  final ChallengeAudience audience;
  final List<String> targetUserIds;
  final ChallengeCompletionMode completionMode;
  final int minWorkoutMinutes;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int participantCount;
  final double completionPercent;

  String get resolvedLilyAsset =>
      lilyAsset.isNotEmpty ? lilyAsset : category.lilyAsset;

  bool get isDraft => status == WeeklyChallengeStatus.draft;
  bool get isPublished => status == WeeklyChallengeStatus.published;
  bool get isArchived => status == WeeklyChallengeStatus.archived;

  bool get isScheduled {
    final now = DateTime.now();
    return isPublished && now.isBefore(startDate);
  }

  bool get isActive {
    final now = DateTime.now();
    return isPublished &&
        !now.isBefore(startDate) &&
        !now.isAfter(endDate.add(const Duration(days: 1)));
  }

  bool get hasEnded {
    final now = DateTime.now();
    return now.isAfter(endDate.add(const Duration(hours: 23, minutes: 59)));
  }

  bool visibleTo(String userId) {
    if (!isPublished && !isArchived) return false;
    if (audience == ChallengeAudience.all) return true;
    return targetUserIds.contains(userId);
  }

  List<DateTime> get calendarDays {
    final days = <DateTime>[];
    var d = DateTime(startDate.year, startDate.month, startDate.day);
    final last = DateTime(endDate.year, endDate.month, endDate.day);
    for (var i = 0; i < totalDays && !d.isAfter(last); i++) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    if (days.isEmpty) {
      for (var i = 0; i < totalDays; i++) {
        days.add(startDate.add(Duration(days: i)));
      }
    }
    return days;
  }

  String get periodLabel {
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    return '${fmt(startDate)} — ${fmt(endDate)}';
  }

  WeeklyChallenge copyWith({
    String? title,
    String? shortDescription,
    String? fullDescription,
    String? rules,
    String? objective,
    WeeklyChallengeCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int? requiredDays,
    int? totalDays,
    String? motivationalMessage,
    String? rewardTitle,
    int? rewardXp,
    int? rewardCoins,
    WeeklyChallengeStatus? status,
    String? imageUrl,
    String? lilyAsset,
    ChallengeAudience? audience,
    List<String>? targetUserIds,
    ChallengeCompletionMode? completionMode,
    int? minWorkoutMinutes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? participantCount,
    double? completionPercent,
  }) =>
      WeeklyChallenge(
        id: id,
        title: title ?? this.title,
        shortDescription: shortDescription ?? this.shortDescription,
        fullDescription: fullDescription ?? this.fullDescription,
        rules: rules ?? this.rules,
        objective: objective ?? this.objective,
        category: category ?? this.category,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        requiredDays: requiredDays ?? this.requiredDays,
        totalDays: totalDays ?? this.totalDays,
        motivationalMessage: motivationalMessage ?? this.motivationalMessage,
        rewardTitle: rewardTitle ?? this.rewardTitle,
        rewardXp: rewardXp ?? this.rewardXp,
        rewardCoins: rewardCoins ?? this.rewardCoins,
        status: status ?? this.status,
        imageUrl: imageUrl ?? this.imageUrl,
        lilyAsset: lilyAsset ?? this.lilyAsset,
        audience: audience ?? this.audience,
        targetUserIds: targetUserIds ?? this.targetUserIds,
        completionMode: completionMode ?? this.completionMode,
        minWorkoutMinutes: minWorkoutMinutes ?? this.minWorkoutMinutes,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        participantCount: participantCount ?? this.participantCount,
        completionPercent: completionPercent ?? this.completionPercent,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'shortDescription': shortDescription,
        'fullDescription': fullDescription,
        'rules': rules,
        'objective': objective,
        'category': category.name,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'requiredDays': requiredDays,
        'totalDays': totalDays,
        'motivationalMessage': motivationalMessage,
        'rewardTitle': rewardTitle,
        'rewardXp': rewardXp,
        'rewardCoins': rewardCoins,
        'status': status.name,
        'imageUrl': imageUrl,
        'lilyAsset': lilyAsset,
        'audience': audience.name,
        'targetUserIds': targetUserIds,
        'completionMode': completionMode.name,
        'minWorkoutMinutes': minWorkoutMinutes,
        'createdBy': createdBy,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'participantCount': participantCount,
        'completionPercent': completionPercent,
      };

  factory WeeklyChallenge.fromMap(String id, Map<String, dynamic> m) =>
      WeeklyChallenge(
        id: id,
        title: (m['title'] ?? '') as String,
        shortDescription: (m['shortDescription'] ?? '') as String,
        fullDescription: (m['fullDescription'] ?? '') as String,
        rules: (m['rules'] ?? '') as String,
        objective: (m['objective'] ?? '') as String,
        category: WeeklyChallengeCategory.values.firstWhere(
          (c) => c.name == m['category'],
          orElse: () => WeeklyChallengeCategory.treino,
        ),
        startDate: _asDate(m['startDate']) ?? DateTime.now(),
        endDate: _asDate(m['endDate']) ??
            DateTime.now().add(const Duration(days: 6)),
        requiredDays: _asInt(m['requiredDays'], 5),
        totalDays: _asInt(m['totalDays'], 7),
        motivationalMessage: (m['motivationalMessage'] ?? '') as String,
        rewardTitle: (m['rewardTitle'] ?? 'Constância') as String,
        rewardXp: _asInt(m['rewardXp'], 120),
        rewardCoins: _asInt(m['rewardCoins'], 40),
        status: WeeklyChallengeStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => WeeklyChallengeStatus.draft,
        ),
        imageUrl: (m['imageUrl'] ?? '') as String,
        lilyAsset: (m['lilyAsset'] ?? '') as String,
        audience: ChallengeAudience.values.firstWhere(
          (a) => a.name == m['audience'],
          orElse: () => ChallengeAudience.all,
        ),
        targetUserIds: List<String>.from(m['targetUserIds'] ?? const []),
        completionMode: ChallengeCompletionMode.values.firstWhere(
          (c) => c.name == m['completionMode'],
          orElse: () => ChallengeCompletionMode.manual,
        ),
        minWorkoutMinutes: _asInt(m['minWorkoutMinutes'], 30),
        createdBy: (m['createdBy'] ?? '') as String,
        createdAt: _asDate(m['createdAt']),
        updatedAt: _asDate(m['updatedAt']),
        participantCount: _asInt(m['participantCount']),
        completionPercent: (m['completionPercent'] is num)
            ? (m['completionPercent'] as num).toDouble()
            : 0,
      );

  /// Desafio padrão exibido quando ainda não há um publicado no Firestore.
  static WeeklyChallenge seedCurrent() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final begin = DateTime(start.year, start.month, start.day);
    final end = begin.add(const Duration(days: 6));
    return WeeklyChallenge(
      id: 'seed_movimento_${begin.year}${begin.month}${begin.day}',
      title: 'Desafio 7 Dias em Movimento',
      shortDescription:
          'Complete pelo menos 30 minutos de atividade física em 5 dos próximos 7 dias.',
      fullDescription:
          'Uma semana para escolher se movimentar, no seu ritmo. '
          'Não precisa ser perfeita — só constante. Um dia de cada vez.',
      rules:
          '• Faça ao menos 30 minutos de atividade em 5 dos 7 dias.\n'
          '• Vale treino, caminhada, corrida, dança ou alongamento.\n'
          '• Marque o dia assim que concluir.\n'
          '• O tempo real do cronômetro de treino também conta.',
      objective: '5 dias ativos nesta semana',
      category: WeeklyChallengeCategory.treino,
      startDate: begin,
      endDate: end,
      requiredDays: 5,
      totalDays: 7,
      motivationalMessage:
          'Você não precisa ser perfeita. Só precisa começar — e continuar.',
      rewardTitle: 'Constância',
      rewardXp: 120,
      rewardCoins: 40,
      status: WeeklyChallengeStatus.published,
      lilyAsset: LilyAssets.treinoHalteres,
      completionMode: ChallengeCompletionMode.workoutMinutes,
      minWorkoutMinutes: 30,
    );
  }
}

@immutable
class ChallengeDayEntry {
  const ChallengeDayEntry({
    required this.dateKey,
    required this.completed,
    this.note = '',
    this.source = 'manual',
  });

  final String dateKey;
  final bool completed;
  final String note;
  final String source;

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'completed': completed,
        'note': note,
        'source': source,
      };

  factory ChallengeDayEntry.fromMap(Map<String, dynamic> m) =>
      ChallengeDayEntry(
        dateKey: (m['dateKey'] ?? '') as String,
        completed: (m['completed'] ?? false) as bool,
        note: (m['note'] ?? '') as String,
        source: (m['source'] ?? 'manual') as String,
      );
}

@immutable
class WeeklyChallengeProgress {
  const WeeklyChallengeProgress({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.status,
    required this.days,
    this.startedAt,
    this.completedAt,
    this.achievementId = '',
    this.achievementTitle = '',
    this.lastActivityAt,
    this.displayName = '',
  });

  final String id;
  final String userId;
  final String challengeId;
  final ParticipationStatus status;
  final List<ChallengeDayEntry> days;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String achievementId;
  final String achievementTitle;
  final DateTime? lastActivityAt;
  final String displayName;

  int get completedCount => days.where((d) => d.completed).length;

  Set<String> get completedKeys =>
      {for (final d in days.where((e) => e.completed)) e.dateKey};

  bool isDayDone(DateTime date) => completedKeys.contains(dateKeyOf(date));

  double ratio(int goal) =>
      goal == 0 ? 0 : (completedCount / goal).clamp(0.0, 1.0);

  WeeklyChallengeProgress copyWith({
    ParticipationStatus? status,
    List<ChallengeDayEntry>? days,
    DateTime? startedAt,
    DateTime? completedAt,
    String? achievementId,
    String? achievementTitle,
    DateTime? lastActivityAt,
    String? displayName,
  }) =>
      WeeklyChallengeProgress(
        id: id,
        userId: userId,
        challengeId: challengeId,
        status: status ?? this.status,
        days: days ?? this.days,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        achievementId: achievementId ?? this.achievementId,
        achievementTitle: achievementTitle ?? this.achievementTitle,
        lastActivityAt: lastActivityAt ?? this.lastActivityAt,
        displayName: displayName ?? this.displayName,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'challengeId': challengeId,
        'status': status.name,
        'days': days.map((d) => d.toMap()).toList(),
        'startedAt':
            startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'achievementId': achievementId,
        'achievementTitle': achievementTitle,
        'lastActivityAt': FieldValue.serverTimestamp(),
        'displayName': displayName,
        'completedCount': completedCount,
      };

  factory WeeklyChallengeProgress.fromMap(String id, Map<String, dynamic> m) =>
      WeeklyChallengeProgress(
        id: id,
        userId: (m['userId'] ?? '') as String,
        challengeId: (m['challengeId'] ?? '') as String,
        status: ParticipationStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => ParticipationStatus.notStarted,
        ),
        days: ((m['days'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) =>
                ChallengeDayEntry.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        startedAt: _asDate(m['startedAt']),
        completedAt: _asDate(m['completedAt']),
        achievementId: (m['achievementId'] ?? '') as String,
        achievementTitle: (m['achievementTitle'] ?? '') as String,
        lastActivityAt: _asDate(m['lastActivityAt']),
        displayName: (m['displayName'] ?? '') as String,
      );

  static String dateKeyOf(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String docId(String userId, String challengeId) =>
      '${userId}_$challengeId';
}

@immutable
class ChallengeAchievementDef {
  const ChallengeAchievementDef({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;

  static const primeiro = ChallengeAchievementDef(
    id: 'primeiro_desafio',
    title: 'Primeiro Desafio',
    emoji: '🏆',
    description: 'Concluiu o primeiro Desafio da Semana.',
  );
  static const tresSemanas = ChallengeAchievementDef(
    id: '3_semanas_seguidas',
    title: '3 Semanas Seguidas',
    emoji: '🔥',
    description: 'Três desafios concluídos em sequência.',
  );
  static const constancia = ChallengeAchievementDef(
    id: 'constancia',
    title: 'Constância',
    emoji: '💜',
    description: 'Completou todos os dias necessários de um desafio.',
  );
  static const cinco = ChallengeAchievementDef(
    id: '5_desafios',
    title: '5 Desafios Concluídos',
    emoji: '⭐',
    description: 'Cinco Desafios da Semana finalizados.',
  );
  static const dez = ChallengeAchievementDef(
    id: '10_desafios',
    title: '10 Desafios Concluídos',
    emoji: '👑',
    description: 'Dez Desafios da Semana finalizados.',
  );

  static const all = [primeiro, tresSemanas, constancia, cinco, dez];
}

int _asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.round();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
