import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../missions/providers/missions_providers.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';

const _falasLili = [
  'Você consegue! 💪',
  'Mais uma série!',
  'Excelente execução!',
  'Continua assim!',
  'Hora da água depois dessa série 💧',
  'Respira e foca — você tá indo bem.',
  'Um dia de cada vez, um exercício de cada vez.',
];

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen(
      {super.key, required this.student, required this.plan});
  final Student student;
  final WorkoutPlan plan;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  int _atual = 0;
  final Set<String> _concluidos = {};
  Timer? _timer;
  int _descansoRestante = 0;
  String _falaLili = _falasLili.first;

  WorkoutExerciseConfig get _exercicio => widget.plan.exercises[_atual];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _novaFala() {
    setState(() => _falaLili = _falasLili[Random().nextInt(_falasLili.length)]);
  }

  void _concluirSerie() {
    _novaFala();
    FeedbackService.play(FeedbackEvent.toqueLeve);
    setState(() => _descansoRestante = _exercicio.intervaloSegundos);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_descansoRestante <= 1) {
        t.cancel();
        setState(() => _descansoRestante = 0);
      } else {
        setState(() => _descansoRestante--);
      }
    });
  }

  Future<void> _adicionarCarga() async {
    final controller = TextEditingController();
    final peso = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Carga utilizada'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'kg'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(
                ctx, double.tryParse(controller.text.replaceAll(',', '.'))),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (peso == null) return;
    await ref.read(ptRepositoryProvider).logLoad(LoadEntry(
          id: '',
          studentId: widget.student.id,
          exerciseId: _exercicio.exerciseId,
          exerciseName: _exercicio.exerciseName,
          date: DateTime.now(),
          weightKg: peso,
        ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carga registrada: ${peso}kg 💪')),
      );
    }
  }

  void _concluirExercicio() {
    setState(() {
      _concluidos.add(_exercicio.exerciseId);
      if (_atual < widget.plan.exercises.length - 1) {
        _atual++;
        _timer?.cancel();
        _descansoRestante = 0;
        _novaFala();
      }
    });
  }

  Future<void> _finalizarTreino() async {
    await ref.read(ptRepositoryProvider).logSession(WorkoutSessionLog(
          id: '',
          studentId: widget.student.id,
          workoutPlanId: widget.plan.id,
          workoutName: widget.plan.name,
          date: DateTime.now(),
          completedExerciseIds: _concluidos.toList(),
        ));
    ref.read(missionsProvider.notifier).report(MissionEvent.treinoConcluido);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino concluído! Parabéns! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exercicio;
    final ultimoExercicio = _atual == widget.plan.exercises.length - 1;
    final todosConcluidos = _concluidos.length == widget.plan.exercises.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.plan.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            LinearProgressIndicator(
              value: (_atual + 1) / widget.plan.exercises.length,
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text('Exercício ${_atual + 1} de ${widget.plan.exercises.length}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),

            // Lili motivando
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Row(
                children: [
                  const AnimatedLiliMascot(
                      pose: MascotePose.halteres,
                      mood: LiliMood.viva,
                      height: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_falaLili,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(ex.exerciseName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _info('${ex.series} séries'),
                _info('${ex.repeticoes} reps'),
                _info('${ex.intervaloSegundos}s intervalo'),
                if (ex.metodo.isNotEmpty) _info(ex.metodo),
              ],
            ),
            if (ex.observacoes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(ex.observacoes,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 20),

            if (_descansoRestante > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                ),
                child: Column(
                  children: [
                    const Text('Descansando...',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text('${_descansoRestante}s',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _concluirSerie,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Concluir série'),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _adicionarCarga,
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('Adicionar carga'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: todosConcluidos
                    ? _finalizarTreino
                    : (ultimoExercicio
                        ? () {
                            setState(() => _concluidos.add(ex.exerciseId));
                            _finalizarTreino();
                          }
                        : _concluirExercicio),
                child: Text(ultimoExercicio || todosConcluidos
                    ? 'Finalizar treino 🎉'
                    : 'Próximo exercício'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String t) => Text(t,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13));
}
