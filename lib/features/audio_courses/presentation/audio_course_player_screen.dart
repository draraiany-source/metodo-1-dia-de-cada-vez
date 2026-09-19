import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/mascot/lily_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/lily_character_widget.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../domain/audio_course_models.dart';
import '../providers/audio_course_providers.dart';

class AudioCoursePlayerScreen extends ConsumerStatefulWidget {
  const AudioCoursePlayerScreen({super.key, required this.course});
  final AudioCourse course;

  @override
  ConsumerState<AudioCoursePlayerScreen> createState() =>
      _AudioCoursePlayerScreenState();
}

class _AudioCoursePlayerScreenState
    extends ConsumerState<AudioCoursePlayerScreen> {
  static const _meditationCategories = {
    AudioCourseCategory.meditacao,
    AudioCourseCategory.respiracao,
    AudioCourseCategory.ansiedade,
    AudioCourseCategory.sono,
  };

  AudioChapter? _current;
  double _speed = 1.0;
  bool _loading = false;
  String? _error;
  bool _completionSheetOpen = false;
  StreamSubscription<PlayerState>? _stateSub;

  bool get _isMeditation =>
      _meditationCategories.contains(widget.course.category);

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider) ?? AppUser.uiFallback();
    if (isContentLocked(ref, widget.course.isPremium)) return; // gate: ver build()
    if (widget.course.chapters.isNotEmpty) {
      final historico = ref.read(audioHistoryProvider)[widget.course.id];
      final retomar = historico != null
          ? widget.course.chapters
              .where((c) => c.id == historico.chapterId)
              .cast<AudioChapter?>()
              .firstWhere((c) => c != null, orElse: () => null)
          : null;
      _current = retomar ?? widget.course.chapters.first;
      WidgetsBinding.instance.addPostFrameCallback((_) => _play(
          _current!,
          startAt: retomar != null
              ? Duration(seconds: historico!.seconds)
              : Duration.zero));
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> _play(AudioChapter chapter, {Duration? startAt}) async {
    final player = ref.read(audioPlayerProvider);
    setState(() {
      _current = chapter;
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(audioCoursesRepositoryProvider)
          .resolveChapterUrl(widget.course.id, chapter.id);
      if (!result.ok) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = result.error ?? 'Não consegui tocar este áudio.';
          });
        }
        return;
      }
      await player.setUrl(result.url!);
      await player.setSpeed(_speed);
      if (startAt != null && startAt > Duration.zero) {
        await player.seek(startAt);
      }
      await player.play();
      ref.read(nowPlayingProvider.notifier).state =
          (widget.course, chapter);

      await _stateSub?.cancel();
      _stateSub = player.playerStateStream.listen((s) {
        if (s.processingState == ProcessingState.completed) {
          _onChapterCompleted();
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não consegui carregar este áudio agora.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _retry() async {
    final chapter = _current;
    if (chapter == null) return;
    await _play(chapter);
  }

  Future<void> _onChapterCompleted() async {
    if (!mounted || _completionSheetOpen) return;
    _completionSheetOpen = true;

    final message = _isMeditation
        ? 'Parabéns. Você separou alguns minutos para cuidar de você.'
        : 'Você concluiu mais um passo da sua jornada.';
    final buttonLabel = _isMeditation ? 'Concluir' : 'Continuar';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LilyCharacterWidget(
                  situation: _isMeditation
                      ? LilySituation.meditating
                      : LilySituation.celebrating,
                  height: 140,
                  animated: false,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    _completionSheetOpen = false;
    _proximoCapitulo();
  }

  void _proximoCapitulo() {
    final chapters = widget.course.chapters;
    final idx = chapters.indexWhere((c) => c.id == _current?.id);
    if (idx >= 0 && idx < chapters.length - 1) {
      _play(chapters[idx + 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final bloqueado = isContentLocked(ref, widget.course.isPremium);

    if (bloqueado) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.course.title)),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium,
                      size: 56, color: AppColors.warning),
                  const SizedBox(height: 16),
                  const Text('Curso exclusivo Premium',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('"${widget.course.title}" é exclusivo para assinantes.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(Routes.premium);
                    },
                    child: const Text('Ver planos Premium'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final player = ref.watch(audioPlayerProvider);
    final favoritos = ref.watch(audioFavoritesProvider);
    final isFavorite = favoritos.contains(widget.course.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: FavoriteAssetIcon(active: isFavorite, size: 22),
            onPressed: () => ref
                .read(audioFavoritesProvider.notifier)
                .toggle(widget.course.id),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share(
                '"${widget.course.title}" com ${widget.course.teacher} — '
                'disponível no Método 1 Dia de Cada Vez'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      child: widget.course.coverUrl.isEmpty
                          ? Container(
                              width: 180,
                              height: 180,
                              color: AppColors.surface,
                              child: const Icon(Icons.headphones,
                                  size: 48, color: AppColors.textTertiary),
                            )
                          : CachedNetworkImage(
                              imageUrl: widget.course.coverUrl,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(widget.course.teacher,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                  ),
                  if (_loading) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Preparando seu áudio…',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton(
                        onPressed: _retry,
                        child: const Text('Tentar novamente'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text('Capítulos',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...widget.course.chapters.map((c) {
                    final tocando = c.id == _current?.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: tocando
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: ListTile(
                        leading: Icon(
                          tocando ? Icons.graphic_eq : Icons.play_circle_outline,
                          color: tocando
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(c.title,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          '${c.duration.inMinutes}min',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        onTap: () => _play(c),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Barra de controle fixa
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                children: [
                  StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, snap) {
                      final pos = snap.data ?? Duration.zero;
                      final total = player.duration ?? Duration.zero;
                      final remaining = total > pos ? total - pos : Duration.zero;
                      if (_current != null && pos.inSeconds % 5 == 0) {
                        ref
                            .read(audioHistoryProvider.notifier)
                            .update(widget.course.id, _current!.id, pos);
                      }
                      return Column(
                        children: [
                          Slider(
                            value: total.inMilliseconds > 0
                                ? pos.inMilliseconds
                                    .clamp(0, total.inMilliseconds)
                                    .toDouble()
                                : 0,
                            max: total.inMilliseconds > 0
                                ? total.inMilliseconds.toDouble()
                                : 1,
                            activeColor: AppColors.primary,
                            onChanged: (v) =>
                                player.seek(Duration(milliseconds: v.round())),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_fmt(pos),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                              Text('-${_fmt(remaining)}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<double>(
                        value: _speed,
                        dropdownColor: AppColors.surface,
                        underline: const SizedBox(),
                        items: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text('${s}x',
                                    style:
                                        const TextStyle(color: Colors.white))))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _speed = v);
                          player.setSpeed(v);
                        },
                      ),
                      IconButton(
                        iconSize: 56,
                        icon: _loading
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                    color: AppColors.primary))
                            : StreamBuilder<bool>(
                                stream: player.playingStream,
                                builder: (context, snap) => Icon(
                                  (snap.data ?? false)
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: AppColors.primary,
                                ),
                              ),
                        onPressed: () {
                          if (player.playing) {
                            player.pause();
                          } else {
                            player.play();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next,
                            color: AppColors.textSecondary),
                        onPressed: _proximoCapitulo,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
