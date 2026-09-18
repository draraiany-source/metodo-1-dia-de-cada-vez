import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../accompaniment/presentation/accompaniment_feature_grids.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';
import '../../evolution/presentation/load_history_screen.dart';
import '../../evolution/presentation/personal_records_screen.dart';
import 'evolution_pt_screen.dart';
import 'student_anamnesis_screen.dart';
import 'workout_session_screen.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final studentAsync = ref.watch(
      ptMyStudentProfileProvider((userId: user.id, email: user.email)),
    );
    final gamification = ref.watch(gamificationProvider);

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Meu treino',
        showBack: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppIconImage(
              AppIcons.personal,
              size: 28,
              fallbackIcon: Icons.fitness_center,
            ),
          ),
        ],
      ),
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
                        color: AppColors.primary,
                        iconAsset: AppIcons.trophy,
                        fallbackIcon: Icons.military_tech_outlined),
                    const SizedBox(width: 10),
                    _StatChip(
                        label: 'XP',
                        value: '${gamification.xp}',
                        color: AppColors.secondary,
                        iconAsset: AppIcons.achievement,
                        fallbackIcon: Icons.bolt_outlined),
                    const SizedBox(width: 10),
                    _StatChip(
                        label: 'Sequência',
                        value: '${gamification.streak}d',
                        color: AppColors.warning,
                        iconAsset: AppIcons.streak,
                        fallbackIcon: Icons.local_fire_department_outlined),
                  ],
                ),
                const SizedBox(height: 20),
                plansAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (plans) => _WeekCalendar(
                    plans: plans,
                    sessions: ref.watch(ptSessionsProvider(student.id)).valueOrNull ??
                        const [],
                  ),
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
                      icon: AppIconImage(
                        AppIcons.evolution,
                        size: 18,
                        fallbackIcon: Icons.show_chart,
                      ),
                      label: const Text('Minha evolução'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StudentAccompanimentSection(
                  onEvolution: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EvolutionPtScreen(student: student),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => StudentAnamnesisScreen(student: student))),
                  icon: const Icon(Icons.assignment_outlined, size: 18),
                  label: const Text('Ficha de treino (anamnese)'),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          LoadHistoryScreen(studentId: student.id))),
                  icon: const Icon(Icons.fitness_center_outlined, size: 18),
                  label: const Text('Histórico de cargas'),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const PersonalRecordsScreen())),
                  icon: const Icon(Icons.emoji_events_outlined, size: 18),
                  label: const Text('Meus recordes'),
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
                              .map((p) => AppCard(
                                    padding: EdgeInsets.zero,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 4),
                                      leading: AppIconImage(
                                        AppIcons.workout,
                                        size: 32,
                                        fallbackIcon: Icons.fitness_center,
                                      ),
                                      title: Text(p.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      subtitle: Text(
                                          '${p.exercises.length} exercícios · ${p.diasSemana.join(', ')}',
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12)),
                                      trailing: AppIconImage(
                                          AppIcons.next,
                                          size: 22,
                                          fallbackIcon:
                                              Icons.chevron_right_rounded),
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
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.iconAsset,
    required this.fallbackIcon,
  });
  final String label;
  final String value;
  final Color color;
  final String iconAsset;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            AppIconImage(iconAsset, size: 22, fallbackIcon: fallbackIcon),
            const SizedBox(height: 6),
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

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar({required this.plans, required this.sessions});
  final List<WorkoutPlan> plans;
  final List<WorkoutSessionLog> sessions;

  static const _labels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: (now.weekday - 1) % 7));
    final planned = <String>{};
    for (final p in plans) {
      planned.addAll(p.diasSemana.map((e) => e.toUpperCase()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Semana',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Builder(builder: (_) {
                  final day = monday.add(Duration(days: i));
                  final key = _labels[i];
                  final isToday = day.year == now.year &&
                      day.month == now.month &&
                      day.day == now.day;
                  final done = sessions.any((s) =>
                      s.date.year == day.year &&
                      s.date.month == day.month &&
                      s.date.day == day.day);
                  final hasPlan = planned.contains(key);
                  Color bg;
                  if (done) {
                    bg = AppColors.success.withOpacity(0.25);
                  } else if (hasPlan) {
                    bg = AppColors.secondary.withOpacity(0.2);
                  } else {
                    bg = AppColors.surface;
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday
                            ? AppColors.secondary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(key,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 10)),
                        const SizedBox(height: 4),
                        Text('${day.day}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Icon(
                          done
                              ? Icons.check_circle
                              : hasPlan
                                  ? Icons.fitness_center
                                  : Icons.hotel,
                          size: 12,
                          color: done
                              ? AppColors.success
                              : hasPlan
                                  ? AppColors.secondary
                                  : AppColors.textTertiary,
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Verde = concluído · Rosa = programado · Cinza = descanso',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
      ],
    );
  }
}
