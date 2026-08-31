import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/recipe_favorites_providers.dart';

/// Página de detalhe de UMA receita — recebe a [Recipe] completa (id, nome,
/// imagem, categoria, calorias, tempo, dificuldade, ingredientes, modo de
/// preparo, porções e informações nutricionais), então cada card da tela
/// Receitas abre o SEU PRÓPRIO conteúdo.
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritos = ref.watch(recipeFavoritesProvider);
    final isFavorite = favoritos.contains(recipe.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                _RoundIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                _RoundIconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor:
                      isFavorite ? AppColors.secondary : Colors.white,
                  onTap: () => ref
                      .read(recipeFavoritesProvider.notifier)
                      .toggle(recipe.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FadeInUp(
              child: Container(
                height: 200,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: (recipe.photoUrl == null || recipe.photoUrl!.isEmpty)
                    ? Center(
                        child: Text(recipe.emoji,
                            style: const TextStyle(fontSize: 72)))
                    : CachedNetworkImage(
                        imageUrl: recipe.photoUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, ___) => Center(
                            child: Text(recipe.emoji,
                                style: const TextStyle(fontSize: 72))),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Text(recipe.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _Pill(text: recipe.category),
                for (final t in recipe.tags) _Pill(text: t, accent: true),
                recipe.difficulty == 'Fácil'
                    ? const TagBadge.free()
                    : TagBadge.premium(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                    icon: Icons.timer_outlined,
                    label: '${recipe.durationMin} min'),
                _InfoChip(
                    icon: Icons.local_fire_department,
                    label: '${recipe.kcal} kcal'),
                _InfoChip(
                    icon: Icons.bar_chart, label: recipe.difficulty),
                _InfoChip(
                    icon: Icons.restaurant,
                    label: '${recipe.servings} porç.'),
              ],
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'Informações nutricionais',
              icon: Icons.insights_outlined,
              child: Row(
                children: [
                  _NutrientStat(label: 'Kcal', value: '${recipe.kcal}'),
                  _NutrientStat(label: 'Proteína', value: '${recipe.protein}g'),
                  _NutrientStat(label: 'Carbo', value: '${recipe.carbs}g'),
                  _NutrientStat(label: 'Gordura', value: '${recipe.fat}g'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Ingredientes',
              icon: Icons.shopping_basket_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final ing in recipe.ingredients)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(ing,
                                style: const TextStyle(
                                    color: Colors.white, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Modo de preparo',
              icon: Icons.soup_kitchen_outlined,
              child: Text(recipe.steps,
                  style: const TextStyle(color: Colors.white, height: 1.5)),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Objetivo e dieta',
              icon: Icons.flag_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(text: recipe.objetivo, accent: true),
                  _Pill(text: recipe.dietType),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.white,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.accent = false});
  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (accent ? AppColors.secondary : AppColors.textTertiary)
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: accent ? AppColors.secondary : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _NutrientStat extends StatelessWidget {
  const _NutrientStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
