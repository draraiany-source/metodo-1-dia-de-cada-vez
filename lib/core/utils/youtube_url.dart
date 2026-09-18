/// Helpers puros (sem Flutter) para URLs do YouTube.
///
/// Vive separado de `YoutubeLaunch` porque o domínio da biblioteca de vídeos
/// precisa derivar id e capa a partir de uma URL sem arrastar widgets para
/// dentro da camada de modelo. `YoutubeLaunch` delega para cá: não duplique
/// esta lógica em outro lugar.
class YoutubeUrl {
  YoutubeUrl._();

  /// Prefixos de path que carregam o id no segmento seguinte.
  static const List<String> _kindsComIdNoPath = ['shorts', 'embed', 'live', 'v'];

  static bool isYoutubeHost(String host) {
    final clean = host.toLowerCase().replaceFirst('www.', '');
    return clean == 'youtube.com' ||
        clean == 'youtu.be' ||
        clean == 'm.youtube.com' ||
        clean == 'music.youtube.com' ||
        clean == 'gaming.youtube.com';
  }

  static bool isYoutube(Uri uri) => isYoutubeHost(uri.host);

  /// Normaliza para `watch?v=` quando possível. Devolve a Uri original quando
  /// não é YouTube, e null quando nem dá para interpretar como URL.
  static Uri? normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    var uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$trimmed');
      if (uri == null) return null;
    }

    if (!isYoutubeHost(uri.host)) return uri;

    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      if (id.isNotEmpty) return Uri.https('www.youtube.com', '/watch', {'v': id});
    }

    for (final kind in _kindsComIdNoPath) {
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == kind) {
        final id = uri.pathSegments[1];
        if (id.isNotEmpty) {
          return Uri.https('www.youtube.com', '/watch', {'v': id});
        }
      }
    }

    return uri;
  }

  /// Extrai o id do vídeo de uma URL normal, youtu.be, /shorts/, /embed/,
  /// /live/ ou /v/. Devolve null se a URL não for de um vídeo do YouTube.
  static String? extractVideoId(String rawUrl) {
    final uri = normalize(rawUrl);
    if (uri == null) return null;

    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      if (_pareceId(id)) return _limpar(id);
    }

    final v = uri.queryParameters['v'];
    if (v != null && _pareceId(v)) return _limpar(v);

    if (uri.pathSegments.length >= 2 &&
        _kindsComIdNoPath.contains(uri.pathSegments[0])) {
      final id = uri.pathSegments[1];
      if (_pareceId(id)) return _limpar(id);
    }

    return null;
  }

  /// Capa automática do YouTube — serve para vídeos "não listados" também.
  ///
  /// `maxresdefault` não existe para todo vídeo (depende da resolução do
  /// upload); `hqdefault` existe sempre, então é o padrão seguro em listas.
  static String? thumbnailUrl(String rawUrl, {bool maxRes = false}) {
    final id = extractVideoId(rawUrl);
    if (id == null) return null;
    final nome = maxRes ? 'maxresdefault' : 'hqdefault';
    return 'https://img.youtube.com/vi/$id/$nome.jpg';
  }

  static String _limpar(String id) => id.split('&').first.split('?').first;

  static bool _pareceId(String id) =>
      RegExp(r'^[\w-]{6,}$').hasMatch(_limpar(id));
}
