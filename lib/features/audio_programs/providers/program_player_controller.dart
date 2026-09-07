import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../audio_courses/providers/audio_course_providers.dart';
import '../data/services/audio_playback_engine.dart';
import '../data/services/shared_audio_playback_engine.dart';
import '../domain/entities/audio_program.dart';
import 'audio_program_providers.dart';

class ProgramPlayerState {
  final ProgramAudio? audio;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final bool isFavorite;
  final String? error;

  const ProgramPlayerState({
    this.audio,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
    this.isFavorite = false,
    this.error,
  });

  double get progressFraction {
    if (duration.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  ProgramPlayerState copyWith({
    ProgramAudio? audio,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
    bool? isFavorite,
    String? error,
    bool clearError = false,
  }) {
    return ProgramPlayerState(
      audio: audio ?? this.audio,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isFavorite: isFavorite ?? this.isFavorite,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

const double kAutoCompleteThreshold = 0.97;
const Duration kPositionSaveInterval = Duration(seconds: 5);

class ProgramPlayerController extends StateNotifier<ProgramPlayerState> {
  final String programId;
  final Ref ref;
  final AudioPlaybackEngine _engine;

  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _completedSub;
  DateTime _lastPositionSave = DateTime.fromMillisecondsSinceEpoch(0);
  bool _completedFiredForCurrent = false;

  ProgramPlayerController(this.programId, this.ref, {AudioPlaybackEngine? engine})
      : _engine = engine ??
            SharedAudioPlaybackEngine(ref.read(audioPlayerProvider)),
        super(const ProgramPlayerState()) {
    _posSub = _engine.position.listen(_onPosition);
    _durSub = _engine.duration.listen((d) {
      state = state.copyWith(duration: d ?? Duration.zero);
    });
    _playingSub = _engine.isPlaying.listen((p) {
      state = state.copyWith(isPlaying: p);
    });
    _completedSub = _engine.isCompleted.listen((completed) {
      if (completed) _onCompleted();
    });
  }

  Future<void> open(ProgramAudio audio, {required bool isFavorite}) async {
    _completedFiredForCurrent = false;
    state = state.copyWith(
      audio: audio,
      isLoading: true,
      isFavorite: isFavorite,
      position: Duration.zero,
      clearError: true,
    );
    try {
      final repo = ref.read(audioProgramRepositoryProvider);
      final url = await repo.resolvePlaybackUrl(programId, audio);
      await _engine.load(url, title: audio.title, artUrl: audio.coverUrl);

      final progress = await ref.read(programProgressProvider(programId).future);
      final resumeSeconds = progress.positionFor(audio.id);
      if (resumeSeconds > 0) {
        await _engine.seek(Duration(seconds: resumeSeconds));
      }
      await repo.setCurrentAudio(programId, audio.id);
      await _engine.play();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is StateError ? e.message : e.toString(),
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _engine.pause();
    } else {
      await _engine.play();
    }
  }

  Future<void> seek(Duration position) => _engine.seek(position);
  Future<void> forward15() => _engine.seekBy(const Duration(seconds: 15));
  Future<void> back15() => _engine.seekBy(const Duration(seconds: -15));

  Future<void> toggleFavorite() async {
    final audio = state.audio;
    if (audio == null) return;
    final newValue = !state.isFavorite;
    state = state.copyWith(isFavorite: newValue);
    await ref
        .read(audioProgramRepositoryProvider)
        .toggleFavorite(programId, audio.id, newValue);
  }

  void _onPosition(Duration pos) {
    state = state.copyWith(position: pos);
    final audio = state.audio;
    if (audio == null) return;

    if (!_completedFiredForCurrent &&
        state.duration.inMilliseconds > 0 &&
        state.progressFraction >= kAutoCompleteThreshold) {
      _onCompleted();
    }

    final now = DateTime.now();
    if (now.difference(_lastPositionSave) >= kPositionSaveInterval) {
      _lastPositionSave = now;
      ref
          .read(audioProgramRepositoryProvider)
          .savePlaybackPosition(programId, audio.id, pos.inSeconds);
    }
  }

  void _onCompleted() {
    final audio = state.audio;
    if (audio == null || _completedFiredForCurrent) return;
    _completedFiredForCurrent = true;
    ref.read(audioProgramRepositoryProvider).markCompleted(programId, audio.id);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playingSub?.cancel();
    _completedSub?.cancel();
    _engine.dispose();
    super.dispose();
  }
}

final programPlayerControllerProvider = StateNotifierProvider.family<
    ProgramPlayerController, ProgramPlayerState, String>((ref, programId) {
  return ProgramPlayerController(programId, ref);
});
