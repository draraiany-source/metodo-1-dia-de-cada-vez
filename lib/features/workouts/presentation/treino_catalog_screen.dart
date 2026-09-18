import 'dart:async';







import 'package:flutter/material.dart';



import 'package:flutter_riverpod/flutter_riverpod.dart';







import '../../../core/assets/app_icons.dart';



import '../../../core/mascot/mascot_widget.dart';



import '../../../core/theme/app_colors.dart';



import '../../../core/theme/app_theme.dart';



import '../../../core/widgets/animations.dart';



import '../../../core/widgets/app_icon_image.dart';



import '../../../core/widgets/app_page.dart';

import '../../../core/widgets/lili_widgets.dart';



import '../../ai_trainer/domain/trainer_engine.dart';



import '../../ai_trainer/providers/ai_trainer_providers.dart';



import '../data/treino_catalog_repository.dart';



import '../domain/treino_catalog_models.dart';



import '../providers/treino_catalog_providers.dart';



import '../providers/workout_favorites_providers.dart';



import 'treino_catalog_detail_screen.dart';



import 'treino_catalog_visual.dart';
import '../../../core/lily/lily_treino_image.dart';
import '../../../core/lily/lily_treino_assets.dart';







/// Abas do catálogo: recomendação, 11 seções visuais e favoritos.



enum _CatalogTab {



  paraVoce,



  cardio,



  core,



  mobilidade,



  inferioresGluteos,



  peitoral,



  costas,



  biceps,



  triceps,



  ombros,



  fullBody,



  panturrilhas,



  favoritos,



}







extension _CatalogTabX on _CatalogTab {



  String get label => switch (this) {



        _CatalogTab.paraVoce => 'Para você',



        _CatalogTab.favoritos => 'Favoritos',



        _ => switch (this) {



            _CatalogTab.cardio => TreinoVisualSection.cardio,



            _CatalogTab.core => TreinoVisualSection.core,



            _CatalogTab.mobilidade => TreinoVisualSection.mobilidade,



            _CatalogTab.inferioresGluteos =>



              TreinoVisualSection.inferioresGluteos,



            _CatalogTab.peitoral => TreinoVisualSection.peitoral,



            _CatalogTab.costas => TreinoVisualSection.costas,



            _CatalogTab.biceps => TreinoVisualSection.biceps,



            _CatalogTab.triceps => TreinoVisualSection.triceps,



            _CatalogTab.ombros => TreinoVisualSection.ombros,



            _CatalogTab.fullBody => TreinoVisualSection.fullBody,



            _CatalogTab.panturrilhas => TreinoVisualSection.panturrilhas,



            _ => TreinoVisualSection.fullBody,



          }.label,



      };







  TreinoVisualSection? get section => switch (this) {



        _CatalogTab.paraVoce || _CatalogTab.favoritos => null,



        _CatalogTab.cardio => TreinoVisualSection.cardio,



        _CatalogTab.core => TreinoVisualSection.core,



        _CatalogTab.mobilidade => TreinoVisualSection.mobilidade,



        _CatalogTab.inferioresGluteos => TreinoVisualSection.inferioresGluteos,



        _CatalogTab.peitoral => TreinoVisualSection.peitoral,



        _CatalogTab.costas => TreinoVisualSection.costas,



        _CatalogTab.biceps => TreinoVisualSection.biceps,



        _CatalogTab.triceps => TreinoVisualSection.triceps,



        _CatalogTab.ombros => TreinoVisualSection.ombros,



        _CatalogTab.fullBody => TreinoVisualSection.fullBody,



        _CatalogTab.panturrilhas => TreinoVisualSection.panturrilhas,



      };



}







/// Catálogo oficial de 117 treinos — filtros, busca e navegação.



class TreinoCatalogScreen extends ConsumerStatefulWidget {



  const TreinoCatalogScreen({super.key});







  @override



