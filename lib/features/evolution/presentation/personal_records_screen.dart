import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mascot/lily_catalog.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/lily_journey_complete_sheet.dart';
import '../domain/personal_records.dart';
import '../providers/load_stats_providers.dart';

/// Celebração discreta da Lily — o mesmo sheet já usado em áudios/meditação.
Future<void> celebrarRecordeDeCarga(
  BuildContext context, {
  required String exercicio,
  required String cargaLabel,
}) {
  return showLilyJourneyCompleteSheet(
    context,
    situation: LilySituation.celebrating,
    message: 'Novo recorde!\n$exercicio\n$cargaLabel',
    buttonLabel: 'Continuar',
  );
}

class PersonalRecordsScreen extends ConsumerWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(personalRecordsBoardProvider);
    final cargas = ref.watch(myLoadHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Meus Recordes',
        actions: [
          IconButton(
            tooltip: 'Histórico de cargas',
            onPressed: () => context.push(Routes.loadHistory),
            icon: const Icon(Icons.fitness_center_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: cargas.isLoading
            ? const AppListSkeleton()
            : board.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: AppEmptyState(
                      title: 'Seus recordes aparecem aqui',
                      message:
                          'Treine, registre a carga, corra. Cada marca pessoal '
                          'entra sozinha — sem cobrança, só o registro do que você já fez.',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      const Text(
                        'Marcas pessoais, um dia de cada vez.',
                        style: TextStyle(
                            color: AppColors.textSecondary, height: 1.35),
                      ),
                      const SizedBox(height: 16),
                      for (final rec in board.items) ...[
                        _RecordeCard(recorde: rec),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
      ),
    );
  }
}

class _RecordeCard extends StatelessWidget {
  const _RecordeCard({required this.recorde});
  final PersonalRecord recorde;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icone(recorde.kind), color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recorde.label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  recorde.valueLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                if (recorde.detail.isNotEmpty || recorde.at != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      [
                        if (recorde.detail.isNotEmpty) recorde.detail,
                        if (recorde.at != null) DateFormatBr.data(recorde.at!),
                      ].join(' · '),
                      style: const TextStyle(
                          color: AppColors.textTertiary, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icone(PersonalRecordKind k) => switch (k) {
        PersonalRecordKind.maiorCarga => Icons.fitness_center,
        PersonalRecordKind.maisRepeticoes => Icons.repeat,
        PersonalRecordKind.maiorDistancia => Icons.route_outlined,
        PersonalRecordKind.melhorPace => Icons.speed,
        PersonalRecordKind.treinoMaisLongo => Icons.timer_outlined,
        PersonalRecordKind.maiorSequencia => Icons.local_fire_department,
        PersonalRecordKind.maisTreinosNaSemana => Icons.calendar_view_week,
      };
}
