import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/video_models.dart';

class VideoUrlResult {
  const VideoUrlResult({this.url, this.error});
  final String? url;
  final String? error;
  bool get ok => url != null;
}

/// Busca metadados de vídeo (público, leve) e resolve a URL de streaming
/// sob demanda (protegida — ver Cloud Function `getVideoUrl`).
///
/// Por quê separado: se a URL do vídeo Premium ficasse no mesmo documento
/// público, qualquer usuária logada conseguiria ler o link direto do
/// Firestore e assistir sem pagar, mesmo com o botão escondido na UI. A
/// URL real mora em `videos/{id}/private/stream`, com `allow read: if
/// false` nas regras — só a Cloud Function (Admin SDK) enxerga.
class VideosRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<VideoContent>> fetchAll() async {
    if (!isAvailable) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('videos')
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get();
      return snap.docs
          .map((d) => VideoContent.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
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
      final token = await user.getIdToken();
      final res = await http
          .post(
            Uri.parse(_functionUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
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
    } catch (_) {
      return const VideoUrlResult(
          error: 'Não consegui carregar o vídeo agora.');
    }
  }
}
