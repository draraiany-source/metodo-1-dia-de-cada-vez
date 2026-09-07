/// Abstraction over whatever plays audio in this app.
///
/// IMPORTANT INTEGRATION NOTE:
/// The project overview states the app already has "audio courses with
/// background playback". If that feature has its own player service
/// (e.g. wrapping just_audio + audio_service, or just_audio_background),
/// this new Program module should NOT bring in a second audio engine.
/// Instead, implement this interface as a thin adapter around that existing
/// service. That gives background playback and lock-screen controls "for
/// free" (requirements #12/#13) and avoids two competing audio sessions
/// fighting for the OS's now-playing slot.
///
/// Only if no such shared engine exists yet should [DefaultAudioPlaybackEngine]
/// (just_audio-based, in audio_playback_engine_default.dart) be wired in.
abstract class AudioPlaybackEngine {
  Stream<Duration> get position;
  Stream<Duration?> get duration;
  Stream<bool> get isPlaying;
  Stream<bool> get isCompleted;

  Future<void> load(String url, {required String title, String? artUrl});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> seekBy(Duration offset); // for +15s / -15s
  Future<void> dispose();
}
