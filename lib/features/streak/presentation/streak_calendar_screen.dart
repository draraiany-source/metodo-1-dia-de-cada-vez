import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/lili_animated.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../gamification/providers/gamification_providers.dart';

/// Calendário de sequência — mostra o mês atual com os dias marcados.
///
/// Os dias concluídos são derivados do streak atual do usuário (os últimos N
/// dias). Quando o histórico do Firestore estiver ativo, basta trocar a
/// fonte de `_doneDays` por `workout_history`/`habits`.
class StreakCalendarScreen extends ConsumerWidget {
  const StreakCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fonte única de verdade (persistida e atualizada pelo check-in).
    final streak = ref.watch(gamificationProvider).streak;
    final now = DateTime.now();

    // Dias concluídos = os últimos [streak] dias a partir de hoje.
    final doneDays = <DateTime>{
      for (var i = 0; i < streak; i++)
        DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: i)),
    };

    final firstOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // domingo = 0

    const weekLabels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    const monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Sequência'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            // Destaque do streak
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.vibeGradient,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Row(
                children: [
                  const AnimatedLiliMascot(
                      pose: MascotePose.forte,
                      mood: LiliMood.correndo,
                      height: 90),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔥 $streak dias seguidos',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text(
                            'Constância é o que transforma. Não quebre a corrente!',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('${monthNames[now.month - 1]} ${now.year}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            // Cabeçalho dos dias da semana
            Row(
              children: weekLabels
                  .map((w) => Expanded(
                        child: Center(
                          child: Text(w,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Grade do mês
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (var i = 0; i < leadingBlanks; i++)
                  const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day++)
                  _DayCell(
                    day: day,
                    isToday: day == now.day,
                    done: doneDays.contains(DateTime(now.year, now.month, day)),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: const [
                _LegendDot(color: AppColors.primary, label: 'Concluído'),
                SizedBox(width: 16),
                _LegendDot(color: AppColors.surface2, label: 'Sem registro'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.done, required this.isToday});
  final int day;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: done ? AppColors.primary : AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: AppColors.secondary, width: 2)
            : null,
      ),
      child: Center(
        child: Text('$day',
            style: TextStyle(
                color: done ? Colors.white : AppColors.textSecondary,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
