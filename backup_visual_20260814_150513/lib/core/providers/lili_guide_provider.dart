import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/gamification/providers/gamification_providers.dart';
import '../../features/health_sync/domain/health_models.dart';
import '../../features/health_sync/providers/health_providers.dart';
import '../../features/missions/providers/missions_providers.dart';
import '../../features/rewards/providers/rewards_providers.dart';
import '../widgets/lili_animated.dart';
import '../widgets/lili_widgets.dart';

/// O que a Lili está "sentindo" agora, derivado do estado real do app.
///
/// A ordem importa: quanto mais alto na lista, maior a prioridade.
/// Ex.: perder a sequência fala mais alto que "tem missão pronta".
enum LiliSituation {
  /// A usuária acabou de perder a sequência. Acolhimento, nunca culpa.
  sequenciaPerdida,

  /// Missão(ões) concluída(s) esperando resgate.
  recompensaEsperando,

  /// Sequência longa em andamento.
  emChamas,

  /// Bateu a meta de passos do dia.
  metaPassosBatida,

  /// Tem moedas suficientes para resgatar algo na Loja.
  podeComprar,

  /// Começando (streak baixo, poucos dados).
  comecando,

  /// Estado neutro, dia comum.
  neutro,
}

/// O "estado de espírito" da Lili: expressão + humor + fala.
@immutable
class LiliGuideState {
  const LiliGuideState({
    required this.situation,
    required this.pose,
    required this.mood,
    required this.fala,
    this.cta,
    this.rota,
  });

  final LiliSituation situation;
  final MascotePose pose;
  final LiliMood mood;

  /// A frase que aparece no balão de conversa.
  final String fala;

  /// Texto do botão de ação (null = sem botão).
  final String? cta;

  /// Rota para onde o CTA leva.
  final String? rota;
}

/// Frases por situação. Várias por contexto para não ficar repetitivo.
class _Falas {
  _Falas._();

  static const sequenciaPerdida = [
    'Ei, a sequência parou — e tudo bem. 💜 Recomeçar também é constância.',
    'Você não falhou, só pausou. Vamos começar de novo hoje? 💜',
    'Um dia de cada vez. E hoje é um dia novo. Estou aqui com você.',
  ];

  static const recompensaEsperando = [
    'Você tem recompensa esperando! Vem resgatar comigo. 🎁',
    'Missão cumprida! Corre resgatar seu prêmio. 🎉',
    'Olha só quem completou uma missão! Orgulho de você. 🏆',
  ];

  static const emChamas = [
    'Você está pegando fogo! Que constância linda. 🔥',
    'Essa sequência é resultado da sua disciplina. Continue! 🔥',
    'Cada dia desses te deixa mais perto da sua melhor versão. 💪',
  ];

  static const metaPassosBatida = [
    'Meta de passos batida! Seu corpo agradece. 👟',
    'Você se moveu hoje — e isso muda tudo. 🎉',
  ];

  static const podeComprar = [
    'Suas moedas estão rendendo! Dá uma olhada na Loja. 🪙',
    'Você juntou moedas suficientes para desbloquear algo. ✨',
  ];

  static const comecando = [
    'Todo começo conta. Que tal um treino curto hoje? 💪',
    'Não precisa ser perfeita. Só precisa começar. 💜',
    'Bora fazer o primeiro check-in do dia?',
  ];

  static const neutro = [
    'Como você está hoje? Estou aqui se precisar. 💜',
    'Um dia de cada vez, até sua melhor versão.',
    'Seu corpo consegue. É sua mente que você precisa convencer.',
    'Disciplina hoje, liberdade amanhã.',
  ];

  /// Escolhe uma frase variando por dia (estável dentro do mesmo dia).
  static String pick(List<String> opcoes, {int? seed}) {
    final s = seed ?? DateTime.now().day;
    return opcoes[Random(s).nextInt(opcoes.length)];
  }
}

/// Rotas usadas pelos CTAs da Lili (strings literais para evitar ciclo
/// de import com o router).
class _R {
  static const missions = '/missions';
  static const rewards = '/rewards';
  static const habits = '/habits';
  static const aiTrainer = '/ai-trainer';
  static const streak = '/streak';
}

