import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/seed_data.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/domain_models.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final List<Habit> _habits = SeedData.defaultHabits();
  int _mood = -1;
  final _notes = TextEditingController();

  static const _moods = ['😄', '🙂', '😐', '😔', '😫'];

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final doneCount = _habits.where((h) => h.done).length;
    final xp = AppConstants.xpPerCheckin + doneCount * AppConstants.xpPerHabit;
    ref.read(gamificationProvider.notifier).addXp(xp);
    // Streak real: incrementa uma vez por dia (fonte única de verdade).
    final avancou = ref.read(gamificationProvider.notifier).registerCheckin();
    ref.read(rewardsProvider.notifier).earn(AppConstants.coinsPerCheckin);
    FeedbackService.play(
        avancou ? FeedbackEvent.sucesso : FeedbackEvent.toqueLeve);
    // Missões: check-in do dia + progresso de streak.
    ref.read(missionsProvider.notifier).report(MissionEvent.checkinFeito);
    if (avancou) {
      ref.read(missionsProvider.notifier).report(MissionEvent.streakDia);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Check-in salvo! +$xp XP ⚡ · +${AppConstants.coinsPerCheckin} 🪙')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Check-in do dia ✅',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const Text('Marque o que você cumpriu hoje',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const AnimatedLiliMascot(
                      pose: MascotePose.checklist,
                      mood: LiliMood.respirando,
                      height: MascotSizes.header),
                ],
              ),
              const SizedBox(height: 20),

              // Humor
              const Text('Como você está se sentindo?',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_moods.length, (i) {
                  final selected = _mood == i;
                  return GestureDetector(
                    onTap: () => setState(() => _mood = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(color: AppColors.secondary, width: 2)
                            : Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Center(
                          child: Text(_moods[i],
                              style: const TextStyle(fontSize: 24))),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Hábitos
              const Text('Hábitos de hoje',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._habits.map((h) => GestureDetector(
                    onTap: () => setState(() => h.done = !h.done),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: h.done
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(
                          color: h.done
                              ? AppColors.success
                              : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(h.emoji,
                                style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(h.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600))),
                          Icon(
                            h.done
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: h.done
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),

              // Observações
              const Text('📝 Observações',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              TextField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Como foi seu dia? Alguma conquista?',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar check-in (+50 XP)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
