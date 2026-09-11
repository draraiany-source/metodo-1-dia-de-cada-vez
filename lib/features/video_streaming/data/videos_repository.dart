import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

/// Busca metadados de vídeo (público) e resolve URL via Cloud Function.
class VideosRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<VideoContent>> fetchAll() async {
    if (!isAvailable) return [];

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
        debugPrint(
            'videos query composta falhou ($e); tentando fallback.');
        snap = await FirebaseFirestore.instance
            .collection('videos')
            .where('active', isEqualTo: true)
            .get();
      }

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
      return out;
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
        if (out.isNotEmpty) return out;
      } catch (_) {/* segue para throw amigável */}

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

  /// Lista completa (ativos + desativados) para o CMS / admin.
  Future<List<VideoContent>> fetchAllForAdmin() async {
    if (!isAvailable) return [];
    try {
      final snap =
          await FirebaseFirestore.instance.collection('videos').get();
      final out = <VideoContent>[];
      for (final d in snap.docs) {
        try {
          out.add(VideoContent.fromMap(d.id, d.data()));
        } catch (e) {
          debugPrint('Video parse falhou ${d.id}: $e');
        }
      }
      out.sort((a, b) => a.order.compareTo(b.order));
      return out;
    } catch (e) {
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
