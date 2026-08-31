import 'package:flutter/foundation.dart';

/// Nível de atividade física — usado no cálculo de TDEE (multiplicador
/// sobre a TMB).
enum NivelAtividade { sedentario, leve, moderado, intenso, muitoIntenso }

extension NivelAtividadeX on NivelAtividade {
  String get label => switch (this) {
        NivelAtividade.sedentario => 'Sedentário (pouco ou nenhum exercício)',
        NivelAtividade.leve => 'Leve (1-3x/semana)',
        NivelAtividade.moderado => 'Moderado (3-5x/semana)',
        NivelAtividade.intenso => 'Intenso (6-7x/semana)',
        NivelAtividade.muitoIntenso => 'Muito intenso (2x/dia, trabalho físico)',
      };

  /// Multiplicador de Harris-Benedict/Mifflin sobre a TMB pra chegar no TDEE.
  double get multiplicador => switch (this) {
        NivelAtividade.sedentario => 1.2,
        NivelAtividade.leve => 1.375,
        NivelAtividade.moderado => 1.55,
        NivelAtividade.intenso => 1.725,
        NivelAtividade.muitoIntenso => 1.9,
      };
}

enum TipoDieta {
  onivora,
  vegetariana,
  vegana,
  lowCarb,
  cetogenica,
  paleo,
  semGluten,
  semLactose,
}

extension TipoDietaX on TipoDieta {
  String get label => switch (this) {
        TipoDieta.onivora => 'Onívora',
        TipoDieta.vegetariana => 'Vegetariana',
        TipoDieta.vegana => 'Vegana',
        TipoDieta.lowCarb => 'Low Carb',
        TipoDieta.cetogenica => 'Cetogênica',
        TipoDieta.paleo => 'Paleo',
        TipoDieta.semGluten => 'Sem Glúten',
        TipoDieta.semLactose => 'Sem Lactose',
      };
}

/// Fórmula usada pra estimar a TMB — a usuária pode escolher qual confia
/// mais; Mifflin-St Jeor é o padrão mais moderno/preciso.
enum FormulaTmb { mifflinStJeor, harrisBenedict }

/// Sexo biológico — usado apenas para fórmulas metabólicas (TMB/água).
enum Sexo { feminino, masculino }

/// Objetivo do usuário.
enum Objetivo { emagrecer, tonificar, ganharMassa, saude }

extension ObjetivoX on Objetivo {
  String get label => switch (this) {
        Objetivo.emagrecer => 'Emagrecer',
        Objetivo.tonificar => 'Tonificar',
        Objetivo.ganharMassa => 'Ganhar massa',
        Objetivo.saude => 'Saúde e bem-estar',
      };
}

/// Nível físico.
enum NivelFisico { iniciante, intermediario, avancado }

extension NivelFisicoX on NivelFisico {
  String get label => switch (this) {
        NivelFisico.iniciante => 'Iniciante',
        NivelFisico.intermediario => 'Intermediário',
        NivelFisico.avancado => 'Avançado',
      };
}

/// Limitações físicas consideradas ao montar o treino.
enum Limitacao { joelho, lombar, ombro, punho, gestante, hipertensao, nenhuma }

extension LimitacaoX on Limitacao {
  String get label => switch (this) {
        Limitacao.joelho => 'Joelho',
        Limitacao.lombar => 'Lombar / coluna',
        Limitacao.ombro => 'Ombro',
        Limitacao.punho => 'Punho',
        Limitacao.gestante => 'Gestante',
        Limitacao.hipertensao => 'Hipertensão',
        Limitacao.nenhuma => 'Nenhuma',
      };
}

