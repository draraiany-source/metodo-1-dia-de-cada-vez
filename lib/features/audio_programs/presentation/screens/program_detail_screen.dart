import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/audio_program_providers.dart';
import '../widgets/program_day_card.dart';

class ProgramDetailScreen extends ConsumerWidget {
  final String programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(programByIdProvider(programId));
    final audiosAsync = ref.watch(programAudiosProvider(programId));
    final progressAsync = ref.watch(programProgressProvider(programId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Programa 7 Dias'),
        backgroundColor: AppColors.surfaceDeep,
      ),
      body: audiosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erro ao carregar programa: $e',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (audios) {
          final program = programAsync.value;
          final progress = progressAsync.value;
          final completedCount = progress?.completedAudioIds.length ?? 0;
          final nextAudio = audios
                  .where((a) => !(progress?.isCompleted(a.id) ?? false))
                  .firstOrNull ??
              (audios.isNotEmpty ? audios.first : null);

          return ListView(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: program != null && program.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: program.coverUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.brandGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.self_improvement_rounded,
                            size: 72,
                            color: AppColors.textOnPink,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program?.title ??
                          'Programa 7 Dias — Um Dia de Cada Vez',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      program?.description ??
                          'Um dia de cada vez, com foco, disciplina e mudança de hábitos.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Por ${program?.author ?? 'Amanda Lopes'} · '
                      '${program?.category ?? 'Foco, Disciplina e Mudança de Hábitos'}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProgressBar(
                      completed: completedCount,
                      total: audios.length,
                    ),
                    if (nextAudio != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.push(
                            '/audio-programs/$programId/play/${nextAudio.id}',
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            progress?.currentAudioId != null
                                ? 'Continuar ouvindo · Dia ${nextAudio.day}'
                                : 'Começar · Dia ${nextAudio.day}',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.textOnPink,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...audios.map((audio) {
                final isCompleted = progress?.isCompleted(audio.id) ?? false;
                final isFavorite = progress?.isFavorite(audio.id) ?? false;
                final isCurrent = progress?.currentAudioId == audio.id;
                final hasPos = (progress?.positionFor(audio.id) ?? 0) > 0;
                return ProgramDayCard(
                  audio: audio,
                  isCompleted: isCompleted,
                  isFavorite: isFavorite,
                  isCurrent: isCurrent,
                  inProgress: !isCompleted && (isCurrent || hasPos),
                  onTap: () => context.push(
                    '/audio-programs/$programId/play/${audio.id}',
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$completed de $total dias concluídos',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
          ),
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
