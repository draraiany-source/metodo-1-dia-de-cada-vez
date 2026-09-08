import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/youtube_in_app_screen.dart';

/// Abre links do YouTube preferencialmente **dentro do app**.
/// Aceita URLs normais, youtu.be, /shorts/ e embed.
///
/// Fluxo:
/// 1) Extrai o videoId e navega para [YoutubeInAppScreen] (pilha Flutter) —
///    Voltar do Android / AppBar restaura a tela anterior.
/// 2) Se não for possível embutir, usa Custom Tab / in-app browser.
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
    if (host != 'youtube.com' && host != 'youtu.be' && host != 'm.youtube.com') {
      return uri;
    }

    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments.first;
      if (id.isNotEmpty) {
        return Uri.https('www.youtube.com', '/watch', {'v': id});
      }
    }

    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'shorts') {
      final id = uri.pathSegments[1];
      if (id.isNotEmpty) {
        return Uri.https('www.youtube.com', '/watch', {'v': id});
      }
    }

    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'embed') {
      final id = uri.pathSegments[1];
      if (id.isNotEmpty) {
        return Uri.https('www.youtube.com', '/watch', {'v': id});
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
      return uri.pathSegments.first;
    }
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 'shorts' || uri.pathSegments[0] == 'embed')) {
      return uri.pathSegments[1];
    }
    return null;
  }

  static bool _isYoutube(Uri uri) {
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    return host == 'youtube.com' ||
        host == 'youtu.be' ||
        host == 'm.youtube.com';
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

    // Fallback: Custom Tab / Safari View — Voltar fecha e retorna ao app.
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
