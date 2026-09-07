import 'package:just_audio/just_audio.dart';

import 'audio_playback_engine.dart';

/// Fallback implementation. Requires adding `just_audio` (and, for real
/// lock-screen/notification controls, `audio_service` or
/// `just_audio_background`) to pubspec.yaml if the app does not already
/// depend on an equivalent package for the existing audio courses feature.
///
/// Prefer adapting this module to the EXISTING player service instead of
/// using this class, per the note in audio_playback_engine.dart.
class DefaultAudioPlaybackEngine implements AudioPlaybackEngine {
  final AudioPlayer _player = AudioPlayer();

  @override
  Stream<Duration> get position => _player.positionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  Stream<bool> get isPlaying => _player.playingStream;

  @override
  Stream<bool> get isCompleted =>
      _player.processingStateStream.map((s) => s == ProcessingState.completed);

  @override
  Future<void> load(String url, {required String title, String? artUrl}) async {
    await _player.setUrl(url);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> seekBy(Duration offset) async {
    final current = _player.position;
    final total = _player.duration ?? Duration.zero;
    var target = current + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (target > total) target = total;
    await _player.seek(target);
  }

  @override
  Future<void> dispose() => _player.dispose();
}
