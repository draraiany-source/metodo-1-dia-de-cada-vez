import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/mascot/mascot_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../models/domain_models.dart';
import '../../ai_trainer/domain/trainer_engine.dart';
import '../../ai_trainer/providers/ai_trainer_providers.dart';
import '../providers/workout_favorites_providers.dart';
import 'workout_detail_screen.dart';

/// ============================================================================
/// TREINOS — catálogo com filtros por categoria, busca, filtros avançados,
/// favoritos e recomendação do dia.
///
/// Princípio seguido em toda a tela: **nenhum treino é inventado**. Tudo vem
/// de `SeedData.workouts` (catálogo real do app — mesmo usado na Home e em
/// Meu Plano). "Para você" usa o perfil real já coletado pela IA Personal
/// Trainer (`trainerProfileProvider.nivel` / `.objetivo`) para priorizar o
/// catálogo, sem fabricar histórico que o app ainda não rastreia por treino.
/// ============================================================================
enum _Categoria { paraVoce, forca, cardio, gluteos, favoritos }

extension _CategoriaX on _Categoria {
  String get label => switch (this) {
        _Categoria.paraVoce => 'Para você',
        _Categoria.forca => 'Força',
        _Categoria.cardio => 'Cardio',
        _Categoria.gluteos => 'Glúteos',
        _Categoria.favoritos => '❤️ Favoritos',
      };
}

/// Seleções do modal de filtros avançados — cada campo `null` = "qualquer".
class _AdvancedFilters {
  const _AdvancedFilters({
    this.objetivo,
    this.nivel,
    this.duracao,
    this.parteDoCorpo,
    this.equipamento,
    this.local,
  });

  final String? objetivo;
  final String? nivel;
  final String? duracao;
  final String? parteDoCorpo;
  final String? equipamento;
  final String? local;

  static const objetivos = ['Emagrecimento', 'Hipertrofia', 'Condicionamento', 'Mobilidade'];
  static const niveis = ['Iniciante', 'Intermediário', 'Avançado'];
  static const duracoes = [
    'Até 15 minutos',
    '15 a 30 minutos',
    '30 a 45 minutos',
    'Acima de 45 minutos',
  ];
  static const partesDoCorpo = ['Corpo todo', 'Pernas', 'Braços', 'Costas', 'Abdômen', 'Glúteos'];
  static const equipamentos = ['Peso corporal', 'Halteres', 'Elástico', 'Esteira/Bike', 'Nenhum equipamento'];
  static const locais = ['Casa', 'Academia', 'Ar livre'];

  bool get isEmpty =>
      objetivo == null &&
      nivel == null &&
      duracao == null &&
      parteDoCorpo == null &&
      equipamento == null &&
      local == null;

  int get activeCount => [objetivo, nivel, duracao, parteDoCorpo, equipamento, local]
      .where((v) => v != null)
      .length;

  bool matches(Workout w) {
    if (nivel != null && w.level != nivel) return false;
    if (objetivo != null && !w.tags.contains(objetivo)) return false;
    if (parteDoCorpo != null && !w.tags.contains(parteDoCorpo)) return false;
    if (equipamento != null && !w.tags.contains(equipamento)) return false;
    if (local != null && !w.tags.contains(local)) return false;
    if (duracao != null) {
      final d = w.durationMin;
      final ok = switch (duracao) {
        'Até 15 minutos' => d <= 15,
        '15 a 30 minutos' => d > 15 && d <= 30,
        '30 a 45 minutos' => d > 30 && d <= 45,
        'Acima de 45 minutos' => d > 45,
        _ => true,
      };
      if (!ok) return false;
    }
    return true;
  }

