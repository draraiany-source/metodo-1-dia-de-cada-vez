import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedVideo {
  const DownloadedVideo(
      {required this.videoId, required this.path, required this.sizeBytes});
  final String videoId;
  final String path;
  final int sizeBytes;

  Map<String, dynamic> toMap() =>
      {'videoId': videoId, 'path': path, 'sizeBytes': sizeBytes};
  factory DownloadedVideo.fromMap(Map<String, dynamic> m) => DownloadedVideo(
        videoId: m['videoId'] as String,
        path: m['path'] as String,
        sizeBytes: (m['sizeBytes'] as num).toInt(),
      );
}

/// Download offline pra assistir sem internet — Módulo "Download Offline"
/// do complemento de streaming.
///
/// **Limitação honesta**: isto é um MVP — salva o arquivo de vídeo no
/// armazenamento privado do app (não acessível por outros apps, mas sem
/// criptografia real de conteúdo/DRM). Pra proteção de nível profissional
/// (impedir extração do arquivo mesmo em device rooteado/jailbroken),
/// seria necessário um SDK de DRM do próprio provedor de streaming
/// (Bunny.net e afins oferecem isso) — fora do escopo do que dá pra
/// implementar de forma genérica em Dart puro.
class VideoDownloadService {
  static const _key = 'downloaded_videos';

  static Future<List<DownloadedVideo>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) =>
            DownloadedVideo.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<bool> isDownloaded(String videoId) async {
    final all = await list();
    return all.any((d) => d.videoId == videoId);
  }

  static Future<int> totalBytesUsed() async {
    final all = await list();
    return all.fold<int>(0, (s, d) => s + d.sizeBytes);
  }

  /// Baixa o vídeo, reportando progresso 0..1 via [onProgress].
  static Future<DownloadedVideo?> download(
    String videoId,
    String url, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/video_$videoId.mp4');

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      final total = response.contentLength ?? 0;
      var received = 0;

      final sink = file.openWrite();
      await response.stream.map((chunk) {
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
        return chunk;
      }).pipe(sink);
      await sink.close();

      final downloaded = DownloadedVideo(
          videoId: videoId, path: file.path, sizeBytes: await file.length());

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      raw.add(jsonEncode(downloaded.toMap()));
      await prefs.setStringList(_key, raw);

      return downloaded;
    } catch (_) {
      return null;
    }
  }

  static Future<void> remove(String videoId) async {
    final all = await list();
    final match = all.where((d) => d.videoId == videoId).toList();
    for (final d in match) {
      try {
        await File(d.path).delete();
      } catch (_) {/* já não existe */}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      all
          .where((d) => d.videoId != videoId)
          .map((d) => jsonEncode(d.toMap()))
          .toList(),
    );
  }
}
