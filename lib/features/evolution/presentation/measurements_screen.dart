import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../providers/measurement_history_providers.dart';

/// Página dedicada de Medidas — registrar, consultar histórico, comparar
/// registros e ver a evolução (em cm) de cada parte do corpo.
///
/// Os campos nunca são só decorativos: cada um é lido/gravado de
/// [MeasurementEntry] via [measurementHistoryProvider] (mesmo armazenamento
/// local-first já usado no peso).
class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() =>
      _MeasurementsScreenState();
}

/// Definição de um campo de medida — usada tanto pro formulário de registro
/// quanto pra montar a comparação/evolução, sem repetir a lista de campos.
class _MeasurementField {
  const _MeasurementField(this.label, this.getter, this.unit);
  final String label;
  final double? Function(MeasurementEntry) getter;
  final String unit;
}

const _fields = <_MeasurementField>[
  _MeasurementField('Cintura', _cintura, 'cm'),
  _MeasurementField('Abdômen', _abdomen, 'cm'),
  _MeasurementField('Quadril', _quadril, 'cm'),
  _MeasurementField('Coxa direita', _coxaDireita, 'cm'),
  _MeasurementField('Coxa esquerda', _coxaEsquerda, 'cm'),
  _MeasurementField('Braço direito', _bracoDireito, 'cm'),
  _MeasurementField('Braço esquerdo', _bracoEsquerdo, 'cm'),
  _MeasurementField('Busto', _busto, 'cm'),
  _MeasurementField('Panturrilha', _panturrilha, 'cm'),
  _MeasurementField('% de gordura', _percentualGordura, '%'),
];

double? _cintura(MeasurementEntry e) => e.cintura;
double? _abdomen(MeasurementEntry e) => e.abdomen;
double? _quadril(MeasurementEntry e) => e.quadril;
double? _coxaDireita(MeasurementEntry e) => e.coxaDireita ?? e.coxa;
double? _coxaEsquerda(MeasurementEntry e) => e.coxaEsquerda;
double? _bracoDireito(MeasurementEntry e) => e.bracoDireito ?? e.braco;
double? _bracoEsquerdo(MeasurementEntry e) => e.bracoEsquerdo;
double? _busto(MeasurementEntry e) => e.busto ?? e.peito;
double? _panturrilha(MeasurementEntry e) => e.panturrilha;
double? _percentualGordura(MeasurementEntry e) => e.percentualGordura;

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  Future<void> _registrar() async {
    final controllers = {for (final f in _fields) f.label: TextEditingController()};
    final obsController = TextEditingController();
    var dataEscolhida = DateTime.now();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModal) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registrar medidas',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data'),
                subtitle: Text(DateFormatBr.data(dataEscolhida)),
                trailing: const Icon(Icons.calendar_today_outlined, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dataEscolhida,
                    firstDate: DateTime(2018),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModal(() => dataEscolhida = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              for (final f in _fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: controllers[f.label],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: f.label,
                      suffixText: f.unit,
                    ),
                  ),
                ),
              TextField(
                controller: obsController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Observação (opcional)'),
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
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );

    if (ok != true) {
      for (final c in controllers.values) {
        c.dispose();
      }
      obsController.dispose();
      return;
    }

    double? parse(String s) =>
        double.tryParse(s.trim().replaceAll(',', '.'));

    final entry = MeasurementEntry(
      date: dataEscolhida,
      cintura: parse(controllers['Cintura']!.text),
      abdomen: parse(controllers['Abdômen']!.text),
      quadril: parse(controllers['Quadril']!.text),
      coxaDireita: parse(controllers['Coxa direita']!.text),
      coxaEsquerda: parse(controllers['Coxa esquerda']!.text),
      bracoDireito: parse(controllers['Braço direito']!.text),
      bracoEsquerdo: parse(controllers['Braço esquerdo']!.text),
      busto: parse(controllers['Busto']!.text),
      panturrilha: parse(controllers['Panturrilha']!.text),
      percentualGordura: parse(controllers['% de gordura']!.text),
      observacao:
          obsController.text.trim().isEmpty ? null : obsController.text.trim(),
    );

    for (final c in controllers.values) {
      c.dispose();
    }
    obsController.dispose();

    if (entry.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Preencha ao menos uma medida para salvar.')));
      }
      return;
    }

    await ref.read(measurementHistoryProvider.notifier).add(entry);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medidas registradas!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(measurementHistoryProvider);
    final ultima = history.isNotEmpty ? history.last : null;
    final anterior = history.length >= 2 ? history[history.length - 2] : null;

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
                    const Text('Medidas',
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
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  if (ultima == null)
                    _EmptyMeasurements(onTap: _registrar)
                  else ...[
                    Text('Última medição · ${DateFormatBr.data(ultima.date)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final f in _fields)
                          if (f.getter(ultima) != null)
                            _MeasureTile(
                              field: f,
                              atual: f.getter(ultima)!,
                              anterior:
                                  anterior != null ? f.getter(anterior) : null,
                            ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    PressableScale(
                      onTap: _registrar,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroPinkGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text('Registrar novas medidas',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    const Text(
                      'Deslize para excluir um registro',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    for (var i = history.length - 1; i >= 0; i--)
                      Dismissible(
                        key: ValueKey('m_${history[i].date.toIso8601String()}_$i'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: const Text('Excluir medidas?'),
                                  content: Text(DateFormatBr.data(history[i].date)),
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
                        onDismissed: (_) => ref
                            .read(measurementHistoryProvider.notifier)
                            .removeAt(i),
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormatBr.data(history[i].date),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                for (final f in _fields)
                                  if (f.getter(history[i]) != null)
                                    Text(
                                        '${f.label}: ${f.getter(history[i])!.toStringAsFixed(1)}${f.unit}',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12)),
                              ],
                            ),
                            if (history[i].observacao != null) ...[
                              const SizedBox(height: 6),
                              Text('"${history[i].observacao}"',
                                  style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasureTile extends StatelessWidget {
  const _MeasureTile(
      {required this.field, required this.atual, required this.anterior});
  final _MeasurementField field;
  final double atual;
  final double? anterior;

  @override
  Widget build(BuildContext context) {
    final delta = anterior != null ? atual - anterior! : null;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text('${atual.toStringAsFixed(1)}${field.unit}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          if (delta != null && delta != 0)
            Text(
                '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}${field.unit}',
                style: TextStyle(
                    color: delta < 0 ? AppColors.success : AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyMeasurements extends StatelessWidget {
  const _EmptyMeasurements({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          AppIconImage(AppIcons.measurement, size: 56,
              fallbackIcon: Icons.straighten),
          const SizedBox(height: 16),
          const Text('Nenhuma medida registrada ainda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          PressableScale(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.heroPinkGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Registrar minhas medidas',
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
