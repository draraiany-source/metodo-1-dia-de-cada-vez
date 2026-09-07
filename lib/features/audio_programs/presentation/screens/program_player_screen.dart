import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/audio_program.dart';
import '../../providers/audio_program_providers.dart';
import '../../providers/program_player_controller.dart';

class ProgramPlayerScreen extends ConsumerStatefulWidget {
  final String programId;
  final String audioId;
  final ProgramAudio? initialAudio;

  const ProgramPlayerScreen({
    super.key,
    required this.programId,
    required this.audioId,
    this.initialAudio,
  });

  @override
  ConsumerState<ProgramPlayerScreen> createState() =>
      _ProgramPlayerScreenState();
}

class _ProgramPlayerScreenState extends ConsumerState<ProgramPlayerScreen> {
  String? _openedFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryOpen();
  }

  Future<void> _tryOpen() async {
    final key = '${widget.programId}:${widget.audioId}';
    if (_openedFor == key) return;

    ProgramAudio? audio = widget.initialAudio;
    if (audio == null || audio.id != widget.audioId) {
      final audios =
          await ref.read(programAudiosProvider(widget.programId).future);
      audio = audios.where((a) => a.id == widget.audioId).firstOrNull;
    }
    if (audio == null || !mounted) return;

    _openedFor = key;
    final progress =
        await ref.read(programProgressProvider(widget.programId).future);
    if (!mounted) return;
    await ref
        .read(programPlayerControllerProvider(widget.programId).notifier)
        .open(audio, isFavorite: progress.isFavorite(audio.id));
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        ref.read(programPlayerControllerProvider(widget.programId).notifier);
    final state = ref.watch(programPlayerControllerProvider(widget.programId));
    final programAsync = ref.watch(programByIdProvider(widget.programId));
    final audio = state.audio ?? widget.initialAudio;
    final author = programAsync.value?.author ?? 'Amanda Lopes';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(audio != null ? 'Dia ${audio.day}' : 'Player'),
        backgroundColor: AppColors.surfaceDeep,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  child: audio != null && audio.coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: audio.coverUrl,
                          width: 260,
                          height: 260,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 260,
                          height: 260,
                          decoration: const BoxDecoration(
                            gradient: AppColors.vibeGradient,
                          ),
                          child: const Icon(
                            Icons.headphones_rounded,
                            size: 72,
                            color: AppColors.textOnPink,
                          ),
                        ),
                ),
              ),
            ),
            Text(
              audio?.title ?? 'Carregando…',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              author,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (audio != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                audio.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textTertiary),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            if (state.isLoading)
              const CircularProgressIndicator(color: AppColors.secondary)
            else ...[
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.secondary,
                  thumbColor: AppColors.hotPink,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
                child: Slider(
                  value: state.progressFraction.clamp(0, 1),
                  onChanged: (v) {
                    final target = Duration(
                      milliseconds:
                          (v * state.duration.inMilliseconds).round(),
                    );
                    controller.seek(target);
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(state.position),
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                    Text(_fmt(state.duration),
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 32,
                    tooltip: '-15s',
                    icon: const Icon(Icons.replay,
                        color: AppColors.textPrimary),
                    onPressed: controller.back15,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  IconButton(
                    iconSize: 64,
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppColors.secondary,
                    ),
                    onPressed: controller.togglePlayPause,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  IconButton(
                    iconSize: 32,
                    tooltip: '+15s',
                    icon: const Icon(Icons.forward_30,
                        color: AppColors.textPrimary),
                    onPressed: controller.forward15,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              IconButton(
                icon: Icon(
                  state.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: state.isFavorite
                      ? AppColors.secondary
                      : AppColors.textTertiary,
                ),
                onPressed: controller.toggleFavorite,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
