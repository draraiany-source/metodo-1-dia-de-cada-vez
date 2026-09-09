import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/youtube_in_app_screen.dart';

/// Abre links do YouTube preferencialmente **dentro do app**.
/// Aceita URLs normais, youtu.be, /shorts/, /embed/, /live/ e /v/.
class YoutubeLaunch {
  YoutubeLaunch._();

  /// Normaliza URL para formato watch?v= quando possível.
  static Uri? normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    var uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    if (!uri.hasScheme) {
      uri = Uri.tryParse('https://$trimmed');
      if (uri == null) return null;
    }

    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    if (!_isYoutubeHost(host)) return uri;

    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      if (id.isNotEmpty) {
        return Uri.https('www.youtube.com', '/watch', {'v': id});
      }
    }

    for (final kind in ['shorts', 'embed', 'live', 'v']) {
      if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == kind) {
        final id = uri.pathSegments[1];
        if (id.isNotEmpty) {
          return Uri.https('www.youtube.com', '/watch', {'v': id});
        }
      }
    }

    return uri;
  }

  /// Extrai o ID do vídeo a partir de uma URL já normalizada (ou raw).
  static String? extractVideoId(String rawUrl) {
    final uri = normalize(rawUrl);
    if (uri == null) return null;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      if (_looksLikeVideoId(id)) return id;
    }
    final v = uri.queryParameters['v'];
    if (v != null && _looksLikeVideoId(v)) return v;
    if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 'shorts' ||
            uri.pathSegments[0] == 'embed' ||
            uri.pathSegments[0] == 'live' ||
            uri.pathSegments[0] == 'v')) {
      final id = uri.pathSegments[1];
      if (_looksLikeVideoId(id)) return id;
    }
    return null;
  }

  static bool _looksLikeVideoId(String id) {
    final clean = id.split('&').first.split('?').first;
    return RegExp(r'^[\w-]{6,}$').hasMatch(clean);
  }

  static bool _isYoutubeHost(String host) {
    return host == 'youtube.com' ||
        host == 'youtu.be' ||
        host == 'm.youtube.com' ||
        host == 'music.youtube.com' ||
        host == 'gaming.youtube.com';
  }

  static bool _isYoutube(Uri uri) {
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    return _isYoutubeHost(host);
  }

  static Future<bool> open(
    BuildContext context,
    String rawUrl, {
    String unavailableMessage = 'Link de vídeo indisponível.',
    String failureMessage =
        'Não foi possível abrir o vídeo. Se estiver privado ou indisponível, ajuste a privacidade no YouTube.',
  }) async {
    final uri = normalize(rawUrl);
    if (uri == null || !_isYoutube(uri)) {
      _snack(context, unavailableMessage);
      return false;
    }

    final videoId = extractVideoId(rawUrl);

    // WebView embutido é instável no Flutter Web — abre externo.
    if (kIsWeb) {
      return _launchExternal(context, uri, failureMessage);
    }

    if (videoId != null && videoId.isNotEmpty && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => YoutubeInAppScreen(
            videoId: videoId,
            watchUrl: uri,
          ),
        ),
      );
      return true;
    }

    return _launchExternal(context, uri, failureMessage);
  }

  static Future<bool> _launchExternal(
    BuildContext context,
    Uri uri,
    String failureMessage,
  ) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!ok && context.mounted) {
        final external = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!external && context.mounted) {
          _snack(context, failureMessage);
        }
        return external;
      }
      return ok;
    } catch (_) {
      if (context.mounted) _snack(context, failureMessage);
      return false;
    }
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
