import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../models/app_user.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';
import 'exercise_library_screen.dart';

class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  const WorkoutBuilderScreen({super.key, required this.student});
  final Student student;

  @override
  ConsumerState<WorkoutBuilderScreen> createState() =>
      _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  final _nameController = TextEditingController(text: 'Treino A');
  final _objectiveController = TextEditingController();
  NivelTreino _nivel = NivelTreino.iniciante;
  final Set<String> _dias = {};
  final List<WorkoutExerciseConfig> _exercicios = [];

  static const _diasSemana = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];

  Future<void> _adicionarExercicio() async {
    final exercicio = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
          builder: (_) => const ExerciseLibraryScreen(selectMode: true)),
    );
    if (exercicio == null || !mounted) return;

    final seriesController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '12');
    final intervaloController = TextEditingController(text: '60');
    final metodoController = TextEditingController();
    final obsController = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
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
              const Text('Intervalo (segundos)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              TextField(
                  controller: intervaloController,
                  keyboardType: TextInputType.number),
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
    );

    if (ok == true) {
      setState(() {
        _exercicios.add(WorkoutExerciseConfig(
          exerciseId: exercicio.id,
          exerciseName: exercicio.name,
          series: int.tryParse(seriesController.text) ?? 3,
          repeticoes: repsController.text.trim(),
          intervaloSegundos: int.tryParse(intervaloController.text) ?? 60,
          metodo: metodoController.text.trim(),
          observacoes: obsController.text.trim(),
          order: _exercicios.length,
        ));
      });
    }
  }

  Future<void> _salvar() async {
    if (_nameController.text.trim().isEmpty || _exercicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Dê um nome ao treino e adicione ao menos 1 exercício.')));
      return;
    }
    final trainer = ref.read(currentUserProvider) ?? AppUser.demo();
    await ref.read(ptRepositoryProvider).createWorkoutPlan(WorkoutPlan(
          id: '',
          studentId: widget.student.id,
          trainerId: trainer.id,
          name: _nameController.text.trim(),
          objective: _objectiveController.text.trim(),
          level: _nivel,
          diasSemana: _dias.toList(),
          exercises: _exercicios,
          createdAt: DateTime.now(),
        ));
    ref.invalidate(ptWorkoutPlansProvider(widget.student.id));
    if (mounted) Navigator.pop(context);
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
      appBar: AppBar(title: Text('Treino para ${widget.student.name}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text('Nome do treino',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _nameController),
            const SizedBox(height: 16),
            const Text('Objetivo',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: _objectiveController),
            const SizedBox(height: 16),
            const Text('Nível',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  icon: const Icon(Icons.add),
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
              ...List.generate(_exercicios.length, (i) {
                final ex = _exercicios[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Text('${i + 1}.',
                          style: const TextStyle(color: AppColors.textTertiary)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex.exerciseName,
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                '${ex.series}x${ex.repeticoes} · ${ex.intervaloSegundos}s intervalo',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.danger, size: 18),
                        onPressed: () => setState(() => _exercicios.removeAt(i)),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: const Text('Salvar treino'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
