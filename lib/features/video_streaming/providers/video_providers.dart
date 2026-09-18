import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/videos_repository.dart';
import '../domain/video_models.dart';
import '../domain/video_watch_state.dart';

final videosRepositoryProvider = Provider((ref) => VideosRepository());

final videosProvider = FutureProvider<List<VideoContent>>((ref) {
  return ref.read(videosRepositoryProvider).fetchAll();
});

/// Inclui desativados — só para telas de CMS / admin.
final videosAdminListProvider = FutureProvider<List<VideoContent>>((ref) {
  return ref.read(videosRepositoryProvider).fetchAllForAdmin();
});

/// Categorias que realmente têm vídeo publicado, na ordem da enum.
/// Evita mostrar 10 chips de filtro quando só 1 categoria tem conteúdo.
final videoCategoriasComConteudoProvider =
    Provider<List<VideoCategory>>((ref) {
  final videos = ref.watch(videosProvider).valueOrNull ?? const [];
  final presentes = videos.map((v) => v.category).toSet();
  return VideoCategory.values.where(presentes.contains).toList(growable: false);
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

/// Progresso do player legado auto-hospedado (chewie) — posição em segundos.
/// A biblioteca do YouTube usa [videoWatchStateProvider]; ver
/// `VideoWatchState` para o motivo.
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
      state = map.map((k, v) => MapEntry(k, (v as num).toInt()));
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

/// "Continuar assistindo" + "já assistido" da biblioteca de vídeos.
class VideoWatchStateNotifier
    extends StateNotifier<Map<String, VideoWatchState>> {
  VideoWatchStateNotifier() : super({}) {
    _load();
  }

  static const _key = 'video_watch_state_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = map.map(
        (k, v) => MapEntry(
          k,
          VideoWatchState.fromMap(Map<String, dynamic>.from(v as Map)),
        ),
      );
    } catch (e) {
      debugPrint('Estado de vídeos corrompido, descartado ($e).');
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((k, v) => MapEntry(k, v.toMap()))),
    );
  }

  VideoWatchState of(String videoId) =>
      state[videoId] ?? const VideoWatchState();

  /// Chamado ao ABRIR o player, para o vídeo já entrar em "continuar assistindo"
  /// mesmo que a aluna feche o app no meio.
  Future<void> marcarAbertura(String videoId) async {
    final atual = of(videoId);
    state = {
      ...state,
      videoId: atual.copyWith(
        lastOpenedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    };
    await _persist();
  }

  /// Chamado ao SAIR do player, com o tempo que a aluna ficou na tela.
  /// Marca como concluído quando o tempo de tela cobre
  /// [VideoWatchState.kCompletionRatio] da duração cadastrada.
  Future<void> registrarTempoAssistido(
    String videoId,
    Duration tempoNaTela, {
    required int durationSeconds,
  }) async {
    if (tempoNaTela.inSeconds <= 0) return;
    final atual = of(videoId);
    final acumulado = atual.secondsInPlayer + tempoNaTela.inSeconds;
    final concluiu = atual.completed ||
        (durationSeconds > 0 &&
            acumulado >= durationSeconds * VideoWatchState.kCompletionRatio);

    state = {
      ...state,
      videoId: atual.copyWith(
        secondsInPlayer: acumulado,
        completed: concluiu,
        lastOpenedAtMs: DateTime.now().millisecondsSinceEpoch,
      ),
    };
    await _persist();
  }

  Future<void> definirAssistido(String videoId, bool assistido) async {
    final atual = of(videoId);
    state = {
      ...state,
      videoId: atual.copyWith(
        completed: assistido,
        lastOpenedAtMs: atual.lastOpenedAtMs == 0
            ? DateTime.now().millisecondsSinceEpoch
            : atual.lastOpenedAtMs,
      ),
    };
    await _persist();
  }
}

final videoWatchStateProvider = StateNotifierProvider<VideoWatchStateNotifier,
    Map<String, VideoWatchState>>((ref) {
  return VideoWatchStateNotifier();
});

/// Vídeos começados e não concluídos, do mais recente para o mais antigo.
final continuarAssistindoProvider = Provider<List<VideoContent>>((ref) {
  final videos = ref.watch(videosProvider).valueOrNull ?? const [];
  final estados = ref.watch(videoWatchStateProvider);

  final pendentes = videos.where((v) {
    final e = estados[v.id];
    return e != null && e.iniciado && !e.completed;
  }).toList();

  pendentes.sort((a, b) {
    final ta = estados[a.id]?.lastOpenedAtMs ?? 0;
    final tb = estados[b.id]?.lastOpenedAtMs ?? 0;
    return tb.compareTo(ta);
  });
  return pendentes;
});
