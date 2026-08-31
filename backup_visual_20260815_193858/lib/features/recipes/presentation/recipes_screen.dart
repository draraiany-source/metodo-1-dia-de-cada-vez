import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../providers/recipe_favorites_providers.dart';
import 'recipe_detail_screen.dart';

/// ============================================================================
/// RECEITAS — catálogo com busca, categorias, favoritos, recomendação do dia
/// e filtros avançados.
///
/// Princípio seguido em toda a tela: **nenhuma receita é inventada**. Tudo
/// vem de `SeedData.recipes` (mesmo catálogo usado em Meu Plano e em
/// Nutrição), agora com campos extras (tempo de preparo, dificuldade,
/// porções, dieta, objetivo, macros) usados só por esta tela.
/// ============================================================================
enum _Categoria {
  todas,
  emagrecer,
  hipertrofia,
  lowCarb,
  veganas,
  airFryer,
  sobremesas,
  shakes,
  favoritas,
}

extension _CategoriaX on _Categoria {
  String get label => switch (this) {
        _Categoria.todas => 'Todas',
        _Categoria.emagrecer => 'Emagrecer',
        _Categoria.hipertrofia => 'Hipertrofia',
        _Categoria.lowCarb => 'Low Carb',
        _Categoria.veganas => 'Veganas',
        _Categoria.airFryer => 'Air Fryer',
        _Categoria.sobremesas => 'Sobremesas',
        _Categoria.shakes => 'Shakes',
        _Categoria.favoritas => '❤️ Favoritas',
      };

  /// Tag correspondente em `Recipe.tags` — `null` para "Todas"/"Favoritas",
  /// que não filtram por tag.
  String? get tag => switch (this) {
        _Categoria.emagrecer => 'Emagrecer',
        _Categoria.hipertrofia => 'Hipertrofia',
        _Categoria.lowCarb => 'Low Carb',
        _Categoria.veganas => 'Veganas',
        _Categoria.airFryer => 'Air Fryer',
        _Categoria.sobremesas => 'Sobremesas',
        _Categoria.shakes => 'Shakes',
        _ => null,
      };
}

/// Seleções do modal de filtros avançados — cada campo `null` = "qualquer".
class _AdvancedFilters {
  const _AdvancedFilters({
    this.objetivo,
    this.dieta,
    this.tempo,
    this.calorias,
    this.dificuldade,
  });

  final String? objetivo;
  final String? dieta;
  final String? tempo;
  final String? calorias;
  final String? dificuldade;

  static const objetivos = ['Emagrecimento', 'Hipertrofia', 'Manutenção', 'Saúde'];
  static const dietas = [
    'Tradicional',
    'Low Carb',
    'Vegana',
    'Vegetariana',
    'Carnívora',
    'Sem lactose',
    'Sem glúten',
  ];
  static const tempos = [
    'Até 15 minutos',
    '15 a 30 minutos',
    '30 a 45 minutos',
    'Acima de 45 minutos',
  ];
  static const faixasCalorias = [
    'Até 200 kcal',
    '200 a 400 kcal',
    '400 a 600 kcal',
    'Acima de 600 kcal',
  ];
  static const dificuldades = ['Fácil', 'Média', 'Avançada'];

  bool get isEmpty =>
      objetivo == null &&
      dieta == null &&
      tempo == null &&
      calorias == null &&
      dificuldade == null;

  int get activeCount =>
      [objetivo, dieta, tempo, calorias, dificuldade].where((v) => v != null).length;

  bool matches(Recipe r) {
    if (objetivo != null && r.objetivo != objetivo) return false;
    if (dieta != null && r.dietType != dieta) return false;
    if (dificuldade != null && r.difficulty != dificuldade) return false;
    if (tempo != null) {
      final d = r.durationMin;
      final ok = switch (tempo) {
        'Até 15 minutos' => d <= 15,
        '15 a 30 minutos' => d > 15 && d <= 30,
        '30 a 45 minutos' => d > 30 && d <= 45,
        'Acima de 45 minutos' => d > 45,
        _ => true,
      };
      if (!ok) return false;
    }
    if (calorias != null) {
      final k = r.kcal;
      final ok = switch (calorias) {
        'Até 200 kcal' => k <= 200,
        '200 a 400 kcal' => k > 200 && k <= 400,
        '400 a 600 kcal' => k > 400 && k <= 600,
        'Acima de 600 kcal' => k > 600,
        _ => true,
      };
      if (!ok) return false;
    }
    return true;
  }

