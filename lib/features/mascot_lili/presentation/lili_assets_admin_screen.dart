import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../personal_cms/presentation/cms_confirm.dart';
import '../data/lili_assets_admin_repository.dart';
import '../domain/lili_asset_models.dart';
import '../providers/lili_assets_providers.dart';

final liliAssetsAdminRepositoryProvider =
    Provider((ref) => LiliAssetsAdminRepository());

class LiliAssetsAdminScreen extends ConsumerWidget {
  const LiliAssetsAdminScreen({super.key});

  Future<void> _novoAsset(BuildContext context, WidgetRef ref) async {
    var categoria = LiliAssetCategory.feliz;
    var tipo = LiliAssetType.imagem;
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
                Text('Novo asset da Lili',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                const Text('Categoria',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<LiliAssetCategory>(
                  value: categoria,
                  items: LiliAssetCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) =>
                      setSheetState(() => categoria = v ?? categoria),
                ),
                const SizedBox(height: 16),
                const Text('Tipo',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<LiliAssetType>(
                  value: tipo,
                  items: const [
                    DropdownMenuItem(
                        value: LiliAssetType.imagem, child: Text('Imagem')),
                    DropdownMenuItem(
                        value: LiliAssetType.lottie,
                        child: Text('Animação Lottie')),
                    DropdownMenuItem(
                        value: LiliAssetType.rive,
                        child: Text('Animação Rive (em breve)')),
                  ],
                  onChanged: (v) => setSheetState(() => tipo = v ?? tipo),
                ),
                const SizedBox(height: 16),
                if (tipo == LiliAssetType.imagem)
                  OutlinedButton.icon(
                    onPressed: enviando
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final xfile = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85);
                            if (xfile == null) return;
                            setSheetState(() => enviando = true);
                            final bytes = await xfile.readAsBytes();
                            final url = await ref
                                .read(liliAssetsAdminRepositoryProvider)
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
                        : 'Enviar imagem do dispositivo'),
                  ),
                const SizedBox(height: 12),
                const Text(
                    '...ou cole a URL direto (obrigatório p/ Lottie/Rive)',
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
      await ref.read(liliAssetsAdminRepositoryProvider).create(LiliAsset(
            id: '',
            category: categoria,
            type: tipo,
            url: urlController.text.trim(),
            active: true,
            order: int.tryParse(orderController.text) ?? 0,
          ));
      ref.invalidate(liliAssetsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(liliAssetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assets da Lili (admin) 🎨')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoAsset(context, ref),
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
                      'Nenhum asset dinâmico cadastrado ainda\n'
                      '(a Lili está usando as poses estáticas locais).',
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
                        leading: a.type == LiliAssetType.imagem
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(a.url))
                            : const CircleAvatar(
                                child: Icon(Icons.movie_outlined)),
                        title: Text(a.category.label,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${a.type.name} · ordem ${a.order}',
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
                                if (!v) {
                                  final ok = await confirmDeactivate(
                                    context,
                                    title: 'Desativar imagem Lily?',
                                  );
                                  if (!ok) return;
                                }
                                await ref
                                    .read(liliAssetsAdminRepositoryProvider)
                                    .toggleActive(a.id, v);
                                ref.invalidate(liliAssetsProvider);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () async {
                                final ok = await confirmDeactivate(
                                  context,
                                  title: 'Excluir asset Lily?',
                                  message:
                                      'Remove o asset. Prefira desativar se puder reusar.',
                                  confirmLabel: 'Excluir',
                                );
                                if (!ok) return;
                                await ref
                                    .read(liliAssetsAdminRepositoryProvider)
                                    .delete(a.id);
                                ref.invalidate(liliAssetsProvider);
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
