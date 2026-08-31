import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/videos_admin_repository.dart';
import '../domain/video_models.dart';
import '../providers/video_providers.dart';

final videosAdminRepositoryProvider = Provider((ref) => VideosAdminRepository());

class VideosAdminScreen extends ConsumerWidget {
  const VideosAdminScreen({super.key});

  Future<void> _novoVideo(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final teacherController = TextEditingController();
    final thumbController = TextEditingController();
    final urlController = TextEditingController();
    final durationController = TextEditingController(text: '600');
    final orderController = TextEditingController(text: '0');
    var category = VideoCategory.casa;
    var level = VideoLevel.iniciante;
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
                Text('Novo vídeo', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                _label('Nome'),
                TextField(controller: nameController),
                const SizedBox(height: 12),
                _label('Descrição'),
                TextField(controller: descController, maxLines: 2),
                const SizedBox(height: 12),
                _label('Professor(a)'),
                TextField(controller: teacherController),
                const SizedBox(height: 12),
                _label('URL da capa (thumbnail)'),
                TextField(controller: thumbController),
                const SizedBox(height: 12),
                _label('URL de streaming (Bunny.net, R2, S3...)'),
                TextField(controller: urlController),
                const SizedBox(height: 12),
                _label('Categoria'),
                DropdownButtonFormField<VideoCategory>(
                  value: category,
                  items: VideoCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                _label('Nível'),
                DropdownButtonFormField<VideoLevel>(
                  value: level,
                  items: VideoLevel.values
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => level = v ?? level),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Duração (segundos)'),
                          TextField(
                              controller: durationController,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Ordem'),
                          TextField(
                              controller: orderController,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Conteúdo Premium',
                      style: TextStyle(color: Colors.white)),
                  value: isPremium,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setSheetState(() => isPremium = v ?? false),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Publicar vídeo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true &&
        nameController.text.trim().isNotEmpty &&
        urlController.text.trim().isNotEmpty) {
      await ref.read(videosAdminRepositoryProvider).create(
            VideoContent(
              id: '',
              category: category,
              subcategory: '',
              name: nameController.text.trim(),
              description: descController.text.trim(),
              teacher: teacherController.text.trim(),
              thumbnailUrl: thumbController.text.trim(),
              durationSeconds: int.tryParse(durationController.text) ?? 0,
              level: level,
              isPremium: isPremium,
              order: int.tryParse(orderController.text) ?? 0,
              active: true,
            ),
            urlController.text.trim(),
          );
      ref.invalidate(videosProvider);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vídeos (admin) 🎥')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoVideo(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: videosAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Não consegui carregar.',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (videos) => videos.isEmpty
              ? const Center(
                  child: Text('Nenhum vídeo cadastrado ainda.',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: videos.length,
                  itemBuilder: (_, i) {
                    final v = videos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(v.name,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          '${v.category.label} · ${v.level.label}${v.isPremium ? ' · Premium' : ''}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger),
                          onPressed: () async {
                            await ref
                                .read(videosAdminRepositoryProvider)
                                .delete(v.id);
                            ref.invalidate(videosProvider);
                          },
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
