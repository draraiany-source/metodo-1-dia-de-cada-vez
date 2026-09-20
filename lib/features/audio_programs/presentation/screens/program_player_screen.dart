import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/router/premium_app_bar.dart';
import '../../../../core/mascot/lily_catalog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lily_character_widget.dart';
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
  bool _celebrationSheetOpen = false;
  bool _lookupFailed = false;

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
      try {
        final audios = await ref
            .read(programAudiosProvider(widget.programId).future)
            .timeout(const Duration(seconds: 10));
        audio = audios.where((a) => a.id == widget.audioId).firstOrNull;
      } catch (_) {
        audio = null;
      }
    }
    if (!mounted) return;
    if (audio == null) {
      setState(() => _lookupFailed = true);
      return;
    }

    _lookupFailed = false;
    _openedFor = key;
    final progressAsync = ref.read(programProgressProvider(widget.programId));
    final isFavorite = progressAsync.value?.isFavorite(audio.id) ?? false;
    if (!mounted) return;
    await ref
        .read(programPlayerControllerProvider(widget.programId).notifier)
        .open(audio, isFavorite: isFavorite);
  }

  Future<void> _retryOpen() async {
    final state = ref.read(programPlayerControllerProvider(widget.programId));
    final audio = state.audio ?? widget.initialAudio;
    if (audio == null) {
      _openedFor = null;
      await _tryOpen();
      return;
    }
    final progressAsync = ref.read(programProgressProvider(widget.programId));
    final isFavorite = progressAsync.value?.isFavorite(audio.id) ?? false;
    await ref
        .read(programPlayerControllerProvider(widget.programId).notifier)
        .open(audio, isFavorite: isFavorite);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _showCelebrationSheet() async {
    if (_celebrationSheetOpen || !mounted) return;
    _celebrationSheetOpen = true;
    final controller =
        ref.read(programPlayerControllerProvider(widget.programId).notifier);
    controller.acknowledgeCelebration();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDeep,
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
                const LilyCharacterWidget(
                  situation: LilySituation.celebrating,
                  height: 140,
                  animated: false,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Você concluiu mais um passo da sua jornada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
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
                    child: const Text('Continuar'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) _celebrationSheetOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        ref.read(programPlayerControllerProvider(widget.programId).notifier);
    final state = ref.watch(programPlayerControllerProvider(widget.programId));
    final programAsync = ref.watch(programByIdProvider(widget.programId));
    final audio = state.audio ?? widget.initialAudio;
    final author = programAsync.value?.author ?? 'Amanda Lopes';

    ref.listen<ProgramPlayerState>(
      programPlayerControllerProvider(widget.programId),
      (prev, next) {
        if (next.celebrationPending && !(prev?.celebrationPending ?? false)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCelebrationSheet();
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: audio != null ? 'Dia ${audio.day}' : 'Player',
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
              audio?.title ??
                  (_lookupFailed
                      ? 'Áudio não encontrado'
                      : 'Preparando seu áudio…'),
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
            if (state.error != null || _lookupFailed) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  state.error ??
                      'Não foi possível abrir este áudio. Verifique a internet e tente novamente.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _lookupFailed = false);
                  _retryOpen();
                },
                child: const Text('Tentar novamente'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (state.isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(color: AppColors.secondary),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Preparando seu áudio…',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              )
            else if (state.error == null) ...[
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
                    Text('-${_fmt(state.remaining)}',
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
                    tooltip: '-10s',
                    icon: const Icon(Icons.replay_10,
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
                    tooltip: '+10s',
                    icon: const Icon(Icons.forward_10,
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
