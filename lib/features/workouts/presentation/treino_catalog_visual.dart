import 'package:flutter/material.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../domain/treino_catalog_models.dart';

/// Ícone coerente por seção visual — nunca usa coração genérico.
class TreinoSectionIcon extends StatelessWidget {
  const TreinoSectionIcon({
    super.key,
    required this.section,
    this.size = 36,
  });

  final TreinoVisualSection section;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (asset, fallback) = switch (section) {
      TreinoVisualSection.cardio => (AppIcons.cardio, Icons.directions_run),
      TreinoVisualSection.core => (AppIcons.abs, Icons.fitness_center),
      TreinoVisualSection.mobilidade =>
        (AppIcons.yoga, Icons.self_improvement),
      TreinoVisualSection.inferioresGluteos =>
        (AppIcons.glutes, Icons.accessibility_new),
      TreinoVisualSection.peitoral =>
        (AppIcons.workout, Icons.sports_gymnastics),
      TreinoVisualSection.costas =>
        (AppIcons.personal, Icons.sports_martial_arts),
      TreinoVisualSection.biceps =>
        (AppIcons.workoutGoal, Icons.sports_handball),
      TreinoVisualSection.triceps =>
        (AppIcons.achievement, Icons.sports_mma),
      TreinoVisualSection.ombros =>
        (AppIcons.trophy, Icons.sports_kabaddi),
      TreinoVisualSection.fullBody =>
        (AppIcons.workout, Icons.sports),
      TreinoVisualSection.panturrilhas =>
        (AppIcons.running, Icons.directions_walk),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: AppIconImage(
          asset,
          size: size * 0.55,
          fallbackIcon: fallback,
        ),
      ),
    );
  }
}

String? treinoFieldOrNull(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty ||
      trimmed.toLowerCase() == 'null' ||
      trimmed.toLowerCase() == 'undefined') {
    return null;
  }
  return trimmed;
}

String treinoSubtitle(TreinoCatalogEntry t) {
  final parts = <String>[];
  final cat = treinoFieldOrNull(t.categoria);
  if (cat != null) parts.add(cat);
  if (t.nivelLabel.isNotEmpty) parts.add(t.nivelLabel);
  return parts.join(' · ');
}

String treinoMetaLine(TreinoCatalogEntry t) {
  final parts = <String>[];
  final grupo = treinoFieldOrNull(t.grupoMuscular);
  final equip = treinoFieldOrNull(t.equipamento);
  final presc = treinoFieldOrNull(t.prescricao);
  if (grupo != null) parts.add(grupo);
  if (equip != null) parts.add(equip);
  if (presc != null) parts.add(presc);
  return parts.join('  ·  ');
}
