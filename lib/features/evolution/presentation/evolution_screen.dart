import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/mascot/mascot_widget.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/quick_access_tile.dart';
import '../../../models/app_user.dart';
import '../../ai_trainer/domain/trainer_engine.dart';
import '../../ai_trainer/providers/ai_trainer_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../calendar/providers/calendar_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../health_sync/domain/health_models.dart';
import '../../health_sync/providers/health_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../nutrition/domain/nutrition_models.dart';
import '../../nutrition/providers/water_log_providers.dart';
import '../providers/measurement_history_providers.dart';
import '../providers/weight_history_providers.dart';

/// ============================================================================
/// ACOMPANHAMENTO / PROGRESSO
///
/// Princípio seguido em toda a tela: **nenhum dado é inventado**. Peso,
/// medidas, água, treinos, sequência e hábitos vêm todos de providers reais
/// já usados no resto do app. Quando não há dado suficiente (ex.: gráfico
/// com poucas pesagens, sem wearable conectado), a tela mostra exatamente o
/// que existe — nunca preenche com números fictícios.
/// ============================================================================

/// Meta diária de passos usada só como referência geral (o app ainda não
/// tem uma meta de passos personalizada por usuária em nenhum outro lugar).
const _defaultStepsGoal = 8000;

enum _Period { dias7, dias30, meses3, meses6, ano1, tudo }

extension _PeriodX on _Period {
  String get label => switch (this) {
        _Period.dias7 => 'Últimos 7 dias',
        _Period.dias30 => 'Últimos 30 dias',
        _Period.meses3 => '3 meses',
        _Period.meses6 => '6 meses',
        _Period.ano1 => '1 ano',
        _Period.tudo => 'Todo o período',
      };

  int? get days => switch (this) {
        _Period.dias7 => 7,
        _Period.dias30 => 30,
        _Period.meses3 => 90,
        _Period.meses6 => 180,
        _Period.ano1 => 365,
        _Period.tudo => null,
      };
}

class EvolutionScreen extends ConsumerStatefulWidget {
  const EvolutionScreen({super.key});

