import 'package:flutter/material.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../domain/treino_catalog_models.dart';

/// Identidade visual profissional de um treino do catálogo.
///
/// Prioridade: modalidade específica (corrida/bike/…) → grupo muscular →
/// categoria → placeholder neutro. Coração (`AppIcons.cardio`) **somente**
/// para cardio genérico.
@immutable
class TreinoVisualLook {
  const TreinoVisualLook({
    required this.label,
    required this.icon,
    required this.accent,
    this.asset,
    this.source = TreinoVisualSource.category,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final String? asset;
  final TreinoVisualSource source;
}

enum TreinoVisualSource {
  /// PNG/ícone específico do exercício (quando houver capa futura).
  exercise,

  /// Ícone da categoria / grupo muscular.
  category,

  /// Placeholder neutro profissional.
  placeholder,
}

/// Resolve o visual a partir dos campos já existentes (sem alterar JSON).
///
/// Prioridade: exercício específico → modalidade → grupo muscular →
/// categoria → [AppIcons.workoutPlaceholder]. Coração/cardio **somente**
/// para cardio puro.
TreinoVisualLook treinoVisualLookOf(TreinoCatalogEntry treino) {
  final cat = _norm(treino.categoria);
  final grupo = _norm(treino.grupoMuscular);
  final nome = _norm(treino.nome);
  final hay = '$cat $grupo $nome';

  // 0) Exercícios específicos (ícones neon dedicados).
  if (_has(hay, const ['burpee'])) {
    return const TreinoVisualLook(
      label: 'Burpee',
      icon: Icons.sports_gymnastics_rounded,
      accent: Color(0xFFF97316),
      asset: AppIcons.exBurpee,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['polichinelo', 'jumping jack'])) {
    return const TreinoVisualLook(
      label: 'Polichinelo',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFFBBF24),
      asset: AppIcons.exJumpingJack,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['kettle', 'swing'])) {
    return const TreinoVisualLook(
      label: 'Kettlebell',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFF97316),
      asset: AppIcons.exKettlebell,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['hip thrust', 'elevacao pelvica', 'ponte de gluteo'])) {
    return const TreinoVisualLook(
      label: 'Hip thrust',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFE879F9),
      asset: AppIcons.exHipThrust,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['leg press'])) {
    return const TreinoVisualLook(
      label: 'Leg press',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFF818CF8),
      asset: AppIcons.exLegPress,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['mesa flexora', 'flexora'])) {
    return const TreinoVisualLook(
      label: 'Mesa flexora',
      icon: Icons.directions_run_rounded,
      accent: Color(0xFFC084FC),
      asset: AppIcons.exLegCurl,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['extensora', 'extensao de perna', 'extensao de pernas'])) {
    return const TreinoVisualLook(
      label: 'Extensora',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFF818CF8),
      asset: AppIcons.exLegExtension,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['agachamento sumo', 'sumo'])) {
    return const TreinoVisualLook(
      label: 'Agachamento sumo',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFFA78BFA),
      asset: AppIcons.exSquatSumo,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['agachamento com barra', 'agacha com barra'])) {
    return const TreinoVisualLook(
      label: 'Agachamento',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFF818CF8),
      asset: AppIcons.exSquatBar,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['agacha'])) {
    return const TreinoVisualLook(
      label: 'Agachamento',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFF818CF8),
      asset: AppIcons.exSquat,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['afundo', 'passada', 'lunge'])) {
    return const TreinoVisualLook(
      label: 'Afundo',
      icon: Icons.directions_walk_rounded,
      accent: Color(0xFFA78BFA),
      asset: AppIcons.exLunge,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['panturrilha', 'gemeo'])) {
    return const TreinoVisualLook(
      label: 'Panturrilha',
      icon: Icons.directions_walk_rounded,
      accent: Color(0xFF94A3B8),
      asset: AppIcons.exCalf,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['elevacao de perna', 'elevacao de pernas', 'abdominal infra'])) {
    return const TreinoVisualLook(
      label: 'Elevação de pernas',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFFB7185),
      asset: AppIcons.exLegRaise,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['rosca'])) {
    return const TreinoVisualLook(
      label: 'Rosca',
      icon: Icons.sports_handball_rounded,
      accent: Color(0xFFFB923C),
      asset: AppIcons.exCurl,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['triceps na polia', 'triceps corda', 'triceps pulley'])) {
    return const TreinoVisualLook(
      label: 'Tríceps polia',
      icon: Icons.back_hand_rounded,
      accent: Color(0xFFF87171),
      asset: AppIcons.exTriceps,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['triceps', 'tríceps', 'coice', 'frances'])) {
    return const TreinoVisualLook(
      label: 'Tríceps',
      icon: Icons.back_hand_rounded,
      accent: Color(0xFFF87171),
      asset: AppIcons.exTricepsExt,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['kickback', 'coice de gluteo'])) {
    return const TreinoVisualLook(
      label: 'Kickback',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFE879F9),
      asset: AppIcons.exKickback,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['elevacao lateral'])) {
    return const TreinoVisualLook(
      label: 'Elevação lateral',
      icon: Icons.sports_gymnastics_rounded,
      accent: Color(0xFFFBBF24),
      asset: AppIcons.exLateralRaise,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['supino com halter', 'supino halter'])) {
    return const TreinoVisualLook(
      label: 'Supino',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFF472B6),
      asset: AppIcons.exBenchDb,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['supino', 'crucifixo'])) {
    return const TreinoVisualLook(
      label: 'Peito',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFF472B6),
      asset: AppIcons.exBench,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['remada baixa'])) {
    return const TreinoVisualLook(
      label: 'Remada baixa',
      icon: Icons.sports_martial_arts_rounded,
      accent: Color(0xFF60A5FA),
      asset: AppIcons.exRowLow,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['remada'])) {
    return const TreinoVisualLook(
      label: 'Remada',
      icon: Icons.sports_martial_arts_rounded,
      accent: Color(0xFF60A5FA),
      asset: AppIcons.exRow,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['puxada', 'pulldown'])) {
    return const TreinoVisualLook(
      label: 'Puxada',
      icon: Icons.sports_martial_arts_rounded,
      accent: Color(0xFF60A5FA),
      asset: AppIcons.exPulldown,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['flexao', 'flexão', 'push-up', 'push up'])) {
    return const TreinoVisualLook(
      label: 'Flexão',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFF472B6),
      asset: AppIcons.exPushup,
      source: TreinoVisualSource.exercise,
    );
  }
  if (_has(hay, const ['prancha', 'plank'])) {
    return const TreinoVisualLook(
      label: 'Prancha',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFFB7185),
      asset: AppIcons.exPlank,
      source: TreinoVisualSource.exercise,
    );
  }

  // 1) Modalidades específicas (nunca coração genérico).
  if (_has(hay, const ['esteira'])) {
    return const TreinoVisualLook(
      label: 'Esteira',
      icon: Icons.directions_run_rounded,
      accent: Color(0xFF22D3EE),
      asset: AppIcons.treadmill,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['bike', 'bicicleta', 'ciclismo', 'spinning'])) {
    return const TreinoVisualLook(
      label: 'Bike',
      icon: Icons.pedal_bike_rounded,
      accent: Color(0xFF38BDF8),
      asset: AppIcons.bike,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['escada', 'stepper'])) {
    return const TreinoVisualLook(
      label: 'Escada',
      icon: Icons.stairs_rounded,
      accent: Color(0xFF22D3EE),
      asset: AppIcons.stairs,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['caminhada', 'walk'])) {
    return const TreinoVisualLook(
      label: 'Caminhada',
      icon: Icons.directions_walk_rounded,
      accent: Color(0xFF34D399),
      asset: AppIcons.walk,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['corrida', 'running']) &&
      !_has(hay, const ['caminhada'])) {
    return const TreinoVisualLook(
      label: 'Corrida',
      icon: Icons.directions_run_rounded,
      accent: Color(0xFF2DD4BF),
      asset: AppIcons.running,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['hiit', 'alta intensidade', 'tabata'])) {
    return const TreinoVisualLook(
      label: 'HIIT',
      icon: Icons.timer_rounded,
      accent: Color(0xFFF97316),
      asset: AppIcons.stopwatch,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['along'])) {
    return const TreinoVisualLook(
      label: 'Alongamento',
      icon: Icons.self_improvement_rounded,
      accent: Color(0xFFA78BFA),
      asset: AppIcons.exStretch,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['aquec'])) {
    return const TreinoVisualLook(
      label: 'Aquecimento',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFFBBF24),
      asset: AppIcons.exFunctional,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['mobili', 'flexib', 'yoga'])) {
    return const TreinoVisualLook(
      label: 'Mobilidade',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFC084FC),
      asset: AppIcons.exStretchAlt,
      source: TreinoVisualSource.category,
    );
  }

  // 2) Grupos musculares.
  if (_has(hay, const ['abdomen', 'abdominal', 'core'])) {
    return const TreinoVisualLook(
      label: 'Abdômen',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFFB7185),
      asset: AppIcons.abs,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['peitoral', 'peito'])) {
    return const TreinoVisualLook(
      label: 'Peito',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFF472B6),
      asset: AppIcons.exTorso,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['costas', 'dorsal'])) {
    return const TreinoVisualLook(
      label: 'Costas',
      icon: Icons.sports_martial_arts_rounded,
      accent: Color(0xFF60A5FA),
      asset: AppIcons.exBack,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['ombro', 'desenvolvimento', 'trap'])) {
    return const TreinoVisualLook(
      label: 'Ombro',
      icon: Icons.sports_gymnastics_rounded,
      accent: Color(0xFFFBBF24),
      asset: AppIcons.exLateralRaise,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['biceps'])) {
    return const TreinoVisualLook(
      label: 'Bíceps',
      icon: Icons.sports_handball_rounded,
      accent: Color(0xFFFB923C),
      asset: AppIcons.exArm,
      source: TreinoVisualSource.category,
    );
  }

  final lowerHits = [
    'gluteo',
    'quadriceps',
    'posterior',
    'isquio',
    'adutor',
    'abdut',
  ].where((k) => hay.contains(k)).length;
  if (lowerHits >= 2 ||
      (_has(hay, const ['membros inferiores']) && lowerHits >= 1)) {
    return const TreinoVisualLook(
      label: 'Inferiores',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFFA78BFA),
      asset: AppIcons.glutes,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['quadriceps'])) {
    return const TreinoVisualLook(
      label: 'Quadríceps',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFF818CF8),
      asset: AppIcons.exLegExtension,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['posterior', 'isquio', 'isquiotib', 'stiff'])) {
    return const TreinoVisualLook(
      label: 'Posterior',
      icon: Icons.directions_run_rounded,
      accent: Color(0xFFC084FC),
      asset: AppIcons.exLegCurl,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['gluteo'])) {
    return const TreinoVisualLook(
      label: 'Glúteo',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFE879F9),
      asset: AppIcons.glutes,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['adutor', 'abdut', 'membros inferiores', 'perna', 'pernas'])) {
    return const TreinoVisualLook(
      label: 'Inferiores',
      icon: Icons.accessibility_rounded,
      accent: Color(0xFFA78BFA),
      asset: AppIcons.exLunge,
      source: TreinoVisualSource.category,
    );
  }

  // 3) Funcional / full body.
  if (_has(hay, const ['funcional', 'full body', 'corpo todo', 'corpo inteiro'])) {
    return const TreinoVisualLook(
      label: 'Funcional',
      icon: Icons.bolt_rounded,
      accent: Color(0xFFA855F7),
      asset: AppIcons.exFunctional,
      source: TreinoVisualSource.category,
    );
  }

  // 4) Cardio puro — nunca como fallback geral.
  if (_has(hay, const ['cardio']) && !_has(hay, const ['hipertrofia'])) {
    return const TreinoVisualLook(
      label: 'Cardio',
      icon: Icons.directions_run_rounded,
      accent: Color(0xFFF43F5E),
      asset: AppIcons.cardio,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['cardio']) && _has(hay, const ['hipertrofia'])) {
    return const TreinoVisualLook(
      label: 'Musculação',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFA855F7),
      asset: AppIcons.workout,
      source: TreinoVisualSource.category,
    );
  }

  if (_has(hay, const ['hipertrofia', 'muscul'])) {
    return const TreinoVisualLook(
      label: 'Musculação',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFA855F7),
      asset: AppIcons.workout,
      source: TreinoVisualSource.category,
    );
  }

  // 5) Placeholder neutro do kit neon (sem coração).
  return const TreinoVisualLook(
    label: 'Treino',
    icon: Icons.sports_rounded,
    accent: Color(0xFF94A3B8),
    asset: AppIcons.workoutPlaceholder,
    source: TreinoVisualSource.placeholder,
  );
}

