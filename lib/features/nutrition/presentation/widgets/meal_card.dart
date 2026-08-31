import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/widgets/app_icon_image.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../domain/meal.dart';
import '../../domain/nutrition_models.dart';

class NutritionMealCard extends StatelessWidget {
  const NutritionMealCard({
    super.key,
    required this.meal,
    this.onTap,
  });

  final Meal meal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final itemNames = meal.items.map((i) => i.name).take(3).join(', ');
    final extra = meal.items.length > 3 ? ' +${meal.items.length - 3}' : '';
    final hasIa = meal.hasUnconfirmedAiItems;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: AppIconImage(
                AppIcons.nutrition,
                size: 22,
                fallbackIcon: Icons.restaurant_outlined,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.mealType.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${meal.totals.kcal} kcal',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemNames$extra',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (hasIa)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Estimativa IA — confirme antes de salvar',
                      style: TextStyle(color: AppColors.warning, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }
}
