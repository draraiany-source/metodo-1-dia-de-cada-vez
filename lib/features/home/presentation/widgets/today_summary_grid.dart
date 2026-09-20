import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/app_navigation.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/app_icon_image.dart';
import '../../../ai_trainer/providers/ai_trainer_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../gamification/providers/gamification_providers.dart';
import '../../../health_sync/domain/health_models.dart';
import '../../../health_sync/providers/health_providers.dart';
import '../../../missions/providers/missions_providers.dart';
import '../../../nutrition/domain/nutrition_models.dart';
import '../../../nutrition/providers/food_log_providers.dart';
import '../../../nutrition/providers/water_log_providers.dart';

/// ============================================================================
/// GRADE "RESUMO DE HOJE" (2×2) — Treino, Água, Calorias, Passos.
///
/// Cada valor vem de um provider real já existente no app (nada fabricado):
///  - Treino  → progresso da missão diária `d_treino`.
///  - Água    → `waterLogProvider` (copos) × meta calculada do peso cadastrado.
///  - Calorias→ `todayKcalProvider` vs a meta TDEE do `trainerProfileProvider`.
///  - Passos  → `healthSummaryProvider`, se houver um wearable conectado；
///              sem isso, mostra a sequência (streak) em vez de inventar um
///              número de passos que ninguém mediu.
/// ============================================================================
class TodaySummaryGrid extends ConsumerWidget {
  const TodaySummaryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);
    final treinoFeito = missions.progressOf('d_treino').current >= 1;

    final glasses = ref.watch(waterLogProvider);
    final user = ref.watch(currentUserProvider);
    final goalGlasses =
        ref.watch(waterDayProvider).effectiveGoalGlasses(user?.currentWeight);
    final litrosAtual = (glasses * WaterCalculator.mlPerGlass / 1000);
    final litrosMeta = (goalGlasses * WaterCalculator.mlPerGlass / 1000);

    final kcalHoje = ref.watch(todayKcalProvider);
    final metaKcal = ref.watch(trainerProfileProvider).metaCalorica.round();

    final healthSnap = ref.watch(healthSummaryProvider);
    final temPassos = healthSnap != null && healthSnap.has(HealthMetric.passos);
    final streak = ref.watch(gamificationProvider).streak;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: [
        _Tile(
          iconAsset: AppIcons.workout,
          label: 'Treino',
          value: treinoFeito ? 'Completo' : 'Pendente',
          accent: treinoFeito ? AppColors.success : AppColors.secondary,
          valueColor: treinoFeito ? AppColors.success : AppColors.textPrimary,
          delayMs: 0,
        ),
        _Tile(
          iconAsset: AppIcons.hydration,
          label: 'Água',
          value:
              '${litrosAtual.toStringAsFixed(1)} / ${litrosMeta.toStringAsFixed(1)} L',
          accent: AppColors.info,
          onTap: () => AppNavigation.open(context, Routes.hydration),
          delayMs: 60,
        ),
        _Tile(
          iconAsset: AppIcons.calories,
          label: 'Calorias',
          value: '$kcalHoje / $metaKcal',
          accent: AppColors.warning,
          delayMs: 120,
        ),
        temPassos
            ? _Tile(
                iconAsset: AppIcons.running,
                label: 'Passos',
                value: healthSnap.formatted(HealthMetric.passos),
                accent: AppColors.primary,
                delayMs: 180,
              )
            : _Tile(
                iconAsset: AppIcons.streak,
                label: 'Sequência',
                value: '$streak dia(s)',
                accent: AppColors.primary,
                delayMs: 180,
              ),
      ],
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.accent,
    this.valueColor = Colors.white,
    this.onTap,
    this.delayMs = 0,
  });

  final String iconAsset;
  final String label;
  final String value;
  final Color accent;
  final Color valueColor;
  final VoidCallback? onTap;
  final int delayMs;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  // Efeito "hover" (web/desktop) — leve elevação ao passar o mouse.
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delayMs: widget.delayMs,
      offset: 14,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: PressableScale(
          onTap: widget.onTap,
          scale: 0.97,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            transform: _hovering
                ? (Matrix4.identity()..translate(0.0, -2.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.accent.withOpacity(_hovering ? 0.4 : 0.16),
              ),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: widget.accent.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: AppIconImage(widget.iconAsset,
                        size: 34, semanticLabel: widget.label),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.label,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                      Text(widget.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: widget.valueColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
