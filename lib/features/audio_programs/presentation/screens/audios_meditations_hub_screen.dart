import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/audio_program_repository_impl.dart';
import '../../providers/audio_program_providers.dart';

/// Hub "Áudios & Meditações" — destaca o Programa 7 Dias e reaproveita
/// a biblioteca existente de cursos/meditações.
class AudiosMeditationsHubScreen extends ConsumerWidget {
  const AudiosMeditationsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programsListProvider);
    final progressAsync =
        ref.watch(programProgressProvider(kPrograma7DiasId));
    final audiosAsync =
        ref.watch(programAudiosProvider(kPrograma7DiasId));

    final progress = progressAsync.value;
    final audios = audiosAsync.value ?? const [];
    final done = progress?.completedAudioIds.length ?? 0;
    final total = audios.isNotEmpty ? audios.length : 7;
    final currentId = progress?.currentAudioId;
    final hasResume = currentId != null &&
        (progress?.positionFor(currentId) ?? 0) > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Áudios de transformação'),
        backgroundColor: AppColors.surfaceDeep,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (hasResume) ...[
            _SectionTitle('Continuar ouvindo'),
            const SizedBox(height: AppSpacing.sm),
            _ContinueCard(
              dayLabel: progress?.currentAudioId ?? '',
              onTap: () => context.push(
                '/audio-programs/$kPrograma7DiasId/play/$currentId',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          _SectionTitle('Programa 7 Dias'),
          const SizedBox(height: AppSpacing.sm),
          _Programa7DiasHero(
            done: done,
            total: total,
            category: programsAsync.value
                    ?.where((p) => p.id == kPrograma7DiasId)
                    .firstOrNull
                    ?.category ??
                'Foco, Disciplina e Mudança de Hábitos',
            author: 'Amanda Lopes',
            onOpen: () =>
                context.push('/audio-programs/$kPrograma7DiasId'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle('Biblioteca'),
          const SizedBox(height: AppSpacing.sm),
          _LinkTile(
            title: 'Todos os áudios',
            subtitle: 'Cursos e faixas',
            icon: Icons.library_music_rounded,
            onTap: () => context.push('/audio-courses'),
          ),
          _LinkTile(
            title: 'Meditações',
            subtitle: 'Sono, respiração e ansiedade',
            icon: Icons.self_improvement_rounded,
            onTap: () => context.push('/meditations'),
          ),
          _LinkTile(
            title: 'Áudios da Lili',
            subtitle: 'Bom dia, treino e motivação',
            icon: Icons.auto_awesome_rounded,
            onTap: () => context.push('/lili-audios'),
          ),
          if ((progress?.favoriteAudioIds.isNotEmpty ?? false)) ...[
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle('Favoritos'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${progress!.favoriteAudioIds.length} favorito(s) no Programa 7 Dias',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () =>
                  context.push('/audio-programs/$kPrograma7DiasId'),
              child: const Text('Ver no programa'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Programa7DiasHero extends StatelessWidget {
  final int done;
  final int total;
  final String category;
  final String author;
  final VoidCallback onOpen;

  const _Programa7DiasHero({
    required this.done,
    required this.total,
    required this.category,
    required this.author,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            gradient: AppColors.brandGradient,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROGRAMA 7 DIAS',
                style: TextStyle(
                  color: AppColors.textOnPink,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Um Dia de Cada Vez',
                style: TextStyle(
                  color: AppColors.textOnPink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                category,
                style: TextStyle(
                  color: AppColors.textOnPink.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
              Text(
                'Autora: $author',
                style: TextStyle(
                  color: AppColors.textOnPink.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '$done de $total dias concluídos',
                style: const TextStyle(
                  color: AppColors.textOnPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.textOnPink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final String dayLabel;
  final VoidCallback onTap;

  const _ContinueCard({required this.dayLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      tileColor: AppColors.surfaceElevated,
      leading: const Icon(Icons.play_circle_fill, color: AppColors.secondary),
      title: const Text('Continuar de onde parou',
          style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(dayLabel,
          style: const TextStyle(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _LinkTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle:
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
    );
  }
}

extension _FirstOrNullHub<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