/// Perfil usado pela IA para personalizar tudo.
@immutable
class TrainerProfile {
  const TrainerProfile({
    this.idade = 30,
    this.pesoKg = 70,
    this.alturaM = 1.65,
    this.sexo = Sexo.feminino,
    this.objetivo = Objetivo.emagrecer,
    this.nivel = NivelFisico.iniciante,
    this.limitacoes = const {Limitacao.nenhuma},
    this.diasPorSemana = 3,
    this.pesoInicial,
    this.pesoDesejado,
    this.percentualGordura,
    this.massaMuscularKg,
    this.nivelAtividade = NivelAtividade.leve,
    this.tipoDieta = TipoDieta.onivora,
    this.restricoesAlimentares = const {},
    this.alergias = const {},
    this.preferenciasAlimentares = const {},
    this.formulaTmb = FormulaTmb.mifflinStJeor,
  });

  final int idade;
  final double pesoKg;
  final double alturaM;
  final Sexo sexo;
  final Objetivo objetivo;
  final NivelFisico nivel;
  final Set<Limitacao> limitacoes;
  final int diasPorSemana;

  // ---- Perfil nutricional (aditivo) ----
  final double? pesoInicial;
  final double? pesoDesejado;
  final double? percentualGordura;
  final double? massaMuscularKg;
  final NivelAtividade nivelAtividade;
  final TipoDieta tipoDieta;
  final Set<String> restricoesAlimentares; // texto livre: "lactose", "glúten"...
  final Set<String> alergias;
  final Set<String> preferenciasAlimentares;
  final FormulaTmb formulaTmb;

  double get imc => alturaM <= 0 ? 0 : pesoKg / (alturaM * alturaM);

  /// Taxa Metabólica Basal (Mifflin-St Jeor).
  double get tmbMifflinStJeor {
    final base = 10 * pesoKg + 6.25 * (alturaM * 100) - 5 * idade;
    return sexo == Sexo.feminino ? base - 161 : base + 5;
  }

  /// Taxa Metabólica Basal (Harris-Benedict revisada).
  double get tmbHarrisBenedict {
    final alturaCm = alturaM * 100;
    return sexo == Sexo.feminino
        ? 447.6 + 9.25 * pesoKg + 3.1 * alturaCm - 4.33 * idade
        : 88.36 + 13.4 * pesoKg + 4.8 * alturaCm - 5.68 * idade;
  }

  /// TMB pela fórmula escolhida em [formulaTmb].
  double get tmb => formulaTmb == FormulaTmb.mifflinStJeor
      ? tmbMifflinStJeor
      : tmbHarrisBenedict;

  /// TDEE — gasto energético total diário (TMB × nível de atividade).
  double get tdee => tmb * nivelAtividade.multiplicador;

  /// Déficit ou superávit calórico sugerido conforme o objetivo (kcal/dia).
  /// Emagrecer: déficit de ~20%. Ganhar massa: superávit de ~15%. Os
  /// demais objetivos mantêm o TDEE (manutenção).
  double get ajusteCalorico => switch (objetivo) {
        Objetivo.emagrecer => -(tdee * 0.20),
        Objetivo.ganharMassa => tdee * 0.15,
        Objetivo.tonificar => -(tdee * 0.10),
        Objetivo.saude => 0,
      };

  /// Meta diária de calorias já com o ajuste do objetivo aplicado.
  double get metaCalorica => tdee + ajusteCalorico;

  /// Metas de macros em gramas — proporção varia por objetivo (mais
  /// proteína pra ganho de massa/tonificação, mais carbo pra manutenção).
  double get metaProteinaG => switch (objetivo) {
        Objetivo.ganharMassa => pesoKg * 2.0,
        Objetivo.tonificar => pesoKg * 1.8,
        Objetivo.emagrecer => pesoKg * 1.6,
        Objetivo.saude => pesoKg * 1.2,
      };

  double get metaGorduraG => (metaCalorica * 0.25) / 9; // 25% das kcal, 9kcal/g

  double get metaCarboidratoG {
    final kcalProteina = metaProteinaG * 4;
    final kcalGordura = metaGorduraG * 9;
    final kcalRestante = (metaCalorica - kcalProteina - kcalGordura).clamp(0, metaCalorica);
    return kcalRestante / 4; // 4kcal/g
  }

