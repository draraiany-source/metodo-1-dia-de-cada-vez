import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../personal_cms/presentation/cms_confirm.dart';
import '../domain/weekly_challenge_models.dart';
import '../providers/weekly_challenge_providers.dart';

class WeeklyChallengeCmsListScreen extends ConsumerWidget {
  const WeeklyChallengeCmsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(staffWeeklyChallengesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gerenciar Desafios'),
        actions: [
          IconButton(
            tooltip: 'Novo desafio',
            onPressed: () => context.push(Routes.personalCmsChallengeEdit),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.personalCmsChallengeEdit),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add),
        label: const Text('Criar desafio'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.white)),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum desafio cadastrado.\nToque em Criar desafio para publicar a primeira semana.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _Row(challenge: list[i]),
          );
        },
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.challenge});
  final WeeklyChallenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                _StatusChip(challenge: challenge),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${challenge.category.label} · ${challenge.periodLabel}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 6),
            Text(
              '${challenge.participantCount} participantes · '
              '${challenge.completionPercent.round()}% de conclusão',
              style: const TextStyle(color: AppColors.accent, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => context.push(
                    '${Routes.personalCmsChallengeEdit}?id=${challenge.id}',
                  ),
                  child: const Text('Editar'),
                ),
                OutlinedButton(
                  onPressed: () => context.push(
                    '${Routes.personalCmsChallengeParticipants}/${challenge.id}',
                  ),
                  child: const Text('Participantes'),
                ),
                if (challenge.status != WeeklyChallengeStatus.published)
                  FilledButton(
                    onPressed: () => _publish(ref, challenge),
                    child: const Text('Publicar'),
                  ),
                TextButton(
                  onPressed: () => _delete(context, ref),
                  child: const Text('Excluir',
                      style: TextStyle(color: AppColors.danger)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publish(WidgetRef ref, WeeklyChallenge challenge) async {
    await ref.read(weeklyChallengeRepositoryProvider).saveChallenge(
          challenge.copyWith(status: WeeklyChallengeStatus.published),
        );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDeactivate(
      context,
      title: 'Excluir desafio?',
      message: 'O desafio deixa de aparecer para as alunas.',
      confirmLabel: 'Excluir',
    );
    if (!ok) return;
    await ref.read(weeklyChallengeRepositoryProvider).deleteChallenge(challenge.id);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.challenge});
  final WeeklyChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final label = challenge.isScheduled
        ? 'Agendado'
        : challenge.status.label;
    final color = switch (challenge.status) {
      WeeklyChallengeStatus.published =>
        challenge.isScheduled ? AppColors.info : AppColors.success,
      WeeklyChallengeStatus.draft => AppColors.warning,
      WeeklyChallengeStatus.archived => AppColors.textTertiary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