  ConsumerState<TreinoCatalogScreen> createState() =>



      _TreinoCatalogScreenState();



}







class _TreinoCatalogScreenState extends ConsumerState<TreinoCatalogScreen> {



  _CatalogTab _tab = _CatalogTab.paraVoce;



  String _query = '';



  TreinoCatalogFilters _filters = const TreinoCatalogFilters();



  Timer? _debounce;



  final _searchController = TextEditingController();







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







  List<TreinoCatalogEntry> _recommended(



    List<TreinoCatalogEntry> all,



    TrainerProfile profile,



  ) {



    final boost = switch (profile.objetivo) {



      Objetivo.emagrecer => TreinoVisualSection.cardio,



      Objetivo.tonificar => TreinoVisualSection.inferioresGluteos,



      Objetivo.ganharMassa => TreinoVisualSection.peitoral,



      Objetivo.saude => TreinoVisualSection.mobilidade,



    };



    final nivel = profile.nivel.label;



    final scored = all.map((t) {



      var score = 0;



      if (t.visualSection == boost) score += 3;



      if (t.nivel.contains(nivel)) score += 2;



      if (t.nivel.contains('Iniciante')) score += 1;



      return (t, score);



    }).toList()



      ..sort((a, b) => b.$2.compareTo(a.$2));



    return scored.take(12).map((e) => e.$1).toList();



  }







  TreinoCatalogEntry? _dailyPick(



    List<TreinoCatalogEntry> pool,



    TrainerProfile profile,



  ) {



    if (pool.isEmpty) return null;



    final day = DateTime.now().day;



    final rec = _recommended(pool, profile);



    return rec[day % rec.length];



  }







  List<TreinoCatalogEntry> _byTab(



    _CatalogTab tab,



    List<TreinoCatalogEntry> all,



    TrainerProfile profile,



    Set<String> favoritos,



  ) {



    switch (tab) {



      case _CatalogTab.paraVoce:



        return _recommended(all, profile);



      case _CatalogTab.favoritos:



        return all.where((t) => favoritos.contains(t.id)).toList();



      default:



        final section = tab.section!;



        return all.where((t) => t.visualSection == section).toList();



    }



  }







  bool _matchesQuery(TreinoCatalogEntry t, String q) {



    if (q.isEmpty) return true;



    final lower = q.toLowerCase();



    return t.nome.toLowerCase().contains(lower) ||



        (t.categoria ?? '').toLowerCase().contains(lower) ||



        (t.grupoMuscular ?? '').toLowerCase().contains(lower) ||



        (t.equipamento ?? '').toLowerCase().contains(lower) ||



        (t.objetivo ?? '').toLowerCase().contains(lower) ||



        t.nivel.any((n) => n.toLowerCase().contains(lower));



  }







  Future<void> _openFilters(TreinoCatalogFilterOptions options) async {



    final result = await showModalBottomSheet<TreinoCatalogFilters>(



      context: context,



      backgroundColor: AppColors.surface,



      isScrollControlled: true,



      shape: const RoundedRectangleBorder(



        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),



      ),



      builder: (_) => _CatalogFiltersSheet(



        initial: _filters,



        options: options,



      ),



    );