  _AdvancedFilters copyWith({
    String? Function()? objetivo,
    String? Function()? nivel,
    String? Function()? duracao,
    String? Function()? parteDoCorpo,
    String? Function()? equipamento,
    String? Function()? local,
  }) =>
      _AdvancedFilters(
        objetivo: objetivo != null ? objetivo() : this.objetivo,
        nivel: nivel != null ? nivel() : this.nivel,
        duracao: duracao != null ? duracao() : this.duracao,
        parteDoCorpo: parteDoCorpo != null ? parteDoCorpo() : this.parteDoCorpo,
        equipamento: equipamento != null ? equipamento() : this.equipamento,
        local: local != null ? local() : this.local,
      );
}

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  _Categoria _categoria = _Categoria.paraVoce;
  String _query = '';
  _AdvancedFilters _advanced = const _AdvancedFilters();

  Timer? _debounce;
  final _searchController = TextEditingController();

  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    // Pequena transição inicial — o catálogo é 100% local (SeedData), então
    // não há requisição de rede real; o skeleton serve só pra suavizar o
    // primeiro frame e deixar o padrão de estados (carregando/erro/vazio/
    // carregado) coerente com o resto do app.
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

  List<Workout> _recommended(TrainerProfile profile) {
    final nivelLabel = profile.nivel.label;
    var list = SeedData.workouts
        .where((w) => w.level == nivelLabel || w.level == 'Todos os níveis')
        .toList();
    if (list.isEmpty) list = List.of(SeedData.workouts);

    final boost = switch (profile.objetivo) {
      Objetivo.emagrecer => 'Cardio',
      Objetivo.tonificar => 'Força',
      Objetivo.ganharMassa => 'Força',
      Objetivo.saude => 'Mobilidade',
    };
    list.sort((a, b) {
      final aBoost = a.tags.contains(boost) ? 0 : 1;
      final bBoost = b.tags.contains(boost) ? 0 : 1;
      return aBoost.compareTo(bBoost);
    });
    return list;
  }

  List<Workout> _byCategoria(
      _Categoria cat, TrainerProfile profile, Set<String> favoritos) {
    switch (cat) {
      case _Categoria.paraVoce:
        return _recommended(profile);
      case _Categoria.forca:
        return SeedData.workouts.where((w) => w.tags.contains('Força')).toList();
      case _Categoria.cardio:
        return SeedData.workouts.where((w) => w.tags.contains('Cardio')).toList();
      case _Categoria.gluteos:
        return SeedData.workouts.where((w) => w.tags.contains('Glúteos')).toList();
      case _Categoria.favoritos:
        return SeedData.workouts.where((w) => favoritos.contains(w.id)).toList();
    }
  }

  bool _matchesQuery(Workout w, String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase();
    return w.title.toLowerCase().contains(lower) ||
        w.level.toLowerCase().contains(lower) ||
        w.tags.any((t) => t.toLowerCase().contains(lower)) ||
        '${w.durationMin}'.contains(lower);
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

  void _openDetail(Workout w) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final favoritos = ref.watch(workoutFavoritesProvider);
    final profile = ref.watch(trainerProfileProvider);

    List<Workout> filtrados = const [];
    if (!_loading) {
      try {
        filtrados = _byCategoria(_categoria, profile, favoritos)
            .where((w) => _matchesQuery(w, _query))
            .where(_advanced.matches)
            .toList();
        _error = false;
      } catch (_) {
        _error = true;
      }
    }

    final recPool = _recommended(profile);
    final recomendado = recPool.isEmpty
        ? null
        : recPool[DateTime.now().weekday % recPool.length];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _WorkoutsHeader(showBack: canPop),
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
                              onFilterTap: _openAdvancedFilters,
                              activeFilters: _advanced.activeCount,
                            ),
                            const SizedBox(height: 16),
                            _CategoryChips(
                              selected: _categoria,
                              onSelected: (c) => setState(() => _categoria = c),
                            ),
                            const SizedBox(height: 16),
                            if (_query.isEmpty && _advanced.isEmpty && recomendado != null) ...[
                              _RecommendedCard(
                                workout: recomendado,
                                onStart: () => _openDetail(recomendado),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (filtrados.isEmpty)
                              _EmptyState(
                                searching: _query.isNotEmpty || !_advanced.isEmpty,
                                isFavoritosTab: _categoria == _Categoria.favoritos,
                              )
                            else
                              ...List.generate(filtrados.length, (i) {
                                  final w = filtrados[i];
                                  return FadeInUp(
                                    delayMs: i * 40,
                                    offset: 12,
                                    child: _WorkoutCard(
                                      workout: w,
                                      onTap: () => _openDetail(w),
                                      isFavorite: favoritos.contains(w.id),
                                      onToggleFavorite: () => ref
                                          .read(workoutFavoritesProvider.notifier)
                                          .toggle(w.id),
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
class _WorkoutsHeader extends StatelessWidget {
  const _WorkoutsHeader({required this.showBack});
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
            const Text('Treinos',
                style: TextStyle(
                    color: AppColors.textPrimary,
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
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.arrow_back,
                        size: 18, color: AppColors.textPrimary),
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
// BUSCA + BOTÃO DE FILTROS AVANÇADOS
// ============================================================================
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
              hintText: 'Buscar treinos...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
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
                Icon(Icons.tune,
                    color: activeFilters > 0
                        ? Colors.white
                        : AppColors.textPrimary,
                    size: 20),
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
// CHIPS DE CATEGORIA — Para você / Força / Cardio / Glúteos / Favoritos
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
// CARD "TREINO RECOMENDADO PARA HOJE"
// ============================================================================
class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.workout, required this.onStart});
  final Workout workout;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.vibeGradient,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('⭐ Treino recomendado para hoje',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                    const SizedBox(height: 10),
                    Text(workout.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19)),
                    const SizedBox(height: 4),
                    Text(
                        '${workout.durationMin} min · ${workout.level} · ${workout.exercises} exercícios',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12)),
                    const SizedBox(height: 14),
                    PressableScale(
                      onTap: onStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Começar agora',
                            style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const LiliFitMascot(
                pose: MascotePose.halteres,
                height: 200,
                blackBackdrop: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARD DE TREINO NA LISTA
// ============================================================================
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.workout,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFavorite,
  });
  final Workout workout;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final thumb = wide ? 96.0 : 80.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Ink(
            padding: EdgeInsets.all(wide ? 16 : 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppColors.border.withOpacity(0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
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
                    gradient: AppColors.softCardGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: (workout.photoUrl == null || workout.photoUrl!.isEmpty)
                      ? Center(
                          child: Text(workout.emoji,
                              style: TextStyle(fontSize: wide ? 40 : 34)))
                      : CachedNetworkImage(
                          imageUrl: workout.photoUrl!,
                          fit: BoxFit.cover,
                          width: thumb,
                          height: thumb,
                          errorWidget: (_, __, ___) => Center(
                              child: Text(workout.emoji,
                                  style: TextStyle(fontSize: wide ? 40 : 34))),
                        ),
                ),
                SizedBox(width: wide ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: wide ? 17 : 15.5,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _MetaChip(
                            icon: Icons.schedule_rounded,
                            label: '${workout.durationMin} min',
                          ),
                          _MetaChip(
                            icon: Icons.fitness_center_rounded,
                            label: workout.level,
                          ),
                          _MetaChip(
                            icon: Icons.local_fire_department_rounded,
                            label: workout.kcal != null
                                ? '${workout.kcal} kcal'
                                : '—',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      workout.isPremium
                          ? const TagBadge.premium()
                          : const TagBadge.free(),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  children: [
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
                    const SizedBox(height: 10),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.secondary),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ESTADOS — vazio / carregando / erro
// ============================================================================
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
            : 'Ainda não há treinos disponíveis nesta categoria.';
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
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
      children: [
        const SkeletonBox(height: 48, radius: 12),
        const SizedBox(height: 16),
        Row(
          children: const [
            SkeletonBox(width: 90, height: 34, radius: 20),
            SizedBox(width: 8),
            SkeletonBox(width: 70, height: 34, radius: 20),
            SizedBox(width: 8),
            SkeletonBox(width: 70, height: 34, radius: 20),
          ],
        ),
        const SizedBox(height: 20),
        const SkeletonBox(height: 140, radius: AppTheme.radius),
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
            const Text('Não foi possível carregar os treinos.',
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
              title: 'Nível',
              options: _AdvancedFilters.niveis,
              value: _filters.nivel,
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(nivel: () => v)),
            ),
            _FilterGroup(
              title: 'Duração',
              options: _AdvancedFilters.duracoes,
              value: _filters.duracao,
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(duracao: () => v)),
            ),
            _FilterGroup(
              title: 'Parte do corpo',
              options: _AdvancedFilters.partesDoCorpo,
              value: _filters.parteDoCorpo,
              onChanged: (v) => setState(
                  () => _filters = _filters.copyWith(parteDoCorpo: () => v)),
            ),
            _FilterGroup(
              title: 'Equipamento',
              options: _AdvancedFilters.equipamentos,
              value: _filters.equipamento,
              onChanged: (v) => setState(
                  () => _filters = _filters.copyWith(equipamento: () => v)),
            ),
            _FilterGroup(
              title: 'Local do treino',
              options: _AdvancedFilters.locais,
              value: _filters.local,
              onChanged: (v) =>
                  setState(() => _filters = _filters.copyWith(local: () => v)),
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
