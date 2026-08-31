import 'package:flutter/material.dart';

import '../../../../core/widgets/premium_ui.dart';

class MacroProgressCard extends StatelessWidget {
  const MacroProgressCard({
    super.key,
    required this.label,
    required this.consumed,
    required this.goal,
    required this.unit,
    required this.color,
    this.progressLabel,
  });

  final String label;
  final int consumed;
  final int goal;
  final String unit;
  final Color color;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final ratio = goal <= 0 ? 0.0 : (consumed / goal).clamp(0.0, 1.0);
    final pct = (ratio * 100).round();
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: AppColors.background,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressLabel ?? '$consumed / $goal $unit',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
