import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/youtube_launch.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../evolution/domain/training_volume.dart';
import '../../evolution/presentation/personal_records_screen.dart';
import '../../missions/providers/missions_providers.dart';
import '../../workout_timer/domain/timer_blueprints.dart';
import '../../workout_timer/presentation/workout_timer_screen.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';

const _falasLili = [
  'Você consegue!',
  'Mais uma série!',
  'Excelente execução!',
  'Continua assim!',
  'Hora da água depois dessa série.',
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
  double _volumeSessao = 0;

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
    final kgCtrl = TextEditingController(
      text: TrainingVolume.parseWeight(_exercicio.carga)?.toString() ?? '',
    );
    final seriesCtrl = TextEditingController(
      text: _exercicio.series > 0 ? '${_exercicio.series}' : '',
    );
    final repsCtrl = TextEditingController(
      text: '${TrainingVolume.parseReps(_exercicio.repeticoes) ?? ''}',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Carga utilizada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kgCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Carga', suffixText: 'kg'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: seriesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Séries'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    final peso = TrainingVolume.parseWeight(kgCtrl.text);
    final series = int.tryParse(seriesCtrl.text.trim());
    final reps = int.tryParse(repsCtrl.text.trim());
    kgCtrl.dispose();
    seriesCtrl.dispose();
    repsCtrl.dispose();
    if (ok != true || peso == null) return;

    final anteriores = (ref.read(ptLoadsProvider(widget.student.id)).valueOrNull ??
            const <LoadEntry>[])
        .where((e) => e.exerciseId == _exercicio.exerciseId)
        .toList();
    final recorde = ExerciseLoadStats.isNewWeightRecord(
      historicoAnterior: anteriores,
      novaCarga: peso,
    );

    await ref.read(ptRepositoryProvider).logLoad(LoadEntry(
          id: '',
          studentId: widget.student.id,
          trainerId: widget.student.trainerId.isNotEmpty
              ? widget.student.trainerId
              : widget.plan.trainerId,
          exerciseId: _exercicio.exerciseId,
          exerciseName: _exercicio.exerciseName,
          date: DateTime.now(),
          weightKg: peso,
          series: (series != null && series > 0) ? series : null,
          repeticoes: (reps != null && reps > 0) ? reps : null,
          userId: widget.student.userId,
        ));

    final volume = TrainingVolume.of(
      weightKg: peso,
      reps: reps ?? 0,
      series: series ?? 0,
    );
    if (volume != null) {
      setState(() => _volumeSessao += volume);
    }

    ref.invalidate(ptLoadsProvider(widget.student.id));

    if (!mounted) return;
    if (recorde) {
      await FeedbackService.play(FeedbackEvent.conquista);
      if (!mounted) return;
      await celebrarRecordeDeCarga(
        context,
        exercicio: _exercicio.exerciseName,
        cargaLabel: TrainingVolume.formatKg(peso, decimals: 1),
      );
    } else if (mounted) {
      final extra = volume == null
          ? ''
          : ' · volume ${TrainingVolume.formatVolume(volume)}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carga registrada: ${TrainingVolume.formatKg(peso, decimals: 1)}$extra')),
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
    String difficulty = 'adequado';
    bool? feltPain;
    String tiredness = 'medio';
    final notesCtrl = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Como foi o treino?',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                if (_volumeSessao > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Volume: ${TrainingVolume.formatVolume(_volumeSessao)}',
                    style: const TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.w700),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in const [
                      ('muito_leve', 'Muito leve'),
                      ('adequado', 'Adequado'),
                      ('dificil', 'Difícil'),
                      ('muito_dificil', 'Muito difícil'),
                    ])
                      ChoiceChip(
                        label: Text(e.$2),
                        selected: difficulty == e.$1,
                        onSelected: (_) =>
                            setSheet(() => difficulty = e.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Sentiu dor?',
                    style: TextStyle(color: AppColors.textSecondary)),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Não'),
                      selected: feltPain == false,
                      onSelected: (_) => setSheet(() => feltPain = false),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Sim'),
                      selected: feltPain == true,
                      onSelected: (_) => setSheet(() => feltPain = true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Cansaço',
                    style: TextStyle(color: AppColors.textSecondary)),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final e in const [
                      ('baixo', 'Baixo'),
                      ('medio', 'Médio'),
                      ('alto', 'Alto'),
                    ])
                      ChoiceChip(
                        label: Text(e.$2),
                        selected: tiredness == e.$1,
                        onSelected: (_) =>
                            setSheet(() => tiredness = e.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Observações (opcional)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Concluir treino'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true) {
      notesCtrl.dispose();
      return;
    }

    await ref.read(ptRepositoryProvider).logSession(WorkoutSessionLog(
          id: '',
          studentId: widget.student.id,
          trainerId: widget.student.trainerId.isNotEmpty
              ? widget.student.trainerId
              : widget.plan.trainerId,
          workoutPlanId: widget.plan.id,
          workoutName: widget.plan.name,
          date: DateTime.now(),
          completedExerciseIds: _concluidos.toList(),
          difficulty: difficulty,
          feltPain: feltPain,
          tiredness: tiredness,
          feedbackNotes: notesCtrl.text.trim(),
          totalVolumeKg: _volumeSessao > 0 ? _volumeSessao : null,
        ));
    notesCtrl.dispose();
    ref.invalidate(ptSessionsProvider(widget.student.id));
    ref.invalidate(ptDashboardStatsProvider(widget.student.trainerId.isNotEmpty
        ? widget.student.trainerId
        : widget.plan.trainerId));
    ref.read(missionsProvider.notifier).report(MissionEvent.treinoConcluido);
    await FeedbackService.play(FeedbackEvent.sucesso);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_volumeSessao > 0
              ? 'Treino concluído! Volume ${TrainingVolume.formatVolume(_volumeSessao)}'
              : 'Treino concluído! Parabéns!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exercicio;
    final ultimoExercicio = _atual == widget.plan.exercises.length - 1;
    final todosConcluidos = _concluidos.length == widget.plan.exercises.length;

    return PopScope(
      canPop: _descansoRestante == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Sair do treino?'),
            content: const Text(
              'O treino ainda está em andamento. Deseja sair?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Continuar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Sair', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        if (leave == true && mounted) {
          _timer?.cancel();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: widget.plan.name,
        showStaffSignOut: true,
      ),
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
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppColors.border),
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
            const SizedBox(height: 10),
            Builder(builder: (context) {
              final exercises = ref.watch(ptExercisesProvider).valueOrNull ?? [];
              Exercise? lib;
              for (final e in exercises) {
                if (e.id == ex.exerciseId) {
                  lib = e;
                  break;
                }
              }
              final video = lib?.videoUrl ?? '';
              if (video.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => YoutubeLaunch.open(context, video),
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text('Assistir vídeo do exercício'),
                  ),
                ),
              );
            }),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  label: '${ex.series} séries',
                  iconAsset: AppIcons.workoutGoal,
                  fallback: Icons.repeat_rounded,
                ),
                _MetaChip(
                  label: '${ex.repeticoes} reps',
                  iconAsset: AppIcons.stopwatch,
                  fallback: Icons.bolt_rounded,
                ),
                _MetaChip(
                  label: '${ex.intervaloSegundos}s descanso',
                  iconAsset: AppIcons.timer,
                  fallback: Icons.timer_outlined,
                ),
                if (ex.carga.isNotEmpty)
                  _MetaChip(
                    label: ex.carga,
                    iconAsset: AppIcons.workout,
                    fallback: Icons.fitness_center,
                  ),
                if (ex.metodo.isNotEmpty)
                  _MetaChip(
                    label: ex.metodo,
                    iconAsset: AppIcons.checklist,
                    fallback: Icons.list_alt,
                  ),
              ],
            ),
            if (ex.observacoes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(ex.observacoes,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutTimerScreen(
                        blueprint: blueprintFromPlan(widget.plan),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.timer_outlined),
                label: const Text('INICIAR CRONÔMETRO'),
              ),
            ),
            const SizedBox(height: 12),
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
                    const AppIconImage(
                      AppIcons.timer,
                      size: 28,
                      fallbackIcon: Icons.timer_outlined,
                    ),
                    const SizedBox(height: 8),
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
                  icon: const AppIconImage(
                    AppIcons.complete,
                    size: 20,
                    fallbackIcon: Icons.check_circle_outline,
                  ),
                  label: const Text('Concluir série'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _adicionarCarga,
                icon: const AppIconImage(
                  AppIcons.workout,
                  size: 20,
                  fallbackIcon: Icons.fitness_center,
                ),
                label: const Text('Adicionar carga'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: todosConcluidos
                    ? _finalizarTreino
                    : (ultimoExercicio
                        ? () {
                            setState(() => _concluidos.add(ex.exerciseId));
                            _finalizarTreino();
                          }
                        : _concluirExercicio),
                icon: AppIconImage(
                  ultimoExercicio || todosConcluidos
                      ? AppIcons.trophy
                      : AppIcons.next,
                  size: 20,
                  fallbackIcon: ultimoExercicio || todosConcluidos
                      ? Icons.emoji_events_outlined
                      : Icons.arrow_forward,
                ),
                label: Text(ultimoExercicio || todosConcluidos
                    ? 'Finalizar treino'
                    : 'Próximo exercício'),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.iconAsset,
    required this.fallback,
  });
  final String label;
  final String iconAsset;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconImage(iconAsset, size: 14, fallbackIcon: fallback),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12.5)),
        ],
      ),
    );
  }
}
