import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/food_database_models.dart';
import '../providers/shopping_list_providers.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  Future<void> _novoItem(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    var categoria = FoodCategory.industrializados;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novo item', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Item')),
              const SizedBox(height: 12),
              TextField(
                  controller: qtyController,
                  decoration:
                      const InputDecoration(labelText: 'Quantidade (opcional)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<FoodCategory>(
                value: categoria,
                items: FoodCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setSheetState(() => categoria = v ?? categoria),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Adicionar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true && nameController.text.trim().isNotEmpty) {
      await ref.read(shoppingListProvider.notifier).add(
          nameController.text.trim(), categoria,
          quantity: qtyController.text.trim());
    }
    nameController.dispose();
    qtyController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de compras 🛒'),
        actions: [
          if (items.any((i) => i.bought))
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: 'Limpar comprados',
              onPressed: () =>
                  ref.read(shoppingListProvider.notifier).clearBought(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoItem(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                      'Sua lista está vazia.\nToque em "+" pra adicionar itens.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (final cat in FoodCategory.values)
                    if (items.any((i) => i.category == cat)) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 8),
                        child: Text(cat.label,
                            style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600)),
                      ),
                      ...items.where((i) => i.category == cat).map((item) =>
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: CheckboxListTile(
                              value: item.bought,
                              activeColor: AppColors.primary,
                              onChanged: (_) => ref
                                  .read(shoppingListProvider.notifier)
                                  .toggle(item.id),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  color: item.bought
                                      ? AppColors.textTertiary
                                      : Colors.white,
                                  decoration: item.bought
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: item.quantity.isNotEmpty
                                  ? Text(item.quantity,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12))
                                  : null,
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.danger),
                                onPressed: () => ref
                                    .read(shoppingListProvider.notifier)
                                    .remove(item.id),
                              ),
                            ),
                          )),
                    ],
                ],
              ),
      ),
    );
  }
}
