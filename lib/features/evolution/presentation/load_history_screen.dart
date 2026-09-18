import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/app_states.dart';
import '../../personal_trainer/providers/pt_providers.dart';
import '../domain/training_volume.dart';
import '../providers/load_stats_providers.dart';
import 'exercise_load_detail_screen.dart';

/// Histórico de cargas por exercício. Não substitui o histórico antigo —
/// só passa a mostrá-lo. A Personal já gravava em `pt_loads`; esta tela
/// é o que faltava para a aluna ver a evolução.
class LoadHistoryScreen extends ConsumerWidget {
  const LoadHistoryScreen({super.key, this.studentId});

  /// Quando a Personal abre o histórico de uma aluna. Null = aluna logada.
  final String? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (studentId != null) {
      final async = ref.watch(ptLoadsProvider(studentId!));
      return _Scaffold(
        child: async.when(
          loading: () => const AppListSkeleton(),
          error: (e, _) => AppErrorState(
            message: 'Não consegui carregar as cargas. $e',
            onRetry: () => ref.invalidate(ptLoadsProvider(studentId!)),
          ),
          data: (cargas) => _Lista(stats: ExerciseLoadStats.group(cargas)),
        ),
      );
    }

    final async = ref.watch(myLoadHistoryProvider);
    return _Scaffold(
      child: async.when(
        loading: () => const AppListSkeleton(),
        error: (e, _) => AppErrorState(
          message: 'Não consegui carregar as cargas. $e',
          onRetry: () => ref.invalidate(myLoadHistoryProvider),
        ),
        data: (cargas) => _Lista(stats: ExerciseLoadStats.group(cargas)),
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Histórico de cargas',
        actions: [
          IconButton(
            tooltip: 'Meus recordes',
            onPressed: () => context.push(Routes.personalRecords),
            icon: const Icon(Icons.emoji_events_outlined),
          ),
        ],
      ),
      body: SafeArea(child: child),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.stats});
  final List<ExerciseLoadStats> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: AppEmptyState(
          title: 'Nenhuma carga ainda',
          message:
              'Quando você registrar a carga no treino, a evolução aparece aqui. '
              'Os registros antigos não se perdem — só passam a ter um lugar para serem vistos.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemCount: stats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _ExercicioCard(stats: stats[i]),
    );
  }
}

class _ExercicioCard extends StatelessWidget {
  const _ExercicioCard({required this.stats});
  final ExerciseLoadStats stats;

  @override
  Widget build(BuildContext context) {
    final last = stats.lastWeight;
    final max = stats.maxWeight;
    final pct = stats.percentEvolution;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExerciseLoadDetailScreen(stats: stats),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats.exerciseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${stats.cronologico.length} '
                '${stats.cronologico.length == 1 ? 'registro' : 'registros'}'
                '${stats.cronologico.isEmpty ? '' : ' · último em ${DateFormatBr.data(stats.cronologico.last.date)}'}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Dado(
                    rotulo: 'Última',
                    valor: last == null ? '—' : TrainingVolume.formatKg(last),
                  ),
                  _Dado(
                    rotulo: 'Maior',
                    valor: max == null ? '—' : TrainingVolume.formatKg(max),
                  ),
                  _Dado(
                    rotulo: 'Média',
                    valor: stats.avgWeight == null
                        ? '—'
                        : TrainingVolume.formatKg(stats.avgWeight!, decimals: 1),
                  ),
                  _Dado(
                    rotulo: 'Evolução',
                    valor: pct == null ? '—' : TrainingVolume.formatPercent(pct),
                    destaque: pct == null
                        ? null
                        : (pct >= 0 ? AppColors.success : AppColors.danger),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  const _Dado({required this.rotulo, required this.valor, this.destaque});
  final String rotulo;
  final String valor;
  final Color? destaque;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 10.5)),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              color: destaque ?? Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
