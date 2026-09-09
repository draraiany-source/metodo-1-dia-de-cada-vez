import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/video_download_service.dart';
import '../domain/video_models.dart';
import '../providers/video_providers.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.playlist,
  });
  final VideoContent video;
  final List<VideoContent> playlist;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  late VideoContent _current;
  bool _loading = true;
  String? _erro;
  bool _baixando = false;
  double _progressoDownload = 0;

  @override
  void initState() {
    super.initState();
    _current = widget.video;
    _iniciar();
  }

  Future<void> _iniciar() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    final user = ref.read(currentUserProvider) ?? AppUser.uiFallback();
    if (_current.isPremium && !user.isPremium) {
      setState(() {
        _loading = false;
        _erro = 'PREMIUM_LOCK';
      });
      return;
    }

    // Se já baixado, toca do arquivo local (funciona offline).
    final baixados = await VideoDownloadService.list();
    final local = baixados.where((d) => d.videoId == _current.id).toList();

    String? source;
    bool isFile = false;
    if (local.isNotEmpty && await File(local.first.path).exists()) {
      source = local.first.path;
      isFile = true;
    } else {
      final result = await ref
          .read(videosRepositoryProvider)
          .resolveStreamUrl(_current.id);
      if (!result.ok) {
        setState(() {
          _loading = false;
          _erro = result.error ?? 'Não foi possível carregar o vídeo.';
        });
        return;
      }
      source = result.url;
    }

    _videoController = isFile
        ? VideoPlayerController.file(File(source!))
        : VideoPlayerController.networkUrl(Uri.parse(source!));

    try {
      await _videoController!.initialize();
      // Retoma de onde parou, se houver histórico.
      final historico = ref.read(videoHistoryProvider)[_current.id];
      if (historico != null && historico > 0) {
        await _videoController!.seekTo(Duration(seconds: historico));
      }
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.secondary,
          bufferedColor: Colors.white24,
        ),
      );
      _videoController!.addListener(_salvarProgresso);
      setState(() => _loading = false);
    } catch (_) {
      setState(() {
        _loading = false;
        _erro = 'Não consegui abrir este vídeo.';
      });
    }
  }

  void _salvarProgresso() {
    final v = _videoController;
    if (v == null || !v.value.isInitialized) return;
    final pos = v.value.position.inSeconds;
    // Persiste a cada ~5s pra não gravar a cada frame.
    if (pos % 5 == 0) {
      ref.read(videoHistoryProvider.notifier).update(_current.id, pos);
    }
    if (v.value.position >= v.value.duration &&
        v.value.duration.inSeconds > 0) {
      _proximoVideo();
    }
  }

  Future<void> _trocarPara(VideoContent novo) async {
    _videoController?.removeListener(_salvarProgresso);
    _chewieController?.dispose();
    await _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    setState(() => _current = novo);
    await _iniciar();
  }

  void _proximoVideo() {
    final idx = widget.playlist.indexWhere((v) => v.id == _current.id);
    if (idx >= 0 && idx < widget.playlist.length - 1) {
      _trocarPara(widget.playlist[idx + 1]);
    }
  }

  Future<void> _baixar() async {
    setState(() {
      _baixando = true;
      _progressoDownload = 0;
    });
    final result = await ref
        .read(videosRepositoryProvider)
        .resolveStreamUrl(_current.id);
    if (!result.ok) {
      setState(() => _baixando = false);
      return;
    }
    await VideoDownloadService.download(
      _current.id,
      result.url!,
      onProgress: (p) {
        if (mounted) setState(() => _progressoDownload = p);
      },
    );
    if (mounted) setState(() => _baixando = false);
  }

  @override
  void dispose() {
    _videoController?.removeListener(_salvarProgresso);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = ref.watch(videoFavoritesProvider);
    final isFavorite = favoritos.contains(_current.id);
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(_current.name, overflow: TextOverflow.ellipsis),
        actions: [
          if (_erro == null && !_loading) ...[
            IconButton(
              icon: FavoriteAssetIcon(active: isFavorite, size: 22),
              onPressed: () => ref
                  .read(videoFavoritesProvider.notifier)
                  .toggle(_current.id),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share(
                  '"${_current.name}" com ${_current.teacher} — '
                  'disponível no Método 1 Dia de Cada Vez 💜'),
            ),
            if (user.isPremium)
              IconButton(
                icon: _baixando
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, value: _progressoDownload))
                    : const Icon(Icons.download_outlined),
                onPressed: _baixando ? null : _baixar,
              ),
          ],
        ],
      ),
      body: SafeArea(
        child: _erro == 'PREMIUM_LOCK'
            ? _PremiumLock(video: _current)
            : _loading
                ? const Center(child: CircularProgressIndicator())
                : _erro != null
                    ? Center(
                        child: Text(_erro!,
                            style: const TextStyle(
                                color: AppColors.textSecondary)))
                    : Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _chewieController != null
                                ? Chewie(controller: _chewieController!)
                                : const SizedBox(),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                Text(_current.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                    '${_current.teacher} · ${_current.level.label}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 12),
                                Text(_current.description,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        height: 1.4)),
                                const SizedBox(height: 20),
                                const Text('A seguir',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                ...widget.playlist
                                    .where((v) => v.id != _current.id)
                                    .take(5)
                                    .map((v) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Icon(
                                              Icons.play_circle_outline,
                                              color: AppColors.textSecondary),
                                          title: Text(v.name,
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          subtitle: Text(v.teacher,
                                              style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 12)),
                                          onTap: () => _trocarPara(v),
                                        )),
                              ],
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}

class _PremiumLock extends StatelessWidget {
  const _PremiumLock({required this.video});
  final VideoContent video;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium,
                size: 56, color: AppColors.warning),
            const SizedBox(height: 16),
            const Text('Conteúdo exclusivo Premium',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('"${video.name}" é exclusivo para assinantes.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push(Routes.premium),
              child: const Text('Ver planos Premium'),
            ),
          ],
        ),
      ),
    );
  }
}
