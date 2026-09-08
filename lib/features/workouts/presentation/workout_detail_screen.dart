import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/youtube_launch.dart';
import '../../../core/assets/app_icons.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/seed_data.dart';
import '../../../core/design_system/app_breakpoints.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/domain_models.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import 'workout_category_visual.dart';

const _kDescansoPadraoSegundos = 45;

class _ExerciseRow {
  const _ExerciseRow({
    required this.name,
    required this.series,
    required this.effort,
    required this.rest,
    required this.equipment,
    required this.load,
    required this.instructions,
    this.videoUrl,
  });
  final String name;
  final String series;
  final String effort;
  final String rest;
  final String equipment;
  final String load;
  final String instructions;
  final String? videoUrl;
}

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
  bool _emAndamento = false;
  bool _pausado = false;
  int _currentIndex = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isCardio {
    final hay =
        '${widget.workout.tags.join(' ')} ${widget.workout.title}'.toLowerCase();
    return hay.contains('cardio') ||
        hay.contains('hiit') ||
        hay.contains('corrida') ||
        hay.contains('caminhada') ||
        hay.contains('bike') ||
        hay.contains('bicicleta');
  }

  List<_ExerciseRow> get _exercises {
    final names = SeedData.workoutExercises[widget.workout.id];
    final list = (names != null && names.isNotEmpty)
        ? names
        : _isCardio
            ? <String>[
                'Aquecimento',
                widget.workout.title,
                'Volta à calma',
              ]
            : const <String>[
                'Aquecimento',
                'Exercício principal',
                'Alongamento',
              ];
    final minutos = (widget.workout.durationMin / list.length)
        .clamp(1, widget.workout.durationMin)
        .round();
    final equipment = _equipment.join(', ');
    return [
      for (final name in list)
        _ExerciseRow(
          name: name,
          series: _isCardio ? '1 bloco' : '3 séries',
          effort: _isCardio ? '$minutos min' : '12 reps',
          rest: _isCardio
              ? 'sem pausa longa'
              : '${_kDescansoPadraoSegundos}s de descanso',
          equipment: equipment,
          load: _isCardio ? 'Ritmo moderado' : 'Carga confortável',
          instructions: _isCardio
              ? 'Mantenha o ritmo constante, respire pelo nariz e foque na postura.'
              : 'Controle a subida e a descida, evite impulsos e complete as reps com qualidade.',
          videoUrl: null,
        ),
    ];
  }

  void _iniciarTreino() {
    FeedbackService.play(FeedbackEvent.toqueLeve);
    setState(() {
      _emAndamento = true;
      _pausado = false;
      _currentIndex = 0;
    });
  }

  void _irParaExercicio(int index) {
    final exercises = _exercises;
    if (exercises.isEmpty) return;
    setState(() {
      _currentIndex = index.clamp(0, exercises.length - 1);
      _pausado = false;
    });
  }

  void _marcarExercicio(int index) {
    if (!_emAndamento) {
      _iniciarTreino();
    }
    if (_concluidos.contains(index)) return;
    FeedbackService.play(FeedbackEvent.toqueLeve);
    setState(() {
      _concluidos.add(index);
      _currentIndex = index;
      _descansoRestante = _isCardio ? 0 : _kDescansoPadraoSegundos;
    });
    _timer?.cancel();
    if (_descansoRestante <= 0) {
      final next = index + 1;
      if (next < _exercises.length) {
        setState(() => _currentIndex = next);
      }
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_pausado) return;
      if (_descansoRestante <= 1) {
        t.cancel();
        setState(() {
          _descansoRestante = 0;
          final next = index + 1;
          if (next < _exercises.length) _currentIndex = next;
        });
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
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedLiliMascot(
              pose: MascotePose.joinha,
              mood: LiliMood.comemorando,
              height: 140,
            ),
            const SizedBox(height: 12),
            Text(
              'Treino concluído! +${AppConstants.xpPerWorkout} XP\n'
              '+${AppConstants.coinsPerWorkout} moedas',
              textAlign: TextAlign.center,
              style: AppTextStyles.title(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Continuar',
              style: AppTextStyles.caption(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  List<String> get _muscles {
    final tags = widget.workout.tags.map((e) => e.toLowerCase()).toList();
    if (tags.any((t) => t.contains('glút') || t.contains('glut'))) {
      return const ['Glúteos', 'Pernas', 'Core'];
    }
    if (tags.any((t) => t.contains('cardio') || t.contains('hiit'))) {
      return const ['Corpo todo', 'Cardio', 'Core'];
    }
    if (tags.any((t) => t.contains('along'))) {
      return const ['Corpo todo', 'Mobilidade'];
    }
    if (tags.any((t) => t.contains('abdô') || t.contains('abdo'))) {
      return const ['Abdômen', 'Core'];
    }
    return const [
      'Peito',
      'Costas',
      'Pernas',
      'Ombros',
      'Braços',
      'Abdômen',
    ];
  }

  List<String> get _equipment {
    final tags = widget.workout.tags.map((e) => e.toLowerCase()).toList();
    if (tags.any((t) => t.contains('along') || t.contains('casa'))) {
      return const ['Colchonete'];
    }
    if (tags.any((t) => t.contains('cardio') || t.contains('hiit'))) {
      return const ['Colchonete', 'Peso corporal'];
    }
    return const ['Halteres', 'Barra', 'Colchonete'];
  }

  @override
  Widget build(BuildContext context) {
    try {
      final workout = widget.workout;
      if (workout.id.isEmpty && workout.title.trim().isEmpty) {
        return _MissingWorkoutScaffold(
          onBack: () => Navigator.of(context).maybePop(),
        );
      }
      return _buildLoaded(context, workout);
    } catch (e, st) {
      debugPrint('WorkoutDetailScreen falhou: $e\n$st');
      return _MissingWorkoutScaffold(
        message: 'Não foi possível abrir este treino.',
        detail: kDebugMode ? '$e' : null,
        onBack: () => Navigator.of(context).maybePop(),
      );
    }
  }

  Widget _buildLoaded(BuildContext context, Workout workout) {
    final exercises = _exercises;
    final wide = context.isDesktopLayout || context.isTabletLayout;
    final category = workout.tags.isEmpty
        ? 'Treino'
        : workout.tags.take(2).join(' • ');
    final description =
        '${workout.title} — ${workout.durationMin} min, nível ${workout.level}, '
        'com ${exercises.length} ${exercises.length == 1 ? 'exercício' : 'exercícios'}. '
        'Siga as séries, as repetições ou o tempo indicado e descanse entre os blocos.';

    const tips = LilyTipsCard(
      tips: [
        LilyTip(
          title: 'Aqueça-se',
          body: 'Faça 5–10 min de aquecimento antes de iniciar.',
        ),
        LilyTip(
          title: 'Hidrate-se',
          body: 'Beba água durante todo o treino.',
        ),
        LilyTip(
          title: 'Descanse',
          body: 'Descanse de 60 a 90 segundos entre as séries.',
        ),
        LilyTip(
          title: 'Consistência',
          body: 'Treine com constância e acompanhe sua evolução.',
        ),
      ],
    );

    final content = <Widget>[
      if (_emAndamento)
        _ExercisePlayer(
          workout: workout,
          exercise: exercises[_currentIndex.clamp(0, exercises.length - 1)],
          index: _currentIndex.clamp(0, exercises.length - 1),
          total: exercises.length,
          descanso: _descansoRestante,
          pausado: _pausado,
          wide: wide,
          onPrev: _currentIndex > 0
              ? () => _irParaExercicio(_currentIndex - 1)
              : null,
          onNext: _currentIndex < exercises.length - 1
              ? () => _irParaExercicio(_currentIndex + 1)
              : null,
          onPauseToggle: () => setState(() => _pausado = !_pausado),
          onCompleteExercise: () =>
              _marcarExercicio(_currentIndex.clamp(0, exercises.length - 1)),
        )
      else
        _Hero(workout: workout, wide: wide),
      const SizedBox(height: 16),
      Text(workout.title, style: AppTextStyles.h2()),
      const SizedBox(height: 4),
      Text(category, style: AppTextStyles.caption()),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MetaPill(
            icon: Icons.timer_outlined,
            iconAsset: AppIcons.stopwatch,
            text: '${workout.durationMin} min',
          ),
          _MetaPill(
            icon: Icons.bar_chart_rounded,
            iconAsset: AppIcons.progress,
            text: workout.level,
          ),
          _MetaPill(
            icon: Icons.fitness_center_outlined,
            iconAsset: AppIcons.workout,
            text:
                '${exercises.length} ${exercises.length == 1 ? 'exercício' : 'exercícios'}',
          ),
          if (workout.kcal != null)
            _MetaPill(
              icon: Icons.local_fire_department_outlined,
              iconAsset: AppIcons.calories,
              text: '${workout.kcal} kcal',
            ),
        ],
      ),
      const SizedBox(height: 16),
      Text('Descrição', style: AppTextStyles.h3()),
      const SizedBox(height: 8),
      Text(description, style: AppTextStyles.bodySecondary()),
      const SizedBox(height: 18),
      Text('Grupos musculares', style: AppTextStyles.h3()),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _muscles
            .map(
              (m) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(m, style: AppTextStyles.caption(color: Colors.white)),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 18),
      Text('Equipamentos', style: AppTextStyles.h3()),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _equipment
            .map(
              (e) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  e,
                  style: AppTextStyles.caption(color: AppColors.secondary),
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 20),
      if (!_emAndamento) ...[
        PrimaryButton(
          label: 'Iniciar treino',
          icon: Icons.play_arrow_rounded,
          iconAsset: AppIcons.play,
          onPressed: _iniciarTreino,
        ),
        const SizedBox(height: 16),
      ],
      SectionHeader(
        title: 'Exercícios (${_concluidos.length}/${exercises.length})',
      ),
      const SizedBox(height: 10),
      for (var i = 0; i < exercises.length; i++)
        _ExerciseCard(
          index: i,
          item: exercises[i],
          feito: _concluidos.contains(i),
          active: _emAndamento && i == _currentIndex,
          onTap: () {
            if (_emAndamento) {
              _irParaExercicio(i);
            } else {
              _marcarExercicio(i);
            }
          },
        ),
      const SizedBox(height: 12),
      if (_emAndamento)
        PrimaryButton(
          label: 'Concluir treino (+${AppConstants.xpPerWorkout} XP)',
          icon: Icons.check_rounded,
          onPressed: _concluirTreino,
        ),
      if (!wide) ...[
        const SizedBox(height: 20),
        tips,
      ],
      const SizedBox(height: 12),
    ];

    return PopScope(
      canPop: !_emAndamento,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_emAndamento) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text('Sair do treino?', style: AppTextStyles.title()),
            content: Text(
              'O treino ainda está em andamento. Deseja sair?',
              style: AppTextStyles.bodySecondary(),
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
        if (leave == true && context.mounted) {
          _timer?.cancel();
          setState(() {
            _emAndamento = false;
            _pausado = false;
            _descansoRestante = 0;
          });
          if (context.mounted) Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(title: workout.title),
      body: SafeArea(
        child: AppPage(
          scrollable: false,
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(4, 8, 12, 28),
                        children: content,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(8, 8, 4, 28),
                        children: [tips],
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 28),
                  children: content,
                ),
        ),
      ),
    ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.workout, required this.wide});
  final Workout workout;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: wide ? 21 / 9 : 16 / 10,
        child: WorkoutCoverImage(
          workout: workout,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          fallbackIconSize: wide ? 120 : 96,
        ),
      ),
    );
  }
}

