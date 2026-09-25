import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../calendar/providers/calendar_providers.dart';
import '../../evolution/providers/weight_history_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../nutrition/providers/food_log_providers.dart';
import '../../nutrition/providers/water_log_providers.dart';
import '../../running/providers/running_providers.dart';

enum DashboardPeriod { dia, semana, mes, ano }

extension on DashboardPeriod {
  int get days => switch (this) {
        DashboardPeriod.dia => 1,
        DashboardPeriod.semana => 7,
        DashboardPeriod.mes => 30,
        DashboardPeriod.ano => 365,
      };
  String get label => switch (this) {
        DashboardPeriod.dia => 'Dia',
        DashboardPeriod.semana => 'Semana',
        DashboardPeriod.mes => 'Mês',
        DashboardPeriod.ano => 'Ano',
      };
}

class PremiumDashboardScreen extends ConsumerStatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  ConsumerState<PremiumDashboardScreen> createState() =>
      _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState
    extends ConsumerState<PremiumDashboardScreen> {
  DashboardPeriod _periodo = DashboardPeriod.semana;
  Map<DateTime, int> _aguaHist = {};
  Map<DateTime, int> _kcalHist = {};
  bool _loadingHist = true;

  @override
  void initState() {
    super.initState();
    _carregarHistoricos();
  }

  Future<void> _carregarHistoricos() async {
    setState(() => _loadingHist = true);
    final agua = await WaterLogNotifier.history(_periodo.days);
    final kcal = await foodKcalHistory(_periodo.days);
    if (!mounted) return;
    setState(() {
      _aguaHist = agua;
      _kcalHist = kcal;
      _loadingHist = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final gamification = ref.watch(gamificationProvider);
    final pesoHist = ref.watch(weightHistoryProvider);
    final taxaHabitos = ref.watch(calendarCompletionRateProvider);
    final macros = ref.watch(todayMacrosProvider);
    final runningAsync = ref.watch(runningHistoryProvider(user.id));

    final desde = DateTime.now().subtract(Duration(days: _periodo.days));
    final pesoFiltrado =
        pesoHist.where((e) => e.date.isAfter(desde)).toList();

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Dashboard Premium 👑'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            SizedBox(
              height: 36,
              child: Row(
                children: DashboardPeriod.values.map((p) {
                  final sel = p == _periodo;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.label),
                      selected: sel,
                      onSelected: (_) {
                        setState(() => _periodo = p);
                        _carregarHistoricos();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Resumo rápido: XP, nível, streak, km total
            Row(
              children: [
                _StatCard(
                    label: 'Nível',
                    value: '${gamification.level}',
                    color: AppColors.primary),
                const SizedBox(width: 10),
                _StatCard(
                    label: 'XP',
                    value: '${gamification.xp}',
                    color: AppColors.secondary),
                const SizedBox(width: 10),
                _StatCard(
                    label: 'Sequência',
                    value: '${gamification.streak}d',
                    color: AppColors.warning),
                const SizedBox(width: 10),
                _StatCard(
                    label: 'Km totais',
                    value: user.totalKm.toStringAsFixed(1),
                    color: AppColors.success),
              ],
            ),
            const SizedBox(height: 24),

            _SectionCard(
              title: '⚖️ Peso & IMC',
              child: pesoFiltrado.length < 2
                  ? const _EmptyHint('Registre seu peso algumas vezes '
                      'pra ver a evolução aqui.')
                  : SizedBox(
                      height: 160,
                      child: _LineChart(
                        values: pesoFiltrado.map((e) => e.weight).toList(),
                      ),
                    ),
              footer: user.bmi != null
                  ? 'IMC atual: ${user.bmi!.toStringAsFixed(1)} (${user.bmiLabel})'
                  : null,
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: '💧 Água',
              child: _loadingHist
                  ? const _LoadingHint()
                  : SizedBox(
                      height: 140,
                      child: _BarChart(
                        values: _aguaHist.values
                            .map((v) => v.toDouble())
                            .toList(),
                      ),
                    ),
              footer:
                  'Média: ${_aguaHist.isEmpty ? '—' : (_aguaHist.values.reduce((a, b) => a + b) / _aguaHist.length).toStringAsFixed(1)} copos/dia',
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: '🔥 Calorias & macros',
              child: _loadingHist
                  ? const _LoadingHint()
                  : SizedBox(
                      height: 140,
                      child: _BarChart(
                        values: _kcalHist.values
                            .map((v) => v.toDouble())
                            .toList(),
                        color: AppColors.secondary,
                      ),
                    ),
              footer:
                  'Hoje: ${macros.$1}g proteína · ${macros.$2}g carbo · ${macros.$3}g gordura',
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: '🏃 Corridas',
              child: runningAsync.when(
                loading: () => const _LoadingHint(),
                error: (_, __) => const _EmptyHint('Não consegui carregar.'),
                data: (sessions) {
                  final filtradas =
                      sessions.where((s) => s.date.isAfter(desde)).toList();
                  if (filtradas.isEmpty) {
                    return const _EmptyHint(
                        'Nenhuma corrida registrada neste período.');
                  }
                  final totalKm = filtradas.fold<double>(
                      0, (s, r) => s + r.distanceKm);
                  final totalKcal =
                      filtradas.fold<int>(0, (s, r) => s + r.kcal);
                  return Row(
                    children: [
                      _StatCard(
                          label: 'Corridas',
                          value: '${filtradas.length}',
                          color: AppColors.secondary),
                      const SizedBox(width: 10),
                      _StatCard(
                          label: 'Km',
                          value: totalKm.toStringAsFixed(1),
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      _StatCard(
                          label: 'Kcal',
                          value: '$totalKcal',
                          color: AppColors.warning),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              title: '✅ Hábitos & calendário',
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: taxaHabitos,
                    backgroundColor: AppColors.background,
                    color: AppColors.success,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(taxaHabitos * 100).toStringAsFixed(0)}% de conclusão nos últimos 30 dias',
                    style: const TextStyle(color: AppColors.textSecondary),
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

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.footer});
  final String title;
  final Widget child;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(footer!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(text,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
    );
  }
}

class _LoadingHint extends StatelessWidget {
  const _LoadingHint();
  @override
  Widget build(BuildContext context) => const SizedBox(
      height: 60,
      child: Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))));
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            gradient: AppColors.vibeGradient,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, this.color = AppColors.info});
  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const _EmptyHint('Sem dados neste período.');
    final maxV = values.reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxV == 0 ? 1 : maxV * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                  toY: values[i],
                  color: color,
                  width: 10,
                  borderRadius: BorderRadius.circular(4)),
            ]),
        ],
      ),
    );
  }
}
