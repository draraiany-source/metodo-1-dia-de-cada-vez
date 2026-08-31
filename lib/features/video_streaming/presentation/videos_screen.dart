import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/video_models.dart';
import '../providers/video_providers.dart';
import 'video_player_screen.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  VideoCategory? _filtro;
  VideoLevel? _nivel;

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videosProvider);
    final favoritos = ref.watch(videoFavoritesProvider);
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Treinos em vídeo 🎥'),
      body: SafeArea(
        child: videosAsync.when(
          loading: () => const AppListSkeleton(),
          error: (_, __) =>
              AppErrorState(onRetry: () => ref.invalidate(videosProvider)),
          data: (videos) {
            final filtrados = videos.where((v) {
              if (_filtro != null && v.category != _filtro) return false;
              if (_nivel != null && v.level != _nivel) return false;
              return true;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Streaming sob demanda — sempre atualizado',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _Chip(
                                  label: 'Todas',
                                  selected: _filtro == null,
                                  onTap: () => setState(() => _filtro = null)),
                              ...VideoCategory.values.map((c) => _Chip(
                                    label: c.label,
                                    selected: _filtro == c,
                                    onTap: () => setState(() => _filtro = c),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 32,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _Chip(
                                  label: 'Todos níveis',
                                  selected: _nivel == null,
                                  onTap: () => setState(() => _nivel = null)),
                              ...VideoLevel.values.map((l) => _Chip(
                                    label: l.label,
                                    selected: _nivel == l,
                                    onTap: () => setState(() => _nivel = l),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (videos.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: ComingSoonView(
                              emoji: '🎥',
                              title: 'Nenhum vídeo disponível ainda',
                              description:
                                  'Assim que os vídeos forem cadastrados, eles aparecem aqui automaticamente.',
                            ),
                          )
                        else if (filtrados.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text('Nenhum vídeo com esse filtro.',
                                  style:
                                      TextStyle(color: AppColors.textSecondary)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Lazy de verdade: só constrói os cards visíveis, mesmo com
                // milhares de vídeos cadastrados.
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _VideoCard(
                        video: filtrados[i],
                        isFavorite: favoritos.contains(filtrados[i].id),
                        locked: filtrados[i].isPremium && !user.isPremium,
                        allVideos: filtrados,
                      ),
                      childCount: filtrados.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
          label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.video,
    required this.isFavorite,
    required this.locked,
    required this.allVideos,
  });
  final VideoContent video;
  final bool isFavorite;
  final bool locked;
  final List<VideoContent> allVideos;

  @override
  Widget build(BuildContext context) {
    final min = (video.durationSeconds / 60).round();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video, playlist: allVideos),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                  video.thumbnailUrl.isEmpty
                      ? Container(
                          color: AppColors.background,
                          child: const Icon(Icons.play_circle_outline,
                              color: AppColors.textTertiary, size: 40),
                        )
                      : CachedNetworkImage(
                          imageUrl: video.thumbnailUrl, fit: BoxFit.cover),
                  if (locked)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 28),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('${min}min',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11)),
                    ),
                  ),
                  if (video.isPremium)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('PREMIUM',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(video.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                      FavoriteAssetIcon(active: isFavorite, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${video.teacher} · ${video.category.label} · ${video.level.label}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
