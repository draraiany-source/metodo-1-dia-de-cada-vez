import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/app_user.dart';

/// "Peso atual e evolução" — usa só o que a usuária já cadastrou
/// (`startWeight`/`currentWeight`/`goalWeight`). Sem peso inicial
/// registrado, o cartão convida a cadastrar em vez de mostrar "0kg".
class WeightEvolutionCard extends StatelessWidget {
  const WeightEvolutionCard({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final current = user.currentWeight;
    final lost = user.lostWeight;
    final goal = user.goalWeight;

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: () => context.push(Routes.evolution),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.monitor_weight_outlined,
                  color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Peso & evolução',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  Text(
                    current != null
                        ? '${current.toStringAsFixed(1)} kg'
                            '${goal != null ? '  ·  meta ${goal.toStringAsFixed(1)} kg' : ''}'
                        : 'Cadastre seu peso para acompanhar aqui',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (lost != null && lost > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('-${lost.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
