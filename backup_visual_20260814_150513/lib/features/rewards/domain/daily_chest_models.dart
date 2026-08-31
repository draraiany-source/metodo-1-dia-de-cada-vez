import 'dart:math';

import 'package:flutter/material.dart';

/// ============================================================================
/// BAÚS DIÁRIOS (Sprint V37 §3) — recompensa por constância.
///
/// Uma vez por dia a usuária abre um baú e recebe moedas LiliMood + XP.
/// A raridade é sorteada por peso; a sequência (streak) melhora as chances
/// de raridades melhores, recompensando quem volta todo dia.
/// ============================================================================
enum ChestRarity { comum, raro, epico, lendario }

extension ChestRarityX on ChestRarity {
  String get label {
    switch (this) {
      case ChestRarity.comum:
        return 'Comum';
      case ChestRarity.raro:
        return 'Raro';
      case ChestRarity.epico:
        return 'Épico';
      case ChestRarity.lendario:
        return 'Lendário';
    }
  }

  String get emoji {
    switch (this) {
      case ChestRarity.comum:
        return '📦';
      case ChestRarity.raro:
        return '🎁';
      case ChestRarity.epico:
        return '💜';
      case ChestRarity.lendario:
        return '👑';
    }
  }

  Color get color {
    switch (this) {
      case ChestRarity.comum:
        return const Color(0xFFB8C4CE);
      case ChestRarity.raro:
        return const Color(0xFF5AA9E6);
      case ChestRarity.epico:
        return const Color(0xFF9B5DE5);
      case ChestRarity.lendario:
        return const Color(0xFFF5C542);
    }
  }

  /// Faixa de moedas LiliMood concedida.
  (int, int) get coinRange {
    switch (this) {
      case ChestRarity.comum:
        return (10, 20);
      case ChestRarity.raro:
        return (25, 45);
      case ChestRarity.epico:
        return (50, 80);
      case ChestRarity.lendario:
        return (100, 160);
    }
  }

  /// XP concedido (fixo por raridade).
  int get xp {
    switch (this) {
      case ChestRarity.comum:
        return 20;
      case ChestRarity.raro:
        return 40;
      case ChestRarity.epico:
        return 70;
      case ChestRarity.lendario:
        return 120;
    }
  }
}

/// Resultado da abertura de um baú.
@immutable
class ChestReward {
  const ChestReward({
    required this.rarity,
    required this.coins,
    required this.xp,
  });

  final ChestRarity rarity;
  final int coins;
  final int xp;
}

/// Sorteia uma recompensa. [streak] desloca os pesos para raridades melhores
/// (a partir de ~7 e ~30 dias), sem nunca zerar a chance da comum.
ChestReward drawChest({required int streak, Random? rng}) {
  final r = rng ?? Random();

  // Pesos base (soma 100). Bônus de streak migra peso para raro/épico/lendário.
  final bonus = streak.clamp(0, 40); // teto pra não estourar
  final wComum = (60 - bonus).clamp(20, 60);
  final wRaro = 25 + (bonus * 0.4).round();
  final wEpico = 12 + (bonus * 0.4).round();
  final wLendario = 3 + (bonus * 0.2).round();
  final total = wComum + wRaro + wEpico + wLendario;

  var roll = r.nextInt(total);
  ChestRarity rarity;
  if (roll < wComum) {
    rarity = ChestRarity.comum;
  } else if (roll < wComum + wRaro) {
    rarity = ChestRarity.raro;
  } else if (roll < wComum + wRaro + wEpico) {
    rarity = ChestRarity.epico;
  } else {
    rarity = ChestRarity.lendario;
  }

  final (lo, hi) = rarity.coinRange;
  final coins = lo + r.nextInt(hi - lo + 1);
  return ChestReward(rarity: rarity, coins: coins, xp: rarity.xp);
}
