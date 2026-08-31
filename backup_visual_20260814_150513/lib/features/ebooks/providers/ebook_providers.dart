import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/content_download_service.dart';
import '../data/ebooks_repository.dart';
import '../domain/ebook_models.dart';

final ebooksRepositoryProvider = Provider((ref) => EbooksRepository());
final ebookDownloadServiceProvider =
    Provider((ref) => ContentDownloadService('ebook'));

final ebooksProvider = FutureProvider<List<Ebook>>((ref) {
  return ref.read(ebooksRepositoryProvider).fetchAll();
});

class EbookFavoritesNotifier extends StateNotifier<Set<String>> {
  EbookFavoritesNotifier() : super({}) {
    _load();
  }
  static const _key = 'ebook_favorites';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> toggle(String id) async {
    final set = {...state};
    set.contains(id) ? set.remove(id) : set.add(id);
    state = set;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, set.toList());
  }
}

final ebookFavoritesProvider =
    StateNotifierProvider<EbookFavoritesNotifier, Set<String>>((ref) {
  return EbookFavoritesNotifier();
});

/// Progresso de leitura — última página vista por e-book (histórico +
/// "continuar de onde parou").
class EbookProgressNotifier extends StateNotifier<Map<String, int>> {
  EbookProgressNotifier() : super({}) {
    _load();
  }
  static const _key = 'ebook_progress';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {/* progresso corrompido descartado */}
  }

  Future<void> update(String ebookId, int page) async {
    state = {...state, ebookId: page};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }
}

final ebookProgressProvider =
    StateNotifierProvider<EbookProgressNotifier, Map<String, int>>((ref) {
  return EbookProgressNotifier();
});
