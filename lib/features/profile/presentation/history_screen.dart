import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../evolution/providers/measurement_history_providers.dart';
import '../../evolution/providers/weight_history_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';

enum _Period { hoje, dias7, dias30, tudo }

extension on _Period {
  String get label => switch (this) {
        _Period.hoje => 'Hoje',
        _Period.dias7 => '7 dias',
        _Period.dias30 => '30 dias',
        _Period.tudo => 'Todo o período',
      };
  int? get days =>
      switch (this) { _Period.hoje => 1, _Period.dias7 => 7, _Period.dias30 => 30, _Period.tudo => null };
}

class _HistoryItem {
  const _HistoryItem(this.date, this.icon, this.text, this.color);
  final DateTime date;
  final IconData icon;
  final String text;
  final Color color;
}

/// Histórico — junta os eventos reais já registrados em outras partes do
/// app (missões concluídas, pesagens, medidas) numa única linha do tempo
/// filtrável por período. Não cria nenhum registro novo — só lê e organiza
/// o que já existe.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Period _period = _Period.dias7;

  static const _missionIcons = {
    'd_treino': (Icons.fitness_center, 'Treino concluído', AppColors.primary),
    'd_agua': (Icons.water_drop, 'Meta de água cumprida', AppColors.info),
    'd_refeicao': (Icons.restaurant, 'Refeição registrada', AppColors.warning),
    'd_checkin': (Icons.check_circle, 'Check-in diário', AppColors.success),
  };

  @override
  Widget build(BuildContext context) {
    final missions = ref.watch(missionsProvider);
    final weights = ref.watch(weightHistoryProvider);
    final measurements = ref.watch(measurementHistoryProvider);
    final gam = ref.watch(gamificationProvider);

    final cutoff =
        _period.days == null ? null : DateTime.now().subtract(Duration(days: _period.days!));
    bool inPeriod(DateTime d) => cutoff == null || !d.isBefore(cutoff);

    final items = <_HistoryItem>[
      for (final r in missions.history)
        if (inPeriod(r.date) && _missionIcons.containsKey(r.id))
          _HistoryItem(r.date, _missionIcons[r.id]!.$1, _missionIcons[r.id]!.$2,
              _missionIcons[r.id]!.$3),
      for (final w in weights)
        if (inPeriod(w.date))
          _HistoryItem(w.date, Icons.monitor_weight_outlined,
              'Peso registrado: ${w.weight.toStringAsFixed(1)} kg', AppColors.secondary),
      for (final m in measurements)
        if (inPeriod(m.date))
          _HistoryItem(
              m.date, Icons.straighten, 'Medidas registradas', AppColors.secondary),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('Histórico',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 17)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PressableScale(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(Icons.arrow_back,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _Period.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final p = _Period.values[i];
                    final active = p == _period;
                    return PressableScale(
                      onTap: () => setState(() => _period = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: active ? AppColors.heroPinkGradient : null,
                          color: active ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(p.label,
                            style: TextStyle(
                                color: active ? Colors.white : AppColors.textSecondary,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 12)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_period == _Period.hoje)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _HojeChecklist(
                  treino: missions.history.any((r) =>
                      r.id == 'd_treino' &&
                      r.date.year == DateTime.now().year &&
                      r.date.month == DateTime.now().month &&
                      r.date.day == DateTime.now().day),
                  agua: missions.history.any((r) =>
                      r.id == 'd_agua' &&
                      r.date.year == DateTime.now().year &&
                      r.date.month == DateTime.now().month &&
                      r.date.day == DateTime.now().day),
                  refeicao: missions.history.any((r) =>
                      r.id == 'd_refeicao' &&
                      r.date.year == DateTime.now().year &&
                      r.date.month == DateTime.now().month &&
                      r.date.day == DateTime.now().day),
                  checkin: missions.history.any((r) =>
                      r.id == 'd_checkin' &&
                      r.date.year == DateTime.now().year &&
                      r.date.month == DateTime.now().month &&
                      r.date.day == DateTime.now().day),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                      child: _SummaryChip(
                          label: 'Sequência atual', value: '${gam.streak} dias')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _SummaryChip(
                          label: 'Eventos no período', value: '${items.length}')),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LiliMascot(pose: MascotePose.triste, height: 100),
                            const SizedBox(height: 16),
                            Text(
                                'Nenhuma atividade registrada ${_period == _Period.tudo ? 'ainda' : 'nesse período'}.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return FadeInUp(
                          delayMs: i * 20,
                          offset: 8,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: item.color.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(item.icon, color: item.color, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(item.text,
                                      style: const TextStyle(color: Colors.white)),
                                ),
                                Text(DateFormatBr.data(item.date),
                                    style: const TextStyle(
                                        color: AppColors.textTertiary, fontSize: 11)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _HojeChecklist extends StatelessWidget {
  const _HojeChecklist({
    required this.treino,
    required this.agua,
    required this.refeicao,
    required this.checkin,
  });

  final bool treino;
  final bool agua;
  final bool refeicao;
  final bool checkin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoje',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _check('Treino', treino),
              _check('Água', agua),
              _check('Refeição', refeicao),
              _check('Check-in', checkin),
            ],
          ),
        ],
      ),
    );
  }

  Widget _check(String label, bool done) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: done ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: done ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