/// Player do exercício atual — substitui a área hero rosa vazia durante o treino.
class _ExercisePlayer extends StatelessWidget {
  const _ExercisePlayer({
    required this.workout,
    required this.exercise,
    required this.index,
    required this.total,
    required this.descanso,
    required this.pausado,
    required this.wide,
    required this.onPrev,
    required this.onNext,
    required this.onPauseToggle,
    required this.onCompleteExercise,
  });

  final Workout workout;
  final _ExerciseRow exercise;
  final int index;
  final int total;
  final int descanso;
  final bool pausado;
  final bool wide;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onPauseToggle;
  final VoidCallback onCompleteExercise;

  @override
  Widget build(BuildContext context) {
    final hasVideo =
        exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty;

    return AppCard(
      glow: true,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: wide ? 16 / 7 : 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasVideo)
                    Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppIconImage(
                            AppIcons.play,
                            size: 56,
                            fallbackIcon: Icons.play_circle_fill,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vídeo do exercício',
                            style: AppTextStyles.caption(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () => YoutubeLaunch.open(
                              context,
                              exercise.videoUrl!,
                            ),
                            child: Text(
                              'Assistir vídeo',
                              style: AppTextStyles.caption(
                                  color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    WorkoutCoverImage(
                      workout: workout,
                      fit: BoxFit.cover,
                      fallbackIconSize: wide ? 110 : 88,
                    ),
                  if (pausado)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text('PAUSADO',
                          style: AppTextStyles.title(color: Colors.white)),
                    ),
                  if (descanso > 0)
                    Container(
                      color: Colors.black.withOpacity(0.72),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('DESCANSO',
                              style: AppTextStyles.caption(color: Colors.white)),
                          Text('${descanso}s',
                              style: AppTextStyles.display(size: 42)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Exercício ${index + 1} de $total',
            style: AppTextStyles.caption(color: AppColors.secondary)
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(exercise.name, style: AppTextStyles.h2()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(
                icon: Icons.repeat_rounded,
                iconAsset: AppIcons.workoutGoal,
                text: exercise.series,
              ),
              _MetaPill(
                icon: Icons.bolt_rounded,
                iconAsset: AppIcons.stopwatch,
                text: exercise.effort,
              ),
              _MetaPill(
                icon: Icons.timer_outlined,
                iconAsset: AppIcons.timer,
                text: exercise.rest,
              ),
              _MetaPill(
                icon: Icons.fitness_center_outlined,
                iconAsset: AppIcons.workout,
                text: exercise.load,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Equipamento: ${exercise.equipment}',
            style: AppTextStyles.caption(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.instructions,
            style: AppTextStyles.caption().copyWith(height: 1.35),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.skip_previous_rounded, size: 18),
                  label: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPauseToggle,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surface2,
                    foregroundColor: Colors.white,
                  ),
                  icon: AppIconImage(
                    pausado ? AppIcons.play : AppIcons.pause,
                    size: 18,
                    fallbackIcon: pausado
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                  ),
                  label: Text(pausado ? 'Continuar' : 'Pausar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('Próximo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Concluir exercício',
            icon: Icons.check_circle_outline_rounded,
            iconAsset: AppIcons.complete,
            height: 46,
            onPressed: onCompleteExercise,
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.index,
    required this.item,
    required this.feito,
    required this.onTap,
    this.active = false,
  });
  final int index;
  final _ExerciseRow item;
  final bool feito;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        glow: active,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: feito
                    ? AppColors.success.withOpacity(0.2)
                    : active
                        ? AppColors.secondary.withOpacity(0.2)
                        : AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: feito
                      ? AppColors.success
                      : active
                          ? AppColors.secondary
                          : AppColors.border,
                ),
              ),
              child: feito
                  ? const Icon(Icons.check, size: 20, color: AppColors.success)
                  : Text(
                      '${index + 1}',
                      style: AppTextStyles.title(color: AppColors.secondary),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.title().copyWith(
                      color: feito ? AppColors.textSecondary : Colors.white,
                      decoration: feito ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.series} • ${item.effort} • ${item.rest}',
                    style: AppTextStyles.caption(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.load} · ${item.equipment}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: AppColors.textTertiary),
                  ),
                  if (item.videoUrl != null && item.videoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Vídeo / YouTube disponível',
                        style: AppTextStyles.caption(color: AppColors.secondary)),
                  ],
                ],
              ),
            ),
            const AppIconImage(
              AppIcons.next,
              size: 18,
              fallbackIcon: Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingWorkoutScaffold extends StatelessWidget {
  const _MissingWorkoutScaffold({
    required this.onBack,
    this.message = 'Treino não encontrado.',
    this.detail,
  });
  final VoidCallback onBack;
  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Treino'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(message, style: AppTextStyles.h2(), textAlign: TextAlign.center),
              if (detail != null) ...[
                const SizedBox(height: 12),
                Text(detail!,
                    style: AppTextStyles.caption(), textAlign: TextAlign.center),
              ],
              const Spacer(),
              PrimaryButton(
                label: 'Voltar',
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.text,
    this.iconAsset,
  });
  final IconData icon;
  final String text;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null)
            AppIconImage(
              iconAsset!,
              size: 16,
              fallbackIcon: icon,
            )
          else
            Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.caption(color: Colors.white)),
        ],
      ),
    );
  }
}
