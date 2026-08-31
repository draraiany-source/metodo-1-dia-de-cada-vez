import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';

/// Banco de exercícios — usado tanto pelo Personal pra cadastrar/consultar
/// (`isAdmin: true`) quanto pelo criador de treinos pra escolher um
/// exercício (`selectMode: true`, retorna o [Exercise] escolhido via pop).
class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen(
      {super.key, this.isAdmin = false, this.selectMode = false});
  final bool isAdmin;
  final bool selectMode;

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  MuscleGroup? _filtro;

  Future<void> _novoExercicio(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final videoController = TextEditingController();
    final gifController = TextEditingController();
    final photoController = TextEditingController();
    final techniqueController = TextEditingController();
    final mistakesController = TextEditingController();
    var grupo = MuscleGroup.peito;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Novo exercício', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                _label('Nome'),
                TextField(controller: nameController),
                const SizedBox(height: 12),
                _label('Grupo muscular'),
                DropdownButtonFormField<MuscleGroup>(
                  value: grupo,
                  items: MuscleGroup.values
                      .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => grupo = v ?? grupo),
                ),
                const SizedBox(height: 12),
                _label('Descrição'),
                TextField(controller: descController, maxLines: 2),
                const SizedBox(height: 12),
                _label('URL do vídeo'),
                TextField(controller: videoController),
                const SizedBox(height: 12),
                _label('URL do GIF'),
                TextField(controller: gifController),
                const SizedBox(height: 12),
                _label('URL da foto'),
                TextField(controller: photoController),
                const SizedBox(height: 12),
                _label('Técnica correta'),
                TextField(controller: techniqueController, maxLines: 2),
                const SizedBox(height: 12),
                _label('Erros comuns'),
                TextField(controller: mistakesController, maxLines: 2),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Salvar no banco de exercícios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && nameController.text.trim().isNotEmpty) {
      await ref.read(ptRepositoryProvider).createExercise(Exercise(
            id: '',
            name: nameController.text.trim(),
            muscleGroup: grupo,
            description: descController.text.trim(),
            videoUrl: videoController.text.trim(),
            gifUrl: gifController.text.trim(),
            photoUrl: photoController.text.trim(),
            technique: techniqueController.text.trim(),
            commonMistakes: mistakesController.text.trim(),
          ));
      ref.invalidate(ptExercisesProvider);
    }
    for (final c in [
      nameController,
      descController,
      videoController,
      gifController,
      photoController,
      techniqueController,
      mistakesController,
    ]) {
      c.dispose();
    }
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      );

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(ptExercisesProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.selectMode
              ? 'Escolher exercício'
              : 'Banco de exercícios 💪')),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _novoExercicio(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: exercisesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Não consegui carregar.',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (exercises) {
            final filtrados = _filtro == null
                ? exercises
                : exercises.where((e) => e.muscleGroup == _filtro).toList();
            return Column(
              children: [
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Todos'),
                          selected: _filtro == null,
                          onSelected: (_) => setState(() => _filtro = null),
                        ),
                      ),
                      ...MuscleGroup.values.map((g) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(g.label),
                              selected: _filtro == g,
                              onSelected: (_) => setState(() => _filtro = g),
                            ),
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: exercises.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'Nenhum exercício cadastrado ainda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textSecondary)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filtrados.length,
                          itemBuilder: (_, i) {
                            final e = filtrados[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.background,
                                  backgroundImage: e.photoUrl.isNotEmpty
                                      ? NetworkImage(e.photoUrl)
                                      : null,
                                  child: e.photoUrl.isEmpty
                                      ? const Icon(Icons.fitness_center,
                                          color: AppColors.textTertiary, size: 18)
                                      : null,
                                ),
                                title: Text(e.name,
                                    style: const TextStyle(color: Colors.white)),
                                subtitle: Text(e.muscleGroup.label,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                onTap: widget.selectMode
                                    ? () => Navigator.of(context).pop(e)
                                    : null,
                              ),
                            );
                          },
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
