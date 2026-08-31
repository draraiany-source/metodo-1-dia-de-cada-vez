import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../reminders/domain/reminder_models.dart';
import '../../../reminders/providers/reminders_providers.dart';

/// "Próxima atividade" — o próximo lembrete ativo de hoje, calculado a
/// partir dos horários reais cadastrados em Lembretes. Sem lembretes
/// cadastrados (ou nenhum restante hoje) o cartão simplesmente não
/// aparece — nunca inventa um horário.
class NextActivityCard extends ConsumerWidget {
  const NextActivityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    Reminder? next;
    var bestDelta = 24 * 60 + 1;
    for (final r in reminders) {
      if (!r.enabled) continue;
      final minutes = r.hour * 60 + r.minute;
      final delta = minutes - nowMinutes;
      if (delta >= 0 && delta < bestDelta) {
        bestDelta = delta;
        next = r;
      }
    }
    if (next == null) return const SizedBox.shrink();

    final hh = next.hour.toString().padLeft(2, '0');
    final mm = next.minute.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () => context.push(Routes.reminders),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppColors.info.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule_rounded,
                    color: AppColors.info, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Próxima atividade',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                    Text(
                      next.label?.isNotEmpty == true
                          ? next.label!
                          : next.category.label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text('$hh:$mm',
                  style: const TextStyle(
                      color: AppColors.info,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