  /// Fibra recomendada: ~14g a cada 1000kcal (diretriz nutricional padrão).
  double get metaFibraG => (metaCalorica / 1000) * 14;

  /// Peso ideal estimado (IMC-alvo de 22, ponto médio da faixa saudável).
  double get pesoIdealKg => 22 * (alturaM * alturaM);

  /// Quanto já perdeu/ganhou desde o peso inicial registrado.
  double? get progressoPesoKg =>
      pesoInicial != null ? pesoKg - pesoInicial! : null;

  /// Água recomendada por dia (litros): 35ml/kg, ajustado por nível de treino.
  double get aguaLitros {
    final base = pesoKg * 0.035;
    final extra = switch (nivel) {
      NivelFisico.iniciante => 0.0,
      NivelFisico.intermediario => 0.3,
      NivelFisico.avancado => 0.5,
    };
    return double.parse((base + extra).toStringAsFixed(1));
  }

  /// Copos de 250ml.
  int get aguaCopos => (aguaLitros * 1000 / 250).round();

  TrainerProfile copyWith({
    int? idade,
    double? pesoKg,
    double? alturaM,
    Sexo? sexo,
    Objetivo? objetivo,
    NivelFisico? nivel,
    Set<Limitacao>? limitacoes,
    int? diasPorSemana,
    double? pesoInicial,
    double? pesoDesejado,
    double? percentualGordura,
    double? massaMuscularKg,
    NivelAtividade? nivelAtividade,
    TipoDieta? tipoDieta,
    Set<String>? restricoesAlimentares,
    Set<String>? alergias,
    Set<String>? preferenciasAlimentares,
    FormulaTmb? formulaTmb,
  }) =>
      TrainerProfile(
        idade: idade ?? this.idade,
        pesoKg: pesoKg ?? this.pesoKg,
        alturaM: alturaM ?? this.alturaM,
        sexo: sexo ?? this.sexo,
        objetivo: objetivo ?? this.objetivo,
        nivel: nivel ?? this.nivel,
        limitacoes: limitacoes ?? this.limitacoes,
        diasPorSemana: diasPorSemana ?? this.diasPorSemana,
        pesoInicial: pesoInicial ?? this.pesoInicial,
        pesoDesejado: pesoDesejado ?? this.pesoDesejado,
        percentualGordura: percentualGordura ?? this.percentualGordura,
        massaMuscularKg: massaMuscularKg ?? this.massaMuscularKg,
        nivelAtividade: nivelAtividade ?? this.nivelAtividade,
        tipoDieta: tipoDieta ?? this.tipoDieta,
        restricoesAlimentares:
            restricoesAlimentares ?? this.restricoesAlimentares,
        alergias: alergias ?? this.alergias,
        preferenciasAlimentares:
            preferenciasAlimentares ?? this.preferenciasAlimentares,
        formulaTmb: formulaTmb ?? this.formulaTmb,
      );

  Map<String, dynamic> toMap() => {
        'idade': idade,
        'pesoKg': pesoKg,
        'alturaM': alturaM,
        'sexo': sexo.name,
        'objetivo': objetivo.name,
        'nivel': nivel.name,
        'limitacoes': limitacoes.map((l) => l.name).toList(),
        'diasPorSemana': diasPorSemana,
        'pesoInicial': pesoInicial,
        'pesoDesejado': pesoDesejado,
        'percentualGordura': percentualGordura,
        'massaMuscularKg': massaMuscularKg,
        'nivelAtividade': nivelAtividade.name,
        'tipoDieta': tipoDieta.name,
        'restricoesAlimentares': restricoesAlimentares.toList(),
        'alergias': alergias.toList(),
        'preferenciasAlimentares': preferenciasAlimentares.toList(),
        'formulaTmb': formulaTmb.name,
      };

