import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/premium_ui.dart';
import '../data/mock/nutrition_dashboard_mock.dart';
import '../providers/nutrition_dashboard_providers.dart';
import '../services/goals_service.dart';
import 'widgets/macro_progress_card.dart';
import 'widgets/meal_card.dart';
import 'widgets/nutrition_water_card.dart';

/// B1 — Dashboard de Nutricao (Etapa 2: dados mockados).
class NutritionDashboardScreen extends ConsumerWidget {
  const NutritionDashboardScreen({super.key});

  void _showFutureStepSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature estara disponivel em etapa futura.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(nutritionDashboardProvider);
    final dateLabel = DateFormat('d \'de\' MMMM', 'pt_BR').format(data.date);
    final capitalizedDate = dateLabel.isEmpty
        ? dateLabel
        : dateLabel[0].toUpperCase() + dateLabel.substring(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Nutricao IA'),
      body: SafeArea(
        child: AppPage(
          scrollable: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                capitalizedDate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (data.isMock) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Preview com dados de exemplo (Etapa 2)',
                    style:
                        TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _CalorieSummaryCard(data: data),
              const SizedBox(height: 14),
              MacroProgressCard(
                label: 'Proteina',
                consumed: data.consumed.proteinG,
                goal: data.goals.proteinG,
                unit: 'g',
                color: AppColors.hotPink,
                progressLabel:
                    '${data.consumed.proteinG}/${data.goals.proteinG} g',
              ),
              const SizedBox(height: 10),
              MacroProgressCard(
                label: 'Carbo',
                consumed: data.consumed.carbsG,
                goal: data.goals.carbsG,
                unit: 'g',
                color: AppColors.primary,
                progressLabel:
                    '${data.consumed.carbsG}/${data.goals.carbsG} g',
              ),
              const SizedBox(height: 10),
              MacroProgressCard(
                label: 'Gordura',
                consumed: data.consumed.fatG,
                goal: data.goals.fatG,
                unit: 'g',
                color: AppColors.primaryDark,
                progressLabel:
                    '${data.consumed.fatG}/${data.goals.fatG} g',
              ),
              const SizedBox(height: 16),
              NutritionWaterCard(
                water: data.log.water,
                goalMl: data.goals.waterMl,
                onAddMl: (ml) => _showFutureStepSnackBar(
                  context,
                  'Atalhos de agua (+$ml ml)',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Refeicoes de hoje',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              for (final meal in data.log.meals) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NutritionMealCard(
                    meal: meal,
                    onTap: () => _showFutureStepSnackBar(
                      context,
                      'Detalhes da refeicao',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                GoalsService.medicalDisclaimer,
                style:
                    const TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Fotografar minha refeicao',
                onPressed: () => _showFutureStepSnackBar(
                  context,
                  'Registro por foto com IA',
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({required this.data});

  final NutritionDashboardViewData data;

  @override
  Widget build(BuildContext context) {
    final progress = data.calorieProgress.clamp(0.0, 1.0);
    return AppCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calorias do dia',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${data.consumed.kcal}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Meta ${data.goals.calories} kcal · ${data.remainingKcal} restantes',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.background,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}% da meta calorica',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
