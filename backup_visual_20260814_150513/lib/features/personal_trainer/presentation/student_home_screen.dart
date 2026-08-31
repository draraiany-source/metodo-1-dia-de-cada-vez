import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../providers/pt_providers.dart';
import 'evolution_pt_screen.dart';
import 'workout_session_screen.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();
    final studentAsync = ref.watch(ptMyStudentProfileProvider(user.id));
    final gamification = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu treino 🏋️')),
      body: SafeArea(
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Não consegui carregar seu perfil de aluno.',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (student) {
            if (student == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AnimatedLiliMascot(
                          pose: MascotePose.checklist,
                          mood: LiliMood.respirando,
                          height: 120),
                      const SizedBox(height: 16),
                      const Text(
                        'Você ainda não está vinculada a um personal trainer.\n'
                        'Peça pro seu personal te cadastrar com o mesmo '
                        'e-mail da sua conta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            final plansAsync = ref.watch(ptWorkoutPlansProvider(student.id));

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    const AnimatedLiliMascot(
                        pose: MascotePose.halteres,
                        mood: LiliMood.viva,
                        height: 76),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Bora treinar, ${student.name.split(' ').first}?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _StatChip(
                        label: 'Nível',
                        value: '${gamification.level}',
                        color: AppColors.primary),
                    const SizedBox(width: 10),
                    _StatChip(
                        label: 'XP',
                        value: '${gamification.xp}',
                        color: AppColors.secondary),
                    const SizedBox(width: 10),
                    _StatChip(
                        label: 'Sequência',
                        value: '${gamification.streak}d',
                        color: AppColors.warning),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seus treinos',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => EvolutionPtScreen(student: student))),
                      icon: const Icon(Icons.show_chart, size: 18),
                      label: const Text('Minha evolução'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                plansAsync.when(
                  loading: () => const Center(
                      child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator())),
                  error: (_, __) => const Text('Não consegui carregar.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  data: (plans) => plans.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                              'Seu personal ainda não montou nenhum treino.',
                              style: TextStyle(color: AppColors.textSecondary)),
                        )
                      : Column(
                          children: plans
                              .map((p) => Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius:
                                          BorderRadius.circular(AppTheme.radiusSm),
                                    ),
                                    child: ListTile(
                                      title: Text(p.name,
                                          style:
                                              const TextStyle(color: Colors.white)),
                                      subtitle: Text(
                                          '${p.exercises.length} exercícios · ${p.diasSemana.join(', ')}',
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12)),
                                      trailing: const Icon(Icons.play_circle_outline,
                                          color: AppColors.primary),
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) => WorkoutSessionScreen(
                                                  student: student, plan: p))),
                                    ),
                                  ))
                              .toList(),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
