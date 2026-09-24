import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/weekly_challenge_models.dart';
import '../providers/weekly_challenge_providers.dart';

class WeeklyChallengeParticipantsScreen extends ConsumerWidget {
  const WeeklyChallengeParticipantsScreen({super.key, required this.challengeId});
  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(challengeParticipantsProvider(challengeId));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(
        title: 'Participantes',
        showStaffSignOut: true,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.white)),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Ainda não há participantes neste desafio.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          final done = list
              .where((p) => p.status == ParticipationStatus.completed)
              .length;
          final percent = list.isEmpty ? 0 : (done / list.length * 100).round();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${list.length} participantes · $percent% concluíram',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = list[i];
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      title: Text(
                        p.displayName.isEmpty ? 'Aluna' : p.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${p.status.label} · ${p.completedCount} dias',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        p.status == ParticipationStatus.completed ? '🏅' : '',
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
