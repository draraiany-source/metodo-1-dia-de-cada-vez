import 'package:flutter/material.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/widgets/app_icon_image.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../domain/water_log_entry.dart';

class NutritionWaterCard extends StatelessWidget {
  const NutritionWaterCard({
    super.key,
    required this.water,
    required this.goalMl,
    this.onAddMl,
  });

  final WaterLogEntry water;
  final int goalMl;
  final ValueChanged<int>? onAddMl;

  @override
  Widget build(BuildContext context) {
    final consumed = water.consumedMl;
    final remaining = (goalMl - consumed).clamp(0, goalMl);
    final ratio = goalMl <= 0 ? 0.0 : (consumed / goalMl).clamp(0.0, 1.0);

    return AppCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconImage(AppIcons.water, size: 22, fallbackIcon: Icons.water_drop),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Agua do dia',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(consumed / 1000).toStringAsFixed(1)} / ${(goalMl / 1000).toStringAsFixed(1)} L',
                style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppColors.background,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$remaining ml restantes para a meta',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          if (onAddMl != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ml in const [200, 300, 500])
                  OutlinedButton(
                    onPressed: () => onAddMl!(ml),
                    child: Text('+$ml ml'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
