import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../personal_cms/presentation/cms_confirm.dart';
import '../data/amanda_assets_admin_repository.dart';
import '../domain/amanda_asset_models.dart';
import '../providers/amanda_assets_providers.dart';

final amandaAssetsAdminRepositoryProvider =
    Provider((ref) => AmandaAssetsAdminRepository());

class AmandaAssetsAdminScreen extends ConsumerWidget {
  const AmandaAssetsAdminScreen({super.key});

  Future<void> _fotoSheet(
    BuildContext context,
    WidgetRef ref, {
    AmandaAsset? existente,
  }) async {
    var categoria = existente?.category ?? AmandaAssetCategory.principal;
    final urlController = TextEditingController(text: existente?.url ?? '');
    final orderController =
        TextEditingController(text: '${existente?.order ?? 0}');
    var storagePath = existente?.storagePath ?? '';
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
                Text(
                  existente == null ? 'Nova foto da Amanda' : 'Trocar foto',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
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
                if (urlController.text.trim().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: urlController.text.trim(),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceDeep,
                          alignment: Alignment.center,
                          child: const Text(
                            'Não consegui carregar esta prévia.',
                            style: TextStyle(
                                color: AppColors.textTertiary, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: enviando
                      ? null
                      : () async {
                          final picker = ImagePicker();
                          final xfile = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 82,
                            maxWidth: 1600,
                          );
                          if (xfile == null) return;
                          setSheetState(() => enviando = true);
                          try {
                            final bytes = await xfile.readAsBytes();
                            if (bytes.length > 9 * 1024 * 1024) {
                              throw StateError(
                                  'A foto passou de 9 MB. Escolha outra ou reduza a qualidade.');
                            }
                            final uploaded = await ref
                                .read(amandaAssetsAdminRepositoryProvider)
                                .uploadImageBytes(
                                  bytes,
                                  categoria.name,
                                  '${DateTime.now().millisecondsSinceEpoch}.jpg',
                                );
                            urlController.text = uploaded.url;
                            storagePath = uploaded.storagePath;
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                    content: Text('Erro no envio: $e')),
                              );
                            }
                          } finally {
                            setSheetState(() => enviando = false);
                          }
                        },
                  icon: enviando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_outlined),
                  label: Text(enviando
                      ? 'Enviando...'
                      : urlController.text.trim().isEmpty
                          ? 'Enviar foto do dispositivo'
                          : 'Trocar foto do dispositivo'),
                ),
                const SizedBox(height: 12),
                const Text('...ou cole a URL direto',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 6),
                TextField(
                  controller: urlController,
                  onChanged: (_) => setSheetState(() {}),
                ),
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
                    onPressed: enviando ? null : () => Navigator.pop(ctx, true),
                    child: Text(existente == null ? 'Publicar' : 'Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true || urlController.text.trim().isEmpty) return;
    final asset = AmandaAsset(
      id: existente?.id ?? '',
      category: categoria,
      url: urlController.text.trim(),
      active: existente?.active ?? true,
      order: int.tryParse(orderController.text) ?? 0,
      storagePath: storagePath,
    );
    final repo = ref.read(amandaAssetsAdminRepositoryProvider);
    if (existente == null) {
      await repo.create(asset);
    } else {
      await repo.update(asset);
    }
    ref.invalidate(amandaAssetsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existente == null
              ? 'Foto publicada.'
              : 'Foto atualizada.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(amandaAssetsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Fotos da Amanda',
        showStaffSignOut: true,
        actions: [
          IconButton(
            tooltip: 'Editar textos do perfil',
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () =>
                AppNavigation.open(context, Routes.amandaProfileEdit),
          ),
          IconButton(
            tooltip: 'Ver como aluna',
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () =>
                AppNavigation.open(context, Routes.amandaProfile),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _fotoSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: assetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(
              child: Text('Não consegui carregar as fotos.\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary))),
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
                        onTap: () => _fotoSheet(context, ref, existente: a),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: CachedNetworkImage(
                              imageUrl: a.url,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                        title: Text(a.category.label,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                            a.active
                                ? 'Publicada · ordem ${a.order}'
                                : 'Oculta · ordem ${a.order}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Trocar / editar',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _fotoSheet(context, ref, existente: a),
                            ),
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
                              tooltip: 'Excluir',
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () async {
                                final ok = await confirmDelete(
                                  context,
                                  title: 'Excluir esta foto?',
                                  message:
                                      'Ela some da Home e do Quem Sou Eu. '
                                      'O arquivo no Storage também é removido.',
                                );
                                if (!ok) return;
                                await ref
                                    .read(amandaAssetsAdminRepositoryProvider)
                                    .delete(a);
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
