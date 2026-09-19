import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/youtube_launch.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../subscriptions/presentation/premium_gate_sheet.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../domain/video_models.dart';
import '../providers/video_providers.dart';
import 'video_player_screen.dart';

/// Ponto único de abertura de um vídeo da biblioteca.
///
/// Centraliza três decisões que a lista e o player precisam tomar igual:
/// bloqueio Premium, vídeo sem URL cadastrada, e YouTube vs. legado
/// auto-hospedado. Também é aqui que medimos o tempo na tela do player, que é a
/// base do "continuar assistindo" (ver `VideoWatchState`).
Future<void> abrirVideo(
  BuildContext context,
  WidgetRef ref,
  VideoContent video, {
  List<VideoContent> playlist = const [],
}) async {
  final user = ref.read(currentUserProvider) ?? AppUser.uiFallback();

  final access = ref.read(effectiveAccessProvider);
  if (video.isPremium && !access.hasPremium && !user.isPremium) {
    await showPremiumGate(context, contentName: video.name);
    return;
  }

  if (video.aguardandoUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Este vídeo está sendo preparado e chega em breve. 💜'),
      ),
    );
    return;
  }

  final notifier = ref.read(videoWatchStateProvider.notifier);
  await notifier.marcarAbertura(video.id);
  if (!context.mounted) return;

  final inicio = DateTime.now();

  if (video.isYoutube) {
    await YoutubeLaunch.open(
      context,
      video.youtubeUrl,
      unavailableMessage: 'O link deste vídeo está inválido. '
          'Avise a Amanda pra corrigir no painel.',
    );
  } else {
    // Legado auto-hospedado: player próprio, que sabe retomar por posição real.
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VideoPlayerScreen(
          video: video,
          playlist: playlist.isEmpty ? [video] : playlist,
        ),
      ),
    );
  }

  await notifier.registrarTempoAssistido(
    video.id,
    DateTime.now().difference(inicio),
    durationSeconds: video.durationSeconds,
  );
}
