import '../entities/audio_program.dart';
import '../entities/program_progress.dart';

/// Abstract boundary — keeps presentation/providers independent from
/// Firestore, following this project's existing Clean Architecture split
/// (domain/data/providers/presentation) and its "falls back to local/demo
/// mode when Firebase is not configured" convention.
abstract class AudioProgramRepository {
  /// Active programs, ordered by [AudioProgram.orderIndex].
  Stream<List<AudioProgram>> watchPrograms();

  Future<AudioProgram?> getProgram(String programId);

  /// The 7 (or N) audios of a program, ordered by [ProgramAudio.order].
  Stream<List<ProgramAudio>> watchProgramAudios(String programId);

  /// Resolves the real playback URL for an audio. For free audios this may
  /// just return [ProgramAudio.audioUrl] directly; for premium audios this
  /// MUST go through the app's existing Cloud Function used for premium
  /// content (e.g. getContentUrl) instead of trusting a client-readable URL.
  Future<String> resolvePlaybackUrl(String programId, ProgramAudio audio);

  Stream<ProgramProgress> watchProgress(String programId);

  Future<void> markCompleted(String programId, String audioId);

  Future<void> savePlaybackPosition(
      String programId, String audioId, int positionSeconds);

  Future<void> setCurrentAudio(String programId, String audioId);

  Future<void> toggleFavorite(String programId, String audioId, bool isFavorite);
}
