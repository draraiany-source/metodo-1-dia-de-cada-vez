import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/feature_illustration_banner.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../auth/providers/auth_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../domain/nutrition_models.dart';
import '../providers/water_log_providers.dart';

/// ============================================================================
/// TELA DE ÁGUA — dedicada (antes só existia embutida em Nutrição).
///
/// Reaproveita 100% a lógica real já existente: [waterLogProvider] (copos do
/// dia), [WaterCalculator] (meta calculada do peso cadastrado, ~35ml/kg) e a
/// integração com a missão diária `copoDeAgua`. Nenhum dado novo inventado —
/// só uma apresentação maior e mais celebrativa desse mesmo estado real.
/// ============================================================================
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
      appBar: AppBar(title: const Text('Água 💧')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const FeatureIllustrationBanner(
              assetPath: AppAssets.illustControleAgua,
              height: 140,
              semanticLabel: 'Ilustração de controle de hidratação',
            ),
            const SizedBox(height: 16),
            FadeInUp(
              child: Column(
                children: [
                  Text('Meta diária', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    '${litrosAtual.toStringAsFixed(1)} / ${litrosMeta.toStringAsFixed(1)} litros',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 90,
                        lineWidth: 14,
                        percent: percent,
                        animation: true,
                        animationDuration: 700,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: AppColors.surface,
                        progressColor: AppColors.info,
                        center: _BottleFill(percent: percent, celebrando: bateuMeta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${(percent * 100).round()}%',
                      style: const TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // A Lili reage: comemora ao bater a meta, incentiva enquanto não bate.
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.info.withOpacity(0.25)),
              ),
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
                          ? 'Meta de água batida! Seu corpo agradece. 💜'
                          : 'Faltam ${goal - glasses} copo(s) pra bater a meta de hoje.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Copos do dia (mesmo padrão de toque rápido já usado em Nutrição).
            Row(
              children: List.generate(goal, (i) {
                final filled = i < glasses;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: filled ? AppColors.info : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.water_drop,
                          size: 16,
                          color: filled ? Colors.white : AppColors.textTertiary),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                if (glasses > 0)
                  IconButton.filledTonal(
                    onPressed: removeGlass,
                    icon: const Icon(Icons.remove),
                  ),
                if (glasses > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: bateuMeta ? null : addGlass,
                    icon: const Icon(Icons.add),
                    label: Text(bateuMeta ? 'Meta batida hoje!' : '+ Beber água'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28)),
                    ),
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

/// Selo central do anel: garrafinha estilizada com nível de preenchimento
/// proporcional ao percentual — sem depender de asset externo.
class _BottleFill extends StatelessWidget {
  const _BottleFill({required this.percent, required this.celebrando});
  final double percent;
  final bool celebrando;

  @override
  Widget build(BuildContext context) {
    const w = 46.0, h = 68.0;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Corpo da garrafa (contorno).
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.info, width: 2.5),
              borderRadius: BorderRadius.circular(10),
              color: AppColors.background,
            ),
          ),
          // Gargalo.
          Positioned(
            top: -8,
            child: Container(
              width: 16,
              height: 10,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.info, width: 2.5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(3)),
                color: AppColors.background,
              ),
            ),
          ),
          // Nível de água, animado.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: w - 5,
              height: (h - 5) * percent,
              color: AppColors.info,
            ),
          ),
          if (celebrando)
            const Positioned(top: 18, child: Text('🎉', style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
