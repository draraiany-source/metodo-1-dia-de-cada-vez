import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/common_widgets.dart';
import '../domain/pdf_recipe_models.dart';
import '../providers/pdf_recipe_providers.dart';
import 'pdf_viewer_screen.dart';

class PdfRecipesScreen extends ConsumerStatefulWidget {
  const PdfRecipesScreen({super.key});

  @override
  ConsumerState<PdfRecipesScreen> createState() => _PdfRecipesScreenState();
}

class _PdfRecipesScreenState extends ConsumerState<PdfRecipesScreen> {
  PdfRecipeCategory? _filtro;
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(pdfRecipesProvider);
    final favoritos = ref.watch(pdfRecipeFavoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Receitas em PDF 📄')),
      body: SafeArea(
        child: recipesAsync.when(
          loading: () => const AppListSkeleton(),
          error: (_, __) =>
              AppErrorState(onRetry: () => ref.invalidate(pdfRecipesProvider)),
          data: (recipes) {
            final buscaLower = _busca.trim().toLowerCase();
            final filtradas = recipes.where((r) {
              final matchCategoria = _filtro == null || r.category == _filtro;
              final matchBusca = buscaLower.isEmpty ||
                  r.title.toLowerCase().contains(buscaLower);
              return matchCategoria && matchBusca;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Baixe, salve e cozinhe no seu ritmo',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        TextField(
                          onChanged: (v) => setState(() => _busca = v),
                          decoration: InputDecoration(
                            hintText: 'Buscar receitas...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _CategoryChip(
                                label: 'Todas',
                                selected: _filtro == null,
                                onTap: () => setState(() => _filtro = null),
                              ),
                              ...PdfRecipeCategory.values.map((c) => _CategoryChip(
                                    label: c.label,
                                    selected: _filtro == c,
                                    onTap: () => setState(() => _filtro = c),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (recipes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: ComingSoonView(
                              emoji: '📄',
                              title: 'Nenhuma receita em PDF ainda',
                              description:
                                  'Assim que as receitas forem cadastradas, elas aparecem aqui automaticamente.',
                            ),
                          )
                        else if (filtradas.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                  buscaLower.isNotEmpty
                                      ? 'Nenhuma receita encontrada pra "$_busca".'
                                      : 'Nenhuma receita nessa categoria ainda.',
                                  style:
                                      const TextStyle(color: AppColors.textSecondary)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (filtradas.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _RecipeCard(
                          recipe: filtradas[i],
                          isFavorite: favoritos.contains(filtradas[i].id),
                        ),
                        childCount: filtradas.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe, required this.isFavorite});
  final PdfRecipe recipe;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PdfViewerScreen(recipe: recipe),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: recipe.coverUrl.isEmpty
                        ? Container(
                            color: AppColors.background,
                            child: const Icon(Icons.restaurant_menu,
                                color: AppColors.textTertiary, size: 32),
                          )
                        : CachedNetworkImage(imageUrl: recipe.coverUrl, fit: BoxFit.cover),
                  ),
                  if (recipe.isPremium)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text('PREMIUM',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(pdfRecipeFavoritesProvider.notifier)
                          .toggle(recipe.id),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black45,
                        child: FavoriteAssetIcon(active: isFavorite, size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.minutes}min · ${recipe.kcal}kcal · ${recipe.difficulty.label}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
