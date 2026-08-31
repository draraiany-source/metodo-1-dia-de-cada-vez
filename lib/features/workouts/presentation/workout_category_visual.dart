import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../models/domain_models.dart';

/// Identidade visual de cada tipo de treino (nunca usa coração como padrão).
enum WorkoutVisualKind {
  musculacao,
  casa,
  funcional,
  core,
  pernas,
  bracos,
  cardio,
  corrida,
  caminhada,
  bike,
  corridaGps,
  alongamento,
  mobilidade,
  rapido,
  concluido,
}

WorkoutVisualKind workoutVisualKindOf(Workout workout) {
  final tags = workout.tags.map((e) => e.toLowerCase()).join(' ');
  final title = workout.title.toLowerCase();
  final hay = '$tags $title ${workout.id.toLowerCase()}';

  bool has(List<String> keywords) {
    return keywords.any((keyword) => hay.contains(keyword));
  }

  // Ordem específica antes de "cardio" genérico.
  if (has(const ['gps']) || hay.contains('corrida gps')) {
    return WorkoutVisualKind.corridaGps;
  }
  if (has(const ['caminhada', 'walk'])) {
    return WorkoutVisualKind.caminhada;
  }
  if (has(const ['bike', 'bicicleta', 'ciclismo'])) {
    return WorkoutVisualKind.bike;
  }
  if (has(const ['hiit'])) return WorkoutVisualKind.funcional;
  if (has(const ['corrida', 'running']) && !has(const ['caminhada'])) {
    return WorkoutVisualKind.corrida;
  }
  if (has(const ['along'])) return WorkoutVisualKind.alongamento;
  if (has(const ['mobili', 'yoga', 'flexib'])) {
    return WorkoutVisualKind.mobilidade;
  }
  if (has(const ['rápido', 'rapido', 'express', '10 min'])) {
    return WorkoutVisualKind.rapido;
  }
  if (has(const ['conclu', 'completo', 'finalizado'])) {
    return WorkoutVisualKind.concluido;
  }
  if (has(const [
        'glút',
        'glut',
        'glúteo',
        'gluteo',
        'perna',
        'agacha',
        'quadríceps',
        'posterior',
        'panturrilha',
      ])) {
    return WorkoutVisualKind.pernas;
  }
  if (has(const ['abdô', 'abdo', 'abdominal', 'core', 'prancha'])) {
    return WorkoutVisualKind.core;
  }
  if (has(const [
        'braço',
        'braco',
        'superior',
        'peito',
        'ombro',
        'bíceps',
        'biceps',
        'tríceps',
        'triceps',
      ])) {
    return WorkoutVisualKind.bracos;
  }
  if (has(const ['funcional', 'kettle', 'circuito'])) {
    return WorkoutVisualKind.funcional;
  }
  if (has(const ['cardio'])) {
    return WorkoutVisualKind.cardio;
  }
  if (has(const ['casa', 'home'])) return WorkoutVisualKind.casa;
  if (has(const ['costas'])) return WorkoutVisualKind.musculacao;
  return WorkoutVisualKind.musculacao;
}

class _KindLook {
  const _KindLook({
    required this.icon,
    this.asset,
  });
  final IconData icon;
  final String? asset;
}

_KindLook _lookOf(WorkoutVisualKind kind) => switch (kind) {
      WorkoutVisualKind.musculacao => _KindLook(
          icon: Icons.fitness_center_rounded,
          asset: AppIcons.workout,
        ),
      WorkoutVisualKind.casa => _KindLook(
          icon: Icons.home_rounded,
          asset: AppIcons.home,
        ),
      WorkoutVisualKind.funcional => _KindLook(
          icon: Icons.bolt_rounded,
          asset: AppIcons.workoutGoal,
        ),
      WorkoutVisualKind.core => _KindLook(
          icon: Icons.accessibility_new_rounded,
          asset: AppIcons.abs,
        ),
      WorkoutVisualKind.pernas => _KindLook(
          icon: Icons.airline_seat_legroom_extra_rounded,
          asset: AppIcons.glutes,
        ),
      WorkoutVisualKind.bracos => _KindLook(
          icon: Icons.sports_gymnastics_rounded,
          asset: AppIcons.workout,
        ),
      WorkoutVisualKind.cardio => _KindLook(
          // Sem coração — usa cardio 3D / fallback de ritmo.
          icon: Icons.monitor_heart_outlined,
          asset: AppIcons.cardio,
        ),
      WorkoutVisualKind.corrida => _KindLook(
          icon: Icons.directions_run_rounded,
          asset: AppIcons.running,
        ),
      WorkoutVisualKind.caminhada => _KindLook(
          icon: Icons.directions_walk_rounded,
          asset: AppIcons.running,
        ),
      WorkoutVisualKind.bike => _KindLook(
          icon: Icons.pedal_bike_rounded,
          asset: AppIcons.workoutGoal,
        ),
      WorkoutVisualKind.corridaGps => _KindLook(
          icon: Icons.directions_run_rounded,
          asset: AppIcons.gps,
        ),
      WorkoutVisualKind.alongamento => _KindLook(
          icon: Icons.self_improvement_rounded,
          asset: AppIcons.yoga,
        ),
      WorkoutVisualKind.mobilidade => _KindLook(
          icon: Icons.accessibility_rounded,
          asset: AppIcons.yoga,
        ),
      WorkoutVisualKind.rapido => _KindLook(
          icon: Icons.timer_rounded,
          asset: AppIcons.stopwatch,
        ),
      WorkoutVisualKind.concluido => _KindLook(
          icon: Icons.emoji_events_rounded,
          asset: AppIcons.trophy,
        ),
    };

/// Ícone premium do treino: moldura única + PNG 3D por modalidade.
class WorkoutCategoryIcon extends StatelessWidget {
  const WorkoutCategoryIcon({
    super.key,
    required this.workout,
    required this.size,
  });

  final Workout workout;
  final double size;

  @override
  Widget build(BuildContext context) {
    final kind = workoutVisualKindOf(workout);
    final look = _lookOf(kind);
    final inner = size * 0.72;

    final glyph = look.asset != null
        ? AppIconImage(
            look.asset!,
            size: inner,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            fallbackIcon: look.icon,
            semanticLabel: workout.title,
          )
        : Icon(
            look.icon,
            size: inner * 0.62,
            color: AppColors.secondary,
            shadows: [
              Shadow(
                color: AppColors.primary.withOpacity(0.55),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1522), Color(0xFF121018)],
        ),
        border: Border.all(color: AppColors.secondary.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: glyph),
    );
  }
}

/// Capa do treino: asset local (`assets/...`) ou URL de rede.
/// Sempre com fallback visual premium (ícone de categoria).
class WorkoutCoverImage extends StatelessWidget {
  const WorkoutCoverImage({
    super.key,
    required this.workout,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallbackIconSize = 72,
    this.alignment = Alignment.center,
  });

  final Workout workout;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double fallbackIconSize;
  final Alignment alignment;

  bool get _hasPhoto =>
      workout.photoUrl != null && workout.photoUrl!.trim().isNotEmpty;

  bool get _isAsset =>
      _hasPhoto && workout.photoUrl!.trim().startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (!_hasPhoto) return _fallback();

    final url = workout.photoUrl!.trim();
    if (_isAsset) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: (_, __) => _loading(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _loading() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface2,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated,
            AppColors.secondary.withOpacity(0.28),
            AppColors.primary.withOpacity(0.32),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: WorkoutCategoryIcon(
        workout: workout,
        size: fallbackIconSize,
      ),
    );
  }
}
