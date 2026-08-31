import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/audio_courses_repository.dart';
import '../domain/audio_course_models.dart';

final audioCoursesRepositoryProvider =
    Provider((ref) => AudioCoursesRepository());

/// Lista de cursos — vazia (não erro) enquanto o Firebase não tiver conteúdo
/// cadastrado ou não estiver configurado.
final audioCoursesProvider = FutureProvider<List<AudioCourse>>((ref) {
  return ref.read(audioCoursesRepositoryProvider).fetchAll();
});

/// Favoritos — persistidos localmente (mesmo padrão do resto do app).
class AudioFavoritesNotifier extends StateNotifier<Set<String>> {
  AudioFavoritesNotifier() : super({}) {
    _load();
  }

  static const _key = 'audio_favorites';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> toggle(String courseId) async {
    final set = {...state};
    set.contains(courseId) ? set.remove(courseId) : set.add(courseId);
    state = set;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, set.toList());
  }
}

final audioFavoritesProvider =
    StateNotifierProvider<AudioFavoritesNotifier, Set<String>>((ref) {
  return AudioFavoritesNotifier();
});

/// Histórico: último capítulo ouvido + posição, por curso — permite
/// "continuar de onde parou".
class AudioHistoryNotifier extends StateNotifier<Map<String, AudioProgress>> {
  AudioHistoryNotifier() : super({}) {
    _load();
  }

  static const _key = 'audio_history';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = map.map((k, v) => MapEntry(k, AudioProgress.fromMap(v)));
    } catch (_) {/* histórico corrompido descartado */}
  }

  Future<void> update(
      String courseId, String chapterId, Duration position) async {
    state = {
      ...state,
      courseId: AudioProgress(chapterId: chapterId, seconds: position.inSeconds),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((k, v) => MapEntry(k, v.toMap()))));
  }
}

class AudioProgress {
  const AudioProgress({required this.chapterId, required this.seconds});
  final String chapterId;
  final int seconds;

  Map<String, dynamic> toMap() => {'chapterId': chapterId, 'seconds': seconds};
  factory AudioProgress.fromMap(Map<String, dynamic> m) => AudioProgress(
      chapterId: m['chapterId'] as String, seconds: m['seconds'] as int);
}

final audioHistoryProvider =
    StateNotifierProvider<AudioHistoryNotifier, Map<String, AudioProgress>>(
        (ref) {
  return AudioHistoryNotifier();
});

/// Player global — um único `AudioPlayer` compartilhado, pra tocar em segundo
/// plano enquanto a usuária navega por outras telas do app.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Curso/capítulo atualmente carregado no player (null = nada tocando).
final nowPlayingProvider =
    StateProvider<(AudioCourse, AudioChapter)?>((ref) => null);
