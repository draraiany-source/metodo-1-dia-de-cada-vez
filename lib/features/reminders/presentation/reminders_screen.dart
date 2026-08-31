import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/reminder_models.dart';
import '../providers/reminders_providers.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  Future<void> _novoLembrete(BuildContext context, WidgetRef ref) async {
    var categoria = ReminderCategory.agua;
    var hora = TimeOfDay.now();
    final labelController = TextEditingController();

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
              Text('Novo lembrete', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              const Text('Categoria',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<ReminderCategory>(
                value: categoria,
                items: ReminderCategory.values
                    .map((c) => DropdownMenuItem(
                        value: c, child: Text('${c.emoji}  ${c.label}')))
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => categoria = v ?? categoria),
              ),
              const SizedBox(height: 16),
              const Text('Observação (opcional)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                    hintText: 'ex.: Vitamina D, 500mg...'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Horário',
                    style: TextStyle(color: AppColors.textSecondary)),
                trailing: Text(hora.format(ctx),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                onTap: () async {
                  final picked =
                      await showTimePicker(context: ctx, initialTime: hora);
                  if (picked != null) setSheetState(() => hora = picked);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Salvar lembrete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      await ref.read(remindersProvider.notifier).upsert(
            category: categoria,
            hour: hora.hour,
            minute: hora.minute,
            label:
                labelController.text.trim().isEmpty ? null : labelController.text.trim(),
          );
      await FeedbackService.play(FeedbackEvent.sucesso);
    }
    labelController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final sorted = [...reminders]
      ..sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Lembretes'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoLembrete(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: sorted.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nenhum lembrete configurado ainda.\nToque em "+" pra criar o primeiro 💜',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: sorted.length,
                itemBuilder: (_, i) {
                  final r = sorted[i];
                  return Dismissible(
                    key: ValueKey(r.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white),
                    ),
                    onDismissed: (_) =>
                        ref.read(remindersProvider.notifier).remove(r.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Text(r.category.emoji,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.label ?? r.category.label,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                Text(r.horaFormatada,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: r.enabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (v) => ref
                                .read(remindersProvider.notifier)
                                .toggle(r.id, v),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
