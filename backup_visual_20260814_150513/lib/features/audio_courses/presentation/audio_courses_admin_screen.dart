import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/audio_courses_admin_repository.dart';
import '../domain/audio_course_models.dart';
import '../providers/audio_course_providers.dart';

final audioCoursesAdminRepositoryProvider =
    Provider((ref) => AudioCoursesAdminRepository());

class AudioCoursesAdminScreen extends ConsumerWidget {
  const AudioCoursesAdminScreen({super.key});

  Future<void> _novoCurso(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final teacherController = TextEditingController();
    final coverController = TextEditingController();
    var categoria = AudioCourseCategory.motivacao;
    var isPremium = false;

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
                Text('Novo curso em áudio',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 12),
                TextField(
                    controller: teacherController,
                    decoration:
                        const InputDecoration(labelText: 'Professor(a)')),
                const SizedBox(height: 12),
                TextField(
                    controller: coverController,
                    decoration:
                        const InputDecoration(labelText: 'URL da capa')),
                const SizedBox(height: 12),
                DropdownButtonFormField<AudioCourseCategory>(
                  value: categoria,
                  items: AudioCourseCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) =>
                      setSheetState(() => categoria = v ?? categoria),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Conteúdo Premium',
                      style: TextStyle(color: Colors.white)),
                  value: isPremium,
                  activeColor: AppColors.primary,
                  onChanged: (v) =>
                      setSheetState(() => isPremium = v ?? false),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Depois de criar, adicione os capítulos tocando no curso na lista.',
                  style:
                      TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Criar curso'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && titleController.text.trim().isNotEmpty) {
      await ref.read(audioCoursesAdminRepositoryProvider).createCourse(
            title: titleController.text.trim(),
            teacher: teacherController.text.trim(),
            category: categoria,
            coverUrl: coverController.text.trim(),
            isPremium: isPremium,
          );
      ref.invalidate(audioCoursesProvider);
    }
  }

  Future<void> _novoCapitulo(
      BuildContext context, WidgetRef ref, AudioCourse curso) async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final durationController = TextEditingController(text: '300');

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Novo capítulo — ${curso.title}',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título')),
            const SizedBox(height: 12),
            TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL do áudio')),
            const SizedBox(height: 12),
            TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Duração (segundos)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Adicionar capítulo'),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok == true &&
        titleController.text.trim().isNotEmpty &&
        urlController.text.trim().isNotEmpty) {
      await ref.read(audioCoursesAdminRepositoryProvider).addChapter(
            courseId: curso.id,
            title: titleController.text.trim(),
            audioUrl: urlController.text.trim(),
            durationSeconds: int.tryParse(durationController.text) ?? 0,
            order: curso.chapters.length,
          );
      ref.invalidate(audioCoursesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(audioCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cursos em áudio (admin) 🎧')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoCurso(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: coursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Não consegui carregar.',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (courses) => courses.isEmpty
              ? const Center(
                  child: Text('Nenhum curso cadastrado ainda.',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: courses.length,
                  itemBuilder: (_, i) {
                    final c = courses[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(c.title,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                            '${c.teacher} · ${c.chapters.length} capítulos${c.isPremium ? ' · Premium' : ''}',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.secondary),
                              tooltip: 'Adicionar capítulo',
                              onPressed: () => _novoCapitulo(context, ref, c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () async {
                                await ref
                                    .read(audioCoursesAdminRepositoryProvider)
                                    .deleteCourse(c.id);
                                ref.invalidate(audioCoursesProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
