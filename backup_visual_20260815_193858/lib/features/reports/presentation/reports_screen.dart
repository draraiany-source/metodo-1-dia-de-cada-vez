import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../calendar/providers/calendar_providers.dart';
import '../../evolution/providers/weight_history_providers.dart';
import '../../nutrition/providers/food_log_providers.dart';
import '../../nutrition/providers/water_log_providers.dart';
import '../../running/providers/running_providers.dart';
import '../data/report_pdf_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _periodDays = 30;
  final Set<String> _selecionadas = kReportSections.map((s) => s.id).toSet();
  bool _gerando = false;

  Future<void> _gerar() async {
    setState(() => _gerando = true);
    try {
      final user = ref.read(currentUserProvider) ?? AppUser.demo();
      final desde = DateTime.now().subtract(Duration(days: _periodDays));

      final pesoHist = ref
          .read(weightHistoryProvider)
          .where((e) => e.date.isAfter(desde))
          .toList();
      final aguaHist = await WaterLogNotifier.history(_periodDays);
      final kcalHist = await foodKcalHistory(_periodDays);
      final corridas = await ref
          .read(runningRepositoryProvider)
          .fetchAll(user.id)
          .then((l) => l.where((s) => s.date.isAfter(desde)).toList());
      final taxaHabitos = ref.read(calendarCompletionRateProvider);

      await ReportPdfService.generateAndShare(
        userName: user.name,
        sections: _selecionadas,
        pesoHist: pesoHist,
        aguaHist: aguaHist,
        kcalHist: kcalHist,
        corridas: corridas,
        taxaHabitos: taxaHabitos,
        periodDays: _periodDays,
      );
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios 📊')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Exporte sua evolução em PDF pra guardar ou levar à consulta.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text('Período',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _PeriodChip(
                    label: '7 dias',
                    selected: _periodDays == 7,
                    onTap: () => setState(() => _periodDays = 7)),
                _PeriodChip(
                    label: '30 dias',
                    selected: _periodDays == 30,
                    onTap: () => setState(() => _periodDays = 30)),
                _PeriodChip(
                    label: '90 dias',
                    selected: _periodDays == 90,
                    onTap: () => setState(() => _periodDays = 90)),
                _PeriodChip(
                    label: '1 ano',
                    selected: _periodDays == 365,
                    onTap: () => setState(() => _periodDays = 365)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('O que incluir',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...kReportSections.map((s) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title:
                      Text(s.label, style: const TextStyle(color: Colors.white)),
                  value: _selecionadas.contains(s.id),
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() {
                    v == true
                        ? _selecionadas.add(s.id)
                        : _selecionadas.remove(s.id);
                  }),
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_gerando || _selecionadas.isEmpty) ? null : _gerar,
                icon: _gerando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf_outlined),
                label:
                    Text(_gerando ? 'Gerando...' : 'Gerar e compartilhar PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
