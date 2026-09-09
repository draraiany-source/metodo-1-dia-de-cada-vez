import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/premium_ui.dart';
import '../data/mock/nutrition_dashboard_mock.dart';
import '../domain/daily_log.dart';
import '../domain/water_log_entry.dart';
import '../providers/nutrition_dashboard_providers.dart';
import '../providers/nutrition_ia_providers.dart';
import '../services/goals_service.dart';
import 'widgets/macro_progress_card.dart';
import 'widgets/meal_card.dart';
import 'widgets/nutrition_water_card.dart';

/// B1 — Dashboard de Nutrição (dados reais via repositórios).
class NutritionDashboardScreen extends ConsumerWidget {
  const NutritionDashboardScreen({super.key});

  Future<void> _addWater(WidgetRef ref, NutritionDashboardViewData data, int ml) async {
    final repo = ref.read(mealRepositoryProvider);
    final water = data.log.water;
    final updated = WaterLogEntry(
      date: water.date,
      consumedMl: water.consumedMl + ml,
      goalMl: data.goals.waterMl,
      entries: [
        ...water.entries,
        WaterIntakeEvent(ml: ml, at: DateTime.now()),
      ],
    );
    await repo.saveDailyLog(
      DailyLog(
        date: data.log.date,
        meals: data.log.meals,
        water: updated,
        syncedAt: data.log.syncedAt,
      ),
    );
    ref.invalidate(nutritionDashboardProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nutritionDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Nutricao IA'),
      body: SafeArea(
        child: AppPage(
          scrollable: false,
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nao foi possivel carregar a nutricao.\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            data: (data) {
              final dateLabel =
                  DateFormat('d \'de\' MMMM', 'pt_BR').format(data.date);
              final capitalizedDate = dateLabel.isEmpty
                  ? dateLabel
                  : dateLabel[0].toUpperCase() + dateLabel.substring(1);

              return ListView(
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
                    onAddMl: (ml) => _addWater(ref, data, ml),
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
                  if (data.log.meals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Nenhuma refeicao registrada hoje.',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  for (final meal in data.log.meals) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NutritionMealCard(
                        meal: meal,
                        onTap: () {},
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    GoalsService.medicalDisclaimer,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Analisar refeicao com IA',
                    onPressed: () => context.push(Routes.calorieScanner),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
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
