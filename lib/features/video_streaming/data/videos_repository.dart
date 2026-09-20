import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../domain/video_models.dart';

class VideoUrlResult {
  const VideoUrlResult({this.url, this.error});
  final String? url;
  final String? error;
  bool get ok => url != null;
}

/// Erro tipado para a UI de vídeos (retry + mensagem amigável).
class VideosFetchException implements Exception {
  VideosFetchException(this.userMessage, {this.cause});
  final String userMessage;
  final Object? cause;
  @override
  String toString() => userMessage;
}

/// Busca metadados de vídeo (público) e resolve URL de streaming.
///
/// Fonte de verdade é a coleção `videos` do Firestore, gerenciada pela Amanda no
/// Painel da Personal. O seed em `assets/content/videos_biblioteca.json` entra
/// só para ids que ainda não existem no Firestore, para a área não ficar sem
/// os vídeos novos do catálogo. Documento existente (título, ordem, ativo)
/// sempre ganha do seed.
class VideosRepository {
  static const String seedAssetPath = 'assets/content/videos_biblioteca.json';

  bool get isAvailable => FirebaseService.isReady;

  List<VideoContent>? _seedCache;

  /// Conteúdo inicial embutido no app. Nunca lança: se o asset faltar ou estiver
  /// inválido, a biblioteca simplesmente fica vazia em vez de quebrar a tela.
  Future<List<VideoContent>> loadSeed() async {
    if (_seedCache != null) return _seedCache!;
    try {
      final raw = await rootBundle.loadString(seedAssetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = (decoded['videos'] as List?) ?? const [];
      final out = <VideoContent>[];
      for (final item in list) {
        final map = Map<String, dynamic>.from(item as Map);
        final id = '${map['id'] ?? ''}';
        if (id.isEmpty) continue;
        out.add(VideoContent.fromMap(id, map));
      }
      out.sort((a, b) => a.order.compareTo(b.order));
      return _seedCache = out;
    } catch (e) {
      debugPrint('Seed de vídeos indisponível ($e).');
      return _seedCache = const [];
    }
  }

  Future<List<VideoContent>> fetchAll() async {
    if (!isAvailable) return loadSeed();

    try {
      QuerySnapshot<Map<String, dynamic>> snap;
      try {
        snap = await FirebaseFirestore.instance
            .collection('videos')
            .where('active', isEqualTo: true)
            .orderBy('order')
            .get();
      } catch (e) {
        // Web: FirebaseException pode chegar como TypeError/JS interop —
        // nunca use só `on FirebaseException` sem fallback genérico.
        debugPrint('videos query composta falhou ($e); tentando fallback.');
        snap = await FirebaseFirestore.instance
            .collection('videos')
            .where('active', isEqualTo: true)
            .get();
      }

      // Coleção sem NENHUM doc ativo: pode ser instalação nova (seed) ou a
      // Amanda despublicou tudo. Distinguimos olhando a coleção inteira.
      if (snap.docs.isEmpty) return _seedSeColecaoVazia();

      final out = <VideoContent>[];
      for (final d in snap.docs) {
        try {
          final parsed = VideoContent.fromMap(d.id, d.data());
          if (parsed.active) out.add(parsed);
        } catch (e) {
          debugPrint('Video parse falhou ${d.id}: $e');
        }
      }
      out.sort((a, b) => a.order.compareTo(b.order));
      return _mesclarSeedAusente(out, soAtivos: true);
    } catch (e) {
      try {
        final all = await FirebaseFirestore.instance.collection('videos').get();
        final out = <VideoContent>[];
        for (final d in all.docs) {
          try {
            final v = VideoContent.fromMap(d.id, d.data());
            if (v.active) out.add(v);
          } catch (err) {
            debugPrint('Video parse falhou ${d.id}: $err');
          }
        }
        out.sort((a, b) => a.order.compareTo(b.order));
        if (out.isNotEmpty) {
          return _mesclarSeedAusente(out, soAtivos: true);
        }
      } catch (_) {/* segue para o seed / throw amigável */}

      // Offline numa instalação nova: melhor mostrar o conteúdo embutido do que
      // uma tela de erro.
      final seed = await loadSeed();
      if (seed.isNotEmpty) return seed;

      if (e is VideosFetchException) rethrow;
      throw VideosFetchException(
        FirebaseErrorMapper.toUserMessage(
          e,
          fallback:
              'Não foi possível carregar os vídeos. Verifique a conexão e tente novamente.',
        ),
        cause: e,
      );
    }
  }

  Future<List<VideoContent>> _seedSeColecaoVazia() async {
    try {
      final todos = await FirebaseFirestore.instance.collection('videos').get();
      if (todos.docs.isNotEmpty) {
        final atuais = <VideoContent>[];
        for (final d in todos.docs) {
          try {
            atuais.add(VideoContent.fromMap(d.id, d.data()));
          } catch (e) {
            debugPrint('Video parse falhou ${d.id}: $e');
          }
        }
        final mesclado = await _mesclarSeedAusente(atuais, soAtivos: true);
        return mesclado.where((v) => v.active).toList();
      }
    } catch (_) {/* na dúvida, mostra o seed */}
    return loadSeed();
  }

  /// Inclui no catálogo itens do seed cujo id ainda não existe no Firestore.
  ///
  /// Não sobrescreve documento existente (título, ordem, ativo/inativo e URL
  /// editados pela Personal/Admin continuam valendo). Se a Amanda excluir um
  /// item semeado, ele volta a aparecer até o id ser gravado de novo no CMS —
  /// por isso a exclusão definitiva de um vídeo do seed deve ser feita
  /// despublicando no painel (grava `active: false` no Firestore).
  Future<List<VideoContent>> _mesclarSeedAusente(
    List<VideoContent> atuais, {
    required bool soAtivos,
  }) async {
    final seed = await loadSeed();
    if (seed.isEmpty) return atuais;
    final ids = atuais.map((v) => v.id).toSet();
    final extra = seed.where((s) {
      if (ids.contains(s.id)) return false;
      if (soAtivos && !s.active) return false;
      return true;
    });
    if (extra.isEmpty) return atuais;
    final out = [...atuais, ...extra];
    out.sort((a, b) => a.order.compareTo(b.order));
    return out;
  }

  /// Lista completa (ativos + desativados) para o CMS / admin.
  Future<List<VideoContent>> fetchAllForAdmin() async {
    if (!isAvailable) return loadSeed();
    try {
      final snap =
          await FirebaseFirestore.instance.collection('videos').get();
      if (snap.docs.isEmpty) return loadSeed();

      final out = <VideoContent>[];
      for (final d in snap.docs) {
        try {
          out.add(VideoContent.fromMap(d.id, d.data()));
        } catch (e) {
          debugPrint('Video parse falhou ${d.id}: $e');
        }
      }
      out.sort((a, b) => a.order.compareTo(b.order));
      return _mesclarSeedAusente(out, soAtivos: false);
    } catch (e) {
      final seed = await loadSeed();
      if (seed.isNotEmpty) return seed;
      throw VideosFetchException(
        FirebaseErrorMapper.toUserMessage(
          e,
          fallback: 'Não foi possível carregar os vídeos. Tente novamente.',
        ),
        cause: e,
      );
    }
  }

  String get _functionUrl => AppConstants.getVideoUrlFunctionUrl;

  /// Só para vídeos legados auto-hospedados. Vídeos do YouTube não passam por
  /// aqui — abrem direto pelo player embutido.
  Future<VideoUrlResult> resolveStreamUrl(String videoId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const VideoUrlResult(error: 'Entre na sua conta pra assistir.');
    }
    if (_functionUrl.contains('SEU-PROJETO')) {
      return const VideoUrlResult(
          error: 'Streaming ainda não configurado neste app.');
    }
    try {
      final headers = await AuthHttpHeaders.forCloudFunction();
      final res = await http
          .post(
            Uri.parse(_functionUrl),
            headers: headers,
            body: jsonEncode({'videoId': videoId}),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['url'] != null) {
        return VideoUrlResult(url: data['url'] as String);
      }
      return VideoUrlResult(
          error: (data['error'] ?? 'Não foi possível carregar o vídeo.')
              as String);
    } catch (e) {
      return VideoUrlResult(
        error: FirebaseErrorMapper.toUserMessage(
          e,
          fallback: 'Não conseguimos carregar o vídeo agora.',
        ),
      );
    }
  }
}
