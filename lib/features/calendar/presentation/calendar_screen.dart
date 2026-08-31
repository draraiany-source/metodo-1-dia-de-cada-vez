import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/calendar_models.dart';
import '../providers/calendar_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  Future<void> _novoEvento(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    var categoria = CalendarCategory.treino;
    var repeticao = EventRepeat.nenhuma;
    TimeOfDay? hora;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novo evento', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              const Text('Título',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(controller: titleController, autofocus: true),
              const SizedBox(height: 16),
              const Text('Categoria',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<CalendarCategory>(
                value: categoria,
                items: CalendarCategory.values
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text('${c.emoji}  ${c.label}')))
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => categoria = v ?? categoria),
              ),
              const SizedBox(height: 16),
              const Text('Repetição',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<EventRepeat>(
                value: repeticao,
                items: const [
                  DropdownMenuItem(
                      value: EventRepeat.nenhuma, child: Text('Não repete')),
                  DropdownMenuItem(
                      value: EventRepeat.diaria, child: Text('Todo dia')),
                  DropdownMenuItem(
                      value: EventRepeat.semanal,
                      child: Text('Toda semana (mesmo dia)')),
                  DropdownMenuItem(
                      value: EventRepeat.mensal,
                      child: Text('Todo mês (mesmo dia)')),
                ],
                onChanged: (v) =>
                    setSheetState(() => repeticao = v ?? repeticao),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Horário (opcional)',
                    style: TextStyle(color: AppColors.textSecondary)),
                trailing: Text(hora?.format(ctx) ?? '—',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                onTap: () async {
                  final picked = await showTimePicker(
                      context: ctx, initialTime: TimeOfDay.now());
                  if (picked != null) setSheetState(() => hora = picked);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Salvar evento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true && titleController.text.trim().isNotEmpty) {
      await ref.read(calendarProvider.notifier).add(CalendarEvent(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: titleController.text.trim(),
            category: categoria,
            date: _selectedDay,
            hour: hora?.hour,
            minute: hora?.minute,
            repeat: repeticao,
          ));
      await FeedbackService.play(FeedbackEvent.sucesso);
    }
    titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(calendarProvider.notifier);
    ref.watch(calendarProvider); // reconstrói ao mudar a lista
    final eventosDoDia = notifier.eventsOn(_selectedDay);
    final taxa = ref.watch(calendarCompletionRateProvider);

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Calendário'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoEvento(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: TableCalendar<CalendarEvent>(
                locale: 'pt_BR',
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _format,
                selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                eventLoader: (day) => notifier.eventsOn(day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onFormatChanged: (f) => setState(() => _format = f),
                onPageChanged: (focused) => _focusedDay = focused,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(color: Colors.white, fontSize: 16),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.textSecondary),
                  weekendStyle: TextStyle(color: AppColors.textSecondary),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white),
                  outsideTextStyle:
                      const TextStyle(color: AppColors.textTertiary),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Conclusão nos últimos 30 dias: ${(taxa * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (eventosDoDia.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(
                  child: Text('Nenhum evento neste dia.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ...eventosDoDia.map((e) {
                final done = e.isDoneOn(_selectedDay);
                return Dismissible(
                  key: ValueKey('${e.id}-${_selectedDay.toIso8601String()}'),
                  direction: e.repeat == EventRepeat.nenhuma
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) =>
                      ref.read(calendarProvider.notifier).remove(e.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border(
                          left: BorderSide(color: e.category.color, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Text(e.category.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      decoration: done
                                          ? TextDecoration.lineThrough
                                          : null)),
                              Text(
                                e.hour != null
                                    ? '${e.hour!.toString().padLeft(2, '0')}:${(e.minute ?? 0).toString().padLeft(2, '0')} · ${e.category.label}'
                                    : e.category.label,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: done,
                          activeColor: AppColors.success,
                          onChanged: (_) => ref
                              .read(calendarProvider.notifier)
                              .toggleDone(e.id, _selectedDay),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
