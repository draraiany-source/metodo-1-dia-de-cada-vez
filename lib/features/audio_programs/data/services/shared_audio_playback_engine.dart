import 'package:just_audio/just_audio.dart';

import 'audio_playback_engine.dart';

/// Adaptador fino sobre o [AudioPlayer] global de `audio_courses`
/// (`audioPlayerProvider`). Evita duas sessões de áudio concorrentes.
///
/// [dispose] NÃO destrói o player compartilhado — só limpa a fonte atual.
class SharedAudioPlaybackEngine implements AudioPlaybackEngine {
  SharedAudioPlaybackEngine(this._player);

  final AudioPlayer _player;

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
    await _player.stop();
    if (url.startsWith('asset:///')) {
      final assetPath = url.replaceFirst('asset:///', '');
      await _player.setAsset(assetPath);
    } else {
      await _player.setUrl(url);
    }
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
    if (total > Duration.zero && target > total) target = total;
    await _player.seek(target);
  }

  @override
  Future<void> dispose() async {
    // Player compartilhado — não dispose. Pausa para não vazar áudio.
    try {
      await _player.pause();
    } catch (_) {}
  }
}
