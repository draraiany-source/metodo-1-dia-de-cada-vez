import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../pdf_recipes/domain/pdf_recipe_models.dart';
import '../../pdf_recipes/providers/pdf_recipe_providers.dart';
import '../data/pdf_recipes_admin_repository.dart';
import 'cms_confirm.dart';

final pdfRecipesAdminRepositoryProvider =
    Provider((ref) => PdfRecipesAdminRepository());

final pdfRecipesAdminStreamProvider = StreamProvider<List<PdfRecipe>>((ref) {
  return ref.watch(pdfRecipesAdminRepositoryProvider).watchAll();
});

/// Stub CMS de receitas PDF — lista Firestore `pdf_recipes`, cria metadados
/// e desativa com soft-delete (`active: false`).
class RecipesCmsScreen extends ConsumerWidget {
  const RecipesCmsScreen({super.key});

  Future<void> _adicionar(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final cover = TextEditingController();
    final minutes = TextEditingController(text: '20');
    final kcal = TextEditingController(text: '0');
    final protein = TextEditingController(text: '0');
    final carbs = TextEditingController(text: '0');
    final fat = TextEditingController(text: '0');
    var category = PdfRecipeCategory.almoco;
    var difficulty = RecipeDifficulty.facil;
    var isPremium = false;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nova receita', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Cadastro de metadados. O PDF fica em /private (via Admin Técnico '
                  'ou upload posterior).',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 12),
                TextField(
                    controller: cover,
                    decoration:
                        const InputDecoration(labelText: 'URL da capa')),
                const SizedBox(height: 12),
                DropdownButtonFormField<PdfRecipeCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: PdfRecipeCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setSheet(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RecipeDifficulty>(
                  value: difficulty,
                  decoration: const InputDecoration(labelText: 'Dificuldade'),
                  items: RecipeDifficulty.values
                      .map((d) =>
                          DropdownMenuItem(value: d, child: Text(d.label)))
                      .toList(),
                  onChanged: (v) =>
                      setSheet(() => difficulty = v ?? difficulty),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: minutes,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Minutos')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: kcal,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Kcal'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: protein,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Prot.'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: carbs,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Carb.'))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: TextField(
                            controller: fat,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Gord.'))),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Premium',
                      style: TextStyle(color: Colors.white)),
                  value: isPremium,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setSheet(() => isPremium = v ?? false),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Salvar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && title.text.trim().isNotEmpty) {
      await ref.read(pdfRecipesAdminRepositoryProvider).create(
            title: title.text.trim(),
            category: category,
            coverUrl: cover.text.trim(),
            minutes: int.tryParse(minutes.text) ?? 0,
            difficulty: difficulty,
            kcal: int.tryParse(kcal.text) ?? 0,
            protein: int.tryParse(protein.text) ?? 0,
            carbs: int.tryParse(carbs.text) ?? 0,
            fat: int.tryParse(fat.text) ?? 0,
            isPremium: isPremium,
          );
      ref.invalidate(pdfRecipesProvider);
    }
  }

  Future<void> _toggleActive(
      BuildContext context, WidgetRef ref, PdfRecipe r) async {
    if (r.active) {
      final ok = await confirmDeactivate(
        context,
        title: 'Desativar "${r.title}"?',
      );
      if (!ok) return;
      await ref.read(pdfRecipesAdminRepositoryProvider).setActive(r.id, false);
    } else {
      await ref.read(pdfRecipesAdminRepositoryProvider).setActive(r.id, true);
    }
    ref.invalidate(pdfRecipesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pdfRecipesAdminStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _adicionar(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Não deu pra carregar as receitas.\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhuma receita PDF cadastrada ainda.\n'
                  'Toque em Adicionar para criar os metadados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final r = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(r.title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${r.category.label} · ${r.minutes} min'
                    '${r.isPremium ? ' · Premium' : ''}'
                    '${r.active ? '' : ' · Desativada'}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: SizedBox(
                    height: 44,
                    child: TextButton(
                      onPressed: () => _toggleActive(context, ref, r),
                      child: Text(r.active ? 'Desativar' : 'Reativar'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
