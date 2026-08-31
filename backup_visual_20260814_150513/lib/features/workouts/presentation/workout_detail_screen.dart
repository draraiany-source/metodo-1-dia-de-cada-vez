import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/seed_data.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/domain_models.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';

/// Segundos de descanso automático entre exercícios (padrão — não há, hoje,
/// um intervalo configurado por exercício no catálogo geral, diferente do
/// fluxo de sessão do Personal Trainer que já tem esse dado por exercício).
const _kDescansoPadraoSegundos = 45;

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({super.key, required this.workout});
  final Workout workout;

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  final Set<int> _concluidos = {};
  Timer? _timer;
  int _descansoRestante = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _marcarExercicio(int index) {
    if (_concluidos.contains(index)) return;
    FeedbackService.play(FeedbackEvent.toqueLeve);
    setState(() {
      _concluidos.add(index);
      _descansoRestante = _kDescansoPadraoSegundos;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_descansoRestante <= 1) {
        t.cancel();
        setState(() => _descansoRestante = 0);
      } else {
        setState(() => _descansoRestante--);
      }
    });
  }

  Future<void> _concluirTreino() async {
    ref.read(gamificationProvider.notifier).addXp(AppConstants.xpPerWorkout);
    ref.read(rewardsProvider.notifier).earn(AppConstants.coinsPerWorkout);
    ref.read(missionsProvider.notifier).report(MissionEvent.treinoConcluido);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedLiliMascot(
                pose: MascotePose.joinha,
                mood: LiliMood.comemorando,
                height: 140),
            const SizedBox(height: 12),
            Text(
                'Treino concluído! +${AppConstants.xpPerWorkout} XP ⚡\n'
                '+${AppConstants.coinsPerWorkout} moedas 🪙',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;
    final exercises = SeedData.workoutExercises[workout.id] ??
        const ['Aquecimento', 'Exercício principal', 'Alongamento'];
    final descansando = _descansoRestante > 0;

    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 160,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: AppColors.vibeGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: (workout.photoUrl == null || workout.photoUrl!.isEmpty)
                ? Center(
                    child: Text(workout.emoji,
                        style: const TextStyle(fontSize: 64)))
                : CachedNetworkImage(
                    imageUrl: workout.photoUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (_, __, ___) => Center(
                        child: Text(workout.emoji,
                            style: const TextStyle(fontSize: 64))),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetaPill(
                  icon: Icons.timer_outlined,
                  text: '${workout.durationMin} min'),
              const SizedBox(width: 8),
              _MetaPill(icon: Icons.bar_chart, text: workout.level),
              const SizedBox(width: 8),
              if (workout.kcal != null)
                _MetaPill(
                    icon: Icons.local_fire_department_outlined,
                    text: '${workout.kcal} kcal'),
            ],
          ),
          const SizedBox(height: 20),

          // Descanso automático — aparece quando um exercício é marcado.
          if (descansando)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_bottom, color: AppColors.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Descanso: ${_descansoRestante}s',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () {
                      _timer?.cancel();
                      setState(() => _descansoRestante = 0);
                    },
                    child: const Text('Pular'),
                  ),
                ],
              ),
            ),

          SectionHeader(
              title: 'Exercícios (${_concluidos.length}/${exercises.length})'),
          ...exercises.asMap().entries.map((e) {
            final feito = _concluidos.contains(e.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _marcarExercicio(e.key),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: feito
                        ? Border.all(color: AppColors.success, width: 1.4)
                        : null,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            feito ? AppColors.success : AppColors.primary,
                        child: feito
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text('${e.key + 1}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(e.value,
                              style: TextStyle(
                                  color: feito
                                      ? AppColors.textSecondary
                                      : Colors.white,
                                  decoration: feito
                                      ? TextDecoration.lineThrough
                                      : null))),
                      const Text('3 x 12',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _concluirTreino,
            icon: const Icon(Icons.check),
            label: Text('Concluir treino (+${AppConstants.xpPerWorkout} XP)'),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}
