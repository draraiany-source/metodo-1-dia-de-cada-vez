import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/food_database_models.dart';
import '../providers/food_database_providers.dart';

/// Busca no banco de alimentos. Usada tanto pra consultar (`isAdmin: true`
/// mostra botão de cadastrar) quanto como seletor pro diário alimentar
/// (retorna o [FoodItem] escolhido via `Navigator.pop`).
class FoodDatabaseScreen extends ConsumerStatefulWidget {
  const FoodDatabaseScreen(
      {super.key, this.selectMode = false, this.isAdmin = false});
  final bool selectMode;
  final bool isAdmin;

  @override
  ConsumerState<FoodDatabaseScreen> createState() =>
      _FoodDatabaseScreenState();
}

class _FoodDatabaseScreenState extends ConsumerState<FoodDatabaseScreen> {
  FoodCategory? _filtro;
  String _busca = '';

  Future<void> _novoAlimento(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final kcalController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    final fiberController = TextEditingController();
    final measureController = TextEditingController();
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Novo alimento', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome')),
                const SizedBox(height: 12),
                DropdownButtonFormField<FoodCategory>(
                  value: categoria,
                  items: FoodCategory.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => categoria = v ?? categoria),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: measureController,
                    decoration: const InputDecoration(
                        labelText: 'Medida caseira (ex.: 1 fatia (25g))')),
                const SizedBox(height: 12),
                const Text('Valores por 100g:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: kcalController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'kcal')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Proteína g')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: carbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Carbo g')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                          controller: fatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Gordura g')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: fiberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Fibra g')),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Salvar no banco'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && nameController.text.trim().isNotEmpty) {
      await ref.read(foodDatabaseRepositoryProvider).create(FoodItem(
            id: '',
            name: nameController.text.trim(),
            category: categoria,
            kcal: int.tryParse(kcalController.text) ?? 0,
            protein: int.tryParse(proteinController.text) ?? 0,
            carbs: int.tryParse(carbsController.text) ?? 0,
            fat: int.tryParse(fatController.text) ?? 0,
            fiber: int.tryParse(fiberController.text) ?? 0,
            householdMeasure: measureController.text.trim(),
          ));
      ref.invalidate(foodDatabaseProvider);
    }
    for (final c in [
      nameController,
      kcalController,
      proteinController,
      carbsController,
      fatController,
      fiberController,
      measureController,
    ]) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(foodDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.selectMode ? 'Escolher alimento' : 'Banco de alimentos 🍎')),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _novoAlimento(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                    hintText: 'Buscar alimento...',
                    prefixIcon: Icon(Icons.search)),
                onChanged: (v) => setState(() => _busca = v.toLowerCase()),
              ),
            ),
            SizedBox(
              height: 40,
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
                  ...FoodCategory.values.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c.label),
                          selected: _filtro == c,
                          onSelected: (_) => setState(() => _filtro = c),
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: foodsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(
                    child: Text('Não consegui carregar.',
                        style: TextStyle(color: AppColors.textSecondary))),
                data: (foods) {
                  final filtrados = foods.where((f) {
                    if (_filtro != null && f.category != _filtro) return false;
                    if (_busca.isNotEmpty &&
                        !f.name.toLowerCase().contains(_busca)) {
                      return false;
                    }
                    return true;
                  }).toList();

                  if (filtrados.isEmpty) {
                    return const Center(
                        child: Text('Nenhum alimento encontrado.',
                            style: TextStyle(color: AppColors.textSecondary)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filtrados.length,
                    itemBuilder: (_, i) {
                      final f = filtrados[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(f.name,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            '${f.kcal} kcal · ${f.protein}g P · ${f.carbs}g C · ${f.fat}g G'
                            '${f.householdMeasure.isNotEmpty ? ' · ${f.householdMeasure}' : ''}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          trailing: Text(f.category.label,
                              style: const TextStyle(
                                  color: AppColors.textTertiary, fontSize: 11)),
                          onTap: widget.selectMode
                              ? () => Navigator.of(context).pop(f)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
