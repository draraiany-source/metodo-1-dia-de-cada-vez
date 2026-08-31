import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../providers/missions_providers.dart';

class MissionsHistoryScreen extends ConsumerWidget {
  const MissionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(missionsProvider).history;

    final totalXp = history.fold<int>(0, (s, r) => s + r.xp);
    final totalCoins = history.fold<int>(0, (s, r) => s + r.coins);

    return Scaffold(
      appBar: AppBar(title: const Text('Missões concluídas')),
      body: SafeArea(
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    AnimatedLiliMascot(
                        pose: MascotePose.padrao,
                        height: 150,
                        mood: LiliMood.respirando),
                    SizedBox(height: 12),
                    Text('Nenhuma missão concluída ainda.',
                        style: TextStyle(color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('Que tal começar pela missão diária? 💪',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 12)),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(value: '${history.length}', label: 'Missões'),
                        _Stat(value: '$totalXp', label: 'XP ganho'),
                        _Stat(value: '$totalCoins', label: 'Moedas'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...history.indexed.map((e) => FadeInUp(
                        delayMs: e.$1 * 40,
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.military_tech,
                                color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.$2.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  Text(DateFormatBr.dataHora(e.$2.date),
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            Text('+${e.$2.xp} XP\n+${e.$2.coins} 🪙',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    color: AppColors.accent, fontSize: 12)),
                          ],
                        ),
                        ),
                      )),
                ],
              ),
      ),
    );
  }

}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
