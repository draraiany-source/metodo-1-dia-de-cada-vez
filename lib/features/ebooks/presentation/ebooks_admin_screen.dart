import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/ebooks_admin_repository.dart';
import '../domain/ebook_models.dart';
import '../providers/ebook_providers.dart';

final ebooksAdminRepositoryProvider = Provider((ref) => EbooksAdminRepository());

class EbooksAdminScreen extends ConsumerWidget {
  const EbooksAdminScreen({super.key});

  Future<void> _novoEbook(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final descController = TextEditingController();
    final coverController = TextEditingController();
    final fileController = TextEditingController();
    final pagesController = TextEditingController(text: '0');
    var categoria = EbookCategory.geral;
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
                Text('Novo e-book', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 12),
                TextField(
                    controller: authorController,
                    decoration: const InputDecoration(labelText: 'Autor(a)')),
                const SizedBox(height: 12),
                TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Descrição')),
                const SizedBox(height: 12),
                TextField(
                    controller: coverController,
                    decoration:
                        const InputDecoration(labelText: 'URL da capa')),
                const SizedBox(height: 12),
                TextField(
                    controller: fileController,
                    decoration:
                        const InputDecoration(labelText: 'URL do PDF')),
                const SizedBox(height: 12),
                TextField(
                    controller: pagesController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Nº de páginas')),
                const SizedBox(height: 12),
                DropdownButtonFormField<EbookCategory>(
                  value: categoria,
                  items: EbookCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => categoria = v ?? categoria),
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
                    child: const Text('Publicar e-book'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true &&
        titleController.text.trim().isNotEmpty &&
        fileController.text.trim().isNotEmpty) {
      await ref.read(ebooksAdminRepositoryProvider).create(
            Ebook(
              id: '',
              title: titleController.text.trim(),
              author: authorController.text.trim(),
              category: categoria,
              coverUrl: coverController.text.trim(),
              description: descController.text.trim(),
              pages: int.tryParse(pagesController.text) ?? 0,
              isPremium: isPremium,
              order: 0,
              active: true,
            ),
            fileController.text.trim(),
          );
      ref.invalidate(ebooksProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebooksAsync = ref.watch(ebooksProvider);
    final user = ref.watch(currentUserProvider);
    final canWriteEbooks = user != null &&
        resolveUserRole(
          isPersonalTrainer: user.isPersonalTrainer,
          isAdmin: user.isAdmin,
        ) ==
        UserRole.admin;

    return Scaffold(
      appBar: AppBar(title: const Text('E-books (admin) 📚')),
      floatingActionButton: canWriteEbooks
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _novoEbook(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: ebooksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Não consegui carregar.',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (ebooks) {
            final list = ebooks.isEmpty
                ? const Center(
                    child: Text('Nenhum e-book cadastrado ainda.',
                        style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: ebooks.length,
                    itemBuilder: (_, i) {
                      final e = ebooks[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(e.title,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                              '${e.author} · ${e.category.label}${e.isPremium ? ' · Premium' : ''}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                          trailing: canWriteEbooks
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.danger),
                                  onPressed: () async {
                                    await ref
                                        .read(ebooksAdminRepositoryProvider)
                                        .delete(e.id);
                                    ref.invalidate(ebooksProvider);
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  );
            if (canWriteEbooks) return list;
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Text(
                    'Publicar ou remover apostilas é exclusivo do Admin Técnico. '
                    'A Personal pode consultar a lista.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
                Expanded(child: list),
              ],
            );
          },
        ),
      ),
    );
  }
}