  static TrainerProfile fromMap(Map<String, dynamic> m) => TrainerProfile(
        idade: m['idade'] as int,
        pesoKg: (m['pesoKg'] as num).toDouble(),
        alturaM: (m['alturaM'] as num).toDouble(),
        sexo: Sexo.values.byName(m['sexo'] as String),
        objetivo: Objetivo.values.byName(m['objetivo'] as String),
        nivel: NivelFisico.values.byName(m['nivel'] as String),
        limitacoes: (m['limitacoes'] as List)
            .map((e) => Limitacao.values.byName(e as String))
            .toSet(),
        diasPorSemana: m['diasPorSemana'] as int,
        pesoInicial: (m['pesoInicial'] as num?)?.toDouble(),
        pesoDesejado: (m['pesoDesejado'] as num?)?.toDouble(),
        percentualGordura: (m['percentualGordura'] as num?)?.toDouble(),
        massaMuscularKg: (m['massaMuscularKg'] as num?)?.toDouble(),
        nivelAtividade: m['nivelAtividade'] != null
            ? NivelAtividade.values.byName(m['nivelAtividade'] as String)
            : NivelAtividade.leve,
        tipoDieta: m['tipoDieta'] != null
            ? TipoDieta.values.byName(m['tipoDieta'] as String)
            : TipoDieta.onivora,
        restricoesAlimentares:
            (m['restricoesAlimentares'] as List?)?.cast<String>().toSet() ??
                {},
        alergias: (m['alergias'] as List?)?.cast<String>().toSet() ?? {},
        preferenciasAlimentares:
            (m['preferenciasAlimentares'] as List?)?.cast<String>().toSet() ??
                {},
        formulaTmb: m['formulaTmb'] != null
            ? FormulaTmb.values.byName(m['formulaTmb'] as String)
            : FormulaTmb.mifflinStJeor,
      );
}

/// Um exercício dentro do plano.
@immutable
class PlannedExercise {
  const PlannedExercise({
    required this.nome,
    required this.series,
    required this.reps,
    required this.descanso,
    this.observacao,
  });

  final String nome;
  final int series;
  final String reps; // "12" ou "30s"
  final String descanso;
  final String? observacao;
}

/// Um dia do plano de treino.
@immutable
class PlannedDay {
  const PlannedDay({
    required this.titulo,
    required this.foco,
    required this.exercicios,
    required this.duracaoMin,
  });

  final String titulo;
  final String foco;
  final List<PlannedExercise> exercicios;
  final int duracaoMin;
}

/// Plano de treino completo gerado pela IA.
@immutable
class WorkoutPlan {
  const WorkoutPlan({
    required this.resumo,
    required this.dias,
    required this.avisos,
  });

  final String resumo;
  final List<PlannedDay> dias;
  final List<String> avisos;
}

/// Motor de inteligência local — funciona **sem chave de API**.
///
/// Aplica regras reais de prescrição: volume por nível, foco por objetivo e
/// substituição de exercícios conforme limitações físicas.
class TrainerEngine {
  TrainerEngine._();

  // Exercícios contraindicados por limitação → substituto seguro.
  static const Map<Limitacao, Map<String, String>> _substituicoes = {
    Limitacao.joelho: {
      'Agachamento': 'Elevação de quadril (ponte)',
      'Afundo': 'Cadeira extensora leve',
      'Corrida': 'Caminhada ou bike',
      'Burpee': 'Prancha com toque de ombro',
      'Polichinelo': 'Marcha estacionária',
    },
    Limitacao.lombar: {
      'Levantamento terra': 'Ponte de glúteo',
      'Abdominal remador': 'Prancha isométrica',
      'Agachamento': 'Agachamento na parede',
      'Burpee': 'Step-up baixo',
    },
    Limitacao.ombro: {
      'Desenvolvimento militar': 'Elevação lateral leve',
      'Flexão de braço': 'Flexão inclinada na parede',
      'Burpee': 'Agachamento livre',
    },
    Limitacao.punho: {
      'Flexão de braço': 'Flexão com halteres (punho neutro)',
      'Prancha': 'Prancha nos antebraços',
    },
    Limitacao.gestante: {
      'Abdominal remador': 'Respiração diafragmática',
      'Prancha': 'Prancha inclinada',
      'Corrida': 'Caminhada leve',
      'Burpee': 'Agachamento na parede',
    },
    Limitacao.hipertensao: {
      'Levantamento terra': 'Remada leve',
      'Burpee': 'Caminhada acelerada',
    },
  };

