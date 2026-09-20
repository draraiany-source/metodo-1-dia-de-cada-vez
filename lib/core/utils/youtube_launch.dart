import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/youtube_in_app_screen.dart';
import 'youtube_url.dart';

/// Abre links do YouTube preferencialmente **dentro do app**.
/// Aceita URLs normais, youtu.be, /shorts/, /embed/, /live/ e /v/.
///
/// A interpretação da URL em si vive em [YoutubeUrl] (Dart puro, testável e
/// reutilizado pelo domínio da biblioteca de vídeos).
class YoutubeLaunch {
  YoutubeLaunch._();

  /// Normaliza URL para formato watch?v= quando possível.
  static Uri? normalize(String raw) => YoutubeUrl.normalize(raw);

  /// Extrai o ID do vídeo a partir de uma URL já normalizada (ou raw).
  static String? extractVideoId(String rawUrl) =>
      YoutubeUrl.extractVideoId(rawUrl);

  static Future<bool> open(
    BuildContext context,
    String rawUrl, {
    String? title,
    String unavailableMessage = 'Link de vídeo indisponível.',
    String failureMessage =
        'Não foi possível abrir o vídeo. Se estiver privado ou indisponível, ajuste a privacidade no YouTube.',
  }) async {
    final uri = YoutubeUrl.normalize(rawUrl);
    if (uri == null || !YoutubeUrl.isYoutube(uri)) {
      _snack(context, unavailableMessage);
      return false;
    }

    final videoId = YoutubeUrl.extractVideoId(rawUrl);

    // Preferir player embutido (mobile WebView ou iframe no Web).
    // Vídeos Privados no YouTube continuam sem reprodução — precisam
    // estar Público ou Não listado no canal.
    if (videoId != null && videoId.isNotEmpty && context.mounted) {
      final titulo = (title ?? '').trim();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => YoutubeInAppScreen(
            videoId: videoId,
            title: titulo.isEmpty ? 'Vídeo' : titulo,
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
