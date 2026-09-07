/// Per-user, per-program progress.
/// Stored as ONE document per (user, program) pair — not one doc per audio —
/// to keep reads/writes cheap and to make "3 de 7 dias concluídos" a single
/// document read.
///
/// Firestore path (recommended):
///   users/{uid}/programProgress/{programId}
/// This mirrors the existing per-user data scoping pattern already used
/// elsewhere in the app (assessments/measurements/load history), so the
/// security rules are a straightforward copy of that pattern.
class ProgramProgress {
  final String programId;
  final Set<String> completedAudioIds;
  final Set<String> favoriteAudioIds;
  final Map<String, int> lastPositionSeconds; // audioId -> last playback position
  final String? currentAudioId; // last opened audio, to resume "where you left off"
  final DateTime? updatedAt;

  const ProgramProgress({
    required this.programId,
    this.completedAudioIds = const {},
    this.favoriteAudioIds = const {},
    this.lastPositionSeconds = const {},
    this.currentAudioId,
    this.updatedAt,
  });

  int completedCount(int totalDays) => completedAudioIds.length;

  bool isCompleted(String audioId) => completedAudioIds.contains(audioId);
  bool isFavorite(String audioId) => favoriteAudioIds.contains(audioId);
  int positionFor(String audioId) => lastPositionSeconds[audioId] ?? 0;

  factory ProgramProgress.empty(String programId) =>
      ProgramProgress(programId: programId);

  factory ProgramProgress.fromMap(String programId, Map<String, dynamic> map) {
    return ProgramProgress(
      programId: programId,
      completedAudioIds:
          ((map['completedAudioIds'] as List?) ?? []).map((e) => e as String).toSet(),
      favoriteAudioIds:
          ((map['favoriteAudioIds'] as List?) ?? []).map((e) => e as String).toSet(),
      lastPositionSeconds: Map<String, int>.from(
          (map['lastPositionSeconds'] as Map?) ?? {}),
      currentAudioId: map['currentAudioId'] as String?,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
              ? map['updatedAt'] as DateTime
              : (map['updatedAt'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAudioIds': completedAudioIds.toList(),
      'favoriteAudioIds': favoriteAudioIds.toList(),
      'lastPositionSeconds': lastPositionSeconds,
      'currentAudioId': currentAudioId,
    };
  }

  ProgramProgress copyWith({
    Set<String>? completedAudioIds,
    Set<String>? favoriteAudioIds,
    Map<String, int>? lastPositionSeconds,
    String? currentAudioId,
  }) {
    return ProgramProgress(
      programId: programId,
      completedAudioIds: completedAudioIds ?? this.completedAudioIds,
      favoriteAudioIds: favoriteAudioIds ?? this.favoriteAudioIds,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
      currentAudioId: currentAudioId ?? this.currentAudioId,
    );
  }
}
