import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedFile {
  const DownloadedFile(
      {required this.contentId, required this.path, required this.sizeBytes});
  final String contentId;
  final String path;
  final int sizeBytes;

  Map<String, dynamic> toMap() =>
      {'contentId': contentId, 'path': path, 'sizeBytes': sizeBytes};
  factory DownloadedFile.fromMap(Map<String, dynamic> m) => DownloadedFile(
        contentId: m['contentId'] as String,
        path: m['path'] as String,
        sizeBytes: (m['sizeBytes'] as num).toInt(),
      );
}

/// Download offline genérico — usado por áudios e e-books (o vídeo tem seu
/// próprio `VideoDownloadService`, já em produção, não mexido aqui pra não
/// arriscar quebrar o que já funciona).
///
/// Mesma limitação honesta do download de vídeo: sem DRM/criptografia real.
class ContentDownloadService {
  ContentDownloadService(this.kind); // 'audio' | 'ebook'
  final String kind;

  String get _key => 'downloaded_${kind}_files';

  Future<List<DownloadedFile>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) =>
            DownloadedFile.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isDownloaded(String contentId) async {
    final all = await list();
    return all.any((d) => d.contentId == contentId);
  }

  Future<DownloadedFile?> download(
    String contentId,
    String url, {
    required String extension,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${kind}_$contentId.$extension');

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

      final downloaded = DownloadedFile(
          contentId: contentId,
          path: file.path,
          sizeBytes: await file.length());

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_key) ?? [];
      raw.add(jsonEncode(downloaded.toMap()));
      await prefs.setStringList(_key, raw);

      return downloaded;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String contentId) async {
    final all = await list();
    for (final d in all.where((d) => d.contentId == contentId)) {
      try {
        await File(d.path).delete();
      } catch (_) {/* já não existe */}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      all
          .where((d) => d.contentId != contentId)
          .map((d) => jsonEncode(d.toMap()))
          .toList(),
    );
  }
}
