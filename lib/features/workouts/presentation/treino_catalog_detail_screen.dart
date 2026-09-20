import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/youtube_launch.dart';
import '../../../core/widgets/app_page.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import '../../workout_timer/domain/timer_blueprints.dart';
import '../../workout_timer/presentation/workout_timer_screen.dart';
import '../domain/treino_catalog_models.dart';
import '../../../core/lily/lily_treino_image.dart';
import 'treino_catalog_visual.dart';

/// Detalhe de um exercício do catálogo oficial (117 treinos).
class TreinoCatalogDetailScreen extends ConsumerWidget {
  const TreinoCatalogDetailScreen({super.key, required this.treino});

  final TreinoCatalogEntry treino;

  Future<void> _openYoutube(BuildContext context) async {
    await YoutubeLaunch.open(context, treino.linkYoutube);
  }

  Future<void> _markComplete(BuildContext context, WidgetRef ref) async {
    ref.read(gamificationProvider.notifier).addXp(AppConstants.xpPerWorkout);
    ref.read(rewardsProvider.notifier).earn(AppConstants.coinsPerWorkout);
    ref.read(missionsProvider.notifier).report(MissionEvent.treinoConcluido);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Treino concluído! +${AppConstants.xpPerWorkout} XP',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = <(String, String?)>[
      ('Grupo muscular', treinoFieldOrNull(treino.grupoMuscular)),
      ('Equipamento', treinoFieldOrNull(treino.equipamento)),
      ('Nível', treinoFieldOrNull(treino.nivelLabel)),
      ('Prescrição', treinoFieldOrNull(treino.prescricao)),
      ('Intervalo', treinoFieldOrNull(treino.intervalo)),
      ('Objetivo', treinoFieldOrNull(treino.objetivo)),
      ('Observações', treinoFieldOrNull(treino.observacao)),
    ].where((e) => e.$2 != null).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: treino.nome,
        showBack: true,
      ),
      body: AppPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                TreinoSectionIcon(
                  section: treino.visualSection,
                  treino: treino,
                  size: 52,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (treinoFieldOrNull(treino.categoria) != null)
                        Text(
                          treino.categoria!,
                          style: TextStyle(
                            color: AppColors.secondary.withOpacity(0.95),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      if (treino.nivelLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          treino.nivelLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: LilyTreinoImage(
                asset: lilyTreinoAssetFor(treino),
                maxHeight: 280,
                maxWidth: 420,
                semanticLabel: treino.nome,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 20),
            for (final (label, value) in fields) ...[
              _DetailRow(label: label, value: value!),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            if (treino.linkYoutube.trim().isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openYoutube(context),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Assistir vídeo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkoutTimerScreen(
                      blueprint: blueprintFromCatalog(treino),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.timer_outlined),
              label: const Text('INICIAR CRONÔMETRO'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _markComplete(context, ref),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar treino como concluído'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
