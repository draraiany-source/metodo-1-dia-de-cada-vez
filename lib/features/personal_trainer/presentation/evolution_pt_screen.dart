import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';

class EvolutionPtScreen extends ConsumerWidget {
  const EvolutionPtScreen({super.key, required this.student});
  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(ptAssessmentsProvider(student.id));
    final photosAsync = ref.watch(ptPhotosProvider(student.id));
    final sessionsAsync = ref.watch(ptSessionsProvider(student.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Evolução · ${student.name.split(' ').first}',
        showStaffSignOut: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: AppIconImage(
              AppIcons.evolution,
              size: 26,
              fallbackIcon: Icons.show_chart,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            assessmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Não consegui carregar.',
                  style: TextStyle(color: AppColors.textSecondary)),
              data: (list) {
                if (list.length < 2) {
                  return const _EmptyCard(
                    'Pelo menos 2 avaliações são necessárias pra mostrar '
                    'o gráfico de evolução.',
                    iconAsset: AppIcons.bmiMeasure,
                    fallbackIcon: Icons.straighten,
                  );
                }
                return Column(
                  children: [
                    _ChartCard(
                      title: 'Peso (kg)',
                      iconAsset: AppIcons.weight,
                      fallbackIcon: Icons.monitor_weight_outlined,
                      values: list
                          .where((a) => a.weightKg != null)
                          .map((a) => a.weightKg!)
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: '% de gordura',
                      iconAsset: AppIcons.bmiMeasure,
                      fallbackIcon: Icons.percent,
                      values: list
                          .where((a) => a.bodyFatPercent != null)
                          .map((a) => a.bodyFatPercent!)
                          .toList(),
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'Massa muscular (kg)',
                      iconAsset: AppIcons.workout,
                      fallbackIcon: Icons.fitness_center,
                      values: list
                          .where((a) => a.muscleMassKg != null)
                          .map((a) => a.muscleMassKg!)
                          .toList(),
                      color: AppColors.success,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            sessionsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (sessions) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBlock(
                        label: 'Treinos realizados',
                        value: '${sessions.length}',
                        iconAsset: AppIcons.workout,
                        fallbackIcon: Icons.fitness_center,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _StatBlock(
                        label: 'Dias ativos',
                        value:
                            '${sessions.map((s) => '${s.date.year}-${s.date.month}-${s.date.day}').toSet().length}',
                        iconAsset: AppIcons.calendar,
                        fallbackIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                AppIconImage(
                  AppIcons.beforeAfter,
                  size: 22,
                  fallbackIcon: Icons.photo_library_outlined,
                ),
                SizedBox(width: 8),
                Text(
                  'Fotos de evolução',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            photosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Não consegui carregar.',
                  style: TextStyle(color: AppColors.textSecondary)),
              data: (photos) {
                if (photos.length < 2) {
                  return const _EmptyCard(
                    'Pelo menos 2 fotos são necessárias pra comparar '
                    'antes e depois.',
                    iconAsset: AppIcons.gallery,
                    fallbackIcon: Icons.photo_library_outlined,
                  );
                }
                final antes = photos.first;
                final depois = photos.last;
                return Row(
                  children: [
                    Expanded(child: _FotoComData('Antes', antes)),
                    const SizedBox(width: 12),
                    Expanded(child: _FotoComData('Agora', depois)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.values,
    required this.iconAsset,
    required this.fallbackIcon,
    this.color = AppColors.primary,
  });
  final String title;
  final List<double> values;
  final String iconAsset;
  final IconData fallbackIcon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconImage(
                iconAsset,
                size: 20,
                fallbackIcon: fallbackIcon,
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 34)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < values.length; i++)
                        FlSpot(i.toDouble(), values[i]),
                    ],
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.iconAsset,
    required this.fallbackIcon,
  });
  final String label;
  final String value;
  final String iconAsset;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppIconImage(
          iconAsset,
          size: 22,
          fallbackIcon: fallbackIcon,
        ),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _FotoComData extends StatelessWidget {
  const _FotoComData(this.label, this.foto);
  final String label;
  final EvolutionPhoto foto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.network(
              foto.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surface2,
                alignment: Alignment.center,
                child: const AppIconImage(
                  AppIcons.gallery,
                  size: 32,
                  fallbackIcon: Icons.broken_image_outlined,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(
    this.text, {
    required this.iconAsset,
    required this.fallbackIcon,
  });
  final String text;
  final String iconAsset;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppIconImage(
            iconAsset,
            size: 28,
            fallbackIcon: fallbackIcon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
