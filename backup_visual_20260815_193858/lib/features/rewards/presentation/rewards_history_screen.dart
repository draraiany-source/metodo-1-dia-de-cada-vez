import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../providers/rewards_providers.dart';

class RewardsHistoryScreen extends ConsumerWidget {
  const RewardsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rewardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recompensas resgatadas')),
      body: SafeArea(
        child: state.history.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    AnimatedLiliMascot(
                        pose: MascotePose.padrao,
                        height: 150,
                        mood: LiliMood.respirando),
                    SizedBox(height: 12),
                    Text('Você ainda não resgatou recompensas.',
                        style: TextStyle(color: AppColors.textSecondary)),
                    SizedBox(height: 4),
                    Text('Complete treinos e desafios para ganhar moedas! 🪙',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 12)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: state.history.length,
                itemBuilder: (_, i) {
                  final r = state.history[i];
                  return FadeInUp(
                    delayMs: i * 40,
                    child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              Text(DateFormatBr.dataHora(r.date),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('-${r.price} 🪙',
                            style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600)),
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