  @override
  ConsumerState<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends ConsumerState<EvolutionScreen> {
  _Period _period = _Period.dias7;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    // Todos os dados são locais (SharedPreferences/providers já carregados
    // no boot do app) — o skeleton só suaviza o primeiro frame, seguindo o
    // mesmo padrão de estados usado em Treinos/Receitas.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _abrirFiltroPeriodo() async {
    final result = await showModalBottomSheet<_Period>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Período',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
            ),
            for (final p in _Period.values)
              ListTile(
                title: Text(p.label,
                    style: const TextStyle(color: Colors.white)),
                trailing: p == _period
                    ? const Icon(Icons.check, color: AppColors.secondary)
                    : null,
                onTap: () => Navigator.pop(ctx, p),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result != null && mounted) setState(() => _period = result);
  }

  Future<void> _registrarPeso(AppUser user) async {
    final pesoController = TextEditingController(
        text: user.currentWeight?.toStringAsFixed(1) ?? '');
    final obsController = TextEditingController();
    DateTime dataEscolhida = DateTime.now();
    String? erro;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registrar peso', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: pesoController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Peso',
                  suffixText: 'kg',
                  errorText: erro,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dataEscolhida,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModalState(() => dataEscolhida = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data'),
                  child: Text(DateFormatBr.data(dataEscolhida),
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: obsController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration:
                    const InputDecoration(labelText: 'Observação (opcional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final raw = pesoController.text.trim().replaceAll(',', '.');
                        if (raw.isEmpty) {
                          setModalState(() => erro = 'Informe um peso.');
                          return;
                        }
                        final v = double.tryParse(raw);
                        if (v == null) {
                          setModalState(() => erro = 'Valor inválido.');
                          return;
                        }
                        if (v <= 0) {
                          setModalState(
                              () => erro = 'O peso não pode ser negativo ou zero.');
                          return;
                        }
                        if (v < 20 || v > 400) {
                          setModalState(
                              () => erro = 'Informe um peso entre 20 kg e 400 kg.');
                          return;
                        }
                        Navigator.pop(ctx, true);
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );

    if (ok != true) {
      pesoController.dispose();
      obsController.dispose();
      return;
    }

    final v = double.parse(pesoController.text.trim().replaceAll(',', '.'));
    final nota = obsController.text.trim().isEmpty ? null : obsController.text.trim();
    pesoController.dispose();
    obsController.dispose();

    await ref
        .read(weightHistoryProvider.notifier)
        .add(v, date: dataEscolhida, note: nota);
    await ref.read(profileUpdaterProvider)(user.copyWith(currentWeight: v));
    ref.read(missionsProvider.notifier).report(MissionEvent.pesoRegistrado);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peso registrado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final fullHistory = ref.watch(weightHistoryProvider);
    final gam = ref.watch(gamificationProvider);
    final missions = ref.watch(missionsProvider);
    final trainerProfile = ref.watch(trainerProfileProvider);
    final medidas = ref.watch(measurementHistoryProvider);
    final glasses = ref.watch(waterLogProvider);
    final healthSnap = ref.watch(healthSummaryProvider);
    final taxaHabitos = ref.watch(calendarCompletionRateProvider);

    List<WeightEntry> periodHistory = const [];
    double? variation;
    bool hasError = false;
    if (!_loading) {
      try {
        final days = _period.days;
        periodHistory = days == null
            ? fullHistory
            : fullHistory
                .where((e) =>
                    e.date.isAfter(DateTime.now().subtract(Duration(days: days))))
                .toList();
        if (periodHistory.length >= 2) {
          variation = periodHistory.last.weight -
              periodHistory[periodHistory.length - 2].weight;
        }
      } catch (_) {
        hasError = true;
      }
    }
    _error = hasError;

    final currentWeight =
        fullHistory.isNotEmpty ? fullHistory.last.weight : user.currentWeight;
    final semDadosDePeso = fullHistory.isEmpty && user.currentWeight == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _error
            ? _ErrorState(onRetry: () => setState(() => _error = false))
            : _loading
                ? const _LoadingSkeleton()
                : semDadosDePeso
                    ? _EmptyProgressState(
                        onRegister: () => _registrarPeso(user))
                    : AppPage(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          _Header(
                            period: _period,
                            onFilterTap: _abrirFiltroPeriodo,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Acompanhe sua transformação!',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 64,
                                height: 64,
                                child: LiliFitMascot(
                                  pose: MascotePose.forte,
                                  height: 64,
                                  fit: BoxFit.contain,
                                  blackBackdrop: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _WeightCard(
                            currentWeight: currentWeight,
                            variation: variation,
                            history: periodHistory,
                            objetivo: trainerProfile.objetivo,
                            goalWeight: user.goalWeight,
                          ),
                          const SizedBox(height: 12),
                          PressableScale(
                            onTap: () => _registrarPeso(user),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                gradient: AppColors.heroPinkGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('Registrar peso',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          QuickAccessTile(
                            icon: Icons.straighten,
                            iconAsset: AppIcons.bmiMeasure,
                            title: 'Medidas',
                            subtitle: medidas.isEmpty
                                ? 'Nenhuma medida ainda'
                                : 'Atualizado em ${DateFormatBr.data(medidas.last.date)}',
                            accent: AppColors.primary,
                            showChevron: true,
                            onTap: () => context.push(Routes.measurements),
                          ),
                          const SizedBox(height: 6),
                          QuickAccessTile(
                            icon: Icons.photo_camera_back_outlined,
                            iconAsset: AppIcons.beforeAfter,
                            title: 'Fotos',
                            subtitle: 'Evolução corporal · privada',
                            accent: AppColors.secondary,
                            showChevron: true,
                            onTap: () => context.push(Routes.progressPhotos),
                          ),
                          const SizedBox(height: 6),
                          QuickAccessTile(
                            icon: Icons.insert_chart_outlined,
                            iconAsset: AppIcons.evolution,
                            title: 'Relatórios',
                            subtitle: 'Veja seus resultados',
                            accent: AppColors.info,
                            showChevron: true,
                            onTap: () => context.push(Routes.reports),
                          ),
                          const SizedBox(height: 6),
                          QuickAccessTile(
                            icon: Icons.fitness_center_outlined,
                            iconAsset: AppIcons.workout,
                            title: 'Histórico de cargas',
                            subtitle: 'Última, maior, média e evolução',
                            accent: AppColors.primary,
                            showChevron: true,
                            onTap: () => context.push(Routes.loadHistory),
                          ),
                          const SizedBox(height: 6),
                          QuickAccessTile(
                            icon: Icons.emoji_events_outlined,
                            iconAsset: AppIcons.trophy,
                            title: 'Meus Recordes',
                            subtitle: 'Carga, corrida, sequência',
                            accent: AppColors.warning,
                            showChevron: true,
                            onTap: () => context.push(Routes.personalRecords),
                          ),
                          const SizedBox(height: 18),
                          Text('Resumo do progresso',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          _ResumoGrid(user: user, gam: gam, missions: missions),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Minhas metas',
                                  style: Theme.of(context).textTheme.titleMedium),
                              TextButton(
                                onPressed: () => context.push(Routes.goals),
                                child: const Text('Editar metas'),
                              ),
                            ],
                          ),
                          _MetasSection(
                            user: user,
                            trainerProfile: trainerProfile,
                            missions: missions,
                            glasses: glasses,
                            healthSnap: healthSnap,
                            taxaHabitos: taxaHabitos,
                          ),
                          const SizedBox(height: 24),
                          Text('Conquistas recentes',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          _ConquistasSection(
                            user: user,
                            gam: gam,
                            glasses: glasses,
                          ),
                          ],
                        ),
                      ),
      ),
    );
  }
}

