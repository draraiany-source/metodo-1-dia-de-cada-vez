import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../data/amanda_assets_admin_repository.dart';
import '../domain/amanda_asset_models.dart';
import '../providers/amanda_assets_providers.dart';

final amandaAssetsAdminRepositoryProvider =
    Provider((ref) => AmandaAssetsAdminRepository());

class AmandaAssetsAdminScreen extends ConsumerWidget {
  const AmandaAssetsAdminScreen({super.key});

  Future<void> _novaFoto(BuildContext context, WidgetRef ref) async {
    var categoria = AmandaAssetCategory.principal;
    final urlController = TextEditingController();
    final orderController = TextEditingController(text: '0');
    var enviando = false;

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
                Text('Nova foto da Amanda',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                const Text('Categoria',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<AmandaAssetCategory>(
                  value: categoria,
                  items: AmandaAssetCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) =>
                      setSheetState(() => categoria = v ?? categoria),
                ),
                const SizedBox(height: 8),
                Text(categoria.hint,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: enviando
                      ? null
                      : () async {
                          final picker = ImagePicker();
                          final xfile = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 85);
                          if (xfile == null) return;
                          setSheetState(() => enviando = true);
                          final bytes = await xfile.readAsBytes();
                          final url = await ref
                              .read(amandaAssetsAdminRepositoryProvider)
                              .uploadImageBytes(bytes, categoria.name,
                                  '${DateTime.now().millisecondsSinceEpoch}.jpg');
                          urlController.text = url;
                          setSheetState(() => enviando = false);
                        },
                  icon: enviando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_outlined),
                  label: Text(enviando
                      ? 'Enviando...'
                      : 'Enviar foto do dispositivo'),
                ),
                const SizedBox(height: 12),
                const Text('...ou cole a URL direto',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 6),
                TextField(controller: urlController),
                const SizedBox(height: 16),
                const Text('Ordem (menor aparece primeiro)',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                    controller: orderController,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        enviando ? null : () => Navigator.pop(ctx, true),
                    child: const Text('Publicar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && urlController.text.trim().isNotEmpty) {
      await ref.read(amandaAssetsAdminRepositoryProvider).create(AmandaAsset(
            id: '',
            category: categoria,
            url: urlController.text.trim(),
            active: true,
            order: int.tryParse(orderController.text) ?? 0,
          ));
      ref.invalidate(amandaAssetsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(amandaAssetsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Fotos da Amanda',
        actions: [
          IconButton(
            tooltip: 'Editar textos do perfil',
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () =>
                AppNavigation.open(context, Routes.amandaProfileEdit),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novaFoto(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: assetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Não consegui carregar.',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (assets) => assets.isEmpty
              ? const Center(
                  child: Text(
                      'Nenhuma foto cadastrada ainda\n'
                      '(a Amanda está usando o placeholder padrão).',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: assets.length,
                  itemBuilder: (_, i) {
                    final a = assets[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(a.url)),
                        title: Text(a.category.label,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text('ordem ${a.order}',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: a.active,
                              activeTrackColor: AppColors.primary,
                              onChanged: (v) async {
                                await ref
                                    .read(amandaAssetsAdminRepositoryProvider)
                                    .toggleActive(a.id, v);
                                ref.invalidate(amandaAssetsProvider);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () async {
                                await ref
                                    .read(amandaAssetsAdminRepositoryProvider)
                                    .delete(a.id);
                                ref.invalidate(amandaAssetsProvider);
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
