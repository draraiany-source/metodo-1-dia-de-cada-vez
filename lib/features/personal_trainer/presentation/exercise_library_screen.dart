import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/youtube_launch.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';

/// Banco de exercícios — cadastrar/editar/prévia de vídeo sem recompilar o app.
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

  Future<void> _abrirFormulario({Exercise? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    final videoController =
        TextEditingController(text: existing?.videoUrl ?? '');
    final gifController = TextEditingController(text: existing?.gifUrl ?? '');
    final photoController =
        TextEditingController(text: existing?.photoUrl ?? '');
    final techniqueController =
        TextEditingController(text: existing?.technique ?? '');
    final mistakesController =
        TextEditingController(text: existing?.commonMistakes ?? '');
    final equipmentController =
        TextEditingController(text: existing?.equipment ?? '');
    final seriesController =
        TextEditingController(text: '${existing?.defaultSeries ?? 3}');
    final repsController =
        TextEditingController(text: existing?.defaultReps ?? '12');
    final obsController =
        TextEditingController(text: existing?.observacoes ?? '');
    var grupo = existing?.muscleGroup ?? MuscleGroup.peito;
    var nivel = existing?.level ?? NivelTreino.iniciante;

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
                Text(existing == null ? 'Novo exercício' : 'Editar exercício',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                _label('Nome'),
                TextField(controller: nameController),
                const SizedBox(height: 12),
                _label('Grupo muscular'),
                DropdownButtonFormField<MuscleGroup>(
                  value: grupo,
                  items: MuscleGroup.values
                      .map((g) =>
                          DropdownMenuItem(value: g, child: Text(g.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => grupo = v ?? grupo),
                ),
                const SizedBox(height: 12),
                _label('Nível'),
                DropdownButtonFormField<NivelTreino>(
                  value: nivel,
                  items: NivelTreino.values
                      .map((n) =>
                          DropdownMenuItem(value: n, child: Text(n.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => nivel = v ?? nivel),
                ),
                const SizedBox(height: 12),
                _label('Equipamento'),
                TextField(
                  controller: equipmentController,
                  decoration: const InputDecoration(
                      hintText: 'Halteres, máquina, peso corporal…'),
                ),
                const SizedBox(height: 12),
                _label('Descrição'),
                TextField(controller: descController, maxLines: 2),
                const SizedBox(height: 12),
                _label('Link do YouTube / vídeo'),
                TextField(
                  controller: videoController,
                  decoration: const InputDecoration(
                    hintText: 'https://youtube.com/watch?v=…',
                  ),
                  onChanged: (_) => setSheetState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: videoController.text.trim().isEmpty
                            ? null
                            : () => YoutubeLaunch.open(
                                ctx, videoController.text.trim()),
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Prévia do vídeo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dica: use links públicos do YouTube. Vídeos privados não abrem no app.',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 12),
                _label('URL do GIF (opcional)'),
                TextField(controller: gifController),
                const SizedBox(height: 12),
                _label('URL da capa/foto (opcional)'),
                TextField(controller: photoController),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Séries padrão'),
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
                          _label('Reps padrão'),
                          TextField(controller: repsController),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _label('Técnica correta'),
                TextField(controller: techniqueController, maxLines: 2),
                const SizedBox(height: 12),
                _label('Erros comuns'),
                TextField(controller: mistakesController, maxLines: 2),
                const SizedBox(height: 12),
                _label('Observações'),
                TextField(controller: obsController, maxLines: 2),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(existing == null
                        ? 'Salvar no banco de exercícios'
                        : 'Salvar alterações'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && nameController.text.trim().isNotEmpty) {
      final exercise = Exercise(
        id: existing?.id ?? '',
        name: nameController.text.trim(),
        muscleGroup: grupo,
        description: descController.text.trim(),
        videoUrl: videoController.text.trim(),
        gifUrl: gifController.text.trim(),
        photoUrl: photoController.text.trim(),
        technique: techniqueController.text.trim(),
        commonMistakes: mistakesController.text.trim(),
        equipment: equipmentController.text.trim(),
        level: nivel,
        defaultSeries: int.tryParse(seriesController.text) ?? 3,
        defaultReps: repsController.text.trim().isEmpty
            ? '12'
            : repsController.text.trim(),
        observacoes: obsController.text.trim(),
        storageVideoPath: existing?.storageVideoPath ?? '',
        active: true,
      );
      if (existing == null) {
        await ref.read(ptRepositoryProvider).createExercise(exercise);
      } else {
        await ref.read(ptRepositoryProvider).updateExercise(exercise);
      }
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
      equipmentController,
      seriesController,
      repsController,
      obsController,
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
            : 'Banco de exercícios'),
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
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _abrirFormulario(),
              child: const AppIconImage(
                AppIcons.complete,
                size: 24,
                fallbackIcon: Icons.add,
              ),
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
                                'Nenhum exercício cadastrado ainda.\nCadastre pelo painel — sem alterar o código.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: AppColors.textSecondary)),
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
                                      ? const AppIconImage(
                                          AppIcons.workout,
                                          size: 18,
                                          fallbackIcon: Icons.fitness_center,
                                        )
                                      : null,
                                ),
                                title: Text(e.name,
                                    style: const TextStyle(color: Colors.white)),
                                subtitle: Text(
                                  [
                                    e.muscleGroup.label,
                                    if (e.equipment.isNotEmpty) e.equipment,
                                    if (e.videoUrl.isNotEmpty) 'YouTube',
                                  ].join(' · '),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (e.videoUrl.isNotEmpty)
                                      IconButton(
                                        tooltip: 'Assistir',
                                        icon: const Icon(
                                            Icons.play_circle_outline,
                                            color: AppColors.secondary),
                                        onPressed: () => YoutubeLaunch.open(
                                            context, e.videoUrl),
                                      ),
                                    if (widget.isAdmin && !widget.selectMode)
                                      IconButton(
                                        tooltip: 'Editar',
                                        icon: const Icon(Icons.edit_outlined,
                                            color: AppColors.textSecondary),
                                        onPressed: () =>
                                            _abrirFormulario(existing: e),
                                      ),
                                  ],
                                ),
                                onTap: widget.selectMode
                                    ? () => Navigator.of(context).pop(e)
                                    : widget.isAdmin
                                        ? () => _abrirFormulario(existing: e)
                                        : e.videoUrl.isNotEmpty
                                            ? () => YoutubeLaunch.open(
                                                context, e.videoUrl)
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
