import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../auth/providers/auth_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../domain/nutrition_models.dart';
import '../providers/water_log_providers.dart';

/// Tela de água — lógica real ([waterLogProvider] + [WaterCalculator]).
class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final goal = WaterCalculator.goalGlassesFor(user?.currentWeight);
    final glasses = ref.watch(waterLogProvider).clamp(0, goal);
    final litrosAtual = glasses * WaterCalculator.mlPerGlass / 1000;
    final litrosMeta = goal * WaterCalculator.mlPerGlass / 1000;
    final percent = goal == 0 ? 0.0 : (glasses / goal).clamp(0.0, 1.0);
    final bateuMeta = glasses >= goal;

    void addGlass() {
      if (glasses >= goal) return;
      final novo = glasses + 1;
      final acabouDeBater = novo >= goal;
      ref.read(waterLogProvider.notifier).setGlasses(novo);
      ref.read(missionsProvider.notifier).setProgress(MissionEvent.copoDeAgua, novo);
      FeedbackService.play(
          acabouDeBater ? FeedbackEvent.sucesso : FeedbackEvent.toqueLeve);
    }

    void removeGlass() {
      if (glasses <= 0) return;
      final novo = glasses - 1;
      ref.read(waterLogProvider.notifier).setGlasses(novo);
      ref.read(missionsProvider.notifier).setProgress(MissionEvent.copoDeAgua, novo);
      FeedbackService.play(FeedbackEvent.toqueLeve);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Meta de água'),
      body: SafeArea(
        child: AppPage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              FadeInUp(
                child: AppCard(
                  glow: bateuMeta,
                  child: Column(
                    children: [
                      Text('Meta do dia', style: AppTextStyles.caption()),
                      const SizedBox(height: 6),
                      Text(
                        '${litrosAtual.toStringAsFixed(1)} / ${litrosMeta.toStringAsFixed(1)} litros',
                        style: AppTextStyles.h2(),
                      ),
                      const SizedBox(height: 22),
                      CircularPercentIndicator(
                        radius: 96,
                        lineWidth: 12,
                        percent: percent,
                        animation: true,
                        animationDuration: 700,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: AppColors.surface2,
                        progressColor: AppColors.info,
                        center: Padding(
                          padding: const EdgeInsets.all(18),
                          child: AppIconImage(
                            AppIcons.water,
                            size: 88,
                            fit: BoxFit.contain,
                            fallbackIcon: Icons.water_drop_rounded,
                            semanticLabel: 'Garrafa de água',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(percent * 100).round()}%',
                        style: AppTextStyles.title(color: AppColors.info),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delayMs: 40,
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                  child: Row(
                    children: [
                      AnimatedLiliMascot(
                        pose: bateuMeta
                            ? MascotePose.celebrando
                            : MascotePose.hidratacao,
                        mood: bateuMeta
                            ? LiliMood.comemorando
                            : LiliMood.respirando,
                        height: MascotSizes.medium,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bateuMeta
                              ? 'Meta de água batida! Seu corpo agradece.'
                              : 'Faltam ${goal - glasses} copo(s) pra bater a meta de hoje.',
                          style: AppTextStyles.body(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Histórico do dia', style: AppTextStyles.h3()),
              const SizedBox(height: 10),
              Row(
                children: List.generate(goal, (i) {
                  final filled = i < glasses;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: filled
                              ? AppColors.info.withOpacity(0.85)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: filled
                                ? AppColors.info
                                : AppColors.border,
                          ),
                        ),
                        child: AppIconImage(
                          AppIcons.water,
                          size: 18,
                          fallbackIcon: Icons.water_drop_rounded,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  if (glasses > 0) ...[
                    SizedBox(
                      height: 52,
                      width: 52,
                      child: OutlinedButton(
                        onPressed: removeGlass,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.remove, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: PrimaryButton(
                      label: bateuMeta ? 'Meta batida hoje!' : '+ Beber água',
                      icon: Icons.add,
                      onPressed: bateuMeta ? null : addGlass,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
