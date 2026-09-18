import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../domain/training_volume.dart';

class ExerciseLoadDetailScreen extends StatelessWidget {
  const ExerciseLoadDetailScreen({super.key, required this.stats});
  final ExerciseLoadStats stats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(title: stats.exerciseName),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _Resumo(stats: stats),
            const SizedBox(height: 16),
            Container(
              height: 180,
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: stats.cronologico.length < 2
                  ? const Center(
                      child: Text(
                        'Registre mais uma carga para ver o gráfico.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : _Grafico(stats: stats),
            ),
            const SizedBox(height: 20),
            const Text(
              'Histórico',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15),
            ),
            const SizedBox(height: 8),
            for (final e in stats.cronologico.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 88,
                      child: Text(
                        DateFormatBr.data(e.date),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.5),
                      ),
                    ),
                    Text(
                      TrainingVolume.formatKg(e.weightKg, decimals: 1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    const Spacer(),
                    if (e.series != null && e.repeticoes != null)
                      Text(
                        '${e.series} × ${e.repeticoes}'
                        '${e.volumeKg == null ? '' : ' · ${TrainingVolume.formatVolume(e.volumeKg!)}'}',
                        style: const TextStyle(
                            color: AppColors.textTertiary, fontSize: 12),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.stats});
  final ExerciseLoadStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Tile('Última', stats.lastWeight == null
                  ? '—'
                  : TrainingVolume.formatKg(stats.lastWeight!)),
              _Tile('Maior', stats.maxWeight == null
                  ? '—'
                  : TrainingVolume.formatKg(stats.maxWeight!)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Tile(
                'Média',
                stats.avgWeight == null
                    ? '—'
                    : TrainingVolume.formatKg(stats.avgWeight!, decimals: 1),
              ),
              _Tile(
                'Evolução',
                stats.percentEvolution == null
                    ? '—'
                    : TrainingVolume.formatPercent(stats.percentEvolution!),
                cor: stats.percentEvolution == null
                    ? null
                    : (stats.percentEvolution! >= 0
                        ? AppColors.success
                        : AppColors.danger),
              ),
            ],
          ),
          if (stats.totalVolumeKg != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _Tile('Volume acumulado',
                    TrainingVolume.formatVolume(stats.totalVolumeKg!)),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.rotulo, this.valor, {this.cor});
  final String rotulo;
  final String valor;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo,
              style: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              color: cor ?? Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _Grafico extends StatelessWidget {
  const _Grafico({required this.stats});
  final ExerciseLoadStats stats;

  @override
  Widget build(BuildContext context) {
    final pontos = <FlSpot>[];
    for (var i = 0; i < stats.cronologico.length; i++) {
      pontos.add(FlSpot(i.toDouble(), stats.cronologico[i].weightKg));
    }
    final ys = pontos.map((p) => p.y);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY).abs() < 1 ? 2.0 : (maxY - minY) * 0.15);

    return LineChart(
      LineChartData(
        minY: (minY - pad).clamp(0, double.infinity).toDouble(),
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.borderSoft,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(0),
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 10),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: pontos,
            isCurved: true,
            barWidth: 3,
            color: AppColors.primary,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.18),
            ),
          ),
        ],
      ),
    );
  }
}