  /// Aplica limitações: troca exercícios de risco por alternativas seguras.
  static PlannedExercise _adaptar(
      PlannedExercise ex, Set<Limitacao> limitacoes) {
    for (final lim in limitacoes) {
      final subs = _substituicoes[lim];
      if (subs == null) continue;
      for (final entry in subs.entries) {
        if (ex.nome.toLowerCase().contains(entry.key.toLowerCase())) {
          return PlannedExercise(
            nome: entry.value,
            series: ex.series,
            reps: ex.reps,
            descanso: ex.descanso,
            observacao: 'Adaptado para ${lim.label.toLowerCase()}',
          );
        }
      }
    }
    return ex;
  }

  /// Séries/reps por nível e objetivo.
  static ({int series, String reps, String descanso}) _volume(
      NivelFisico nivel, Objetivo objetivo) {
    final series = switch (nivel) {
      NivelFisico.iniciante => 2,
      NivelFisico.intermediario => 3,
      NivelFisico.avancado => 4,
    };
    final reps = switch (objetivo) {
      Objetivo.emagrecer => '15',
      Objetivo.tonificar => '12',
      Objetivo.ganharMassa => '8',
      Objetivo.saude => '12',
    };
    final descanso = switch (objetivo) {
      Objetivo.emagrecer => '30s',
      Objetivo.tonificar => '45s',
      Objetivo.ganharMassa => '90s',
      Objetivo.saude => '60s',
    };
    return (series: series, reps: reps, descanso: descanso);
  }

  /// Gera o plano semanal completo, personalizado e seguro.
  static WorkoutPlan gerarPlano(TrainerProfile p) {
    final v = _volume(p.nivel, p.objetivo);
    final duracao = switch (p.nivel) {
      NivelFisico.iniciante => 25,
      NivelFisico.intermediario => 40,
      NivelFisico.avancado => 55,
    };

    // Blocos base por foco.
    List<PlannedExercise> base(String foco) {
      final exs = switch (foco) {
        'Inferiores' => [
            'Agachamento',
            'Afundo',
            'Elevação de quadril (ponte)',
            'Panturrilha em pé',
          ],
        'Superiores' => [
            'Flexão de braço',
            'Remada com halteres',
            'Desenvolvimento militar',
            'Rosca bíceps',
          ],
        'Core' => [
            'Prancha',
            'Abdominal remador',
            'Prancha lateral',
            'Elevação de pernas',
          ],
        _ => [
            'Polichinelo',
            'Agachamento',
            'Flexão de braço',
            'Prancha',
          ],
      };
      return exs
          .map((nome) => _adaptar(
                PlannedExercise(
                  nome: nome,
                  series: v.series,
                  reps: foco == 'Core' ? '30s' : v.reps,
                  descanso: v.descanso,
                ),
                p.limitacoes,
              ))
          .toList();
    }

    // Divisão conforme dias disponíveis.
    final focos = switch (p.diasPorSemana) {
      <= 2 => ['Full body', 'Full body'],
      3 => ['Inferiores', 'Superiores', 'Core'],
      4 => ['Inferiores', 'Superiores', 'Core', 'Full body'],
      _ => ['Inferiores', 'Superiores', 'Core', 'Full body', 'Inferiores'],
    };

    final dias = <PlannedDay>[];
    for (var i = 0; i < focos.length && i < p.diasPorSemana; i++) {
      dias.add(PlannedDay(
        titulo: 'Dia ${i + 1}',
        foco: focos[i],
        exercicios: base(focos[i]),
        duracaoMin: duracao,
      ));
    }

    // Avisos de segurança conforme perfil.
    final avisos = <String>[];
    if (p.limitacoes.any((l) => l != Limitacao.nenhuma)) {
      avisos.add(
          'Exercícios foram adaptados às suas limitações. Sinta dor? Pare e procure um profissional.');
    }
    if (p.limitacoes.contains(Limitacao.gestante)) {
      avisos.add(
          'Gestantes devem ter liberação médica antes de iniciar qualquer treino.');
    }
    if (p.limitacoes.contains(Limitacao.hipertensao)) {
      avisos.add(
          'Com hipertensão, evite apneia e cargas máximas. Acompanhe sua pressão.');
    }
    if (p.idade >= 60) {
      avisos.add('Acima dos 60, priorize mobilidade e equilíbrio no aquecimento.');
    }
    if (p.imc >= 30) {
      avisos.add(
          'Comece com impacto baixo (caminhada, bike) para proteger as articulações.');
    }

    final resumo =
        '${p.objetivo.label} · ${p.nivel.label} · ${p.diasPorSemana}x/semana · '
        '~$duracao min por sessão';

    return WorkoutPlan(resumo: resumo, dias: dias, avisos: avisos);
  }

