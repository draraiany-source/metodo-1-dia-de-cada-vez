/// Indicadores administrativos da anamnese.
///
/// NÃO é diagnóstico médico e NÃO deve ser chamado de "risco clínico".
/// Apenas organiza respostas que a Personal precisa esclarecer.
library;

enum AttentionLevel {
  none,
  clarify,
  reviewBeforeProgression,
}

extension AttentionLevelX on AttentionLevel {
  String get labelPt => switch (this) {
        AttentionLevel.none => 'Sem pendência relevante informada',
        AttentionLevel.clarify => 'Necessita esclarecimento',
        AttentionLevel.reviewBeforeProgression =>
          'Necessita avaliação antes de determinadas progressões',
      };

  String get emoji => switch (this) {
        AttentionLevel.none => '🟢',
        AttentionLevel.clarify => '🟡',
        AttentionLevel.reviewBeforeProgression => '🔴',
      };
}

class AttentionFlag {
  const AttentionFlag({
    required this.reason,
    required this.level,
  });

  final String reason;
  final AttentionLevel level;
}

class AttentionResult {
  const AttentionResult({
    required this.level,
    required this.flags,
  });

  final AttentionLevel level;
  final List<AttentionFlag> flags;

  bool get hasFlags => flags.isNotEmpty;
}

/// Respostas usadas só para pontuar pendências (campos opcionais).
class AnamnesisAttentionInput {
  const AnamnesisAttentionInput({
    this.healthConditions = const [],
    this.usesMedication = false,
    this.painRegions = const [],
    this.maxPainScale = 0,
    this.hadSurgery = false,
    this.chestPainOnEffort = false,
    this.fainting = false,
    this.disproportionateShortness = false,
    this.palpitations = false,
    this.cardiacDiagnosis = false,
    this.exerciseRestriction = false,
    this.pregnant = false,
    this.postpartum = false,
  });

  final List<String> healthConditions;
  final bool usesMedication;
  final List<String> painRegions;
  final int maxPainScale;
  final bool hadSurgery;
  final bool chestPainOnEffort;
  final bool fainting;
  final bool disproportionateShortness;
  final bool palpitations;
  final bool cardiacDiagnosis;
  final bool exerciseRestriction;
  final bool pregnant;
  final bool postpartum;
}

class AnamnesisAttention {
  AnamnesisAttention._();

  static const _reviewConditions = {
    'hipertensao',
    'hipertensão',
    'diabetes',
    'cardiopatia',
    'asma',
    'gestacao',
    'gestação',
    'pos-parto',
    'pós-parto',
  };

  static AttentionResult evaluate(AnamnesisAttentionInput input) {
    final flags = <AttentionFlag>[];

    void red(String reason) => flags.add(AttentionFlag(
          reason: reason,
          level: AttentionLevel.reviewBeforeProgression,
        ));
    void yellow(String reason) => flags.add(AttentionFlag(
          reason: reason,
          level: AttentionLevel.clarify,
        ));

    if (input.chestPainOnEffort) {
      red('Alerta gerado porque a aluna informou dor no peito durante esforço.');
    }
    if (input.fainting) {
      red('Alerta gerado porque a aluna informou desmaios.');
    }
    if (input.disproportionateShortness) {
      red('Alerta gerado porque a aluna informou falta de ar desproporcional.');
    }
    if (input.palpitations) {
      yellow('Alerta gerado porque a aluna informou palpitações.');
    }
    if (input.cardiacDiagnosis) {
      red('Alerta gerado porque a aluna informou diagnóstico cardíaco.');
    }
    if (input.exerciseRestriction) {
      red('Alerta gerado porque a aluna informou restrição médica para exercícios.');
    }
    if (input.pregnant ||
        input.healthConditions.any((c) =>
            c.toLowerCase().contains('gesta'))) {
      yellow('Alerta gerado porque a aluna informou gestação.');
    }
    if (input.postpartum ||
        input.healthConditions.any((c) =>
            c.toLowerCase().contains('parto'))) {
      yellow('Alerta gerado porque a aluna informou pós-parto.');
    }
    for (final c in input.healthConditions) {
      final key = c.toLowerCase().trim();
      if (key.isEmpty || key == 'nenhuma' || key == 'outra') continue;
      if (_reviewConditions.any(key.contains)) {
        yellow('Alerta gerado porque a aluna informou: $c.');
      } else if (key != 'nenhuma') {
        yellow('Alerta gerado porque a aluna informou condição de saúde: $c.');
      }
    }
    if (input.usesMedication) {
      yellow('Alerta gerado porque a aluna informou uso de medicamento.');
    }
    if (input.painRegions.isNotEmpty) {
      yellow(
        'Alerta gerado porque a aluna informou dor em: ${input.painRegions.join(', ')}.',
      );
    }
    if (input.maxPainScale >= 7) {
      yellow(
        'Alerta gerado porque a escala de dor informada foi ${input.maxPainScale} de 10.',
      );
    }
    if (input.hadSurgery) {
      yellow('Alerta gerado porque a aluna informou cirurgia anterior.');
    }

    var level = AttentionLevel.none;
    for (final f in flags) {
      if (f.level == AttentionLevel.reviewBeforeProgression) {
        level = AttentionLevel.reviewBeforeProgression;
        break;
      }
      if (f.level == AttentionLevel.clarify) {
        level = AttentionLevel.clarify;
      }
    }
    return AttentionResult(level: level, flags: flags);
  }

  static const professionalNotice =
      'Antes de iniciar ou intensificar seu programa de exercícios, '
      'pode ser necessária liberação de um profissional de saúde.';
}
