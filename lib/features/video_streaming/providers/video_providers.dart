import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/videos_repository.dart';
import '../domain/video_models.dart';

final videosRepositoryProvider = Provider((ref) => VideosRepository());

final videosProvider = FutureProvider<List<VideoContent>>((ref) {
  return ref.read(videosRepositoryProvider).fetchAll();
});

/// Inclui desativados — só para telas de CMS / admin.
final videosAdminListProvider = FutureProvider<List<VideoContent>>((ref) {
  return ref.read(videosRepositoryProvider).fetchAllForAdmin();
});

class VideoFavoritesNotifier extends StateNotifier<Set<String>> {
  VideoFavoritesNotifier() : super({}) {
    _load();
  }
  static const _key = 'video_favorites';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> toggle(String videoId) async {
    final set = {...state};
    set.contains(videoId) ? set.remove(videoId) : set.add(videoId);
    state = set;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, set.toList());
  }
}

final videoFavoritesProvider =
    StateNotifierProvider<VideoFavoritesNotifier, Set<String>>((ref) {
  return VideoFavoritesNotifier();
});

/// Progresso "continuar assistindo" — posição em segundos por vídeo.
class VideoHistoryNotifier extends StateNotifier<Map<String, int>> {
  VideoHistoryNotifier() : super({}) {
    _load();
  }
  static const _key = 'video_history';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {/* histórico corrompido descartado */}
  }

  Future<void> update(String videoId, int seconds) async {
    state = {...state, videoId: seconds};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }
}

final videoHistoryProvider =
    StateNotifierProvider<VideoHistoryNotifier, Map<String, int>>((ref) {
  return VideoHistoryNotifier();
});
