import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../video_streaming/data/videos_repository.dart';
import '../../video_streaming/domain/video_models.dart';
import '../../video_streaming/providers/video_providers.dart';
import '../../video_streaming/presentation/video_open.dart';

/// Área de Meditação — 7 Shorts do YouTube (e os que a Amanda cadastrar).
///
/// Reproduz pelo player embutido já usado na biblioteca de vídeos.
/// Não baixa MP3/MP4 e não extrai áudio do YouTube.
class MeditationsScreen extends ConsumerWidget {
  const MeditationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(meditationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Meditações'),
      body: SafeArea(
        child: async.when(
          loading: () => const AppListSkeleton(itemHeight: 168, itemCount: 4),
          error: (error, _) => AppErrorState(
            message: error is VideosFetchException
                ? error.userMessage
                : FirebaseErrorMapper.toUserMessage(
                    error,
                    fallback:
                        'Não foi possível carregar as meditações. Verifique a internet e tente de novo.',
                  ),
            onRetry: () => ref.invalidate(videosProvider),
          ),
          data: (itens) {
            if (itens.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: ComingSoonView(
                  emoji: '🧘',
                  title: 'As meditações estão a caminho',
                  description:
                      'A Amanda publica os áudios pelo YouTube. Assim que '
                      'estiverem no ar, eles aparecem aqui.',
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: itens.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Text(
                      'Sete áudios na ordem do programa (1–7). '
                      'O nome na lista corresponde ao Short do YouTube '
                      'aberto ao tocar — sem baixar arquivo.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  );
                }
                final item = itens[i - 1];
                return _MeditationCard(video: item, playlist: itens);
              },
            );
          },
        ),
      ),
    );
  }
}

class _MeditationCard extends ConsumerWidget {
  const _MeditationCard({required this.video, required this.playlist});

  final VideoContent video;
  final List<VideoContent> playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capa = video.displayThumbnailUrl;
    final duracao = video.durationLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (capa.isEmpty)
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.softCardGradient),
                    child: Center(
                      child: Icon(Icons.self_improvement_rounded,
                          color: AppColors.textTertiary, size: 42),
                    ),
                  )
                else
                  CachedNetworkImage(
                    imageUrl: capa,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(
                      color: AppColors.surfaceDeep,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: AppColors.surfaceDeep,
                      child: Center(
                        child: Icon(Icons.wifi_off_rounded,
                            color: AppColors.textTertiary, size: 32),
                      ),
                    ),
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                      stops: [0.5, 1],
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white70, size: 52),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Meditação',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (duracao.isNotEmpty)
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        duracao,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                if (video.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    video.description.trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => abrirVideo(
                      context,
                      ref,
                      video,
                      playlist: playlist,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      video.aguardandoUrl ? 'Em breve' : 'Reproduzir',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