  /// Detecta platô de emagrecimento a partir do histórico de peso.
  ///
  /// Considera platô quando a variação nas últimas 3 semanas é menor que 0,5 kg.
  /// Retorna null quando não há platô (ou dados insuficientes).
  static String? detectarPlato(List<double> pesos) {
    if (pesos.length < 3) return null;
    final ultimos = pesos.sublist(pesos.length - 3);
    final variacao = (ultimos.first - ultimos.last).abs();
    if (variacao < 0.5) {
      return 'Percebi que seu peso está estável há ~3 semanas — isso é um platô, '
          'e é totalmente normal. 💜\n\nSugestões:\n'
          '• Varie o estímulo: troque 1 treino por HIIT ou aumente a carga.\n'
          '• Revise as porções (o corpo se adapta ao déficit).\n'
          '• Priorize proteína e sono de 7–8h.\n'
          '• Meça também circunferências: às vezes você perde gordura sem perder peso.';
    }
    return null;
  }

  /// Recomenda descanso se o volume da semana estiver alto.
  static String? recomendarDescanso({
    required int treinosNaSemana,
    required int streak,
  }) {
    if (treinosNaSemana >= 6 || streak >= 14) {
      return 'Você está treinando muito forte! 🔥 Descanso não é preguiça — é '
          'quando o corpo se reconstrói. Que tal um dia de recuperação ativa '
          '(alongamento ou caminhada leve)? Seu progresso agradece.';
    }
    return null;
  }

  /// Sugere metas semanais coerentes com o perfil.
  static List<String> metasSemanais(TrainerProfile p) => [
        '${p.diasPorSemana} treinos nesta semana',
        'Beber ${p.aguaLitros} L de água por dia (${p.aguaCopos} copos)',
        p.objetivo == Objetivo.emagrecer
            ? 'Fechar a semana com déficit calórico leve'
            : 'Garantir proteína em todas as refeições',
        'Dormir 7–8 horas por noite',
      ];

  /// Sugestões de alimentação por objetivo.
  static List<String> sugestoesAlimentacao(TrainerProfile p) {
    final kcal = (p.tmb * 1.375).round(); // atividade leve
    final alvo = switch (p.objetivo) {
      Objetivo.emagrecer => kcal - 400,
      Objetivo.ganharMassa => kcal + 300,
      _ => kcal,
    };
    return [
      'Estimativa: ~$alvo kcal/dia para ${p.objetivo.label.toLowerCase()}.',
      'Proteína: ~${(p.pesoKg * 1.6).round()} g/dia (frango, ovos, peixe, tofu).',
      'Café da manhã: ovos mexidos + fruta + aveia.',
      'Almoço: proteína magra + arroz integral + salada colorida.',
      'Lanche: iogurte natural com castanhas.',
      'Jantar: sopa de legumes ou omelete com salada.',
      'Beba ${p.aguaLitros} L de água ao longo do dia.',
    ];
  }
}
