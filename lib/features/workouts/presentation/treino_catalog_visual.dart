import 'package:flutter/material.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/theme/app_colors.dart';
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
TreinoVisualLook treinoVisualLookOf(TreinoCatalogEntry treino) {
  final cat = _norm(treino.categoria);
  final grupo = _norm(treino.grupoMuscular);
  final nome = _norm(treino.nome);
  final hay = '$cat $grupo $nome';

  // 1) Modalidades específicas (nunca coração genérico).
  if (_has(hay, const ['esteira'])) {
    return const TreinoVisualLook(
      label: 'Esteira',
      icon: Icons.directions_run_rounded,
      accent: Color(0xFF22D3EE),
      asset: AppIcons.running,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['bike', 'bicicleta', 'ciclismo'])) {
    return const TreinoVisualLook(
      label: 'Bike',
      icon: Icons.pedal_bike_rounded,
      accent: Color(0xFF38BDF8),
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['caminhada', 'walk'])) {
    return const TreinoVisualLook(
      label: 'Caminhada',
      icon: Icons.directions_walk_rounded,
      accent: Color(0xFF34D399),
      asset: AppIcons.running,
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
      asset: AppIcons.yoga,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['aquec'])) {
    return const TreinoVisualLook(
      label: 'Aquecimento',
      icon: Icons.local_fire_department_rounded,
      accent: Color(0xFFFBBF24),
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['mobili', 'flexib', 'yoga'])) {
    return const TreinoVisualLook(
      label: 'Mobilidade',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFC084FC),
      asset: AppIcons.yoga,
      source: TreinoVisualSource.category,
    );
  }

  // 2) Grupos musculares (prioridade sobre "cardio" misturado com hipertrofia).
  if (_has(hay, const ['panturrilha', 'gemeo', 'gáqueo', 'gêmeos'])) {
    return const TreinoVisualLook(
      label: 'Panturrilha',
      icon: Icons.directions_walk_rounded,
      accent: Color(0xFF94A3B8),
      asset: AppIcons.running,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['abdomen', 'abdominal', 'core', 'prancha'])) {
    return const TreinoVisualLook(
      label: 'Abdômen',
      icon: Icons.accessibility_new_rounded,
      accent: Color(0xFFFB7185),
      asset: AppIcons.abs,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['peitoral', 'peito', 'supino', 'crucifixo'])) {
    return const TreinoVisualLook(
      label: 'Peito',
      icon: Icons.fitness_center_rounded,
      accent: Color(0xFFF472B6),
      asset: AppIcons.workout,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['costas', 'dorsal', 'remada', 'puxada', 'pulldown'])) {
    return const TreinoVisualLook(
      label: 'Costas',
      icon: Icons.sports_martial_arts_rounded,
      accent: Color(0xFF60A5FA),
      asset: AppIcons.personal,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['ombro', 'desenvolvimento', 'elevacao lateral', 'trap'])) {
    return const TreinoVisualLook(
      label: 'Ombro',
      icon: Icons.sports_gymnastics_rounded,
      accent: Color(0xFFFBBF24),
      asset: AppIcons.trophy,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['biceps', 'rosca'])) {
    return const TreinoVisualLook(
      label: 'Bíceps',
      icon: Icons.sports_handball_rounded,
      accent: Color(0xFFFB923C),
      asset: AppIcons.workoutGoal,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['triceps', 'tríceps', 'extensao', 'coice', 'frances'])) {
    return const TreinoVisualLook(
      label: 'Tríceps',
      icon: Icons.back_hand_rounded,
      accent: Color(0xFFF87171),
      asset: AppIcons.achievement,
      source: TreinoVisualSource.category,
    );
  }

  // Inferiores: compostos (2+ grupos) antes dos específicos.
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
  if (_has(hay, const [
        'quadriceps',
        'agacha',
        'leg press',
        'extensora',
        'afundo',
        'passada',
      ])) {
    return const TreinoVisualLook(
      label: 'Quadríceps',
      icon: Icons.airline_seat_legroom_extra_rounded,
      accent: Color(0xFF818CF8),
      asset: AppIcons.glutes,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const [
        'posterior',
        'isquio',
        'isquiotib',
        'stiff',
        'mesa flexora',
      ])) {
    return const TreinoVisualLook(
      label: 'Posterior',
      icon: Icons.directions_run_rounded,
      accent: Color(0xFFC084FC),
      asset: AppIcons.glutes,
      source: TreinoVisualSource.category,
    );
  }
  if (_has(hay, const ['gluteo', 'elevacao pelvica', 'ponte', 'hip thrust'])) {
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
      asset: AppIcons.glutes,
      source: TreinoVisualSource.category,
    );
  }

  // 3) Funcional / full body antes de cardio genérico.
  if (_has(hay, const ['funcional', 'full body', 'corpo todo', 'corpo inteiro'])) {
    return const TreinoVisualLook(
      label: 'Funcional',
      icon: Icons.bolt_rounded,
      accent: Color(0xFFA855F7),
      asset: AppIcons.workoutGoal,
      source: TreinoVisualSource.category,
    );
  }

  // 4) Cardio genérico — único caso com coração + batimento.
  if (_has(hay, const ['cardio']) && !_has(hay, const ['hipertrofia'])) {
    return const TreinoVisualLook(
      label: 'Cardio',
      icon: Icons.monitor_heart_outlined,
      accent: Color(0xFFF43F5E),
      asset: AppIcons.cardio,
      source: TreinoVisualSource.category,
    );
  }
  // Hipertrofia/Cardio híbrido sem grupo: usa musculação, não coração.
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

  // 5) Placeholder neutro profissional.
  return const TreinoVisualLook(
    label: 'Treino',
    icon: Icons.sports_rounded,
    accent: Color(0xFF94A3B8),
    asset: AppIcons.workout,
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
          icon: Icons.monitor_heart_outlined,
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