bool _has(String hay, List<String> keys) =>
    keys.any((k) => hay.contains(_norm(k)));

String _norm(String? v) => (v ?? '')
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ã', 'a')
    .replaceAll('õ', 'o')
    .replaceAll('ç', 'c')
    .replaceAll('–', '-')
    .replaceAll('—', '-');

/// Ícone padronizado dos cards (tamanho/proporção/estilo únicos).
class TreinoSectionIcon extends StatelessWidget {
  const TreinoSectionIcon({
    super.key,
    required this.section,
    this.treino,
    this.size = 52,
  });

  /// Mantido para filtros/tabs existentes.
  final TreinoVisualSection section;
  final TreinoCatalogEntry? treino;
  final double size;

  @override
  Widget build(BuildContext context) {
    final look = treino != null
        ? treinoVisualLookOf(treino!)
        : _lookFromSection(section);

    final inner = size * 0.58;
    final radius = size * 0.28;

    final glyph = look.asset != null
        ? AppIconImage(
            look.asset!,
            size: inner,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            fallbackIcon: look.icon,
            semanticLabel: look.label,
          )
        : Icon(look.icon, size: inner * 0.9, color: look.accent);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1520),
            look.accent.withOpacity(0.22),
            const Color(0xFF121018),
          ],
        ),
        border: Border.all(color: look.accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: look.accent.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: glyph,
    );
  }

  /// Fallback quando só a seção do filtro está disponível.
  static TreinoVisualLook _lookFromSection(TreinoVisualSection section) {
    return switch (section) {
      TreinoVisualSection.cardio => const TreinoVisualLook(
          label: 'Cardio',
          icon: Icons.directions_run_rounded,
          accent: Color(0xFFF43F5E),
          asset: AppIcons.cardio,
        ),
      TreinoVisualSection.core => const TreinoVisualLook(
          label: 'Abdômen',
          icon: Icons.accessibility_new_rounded,
          accent: Color(0xFFFB7185),
          asset: AppIcons.abs,
        ),
      TreinoVisualSection.mobilidade => const TreinoVisualLook(
          label: 'Mobilidade',
          icon: Icons.self_improvement_rounded,
          accent: Color(0xFFC084FC),
          asset: AppIcons.yoga,
        ),
      TreinoVisualSection.inferioresGluteos => const TreinoVisualLook(
          label: 'Inferiores',
          icon: Icons.airline_seat_legroom_extra_rounded,
          accent: Color(0xFFA78BFA),
          asset: AppIcons.glutes,
        ),
      TreinoVisualSection.peitoral => const TreinoVisualLook(
          label: 'Peito',
          icon: Icons.fitness_center_rounded,
          accent: Color(0xFFF472B6),
          asset: AppIcons.workout,
        ),
      TreinoVisualSection.costas => const TreinoVisualLook(
          label: 'Costas',
          icon: Icons.sports_martial_arts_rounded,
          accent: Color(0xFF60A5FA),
          asset: AppIcons.personal,
        ),
      TreinoVisualSection.biceps => const TreinoVisualLook(
          label: 'Bíceps',
          icon: Icons.sports_handball_rounded,
          accent: Color(0xFFFB923C),
          asset: AppIcons.workoutGoal,
        ),
      TreinoVisualSection.triceps => const TreinoVisualLook(
          label: 'Tríceps',
          icon: Icons.back_hand_rounded,
          accent: Color(0xFFF87171),
          asset: AppIcons.achievement,
        ),
      TreinoVisualSection.ombros => const TreinoVisualLook(
          label: 'Ombro',
          icon: Icons.sports_gymnastics_rounded,
          accent: Color(0xFFFBBF24),
          asset: AppIcons.trophy,
        ),
      TreinoVisualSection.fullBody => const TreinoVisualLook(
          label: 'Funcional',
          icon: Icons.bolt_rounded,
          accent: Color(0xFFA855F7),
          asset: AppIcons.workoutGoal,
        ),
      TreinoVisualSection.panturrilhas => const TreinoVisualLook(
          label: 'Panturrilha',
          icon: Icons.directions_walk_rounded,
          accent: Color(0xFF94A3B8),
          asset: AppIcons.running,
        ),
    };
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
