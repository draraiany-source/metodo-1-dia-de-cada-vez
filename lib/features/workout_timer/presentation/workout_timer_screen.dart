import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/lily/lily_assets.dart';
import '../../../core/lily/lily_image.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import '../../weekly_challenge/providers/weekly_challenge_providers.dart';
import '../data/workout_session_repository.dart';
import '../domain/workout_timer_models.dart';
import '../providers/workout_timer_controller.dart';

class WorkoutTimerScreen extends ConsumerStatefulWidget {
  const WorkoutTimerScreen({super.key, required this.blueprint});
  final WorkoutTimerBlueprint blueprint;

  @override
  ConsumerState<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends ConsumerState<WorkoutTimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = ref.read(workoutTimerControllerProvider);
      if (c.state == null ||
          c.state!.blueprint.workoutId != widget.blueprint.workoutId ||
          c.state!.finished) {
        c.bind(widget.blueprint);
        c.startWorkout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(workoutTimerControllerProvider);
    final s = controller.state;
    if (s == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (s.finished) {
      return _FinishedView(state: s, onClose: () => Navigator.pop(context));
    }

    final ex = s.current;
    final lastSeconds = s.phase != TimerPhase.idle &&
        s.remaining.inSeconds <= 5 &&
        s.remaining.inSeconds > 0 &&
        s.phaseTotal > Duration.zero;
    final isRest = s.phase == TimerPhase.rest;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: widget.blueprint.title,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                formatTimer(s.totalElapsed),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              if (ex != null) ...[
                Text(
                  ex.name,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2(),
                ),
                const SizedBox(height: 6),
                Text(
                  _subtitle(s, ex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const Spacer(),
              _Ring(
                progress: isRest
                    ? 1 - s.phaseProgress
                    : (s.phaseTotal == Duration.zero ? 0.08 : s.phaseProgress),
                color: isRest ? AppColors.info : AppColors.hotPink,
                highlight: lastSeconds,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isRest ? 'DESCANSO' : (ex?.protocol == TimerProtocol.hiit ? 'TREINO' : 'TEMPO'),
                      style: TextStyle(
                        color: isRest ? AppColors.info : AppColors.hotPink,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastSeconds
                          ? '${s.remaining.inSeconds}'
                          : formatTimer(s.remaining),
                      style: AppTextStyles.display(
                        size: lastSeconds ? 84 : 56,
                        color: lastSeconds ? AppColors.danger : Colors.white,
                      ),
                    ),
                    if (ex?.protocol == TimerProtocol.hiit ||
                        ex?.protocol == TimerProtocol.emom)
                      Text(
                        'RODADA ${s.roundIndex + 1}/${ex!.effectiveRounds}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              if (isRest)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Quando terminar: Vamos para a próxima série! 🔥',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              if (!isRest && s.setIndex > 0 && s.phase == TimerPhase.work)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Vamos para a próxima série! 🔥',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.hotPink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (isRest) ...[
                const Text(
                  'Respira. A próxima série vem aí.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.skip,
                        child: const Text('Pular descanso'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.addRestSeconds(15),
                        child: const Text('+15 segundos'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _BigButton(
                  label: s.running ? 'Pausar' : 'Continuar',
                  onTap: s.running ? controller.pause : controller.resume,
                ),
              ] else ...[
                _BigButton(
                  label: s.phase == TimerPhase.idle
                      ? 'INICIAR CRONÔMETRO'
                      : (s.running ? 'Pausar' : 'Continuar'),
                  onTap: s.phase == TimerPhase.idle
                      ? controller.startCurrent
                      : (s.running ? controller.pause : controller.resume),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.restartPhase,
                        child: const Text('Reiniciar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.skip,
                        child: const Text('Pular'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _confirmFinish(controller),
                  child: const Text('Finalizar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(WorkoutTimerState s, TimerExercise ex) {
    if (ex.protocol == TimerProtocol.hiit) {
      return 'HIIT · ${ex.workSeconds}s ativo / ${ex.restSeconds}s descanso';
    }
    if (ex.effortMode == TimerEffortMode.reps) {
      return 'Série ${s.setIndex + 1}/${ex.effectiveRounds} · ${ex.repsLabel} reps';
    }
    return 'Série ${s.setIndex + 1}/${ex.effectiveRounds} · ${ex.workSeconds}s';
  }

  Future<void> _confirmFinish(WorkoutTimerController controller) async {
    controller.finishWorkout();
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.progress,
    required this.color,
    required this.child,
    this.highlight = false,
  });
  final double progress;
  final Color color;
  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 14,
              backgroundColor: AppColors.surfaceElevated,
              color: highlight ? AppColors.danger : color,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}

class _FinishedView extends ConsumerWidget {
  const _FinishedView({required this.state, required this.onClose});
  final WorkoutTimerState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = state.totalElapsed;
    final mins = total.inMinutes;
    final secs = total.inSeconds.remainder(60);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const LilyImage(
                asset: LilyAssets.posTreino,
                height: 160,
                semanticLabel: 'Lily pós-treino',
              ),
              Text('Treino concluído!', style: AppTextStyles.h1()),
              const SizedBox(height: 8),
              Text(
                'Tempo total: ${mins}min ${secs}s',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.exercisesDone} exercícios · ${state.seriesDone} séries',
                style: const TextStyle(color: AppColors.accent),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  onPressed: () async {
                    await _persist(ref, state);
                    onClose();
                  },
                  child: const Text('Salvar e sair'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _persist(WidgetRef ref, WorkoutTimerState s) async {
    final user = ref.read(currentUserProvider) ?? AppUser.uiFallback();
    final record = WorkoutSessionRecord(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      workoutId: s.blueprint.workoutId,
      title: s.blueprint.title,
      startedAt: s.startedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
      totalDuration: s.totalElapsed,
      activeDuration: s.activeElapsed,
      restDuration: s.restElapsed,
      exercisesDone: s.exercisesDone,
      exercisesTotal: s.blueprint.exercises.length,
      seriesDone: s.seriesDone,
      percent: s.blueprint.exercises.isEmpty
          ? 1
          : (s.exercisesDone / s.blueprint.exercises.length).clamp(0.0, 1.0),
    );
    await ref.read(workoutSessionRepositoryProvider).save(record);
    ref.read(gamificationProvider.notifier).addXp(AppConstants.xpPerWorkout);
    ref.read(rewardsProvider.notifier).earn(AppConstants.coinsPerWorkout);
    ref.read(missionsProvider.notifier).report(MissionEvent.treinoConcluido);
    await ref.read(weeklyChallengeRepositoryProvider).recordWorkout(
          userId: user.id.isEmpty ? 'guest' : user.id,
          duration: s.totalElapsed,
          displayName: user.name,
        );
    await FeedbackService.play(FeedbackEvent.sucesso);
    ref.read(workoutTimerControllerProvider).clear();
  }
}
