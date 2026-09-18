import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/youtube_launch.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
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

  if (video.isPremium && !user.isPremium) {
    await _mostrarBloqueioPremium(context, video);
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

Future<void> _mostrarBloqueioPremium(
  BuildContext context,
  VideoContent video,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PremiumSheet(video: video),
  );
}

class _PremiumSheet extends StatelessWidget {
  const _PremiumSheet({required this.video});
  final VideoContent video;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.workspace_premium,
              size: 48, color: AppColors.warning),
          const SizedBox(height: 14),
          const Text(
            'Conteúdo exclusivo Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '“${video.name}” é liberado para assinantes.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(Routes.premium);
              },
              child: const Text('Ver planos Premium'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora não'),
          ),
        ],
      ),
    );
  }
}