/// O "cérebro" da Lili. Lê o estado real dos módulos e decide como reagir.
///
/// **Não é um módulo novo**: é um `Provider` derivado que apenas observa
/// `gamification`, `missions`, `rewards` e `health_sync`.
final liliGuideProvider = Provider<LiliGuideState>((ref) {
  final gam = ref.watch(gamificationProvider);
  final claimable = ref.watch(claimableMissionsProvider);
  final rewards = ref.watch(rewardsProvider);
  final health = ref.watch(healthSyncProvider).snapshot;

  final passos = health?.get(HealthMetric.passos)?.round() ?? 0;

  // Menor preço da Loja ainda não resgatado.
  final naoResgatados =
      RewardsCatalog.all.where((i) => !rewards.owned.contains(i.id));
  final maisBarato = naoResgatados.isEmpty
      ? null
      : naoResgatados.map((i) => i.price).reduce(min);

  // --- Prioridade 1: perdeu a sequência (acolher) ---
  if (gam.streakJustBroken) {
    final dias = gam.previousStreak;
    return LiliGuideState(
      situation: LiliSituation.sequenciaPerdida,
      pose: MascotePose.triste,
      mood: LiliMood.calma,
      fala: dias > 0
          ? 'Você tinha $dias dias seguidos. A sequência parou — e tudo bem. 💜 '
              'Recomeçar também é constância.'
          : _Falas.pick(_Falas.sequenciaPerdida),
      cta: 'Recomeçar hoje',
      rota: _R.habits,
    );
  }

  // --- Prioridade 2: tem recompensa para resgatar ---
  if (claimable > 0) {
    return LiliGuideState(
      situation: LiliSituation.recompensaEsperando,
      pose: MascotePose.celebrando,
      mood: LiliMood.comemorando,
      fala: claimable == 1
          ? _Falas.pick(_Falas.recompensaEsperando)
          : 'Você tem $claimable missões concluídas esperando resgate! 🎁',
      cta: 'Resgatar',
      rota: _R.missions,
    );
  }

  // --- Prioridade 3: sequência longa ---
  if (gam.streak >= 7) {
    return LiliGuideState(
      situation: LiliSituation.emChamas,
      pose: MascotePose.forte,
      mood: LiliMood.correndo,
      fala: '${gam.streak} dias seguidos! ${_Falas.pick(_Falas.emChamas)}',
      cta: 'Ver sequência',
      rota: _R.streak,
    );
  }

  // --- Prioridade 4: bateu meta de passos ---
  if (passos >= 8000) {
    return LiliGuideState(
      situation: LiliSituation.metaPassosBatida,
      pose: MascotePose.joinha,
      mood: LiliMood.comemorando,
      fala: '$passos passos hoje! ${_Falas.pick(_Falas.metaPassosBatida)}',
    );
  }

  // --- Prioridade 5: pode comprar algo ---
  if (maisBarato != null && rewards.coins >= maisBarato) {
    return LiliGuideState(
      situation: LiliSituation.podeComprar,
      pose: MascotePose.rainha,
      mood: LiliMood.respirando,
      fala: '${rewards.coins} moedas! ${_Falas.pick(_Falas.podeComprar)}',
      cta: 'Abrir Loja',
      rota: _R.rewards,
    );
  }

  // --- Prioridade 6: começando ---
  if (gam.streak == 0) {
    return LiliGuideState(
      situation: LiliSituation.comecando,
      pose: MascotePose.apontando,
      mood: LiliMood.viva,
      fala: _Falas.pick(_Falas.comecando),
      cta: 'Fazer check-in',
      rota: _R.habits,
    );
  }

  // --- Neutro ---
  return LiliGuideState(
    situation: LiliSituation.neutro,
    pose: MascotePose.coracao,
    mood: LiliMood.respirando,
    fala: _Falas.pick(_Falas.neutro),
    cta: 'Conversar',
    rota: _R.aiTrainer,
  );
});