// ============================================================================
// CABEÇALHO
// ============================================================================
class _Header extends StatelessWidget {
  const _Header({required this.period, required this.onFilterTap});
  final _Period period;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Acompanhamento',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20)),
                const SizedBox(height: 2),
                Text('Hoje, ${DateFormatBr.diaMesCompleto(DateTime.now())}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                Text(period.label,
                    style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          PressableScale(
            onTap: onFilterTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CARD DE PESO + GRÁFICO
// ============================================================================
class _WeightCard extends StatelessWidget {
  const _WeightCard({
    required this.currentWeight,
    required this.variation,
    required this.history,
    required this.objetivo,
    this.goalWeight,
  });

  final double? currentWeight;
  final double? variation;
  final List<WeightEntry> history;
  final Objetivo objetivo;
  final double? goalWeight;

  @override
  Widget build(BuildContext context) {
    final favoravelSeDiminuiu = objetivo != Objetivo.ganharMassa;
    Color variationColor = AppColors.textSecondary;
    String variationLabel = '—';
    if (variation != null && variation!.abs() >= 0.05) {
      final isReducao = variation! < 0;
      final isFavoravel = favoravelSeDiminuiu ? isReducao : !isReducao;
      variationColor = isFavoravel ? AppColors.success : AppColors.danger;
      variationLabel =
          '${variation! > 0 ? '+' : ''}${variation!.toStringAsFixed(1)} kg';
    } else if (variation != null) {
      variationLabel = '0,0 kg';
    }

    final metaProgress = (currentWeight != null &&
            goalWeight != null &&
            history.isNotEmpty &&
            history.first.weight != goalWeight)
        ? ((history.first.weight - currentWeight!) /
                (history.first.weight - goalWeight!))
            .clamp(0.0, 1.0)
        : null;

    return FadeInUp(
      delayMs: 60,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        decoration: BoxDecoration(
          gradient: AppColors.softCardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Peso atual',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12.5)),
                ),
                if (goalWeight != null)
                  Text(
                    'Meta ${goalWeight!.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    currentWeight != null
                        ? '${currentWeight!.toStringAsFixed(1)} kg'
                        : '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28)),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: variationColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(variationLabel,
                        style: TextStyle(
                            color: variationColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ),
              ],
            ),
            if (metaProgress != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: metaProgress,
                  minHeight: 5,
                  backgroundColor: AppColors.surface2,
                  color: AppColors.secondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: history.length < 2
                  ? _ChartFallback(pointCount: history.length)
                  : _WeightChart(history: history),
            ),
            if (history.length >= 2 && history.length < 7)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Registre mais pesagens para completar o gráfico.',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Histórico — deslize para excluir',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
              const SizedBox(height: 6),
              for (var i = history.length - 1; i >= 0; i--)
                _WeightHistoryTile(entry: history[i], index: i),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeightHistoryTile extends ConsumerWidget {
  const _WeightHistoryTile({required this.entry, required this.index});
  final WeightEntry entry;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('w_${entry.date.toIso8601String()}_$index'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Excluir pesagem?'),
                content: Text(
                  '${entry.weight.toStringAsFixed(1)} kg em ${DateFormatBr.data(entry.date)}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Excluir'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        color: AppColors.danger.withValues(alpha: 0.35),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(weightHistoryProvider.notifier).removeEntry(entry),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormatBr.data(entry.date),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
            Text(
              '${entry.weight.toStringAsFixed(1)} kg',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartFallback extends StatelessWidget {
  const _ChartFallback({required this.pointCount});
  final int pointCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart, color: AppColors.textTertiary, size: 36),
          const SizedBox(height: 8),
          Text(
            pointCount == 0
                ? 'Nenhuma pesagem registrada neste período.'
                : 'Registre mais pesagens para completar o gráfico.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.history});
  final List<WeightEntry> history;

  static const _letters = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].weight),
    ];
    final showWeekdayLabels = history.length <= 7;
    final minY = history.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxY = history.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY).abs() < 1 ? 1.0 : (maxY - minY) * 0.2;

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(0),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= history.length) return const SizedBox.shrink();
                final label = showWeekdayLabels
                    ? _letters[history[i].date.weekday - 1]
                    : '${history[i].date.day}/${history[i].date.month}';
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(label,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 9)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary.withOpacity(0.3),
                  AppColors.secondary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RESUMO DO PROGRESSO
// ============================================================================
class _ResumoGrid extends ConsumerWidget {
  const _ResumoGrid({required this.user, required this.gam, required this.missions});
  final AppUser user;
  final GamificationState gam;
  final MissionsState missions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diasAtivos =
        missions.history.map((r) => '${r.date.year}-${r.date.month}-${r.date.day}').toSet().length;

    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: [
        _ResumoTile(
            label: 'Peso inicial',
            value: user.startWeight != null
                ? '${user.startWeight!.toStringAsFixed(1)} kg'
                : '—'),
        _ResumoTile(
            label: 'Peso atual',
            value: user.currentWeight != null
                ? '${user.currentWeight!.toStringAsFixed(1)} kg'
                : '—'),
        _ResumoTile(
            label: 'Meta de peso',
            value: user.goalWeight != null
                ? '${user.goalWeight!.toStringAsFixed(0)} kg'
                : '—'),
        _ResumoTile(
            label: 'Evolução',
            value: user.lostWeight != null
                ? '${user.lostWeight! >= 0 ? '-' : '+'}${user.lostWeight!.abs().toStringAsFixed(1)} kg'
                : '—',
            color: user.lostWeight != null
                ? (user.lostWeight! >= 0 ? AppColors.success : AppColors.danger)
                : null),
        _ResumoTile(label: 'Dias ativos', value: '$diasAtivos'),
        _ResumoTile(label: 'Treinos concluídos', value: '${user.totalWorkouts}'),
        FutureBuilder<Map<DateTime, int>>(
          future: WaterLogNotifier.history(7),
          builder: (context, snap) {
            String value = '—';
            if (snap.hasData && snap.data!.isNotEmpty) {
              final media = snap.data!.values.reduce((a, b) => a + b) /
                  snap.data!.length;
              value =
                  '${(media * WaterCalculator.mlPerGlass / 1000).toStringAsFixed(1)} L';
            }
            return _ResumoTile(label: 'Média de água', value: value);
          },
        ),
        _ResumoTile(label: 'Sequência atual', value: '${gam.streak} dias'),
      ],
    );
  }
}

class _ResumoTile extends StatelessWidget {
  const _ResumoTile({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppColors.softCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.border.withOpacity(0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 10.5)),
        ],
      ),
    );
  }
}

