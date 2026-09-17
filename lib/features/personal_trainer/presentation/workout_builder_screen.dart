import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';
import 'exercise_library_screen.dart';

class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  const WorkoutBuilderScreen({
    super.key,
    required this.student,
    this.existingPlan,
  });
  final Student student;
  final WorkoutPlan? existingPlan;

  @override
  ConsumerState<WorkoutBuilderScreen> createState() =>
      _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _objectiveController;
  late NivelTreino _nivel;
  late final Set<String> _dias;
  late final List<WorkoutExerciseConfig> _exercicios;

  static const _diasSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];

  bool get _isEditing => widget.existingPlan != null;

  @override
  void initState() {
    super.initState();
    final plan = widget.existingPlan;
    _nameController = TextEditingController(text: plan?.name ?? 'Treino A');
    _objectiveController = TextEditingController(text: plan?.objective ?? '');
    _nivel = plan?.level ?? NivelTreino.iniciante;
    _dias = {...?plan?.diasSemana};
    _exercicios = [...?plan?.exercises];
  }

  Future<void> _adicionarExercicio() async {
    final exercicio = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
          builder: (_) => const ExerciseLibraryScreen(selectMode: true)),
    );
    if (exercicio == null || !mounted) return;

    final seriesController = TextEditingController(text: '${exercicio.defaultSeries}');
    final repsController = TextEditingController(text: exercicio.defaultReps);
    final intervaloController = TextEditingController(text: '60');
    final tempoController = TextEditingController(text: '0');
    final cargaController = TextEditingController(text: 'peso corporal');
    final metodoController = TextEditingController();
    final obsController = TextEditingController();
    final roundsController = TextEditingController(text: '8');
    var effortMode = 'reps';
    var timerProtocol = 'countdown';
    var autoStart = false;
    var autoAdvance = true;

    final ok = await showModalBottomSheet<bool>(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exercicio.name, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Séries',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        TextField(
                            controller: seriesController,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Repetições',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        TextField(controller: repsController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Duração / tempo (segundos, opcional)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              TextField(
                  controller: tempoController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              const Text('Intervalo / descanso (segundos)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              TextField(
                  controller: intervaloController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              const Text('Rodadas (HIIT / EMOM / AMRAP)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              TextField(
                  controller: roundsController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: effortMode,
                decoration: const InputDecoration(labelText: 'Execução'),
                items: const [
                  DropdownMenuItem(value: 'reps', child: Text('Por repetições')),
                  DropdownMenuItem(value: 'time', child: Text('Por tempo')),
                ],
                onChanged: (v) => setSheet(() => effortMode = v ?? effortMode),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: timerProtocol,
                decoration: const InputDecoration(labelText: 'Modo do cronômetro'),
                items: const [
                  DropdownMenuItem(value: 'free', child: Text('Cronômetro livre')),
                  DropdownMenuItem(value: 'countdown', child: Text('Temporizador')),
                  DropdownMenuItem(value: 'hiit', child: Text('HIIT')),
                  DropdownMenuItem(value: 'circuit', child: Text('Circuito')),
                  DropdownMenuItem(value: 'emom', child: Text('EMOM')),
                  DropdownMenuItem(value: 'amrap', child: Text('AMRAP')),
                ],
                onChanged: (v) =>
                    setSheet(() => timerProtocol = v ?? timerProtocol),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Iniciar cronômetro automaticamente'),
                value: autoStart,
                onChanged: (v) => setSheet(() => autoStart = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Abrir próximo exercício automaticamente'),
                value: autoAdvance,
                onChanged: (v) => setSheet(() => autoAdvance = v),
              ),
              const SizedBox(height: 12),
              const Text('Carga sugerida (ex.: 8 kg, peso corporal)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              TextField(controller: cargaController),
              const SizedBox(height: 12),
              const Text('Método (opcional: bi-set, drop-set...)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              TextField(controller: metodoController),
              const SizedBox(height: 12),
              const Text('Observações',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              TextField(controller: obsController, maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Adicionar ao treino'),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );

    if (ok == true) {
      setState(() {
        _exercicios.add(WorkoutExerciseConfig(
          exerciseId: exercicio.id,
          exerciseName: exercicio.name,
          series: int.tryParse(seriesController.text) ?? 3,
          repeticoes: repsController.text.trim(),
          tempoSegundos: int.tryParse(tempoController.text) ?? 0,
          intervaloSegundos: int.tryParse(intervaloController.text) ?? 60,
          carga: cargaController.text.trim(),
          metodo: metodoController.text.trim(),
          observacoes: obsController.text.trim(),
          order: _exercicios.length,
          effortMode: effortMode,
          timerProtocol: timerProtocol,
          rounds: int.tryParse(roundsController.text) ?? 0,
          autoStartTimer: autoStart,
          autoAdvanceNext: autoAdvance,
        ));
      });
    }
    for (final c in [
      seriesController,
      repsController,
      intervaloController,
      tempoController,
      cargaController,
      metodoController,
      obsController,
      roundsController,
    ]) {
      c.dispose();
    }
  }

  Future<void> _salvar() async {
    if (_nameController.text.trim().isEmpty || _exercicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Dê um nome ao treino e adicione ao menos 1 exercício.')));
      return;
    }
    final trainer = ref.read(currentUserProvider) ?? AppUser.uiFallback();
    final existing = widget.existingPlan;
    final plan = WorkoutPlan(
      id: existing?.id ?? '',
      studentId: widget.student.id,
      trainerId: trainer.id,
      name: _nameController.text.trim(),
      objective: _objectiveController.text.trim(),
      level: _nivel,
      diasSemana: _dias.toList(),
      exercises: [
        for (var i = 0; i < _exercicios.length; i++)
          WorkoutExerciseConfig(
            exerciseId: _exercicios[i].exerciseId,
            exerciseName: _exercicios[i].exerciseName,
            series: _exercicios[i].series,
            repeticoes: _exercicios[i].repeticoes,
            tempoSegundos: _exercicios[i].tempoSegundos,
            intervaloSegundos: _exercicios[i].intervaloSegundos,
            carga: _exercicios[i].carga,
            metodo: _exercicios[i].metodo,
            observacoes: _exercicios[i].observacoes,
            order: i,
            effortMode: _exercicios[i].effortMode,
            timerProtocol: _exercicios[i].timerProtocol,
            rounds: _exercicios[i].rounds,
            autoStartTimer: _exercicios[i].autoStartTimer,
            autoAdvanceNext: _exercicios[i].autoAdvanceNext,
          ),
      ],
      createdAt: existing?.createdAt ?? DateTime.now(),
      active: existing?.active ?? true,
    );

    if (_isEditing) {
      await ref.read(ptRepositoryProvider).updateWorkoutPlan(plan);
    } else {
      await ref.read(ptRepositoryProvider).createWorkoutPlan(plan);
    }
    ref.invalidate(ptWorkoutPlansProvider(widget.student.id));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Treino atualizado.'
              : 'Treino criado com sucesso.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: _isEditing
            ? 'Editar treino'
            : 'Treino para ${widget.student.name.split(' ').first}',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: AppIconImage(
              AppIcons.workout,
              size: 26,
              fallbackIcon: Icons.fitness_center,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text('Nome do treino',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _nameController),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final nome in const [
                  'Treino A',
                  'Treino B',
                  'Treino C',
                  'Superior',
                  'Inferior',
                  'Cardio',
                  'Treino personalizado',
                ])
                  ActionChip(
                    label: Text(nome),
                    onPressed: () =>
                        setState(() => _nameController.text = nome),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Objetivo',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _objectiveController),
            const SizedBox(height: 16),
            const Text('Nível',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: NivelTreino.values
                  .map((n) => ChoiceChip(
                        label: Text(n.label),
                        selected: _nivel == n,
                        onSelected: (_) => setState(() => _nivel = n),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Dias da semana',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _diasSemana
                  .map((d) => FilterChip(
                        label: Text(d),
                        selected: _dias.contains(d),
                        onSelected: (sel) => setState(
                            () => sel ? _dias.add(d) : _dias.remove(d)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Exercícios',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _adicionarExercicio,
                  icon: const AppIconImage(
                    AppIcons.complete,
                    size: 18,
                    fallbackIcon: Icons.add,
                  ),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            if (_exercicios.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhum exercício adicionado ainda.',
                    style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercicios.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _exercicios.removeAt(oldIndex);
                    _exercicios.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, i) {
                  final ex = _exercicios[i];
                  return Container(
                    key: ValueKey('${ex.exerciseId}-$i-${ex.order}'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: i,
                          child: const Icon(Icons.drag_handle,
                              color: AppColors.textTertiary),
                        ),
                        const SizedBox(width: 8),
                        Text('${i + 1}.',
                            style: const TextStyle(
                                color: AppColors.textTertiary)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex.exerciseName,
                                  style:
                                      const TextStyle(color: Colors.white)),
                              Text(
                                  '${ex.series}x${ex.repeticoes} · descanso ${ex.intervaloSegundos}s'
                                  '${ex.tempoSegundos > 0 ? ' · ${ex.tempoSegundos}s' : ''}'
                                  '${ex.carga.isNotEmpty ? ' · ${ex.carga}' : ''}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                              if (ex.observacoes.isNotEmpty)
                                Text(ex.observacoes,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.danger, size: 18),
                          onPressed: () =>
                              setState(() => _exercicios.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvar,
                icon: const AppIconImage(
                  AppIcons.complete,
                  size: 20,
                  fallbackIcon: Icons.check,
                ),
                label: Text(_isEditing ? 'Salvar alterações' : 'Salvar treino'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