    if (result != null && mounted) setState(() => _filters = result);



  }







  void _openDetail(TreinoCatalogEntry t) {



    Navigator.of(context).push(



      MaterialPageRoute(



        builder: (_) => TreinoCatalogDetailScreen(treino: t),



      ),



    );



  }







  @override



  Widget build(BuildContext context) {



    final canPop = Navigator.of(context).canPop();



    final favoritos = ref.watch(workoutFavoritesProvider);



    final profile = ref.watch(trainerProfileProvider);



    final catalogAsync = ref.watch(treinoCatalogStudentProvider);



    final optionsAsync = ref.watch(treinoCatalogFilterOptionsProvider);







    return Scaffold(



      backgroundColor: AppColors.background,



      body: SafeArea(



        child: Column(



          children: [



            _Header(showBack: canPop),



            Expanded(



              child: catalogAsync.when(



                loading: () => const _LoadingSkeleton(),



                error: (err, _) => _ErrorState(



                  message: err.toString(),



                  onRetry: () {



                    ref.read(treinoCatalogRepositoryProvider).clearCache();



                    ref.invalidate(treinoCatalogSnapshotProvider);



                    ref.invalidate(treinoCatalogStudentProvider);



                    ref.invalidate(treinoCatalogFilterOptionsProvider);



                  },



                ),



                data: (all) {



                  final filtrados = _byTab(_tab, all, profile, favoritos)



                      .where((t) => _matchesQuery(t, _query))



                      .where(_filters.matches)



                      .toList();



                  final recomendado = _query.isEmpty &&



                          _filters.isEmpty &&



                          _tab == _CatalogTab.paraVoce



                      ? _dailyPick(all, profile)



                      : null;







                  return AppPage(



                    scrollable: false,



                    child: Column(



                      crossAxisAlignment: CrossAxisAlignment.stretch,



                      children: [



                        _SearchField(



                          controller: _searchController,



                          onChanged: _onSearchChanged,



                          onFilterTap: () {



                            optionsAsync.whenData(_openFilters);



                          },



                          activeFilters: _filters.activeCount,



                        ),



                        const SizedBox(height: 12),



                        _TabChips(



                          selected: _tab,



                          onSelected: (t) => setState(() => _tab = t),



                        ),



                        const SizedBox(height: 12),



                        Text(



                          '${filtrados.length} treino${filtrados.length == 1 ? '' : 's'}',



                          style: const TextStyle(



                            color: AppColors.textTertiary,



                            fontSize: 12,



                          ),



                        ),



                        const SizedBox(height: 8),



                        Expanded(



                          child: filtrados.isEmpty



                              ? _EmptyState(



                                  searching:



                                      _query.isNotEmpty || !_filters.isEmpty,



                                  isFavoritosTab: _tab == _CatalogTab.favoritos,



                                )



                              : ListView.builder(



                                  padding: const EdgeInsets.only(bottom: 24),



                                  itemCount: filtrados.length +



                                      (recomendado != null ? 1 : 0),



                                  itemBuilder: (context, i) {



                                    if (recomendado != null && i == 0) {



                                      return Padding(



                                        padding:



                                            const EdgeInsets.only(bottom: 12),



                                        child: _RecommendedCard(



                                          treino: recomendado,



                                          onStart: () =>



                                              _openDetail(recomendado),



                                        ),



                                      );



                                    }



                                    final idx =



                                        recomendado != null ? i - 1 : i;



                                    final t = filtrados[idx];



                                    return FadeInUp(



                                      delayMs: idx * 30,



                                      offset: 10,



                                      child: _TreinoCard(



                                        treino: t,



                                        onTap: () => _openDetail(t),



                                        isFavorite:



                                            favoritos.contains(t.id),



                                        onToggleFavorite: () => ref



                                            .read(workoutFavoritesProvider



                                                .notifier)



                                            .toggle(t.id),



                                      ),



                                    );



                                  },



                                ),



                        ),



                      ],



                    ),



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







class _Header extends StatelessWidget {



  const _Header({required this.showBack});



  final bool showBack;







  @override



  Widget build(BuildContext context) {



    return Padding(



      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),



      child: Row(



        crossAxisAlignment: CrossAxisAlignment.start,



        children: [



          if (showBack)



            PressableScale(



              onTap: () => Navigator.of(context).maybePop(),



              child: Container(



                width: 38,



                height: 38,



                margin: const EdgeInsets.only(right: 8, top: 4),



                decoration: BoxDecoration(



                  color: AppColors.surface,



                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),



                  border: Border.all(color: AppColors.border),



                ),



                child: const Icon(Icons.arrow_back,



                    size: 18, color: Colors.white),



              ),



            ),



          Expanded(



            child: Column(



              crossAxisAlignment: CrossAxisAlignment.start,



              children: [



                const Text('Treinos',



                    style: TextStyle(



                        color: Colors.white,



                        fontWeight: FontWeight.w800,



                        fontSize: 26)),



                const SizedBox(height: 4),



                RichText(



                  text: const TextSpan(



                    style: TextStyle(



                        color: AppColors.textSecondary, fontSize: 13.5),



                    children: [



                      TextSpan(text: '117 exercícios oficiais — '),



                      TextSpan(



                        text: 'escolha e treine!',



                        style: TextStyle(



                          color: AppColors.secondary,



                          fontWeight: FontWeight.w700,



                        ),



                      ),



                    ],



                  ),



                ),



              ],



            ),



          ),



          const SizedBox(



            width: 64,



            height: 72,



            child: LiliFitMascot(



              pose: MascotePose.halteres,



              height: 72,



              fit: BoxFit.contain,



              blackBackdrop: true,



            ),



          ),



        ],



      ),



    );



  }



}







class _SearchField extends StatelessWidget {



  const _SearchField({



    required this.controller,



    required this.onChanged,



    required this.onFilterTap,



    required this.activeFilters,



  });







  final TextEditingController controller;



  final ValueChanged<String> onChanged;



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



            style: const TextStyle(color: AppColors.textPrimary),



            decoration: const InputDecoration(



              hintText: 'Buscar por nome do exercício...',



              prefixIcon: Padding(



                padding: EdgeInsets.all(12),



                child: AppIconImage(



                  AppIcons.search,



                  size: 20,



                  fallbackIcon: Icons.search,



                ),



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



              color: activeFilters > 0



                  ? AppColors.secondary



                  : AppColors.surface,



              borderRadius: BorderRadius.circular(AppTheme.radiusSm),



              border: activeFilters > 0



                  ? null



                  : Border.all(color: AppColors.border),



            ),



            child: Stack(



              alignment: Alignment.center,



              children: [



                const AppIconImage(



                  AppIcons.filter,



                  size: 20,



                  fallbackIcon: Icons.tune,



                ),



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







class _TabChips extends StatelessWidget {



  const _TabChips({required this.selected, required this.onSelected});







  final _CatalogTab selected;



  final ValueChanged<_CatalogTab> onSelected;







  @override



  Widget build(BuildContext context) {



    return SizedBox(



      height: 38,



      child: ListView.separated(



        scrollDirection: Axis.horizontal,



        itemCount: _CatalogTab.values.length,



        separatorBuilder: (_, __) => const SizedBox(width: 8),



        itemBuilder: (context, i) {



          final tab = _CatalogTab.values[i];



          final active = tab == selected;



          return PressableScale(



            onTap: () => onSelected(tab),



            child: AnimatedContainer(



              duration: const Duration(milliseconds: 220),



              padding: const EdgeInsets.symmetric(horizontal: 14),



              decoration: BoxDecoration(



                gradient: active ? AppColors.heroPinkGradient : null,



                color: active ? null : AppColors.surface,



                borderRadius: BorderRadius.circular(20),



              ),



              alignment: Alignment.center,



              child: Text(



                tab.label,



                style: TextStyle(



                  color: active ? Colors.white : AppColors.textSecondary,



                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,



                  fontSize: 12,



                ),



              ),



            ),



          );



        },



      ),



    );



  }



}







class _RecommendedCard extends StatelessWidget {



  const _RecommendedCard({required this.treino, required this.onStart});







  final TreinoCatalogEntry treino;



  final VoidCallback onStart;







  @override



  Widget build(BuildContext context) {



    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(



      decoration: BoxDecoration(



        gradient: AppColors.vibeGradient,



        borderRadius: BorderRadius.circular(AppTheme.radius),



      ),



      padding: const EdgeInsets.all(16),



      child: Row(



        children: [



          TreinoSectionIcon(
            section: treino.visualSection,
            treino: treino,
            size: 72,
          ),



          const SizedBox(width: 14),



          Expanded(



            child: Column(



              crossAxisAlignment: CrossAxisAlignment.start,



              children: [



                const Text('Treino recomendado para hoje',



                    style: TextStyle(color: Colors.white70, fontSize: 11)),



                const SizedBox(height: 6),



                Text(treino.nome,



                    style: const TextStyle(



                        color: Colors.white,



                        fontWeight: FontWeight.bold,



                        fontSize: 17)),



                const SizedBox(height: 10),



                PressableScale(



                  onTap: onStart,



                  child: Container(



                    padding:



                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),



                    decoration: BoxDecoration(



                      color: Colors.white,



                      borderRadius: BorderRadius.circular(20),



                    ),



                    child: const Text('Ver treino',



                        style: TextStyle(



                            color: AppColors.primaryDark,



                            fontWeight: FontWeight.w700)),



                  ),



                ),



              ],



            ),



          ),



        ],



      ),



    ),
      ),
    );
  }
}


class _TreinoCard extends StatelessWidget {



  const _TreinoCard({



    required this.treino,



    required this.onTap,



    required this.isFavorite,



    required this.onToggleFavorite,



  });







  final TreinoCatalogEntry treino;



  final VoidCallback onTap;



  final bool isFavorite;



  final VoidCallback onToggleFavorite;







  @override



  Widget build(BuildContext context) {



    final intervalo = treinoFieldOrNull(treino.intervalo);



    final objetivo = treinoFieldOrNull(treino.objetivo);







    return Padding(



      padding: const EdgeInsets.only(bottom: 10),



      child: Material(



        color: Colors.transparent,



        child: InkWell(



          onTap: onTap,



          borderRadius: BorderRadius.circular(AppTheme.radius),



          child: Ink(



            padding: const EdgeInsets.all(12),



            decoration: BoxDecoration(



              gradient: AppColors.softCardGradient,



              borderRadius: BorderRadius.circular(AppTheme.radius),



              border: Border.all(color: AppColors.border.withOpacity(0.85)),



            ),



            child: Row(



              children: [



                TreinoSectionIcon(
                  section: treino.visualSection,
                  treino: treino,
                  size: 52,
                ),



                const SizedBox(width: 12),



                Expanded(



                  child: Column(



                    crossAxisAlignment: CrossAxisAlignment.start,



                    children: [



                      Text(



                        treino.nome,



                        maxLines: 2,



                        overflow: TextOverflow.ellipsis,



                        style: const TextStyle(



                          fontWeight: FontWeight.w800,



                          fontSize: 15,



                          color: Colors.white,



                        ),



                      ),



                      const SizedBox(height: 4),



                      Text(



                        treinoSubtitle(treino),



                        maxLines: 1,



                        overflow: TextOverflow.ellipsis,



                        style: TextStyle(



                          color: AppColors.secondary.withOpacity(0.95),



                          fontSize: 11.5,



                          fontWeight: FontWeight.w600,



                        ),



                      ),



                      if (treinoMetaLine(treino).isNotEmpty) ...[



                        const SizedBox(height: 4),



                        Text(



                          treinoMetaLine(treino),



                          maxLines: 2,



                          overflow: TextOverflow.ellipsis,



                          style: const TextStyle(



                            color: AppColors.textSecondary,



                            fontSize: 11,



                          ),



                        ),



                      ],



                      if (intervalo != null || objetivo != null) ...[



                        const SizedBox(height: 4),



                        Text(



                          [



                            if (intervalo != null) 'Intervalo: $intervalo',



                            if (objetivo != null) objetivo,



                          ].join(' · '),



                          maxLines: 2,



                          overflow: TextOverflow.ellipsis,



                          style: const TextStyle(



                            color: AppColors.textTertiary,



                            fontSize: 10.5,



                          ),



                        ),



                      ],



                    ],



                  ),



                ),



                Column(



                  children: [



                    PressableScale(



                      onTap: onToggleFavorite,



                      child: Container(



                        width: 40,



                        height: 40,



                        decoration: BoxDecoration(



                          color: AppColors.surface2,



                          shape: BoxShape.circle,



                          border: Border.all(color: AppColors.border),



                        ),



                        child: FavoriteAssetIcon(active: isFavorite, size: 18),



                      ),



                    ),



                    const SizedBox(height: 8),



                    PressableScale(



                      onTap: onTap,



                      child: Container(



                        padding: const EdgeInsets.symmetric(



                            horizontal: 10, vertical: 6),



                        decoration: BoxDecoration(



                          gradient: AppColors.heroPinkGradient,



                          borderRadius: BorderRadius.circular(20),



                        ),



                        child: const Row(



                          mainAxisSize: MainAxisSize.min,



                          children: [



                            AppIconImage(



                              AppIcons.play,



                              size: 14,



                              fallbackIcon: Icons.play_arrow_rounded,



                            ),



                            SizedBox(width: 4),



                            Text(



                              'Ver',



                              style: TextStyle(



                                color: Colors.white,



                                fontWeight: FontWeight.w700,



                                fontSize: 11,



                              ),



                            ),



                          ],



                        ),



                      ),



                    ),



                  ],



                ),



              ],



            ),



          ),



        ),



      ),



    );



  }



}







class _EmptyState extends StatelessWidget {



  const _EmptyState({required this.searching, required this.isFavoritosTab});







  final bool searching;



  final bool isFavoritosTab;







  @override



  Widget build(BuildContext context) {



    final message = searching



        ? 'Nenhum treino encontrado.'



        : isFavoritosTab



            ? 'Você ainda não favoritou nenhum treino.'



            : 'Ainda não há treinos nesta categoria.';



    return Center(



      child: Column(



        mainAxisSize: MainAxisSize.min,



        children: [



          LiliFitMascot(



            pose: searching ? MascotePose.apontando : MascotePose.triste,



            height: searching ? MascotSizes.medium : MascotSizes.large,



            blackBackdrop: true,



          ),



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



      children: const [



        SkeletonBox(height: 48, radius: 12),



        SizedBox(height: 16),



        SkeletonBox(height: 34, radius: 20),



        SizedBox(height: 20),



        SkeletonBox(height: 100, radius: AppTheme.radius),



        SizedBox(height: 12),



        SkeletonBox(height: 100, radius: AppTheme.radius),



      ],



    );



  }



}







class _ErrorState extends StatelessWidget {



  const _ErrorState({required this.onRetry, this.message});



  final VoidCallback onRetry;



  final String? message;







  @override



  Widget build(BuildContext context) {



    return Center(



      child: Column(



        mainAxisSize: MainAxisSize.min,



        children: [



          const Icon(Icons.error_outline, color: AppColors.danger, size: 48),



          const SizedBox(height: 12),



          const Text('Não foi possível carregar os treinos.',



              textAlign: TextAlign.center,



              style: TextStyle(color: Colors.white)),



          if (message != null && message!.isNotEmpty) ...[



            const SizedBox(height: 8),



            Padding(



              padding: const EdgeInsets.symmetric(horizontal: 24),



              child: Text(



                message!,



                textAlign: TextAlign.center,



                style: AppTextStyles.caption(color: AppColors.textTertiary),



              ),



            ),



          ],



          const SizedBox(height: 16),



          ElevatedButton.icon(



            onPressed: onRetry,



            icon: const Icon(Icons.refresh),



            label: const Text('Tentar novamente'),



          ),



        ],



      ),



    );



  }



}







class _CatalogFiltersSheet extends StatefulWidget {



  const _CatalogFiltersSheet({



    required this.initial,



    required this.options,



  });







  final TreinoCatalogFilters initial;



  final TreinoCatalogFilterOptions options;







  @override



  State<_CatalogFiltersSheet> createState() => _CatalogFiltersSheetState();



}







class _CatalogFiltersSheetState extends State<_CatalogFiltersSheet> {



  late TreinoCatalogFilters _filters = widget.initial;







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



                Text('Filtros',



                    style: Theme.of(context).textTheme.titleLarge),



                IconButton(



                  onPressed: () => Navigator.of(context).pop(),



                  icon: const Icon(Icons.close, color: Colors.white),



                ),



              ],



            ),



            _FilterGroup(



              title: 'Categoria',



              options: widget.options.categorias,



              value: _filters.categoria,



              onChanged: (v) => setState(() => _filters =



                  _filters.copyWith(categoria: () => v)),



            ),



            _FilterGroup(



              title: 'Nível',



              options: widget.options.niveis,



              value: _filters.nivel,



              onChanged: (v) =>



                  setState(() => _filters = _filters.copyWith(nivel: () => v)),



            ),



            _FilterGroup(



              title: 'Grupo muscular',



              options: widget.options.gruposMusculares,



              value: _filters.grupoMuscular,



              onChanged: (v) => setState(() => _filters =



                  _filters.copyWith(grupoMuscular: () => v)),



            ),



            _FilterGroup(



              title: 'Equipamento',



              options: widget.options.equipamentos,



              value: _filters.equipamento,



              onChanged: (v) => setState(() => _filters =



                  _filters.copyWith(equipamento: () => v)),



            ),



            _FilterGroup(



              title: 'Objetivo',



              options: widget.options.objetivos,



              value: _filters.objetivo,



              onChanged: (v) => setState(() => _filters =



                  _filters.copyWith(objetivo: () => v)),



            ),



            const SizedBox(height: 12),



            Row(



              children: [



                Expanded(



                  child: OutlinedButton(



                    onPressed: () => setState(



                        () => _filters = const TreinoCatalogFilters()),



                    child: const Text('Limpar filtros'),



                  ),



                ),



                const SizedBox(width: 12),



                Expanded(



                  child: ElevatedButton(



                    onPressed: () => Navigator.of(context).pop(_filters),



                    child: const Text('Aplicar'),



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



    if (options.isEmpty) return const SizedBox.shrink();



    return Padding(



      padding: const EdgeInsets.only(bottom: 16),



      child: Column(



        crossAxisAlignment: CrossAxisAlignment.start,



        children: [



          Text(title,



              style: const TextStyle(



                  color: AppColors.textSecondary,



                  fontWeight: FontWeight.w600)),



          const SizedBox(height: 8),



          Wrap(



            spacing: 8,



            runSpacing: 8,



            children: [



              _ChipOption(



                label: 'Qualquer',



                selected: value == null,



                onTap: () => onChanged(null),



              ),



              for (final o in options)



                _ChipOption(



                  label: o,



                  selected: value == o,



                  onTap: () => onChanged(o),



                ),



            ],



          ),



        ],



      ),



    );



  }



}







class _ChipOption extends StatelessWidget {



  const _ChipOption({



    required this.label,



    required this.selected,



    required this.onTap,



  });







  final String label;



  final bool selected;



  final VoidCallback onTap;







  @override



  Widget build(BuildContext context) {



    return PressableScale(



      onTap: onTap,



      child: Container(



        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),



        decoration: BoxDecoration(



          color: selected ? AppColors.secondary : AppColors.surface2,



          borderRadius: BorderRadius.circular(20),



          border: Border.all(



            color: selected ? AppColors.secondary : AppColors.border,



          ),



        ),



        child: Text(



          label,



          style: TextStyle(



            color: selected ? Colors.white : AppColors.textSecondary,



            fontSize: 12,



          ),



        ),



      ),



    );



  }



}