// ============================================================================
// MINHAS METAS
// ============================================================================
class _MetasSection extends ConsumerWidget {
  const _MetasSection({
    required this.user,
    required this.trainerProfile,
    required this.missions,
    required this.glasses,
    required this.healthSnap,
    required this.taxaHabitos,
  });

  final AppUser user;
  final TrainerProfile trainerProfile;
  final MissionsState missions;
  final int glasses;
  final HealthSnapshot? healthSnap;
  final double taxaHabitos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final segunda = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final treinosSemana = missions.history
        .where((r) => r.id == 'd_treino' && !r.date.isBefore(segunda))
        .length;
    final metaTreinos = trainerProfile.diasPorSemana;

    final metaAgua =
        ref.watch(waterDayProvider).effectiveGoalGlasses(user.currentWeight);

    final passos = healthSnap?.get(HealthMetric.passos);

    double? pesoProgresso;
    if (user.startWeight != null &&
        user.goalWeight != null &&
        user.currentWeight != null &&
        user.startWeight != user.goalWeight) {
      pesoProgresso = ((user.currentWeight! - user.startWeight!) /
              (user.goalWeight! - user.startWeight!))
          .clamp(0.0, 1.0)
          .toDouble();
    }

    return Column(
      children: [
        if (pesoProgresso != null)
          _MetaTile(
            label: 'Meta de peso',
            atual: '${user.currentWeight!.toStringAsFixed(1)} kg',
            meta: '${user.goalWeight!.toStringAsFixed(0)} kg',
            progress: pesoProgresso,
          ),
        _MetaTile(
          label: 'Meta semanal de treinos',
          atual: '$treinosSemana',
          meta: '$metaTreinos treino(s)',
          progress: metaTreinos > 0
              ? (treinosSemana / metaTreinos).clamp(0.0, 1.0).toDouble()
              : 0,
        ),
        _MetaTile(
          label: 'Meta diária de água',
          atual: '$glasses copo(s)',
          meta: '$metaAgua copo(s)',
          progress:
              metaAgua > 0 ? (glasses / metaAgua).clamp(0.0, 1.0).toDouble() : 0,
        ),
        if (passos != null)
          _MetaTile(
            label: 'Meta de passos',
            atual: passos.toStringAsFixed(0),
            meta: '$_defaultStepsGoal',
            progress: (passos / _defaultStepsGoal).clamp(0.0, 1.0).toDouble(),
          )
        else
          const _MetaUnavailable(
              label: 'Meta de passos',
              reason: 'Conecte um wearable em Saúde para acompanhar.'),
        _MetaTile(
          label: 'Meta de hábitos',
          atual: '${(taxaHabitos * 100).round()}%',
          meta: '100%',
          progress: taxaHabitos.clamp(0.0, 1.0),
        ),
      ],
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.label,
    required this.atual,
    required this.meta,
    required this.progress,
  });
  final String label;
  final String atual;
  final String meta;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Text('${(progress * 100).round()}%',
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedProgressBar(value: progress, color: AppColors.secondary),
          const SizedBox(height: 6),
          Text('$atual / $meta',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MetaUnavailable extends StatelessWidget {
  const _MetaUnavailable({required this.label, required this.reason});
  final String label;
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.watch_outlined, color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(reason,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CONQUISTAS RECENTES
// ============================================================================
class _ConquistasSection extends ConsumerWidget {
  const _ConquistasSection({
    required this.user,
    required this.gam,
    required this.glasses,
  });
  final AppUser user;
  final GamificationState gam;
  final int glasses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metaAgua =
        ref.watch(waterDayProvider).effectiveGoalGlasses(user.currentWeight);
    final conquistas = <String>[
      if (user.totalWorkouts >= 1) 'Primeiro treino concluído',
      if (gam.streak >= 7) '7 dias de sequência',
      if ((user.lostWeight ?? 0) > 0)
        '${user.lostWeight!.toStringAsFixed(1)} kg eliminados',
      if (metaAgua > 0 && glasses >= metaAgua) 'Meta de água cumprida',
      if (user.totalWorkouts >= 10) '10 treinos concluídos',
    ];

    if (conquistas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: const Text(
            'Continue avançando. Sua próxima conquista está perto.',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in conquistas.take(5))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Text(c,
                style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ============================================================================
// ESTADOS
// ============================================================================
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: const [
        SkeletonBox(height: 50, radius: 12),
        SizedBox(height: 16),
        SkeletonBox(height: 260, radius: AppTheme.radius),
        SizedBox(height: 16),
        SkeletonBox(height: 56, radius: 20),
        SizedBox(height: 24),
        SkeletonBox(height: 70, radius: AppTheme.radius),
        SizedBox(height: 10),
        SkeletonBox(height: 70, radius: AppTheme.radius),
        SizedBox(height: 10),
        SkeletonBox(height: 70, radius: AppTheme.radius),
      ],
    );
  }
}

class _EmptyProgressState extends StatelessWidget {
  const _EmptyProgressState({required this.onRegister});
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconImage(
              AppIcons.weight,
              size: 56,
              fallbackIcon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 16),
            const Text(
                'Comece registrando seu peso para acompanhar sua evolução.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            PressableScale(
              onTap: onRegister,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Registrar primeiro peso',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            const Text('Não foi possível carregar seu progresso.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: AppIconImage(AppIcons.retry, size: 20,
                  fallbackIcon: Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
