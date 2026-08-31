import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre links do YouTube (públicos ou não listados) no app externo.
/// Aceita URLs normais, youtu.be, /shorts/ e embed.
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

  static Future<bool> open(
    BuildContext context,
    String rawUrl, {
    String unavailableMessage = 'Link de vídeo indisponível.',
    String failureMessage = 'Não foi possível abrir o vídeo.',
  }) async {
    final uri = normalize(rawUrl);
    if (uri == null) {
      _snack(context, unavailableMessage);
      return false;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _snack(context, failureMessage);
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