  _AdvancedFilters copyWith({
    String? Function()? objetivo,
    String? Function()? dieta,
    String? Function()? tempo,
    String? Function()? calorias,
    String? Function()? dificuldade,
  }) =>
      _AdvancedFilters(
        objetivo: objetivo != null ? objetivo() : this.objetivo,
        dieta: dieta != null ? dieta() : this.dieta,
        tempo: tempo != null ? tempo() : this.tempo,
        calorias: calorias != null ? calorias() : this.calorias,
        dificuldade: dificuldade != null ? dificuldade() : this.dificuldade,
      );
}

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  _Categoria _categoria = _Categoria.todas;
  String _query = '';
  _AdvancedFilters _advanced = const _AdvancedFilters();

  Timer? _debounce;
  final _searchController = TextEditingController();

  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    // Catálogo 100% local (SeedData) — não há requisição de rede real; o
    // skeleton só suaviza o primeiro frame, mantendo os mesmos estados
    // (carregando/erro/vazio/carregado) usados em Treinos.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _query = '');
  }

  List<Recipe> _byCategoria(_Categoria cat, Set<String> favoritos) {
    if (cat == _Categoria.favoritas) {
      return SeedData.recipes.where((r) => favoritos.contains(r.id)).toList();
    }
    final tag = cat.tag;
    if (tag == null) return List.of(SeedData.recipes);
    return SeedData.recipes.where((r) => r.tags.contains(tag)).toList();
  }

  bool _matchesQuery(Recipe r, String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase();
    return r.title.toLowerCase().contains(lower) ||
        r.category.toLowerCase().contains(lower) ||
        r.objetivo.toLowerCase().contains(lower) ||
        r.dietType.toLowerCase().contains(lower) ||
        r.tags.any((t) => t.toLowerCase().contains(lower)) ||
        r.ingredients.any((i) => i.toLowerCase().contains(lower));
  }

  Future<void> _openAdvancedFilters() async {
    final result = await showModalBottomSheet<_AdvancedFilters>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AdvancedFiltersSheet(initial: _advanced),
    );
    if (result != null && mounted) setState(() => _advanced = result);
  }

  void _openDetail(Recipe r) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final favoritos = ref.watch(recipeFavoritesProvider);

    List<Recipe> filtrados = const [];
    if (!_loading) {
      try {
        filtrados = _byCategoria(_categoria, favoritos)
            .where((r) => _matchesQuery(r, _query))
            .where(_advanced.matches)
            .toList();
        _error = false;
      } catch (_) {
        _error = true;
      }
    }

    final recPool = _byCategoria(
        _categoria == _Categoria.favoritas ? _Categoria.todas : _categoria,
        favoritos);
    final recomendado =
        recPool.isEmpty ? null : recPool[DateTime.now().weekday % recPool.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _RecipesHeader(showBack: canPop),
            Expanded(
              child: _error
                  ? _ErrorState(onRetry: () => setState(() => _error = false))
                  : _loading
                      ? const _LoadingSkeleton()
                      : AppPage(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            _SearchField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              onClear: _clearSearch,
                              onFilterTap: _openAdvancedFilters,
                              activeFilters: _advanced.activeCount,
                            ),
                            const SizedBox(height: 16),
                            _CategoryChips(
                              selected: _categoria,
                              onSelected: (c) => setState(() => _categoria = c),
                            ),
                            const SizedBox(height: 20),
                            if (_query.isEmpty && _advanced.isEmpty && recomendado != null) ...[
                              _RecommendedCard(
                                recipe: recomendado,
                                onOpen: () => _openDetail(recomendado),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (filtrados.isEmpty)
                              _EmptyState(
                                searching: _query.isNotEmpty || !_advanced.isEmpty,
                                isFavoritasTab: _categoria == _Categoria.favoritas,
                              )
                            else
                              ...List.generate(filtrados.length, (i) {
                                  final r = filtrados[i];
                                  return FadeInUp(
                                    delayMs: i * 40,
                                    offset: 12,
                                    child: _RecipeCard(
                                      recipe: r,
                                      onTap: () => _openDetail(r),
                                      isFavorite: favoritos.contains(r.id),
                                      onToggleFavorite: () => ref
                                          .read(recipeFavoritesProvider.notifier)
                                          .toggle(r.id),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CABEÇALHO
// ============================================================================
class _RecipesHeader extends StatelessWidget {
  const _RecipesHeader({required this.showBack});
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text('Receitas',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17)),
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: PressableScale(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.arrow_back,
                        size: 18, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BUSCA + LIMPAR + BOTÃO DE FILTROS AVANÇADOS
// ============================================================================
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
    required this.activeFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final int activeFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar receitas...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary, size: 18),
                    onPressed: onClear,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        PressableScale(
          onTap: onFilterTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activeFilters > 0 ? AppColors.secondary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.tune, color: Colors.white, size: 20),
                if (activeFilters > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CHIPS DE CATEGORIA
// ============================================================================
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});
  final _Categoria selected;
  final ValueChanged<_Categoria> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _Categoria.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _Categoria.values[i];
          final active = cat == selected;
          return PressableScale(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                gradient: active ? AppColors.heroPinkGradient : null,
                color: active ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(cat.label,
                  style: TextStyle(
                      color: active ? Colors.white : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// CARD "RECEITA RECOMENDADA PARA HOJE"
// ============================================================================
class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.recipe, required this.onOpen});
  final Recipe recipe;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final imageH = wide ? 220.0 : 180.0;

    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: imageH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  (recipe.photoUrl == null || recipe.photoUrl!.isEmpty)
                      ? Container(
                          color: AppColors.surface2,
                          alignment: Alignment.center,
                          child: Text(recipe.emoji,
                              style: const TextStyle(fontSize: 72)),
                        )
                      : CachedNetworkImage(
                          imageUrl: recipe.photoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surface2,
                            alignment: Alignment.center,
                            child: Text(recipe.emoji,
                                style: const TextStyle(fontSize: 72)),
                          ),
                        ),
                  Positioned(
                    left: 14,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroPinkGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Receita recomendada para hoje',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(wide ? 18 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: wide ? 22 : 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _RecipeMeta(
                          icon: Icons.local_fire_department_rounded,
                          label: '${recipe.kcal} kcal'),
                      _RecipeMeta(
                          icon: Icons.schedule_rounded,
                          label: '${recipe.durationMin} min'),
                      _RecipeMeta(
                          icon: Icons.signal_cellular_alt_rounded,
                          label: recipe.difficulty),
                      _RecipeMeta(
                          icon: Icons.restaurant_rounded,
                          label: recipe.category),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onOpen,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Ver receita',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
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

class _RecipeMeta extends StatelessWidget {
  const _RecipeMeta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CARD DE RECEITA NA LISTA
// ============================================================================
class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  });
  final Recipe recipe;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final thumb = wide ? 100.0 : 84.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Ink(
            padding: EdgeInsets.all(wide ? 14 : 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: thumb,
                  height: thumb,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: (recipe.photoUrl == null || recipe.photoUrl!.isEmpty)
                      ? Center(
                          child: Text(recipe.emoji,
                              style: TextStyle(fontSize: wide ? 40 : 34)))
                      : CachedNetworkImage(
                          imageUrl: recipe.photoUrl!,
                          fit: BoxFit.cover,
                          width: thumb,
                          height: thumb,
                          errorWidget: (_, __, ___) => Center(
                              child: Text(recipe.emoji,
                                  style: TextStyle(fontSize: wide ? 40 : 34))),
                        ),
                ),
                SizedBox(width: wide ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: wide ? 16.5 : 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${recipe.durationMin} min  ·  ${recipe.kcal} kcal  ·  ${recipe.difficulty}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PressableScale(
                  onTap: onToggleFavorite,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.secondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ESTADOS — vazio / carregando / erro
// ============================================================================
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching, required this.isFavoritasTab});
  final bool searching;
  final bool isFavoritasTab;

  @override
  Widget build(BuildContext context) {
    final message = searching
        ? 'Nenhuma receita encontrada.'
        : isFavoritasTab
            ? 'Você ainda não favoritou nenhuma receita.'
            : 'Ainda não há receitas nesta categoria.';
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          LiliMascot(pose: MascotePose.triste, height: searching ? 160 : 220),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        const SkeletonBox(height: 48, radius: 12),
        const SizedBox(height: 16),
        Row(
          children: const [
            SkeletonBox(width: 70, height: 34, radius: 20),
            SizedBox(width: 8),
            SkeletonBox(width: 100, height: 34, radius: 20),
            SizedBox(width: 8),
            SkeletonBox(width: 90, height: 34, radius: 20),
          ],
        ),
        const SizedBox(height: 20),
        const SkeletonBox(height: 240, radius: AppTheme.radius),
        const SizedBox(height: 20),
        for (var i = 0; i < 4; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonBox(height: 80, radius: AppTheme.radiusSm),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 12),
            const Text('Não foi possível carregar as receitas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MODAL DE FILTROS AVANÇADOS
// ============================================================================
class _AdvancedFiltersSheet extends StatefulWidget {
  const _AdvancedFiltersSheet({required this.initial});
  final _AdvancedFilters initial;

  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  late _AdvancedFilters _filters = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filtros avançados',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            _FilterGroup(
              title: 'Objetivo',
              options: _AdvancedFilters.objetivos,
              value: _filters.objetivo,
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(objetivo: () => v)),
            ),
            _FilterGroup(
              title: 'Tipo de dieta',
              options: _AdvancedFilters.dietas,
              value: _filters.dieta,
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(dieta: () => v)),
            ),
            _FilterGroup(
              title: 'Tempo de preparo',
              options: _AdvancedFilters.tempos,
              value: _filters.tempo,
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(tempo: () => v)),
            ),
            _FilterGroup(
              title: 'Faixa de calorias',
              options: _AdvancedFilters.faixasCalorias,
              value: _filters.calorias,
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(calorias: () => v)),
            ),
            _FilterGroup(
              title: 'Dificuldade',
              options: _AdvancedFilters.dificuldades,
              value: _filters.dificuldade,
              onChanged: (v) => setState(
                  () => _filters = _filters.copyWith(dificuldade: () => v)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _filters = const _AdvancedFilters()),
                    child: const Text('Limpar filtros'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_filters),
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opt in options)
                ChoiceChip(
                  label: Text(opt),
                  selected: value == opt,
                  onSelected: (sel) => onChanged(sel ? opt : null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
