import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../../personal_cms/presentation/cms_confirm.dart';
import '../data/audio_courses_admin_repository.dart';
import '../domain/audio_course_models.dart';
import '../providers/audio_course_providers.dart';

final audioCoursesAdminRepositoryProvider =
    Provider((ref) => AudioCoursesAdminRepository());

class AudioCoursesAdminScreen extends ConsumerWidget {
  const AudioCoursesAdminScreen({super.key});

  bool _canManage(WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return false;
    final role = resolveUserRole(
      isPersonalTrainer: user.isPersonalTrainer,
      isAdmin: user.isAdmin,
    );
    return RolePermissions.of(role).canManageContent;
  }

  Future<void> _novoCurso(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final teacherController = TextEditingController(text: 'Amanda Lopes');
    final coverController = TextEditingController();
    var categoria = AudioCourseCategory.motivacao;
    var isPremium = false;
    // Novos cursos começam publicados; testes manuais usam o switch "Ativo".
    var active = true;

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
                        const InputDecoration(labelText: 'URL da capa (opcional)')),
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
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Conteúdo Premium',
                      style: TextStyle(color: Colors.white)),
                  value: isPremium,
                  activeColor: AppColors.primary,
                  onChanged: (v) =>
                      setSheetState(() => isPremium = v ?? false),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Visível para alunas',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                    'Desligue para rascunho ou arquivo de teste.',
                    style:
                        TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                  value: active,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setSheetState(() => active = v),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Depois de criar, abra o curso para enviar MP3, ordenar e remover faixas.',
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
            active: active,
          );
      ref.invalidate(audioCoursesAdminListProvider);
      ref.invalidate(audioCoursesProvider);
    }
  }

  Future<PlatformFile?> _pickAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'm4a', 'wav', 'aac', 'ogg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.bytes == null || file.bytes!.isEmpty) {
      return null;
    }
    return file;
  }

  Future<void> _adicionarCapituloComArquivo(
    BuildContext context,
    WidgetRef ref,
    AudioCourse curso,
  ) async {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '0');
    PlatformFile? picked;
    var uploading = false;
    String? error;

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
                Text('Novo áudio — ${curso.title}',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título da faixa')),
                const SizedBox(height: 12),
                TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Duração (segundos, opcional)')),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: uploading
                      ? null
                      : () async {
                          final f = await _pickAudio();
                          if (f == null) {
                            setSheetState(() => error =
                                'Não foi possível ler o arquivo. Tente de novo.');
                            return;
                          }
                          setSheetState(() {
                            picked = f;
                            error = null;
                            if (titleController.text.trim().isEmpty) {
                              titleController.text =
                                  f.name.replaceAll(RegExp(r'\.[^.]+$'), '');
                            }
                          });
                        },
                  icon: const Icon(Icons.upload_file),
                  label: Text(picked == null
                      ? 'Escolher arquivo de áudio'
                      : 'Arquivo: ${picked!.name}'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: uploading
                        ? null
                        : () async {
                            if (titleController.text.trim().isEmpty ||
                                picked?.bytes == null) {
                              setSheetState(() => error =
                                  'Informe o título e escolha um arquivo de áudio.');
                              return;
                            }
                            setSheetState(() => uploading = true);
                            try {
                              final admin =
                                  ref.read(audioCoursesAdminRepositoryProvider);
                              final chapterId = admin.newChapterId(curso.id);
                              final upload = await admin.uploadAudioBytes(
                                courseId: curso.id,
                                chapterId: chapterId,
                                bytes: picked!.bytes!,
                                fileName: picked!.name,
                              );
                              await admin.addChapter(
                                courseId: curso.id,
                                chapterId: chapterId,
                                title: titleController.text.trim(),
                                audioUrl: upload.downloadUrl,
                                storagePath: upload.storagePath,
                                durationSeconds:
                                    int.tryParse(durationController.text) ?? 0,
                                order: curso.chapters.length,
                              );
                              if (ctx.mounted) Navigator.pop(ctx, true);
                            } catch (e) {
                              setSheetState(() {
                                uploading = false;
                                error =
                                    'Falha ao enviar. Verifique permissão e tente de novo.';
                              });
                            }
                          },
                    child: Text(uploading ? 'Enviando…' : 'Enviar e salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true) {
      ref.invalidate(audioCoursesAdminListProvider);
      ref.invalidate(audioCoursesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Áudio enviado para o Storage.')),
        );
      }
    }
  }

  Future<void> _substituirArquivo(
    BuildContext context,
    WidgetRef ref,
    AudioCourse curso,
    AudioChapter chapter,
  ) async {
    final picked = await _pickAudio();
    if (picked?.bytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo selecionado.')),
        );
      }
      return;
    }
    try {
      final admin = ref.read(audioCoursesAdminRepositoryProvider);
      final upload = await admin.uploadAudioBytes(
        courseId: curso.id,
        chapterId: chapter.id,
        bytes: picked!.bytes!,
        fileName: picked.name,
      );
      await admin.replaceChapterAudio(
        courseId: curso.id,
        chapterId: chapter.id,
        audioUrl: upload.downloadUrl,
        storagePath: upload.storagePath,
        previousStoragePath: chapter.storagePath,
      );
      ref.invalidate(audioCoursesAdminListProvider);
      ref.invalidate(audioCoursesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Áudio substituído.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível substituir o áudio.')),
        );
      }
    }
  }

  Future<void> _abrirCapitulos(
    BuildContext context,
    WidgetRef ref,
    AudioCourse curso,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        var chapters = List<AudioChapter>.from(curso.chapters)
          ..sort((a, b) => a.order.compareTo(b.order));
        return StatefulBuilder(
          builder: (ctx, setSheetState) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, scroll) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Faixas — ${curso.title}',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Adicionar áudio',
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _adicionarCapituloComArquivo(
                              context, ref, curso);
                        },
                        icon: const Icon(Icons.add_circle_outline,
                            color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Arraste pelas setas para ordenar. Substituir troca o arquivo no Storage sem criar faixa nova.',
                    style:
                        TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: chapters.isEmpty
                      ? const Center(
                          child: Text('Nenhuma faixa ainda.',
                              style:
                                  TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          controller: scroll,
                          itemCount: chapters.length,
                          itemBuilder: (_, i) {
                            final ch = chapters[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                child: Text('${i + 1}',
                                    style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(ch.title,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                ch.storagePath.isNotEmpty
                                    ? 'Storage · ${ch.duration.inSeconds}s'
                                    : 'URL · ${ch.duration.inSeconds}s',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11),
                              ),
                              trailing: Wrap(
                                spacing: 0,
                                children: [
                                  IconButton(
                                    tooltip: 'Subir',
                                    onPressed: i == 0
                                        ? null
                                        : () async {
                                            final list = [...chapters];
                                            final tmp = list[i - 1];
                                            list[i - 1] = list[i];
                                            list[i] = tmp;
                                            await ref
                                                .read(
                                                    audioCoursesAdminRepositoryProvider)
                                                .reorderChapters(
                                                    curso.id, list);
                                            setSheetState(() => chapters = list);
                                            ref.invalidate(
                                                audioCoursesAdminListProvider);
                                            ref.invalidate(
                                                audioCoursesProvider);
                                          },
                                    icon: const Icon(Icons.arrow_upward,
                                        size: 20),
                                  ),
                                  IconButton(
                                    tooltip: 'Descer',
                                    onPressed: i >= chapters.length - 1
                                        ? null
                                        : () async {
                                            final list = [...chapters];
                                            final tmp = list[i + 1];
                                            list[i + 1] = list[i];
                                            list[i] = tmp;
                                            await ref
                                                .read(
                                                    audioCoursesAdminRepositoryProvider)
                                                .reorderChapters(
                                                    curso.id, list);
                                            setSheetState(() => chapters = list);
                                            ref.invalidate(
                                                audioCoursesAdminListProvider);
                                            ref.invalidate(
                                                audioCoursesProvider);
                                          },
                                    icon: const Icon(Icons.arrow_downward,
                                        size: 20),
                                  ),
                                  IconButton(
                                    tooltip: 'Substituir arquivo',
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await _substituirArquivo(
                                          context, ref, curso, ch);
                                    },
                                    icon: const Icon(Icons.swap_horiz,
                                        color: AppColors.secondary),
                                  ),
                                  IconButton(
                                    tooltip: 'Remover faixa',
                                    onPressed: () async {
                                      final confirm = await confirmDeactivate(
                                        context,
                                        title: 'Remover "${ch.title}"?',
                                        message:
                                            'Apaga o registro e o arquivo no Storage, se houver.',
                                        confirmLabel: 'Remover',
                                      );
                                      if (!confirm) return;
                                      await ref
                                          .read(
                                              audioCoursesAdminRepositoryProvider)
                                          .deleteChapter(
                                            courseId: curso.id,
                                            chapter: ch,
                                          );
                                      setSheetState(() {
                                        chapters = [...chapters]..removeAt(i);
                                      });
                                      ref.invalidate(
                                          audioCoursesAdminListProvider);
                                      ref.invalidate(audioCoursesProvider);
                                    },
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.danger),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = _canManage(ref);
    final coursesAsync = ref.watch(audioCoursesAdminListProvider);

    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'Cursos em áudio',
        showStaffSignOut: true,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () => _novoCurso(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Novo curso'),
            )
          : null,
      body: SafeArea(
        child: !canManage
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Gerenciar áudios é permitido apenas para Personal ou Administrador.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            : coursesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                    child: Text('Não consegui carregar.',
                        style: TextStyle(color: AppColors.textSecondary))),
                data: (courses) => courses.isEmpty
                    ? const Center(
                        child: Text(
                            'Nenhum curso ainda. Crie um e envie os arquivos de áudio.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                        itemCount: courses.length,
                        itemBuilder: (_, i) {
                          final c = courses[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () => _abrirCapitulos(context, ref, c),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              title: Text(c.title,
                                  style: const TextStyle(color: Colors.white)),
                              subtitle: Text(
                                '${c.teacher} · ${c.chapters.length} faixas'
                                '${c.isPremium ? ' · Premium' : ''}'
                                '${c.active ? '' : ' · Rascunho'}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: c.active
                                        ? 'Ocultar das alunas'
                                        : 'Publicar para alunas',
                                    icon: Icon(
                                      c.active
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: c.active
                                          ? AppColors.secondary
                                          : AppColors.textTertiary,
                                    ),
                                    onPressed: () async {
                                      await ref
                                          .read(
                                              audioCoursesAdminRepositoryProvider)
                                          .updateCourse(
                                            courseId: c.id,
                                            active: !c.active,
                                          );
                                      ref.invalidate(
                                          audioCoursesAdminListProvider);
                                      ref.invalidate(audioCoursesProvider);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.library_music,
                                        color: AppColors.secondary),
                                    tooltip: 'Gerenciar faixas',
                                    onPressed: () =>
                                        _abrirCapitulos(context, ref, c),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.danger),
                                    tooltip: 'Excluir curso',
                                    onPressed: () async {
                                      final ok = await confirmDeactivate(
                                        context,
                                        title: 'Excluir "${c.title}"?',
                                        message:
                                            'Remove o curso, as faixas e os arquivos no Storage.',
                                        confirmLabel: 'Excluir',
                                      );
                                      if (!ok) return;
                                      await ref
                                          .read(
                                              audioCoursesAdminRepositoryProvider)
                                          .deleteCourse(c.id);
                                      ref.invalidate(
                                          audioCoursesAdminListProvider);
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
