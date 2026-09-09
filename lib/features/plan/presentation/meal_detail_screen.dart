import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/seed_data.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../missions/providers/missions_providers.dart';
import '../../nutrition/domain/nutrition_models.dart';
import '../../nutrition/providers/food_log_providers.dart';
import '../../recipes/presentation/widgets/recipe_cover_image.dart';

/// Página de detalhe de UMA refeição do plano do dia.
///
/// Recebe o slot ([mealType]) e a receita real correspondente ([recipe] —
/// vinda de `SeedData.recipes` via `PlannedMealX`), então cada card de
/// "Refeições" na tela Meu Plano abre o SEU PRÓPRIO conteúdo: nome, prato,
/// calorias, ingredientes e modo de preparo nunca se repetem entre slots.
class MealDetailScreen extends ConsumerWidget {
  const MealDetailScreen({
    super.key,
    required this.mealType,
    required this.recipe,
  });

  final MealType mealType;
  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(foodLogProvider);
    final concluida = log.any((e) => e.mealType == mealType);

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
                _StatusPill(concluida: concluida),
              ],
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppColors.heroPinkGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: RecipeCoverImage(recipe: recipe),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(mealType.label,
                  style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(recipe.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoChip(icon: Icons.local_fire_department,
                    label: '${recipe.kcal} kcal',
                    color: AppColors.warning),
                const SizedBox(width: 10),
                _InfoChip(icon: Icons.restaurant_rounded,
                    label: '${recipe.protein}g proteína',
                    color: AppColors.info),
              ],
            ),
            const SizedBox(height: 28),
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
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _toggle(context, ref, concluida),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      concluida ? AppColors.surface2 : AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    side: concluida
                        ? BorderSide(color: AppColors.success.withOpacity(0.5))
                        : BorderSide.none,
                  ),
                ),
                icon: Icon(concluida
                    ? Icons.check_circle
                    : Icons.restaurant_menu),
                label: Text(concluida
                    ? 'Concluída — toque para desmarcar'
                    : 'Marcar como concluída'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(BuildContext context, WidgetRef ref, bool concluida) async {
    if (concluida) {
      await ref.read(foodLogProvider.notifier).removeMealType(mealType);
      FeedbackService.play(FeedbackEvent.toqueLeve);
      return;
    }
    await ref.read(foodLogProvider.notifier).add(
          recipe.title,
          recipe.kcal,
          protein: recipe.protein,
          mealType: mealType,
        );
    ref.read(missionsProvider.notifier).report(MissionEvent.refeicaoRegistrada);
    FeedbackService.play(FeedbackEvent.sucesso);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${mealType.label} concluída! 🎉')),
      );
    }
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.concluida});
  final bool concluida;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (concluida ? AppColors.success : AppColors.textTertiary)
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        concluida ? '✓ Concluída' : 'Pendente',
        style: TextStyle(
          color: concluida ? AppColors.success : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 12)),
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
