import 'package:flutter/material.dart';

/// ============================================================================
/// LIGAS — competição semanal no estilo Duolingo (Sprint V36 §3).
///
/// A liga é decidida pelo XP ganho NA SEMANA (segunda→domingo), não pelo XP
/// total: quem mantém constância sobe (Bronze → Prata → Ouro → Diamante);
/// semanas paradas rebaixam um degrau. Tudo offline e determinístico, na
/// mesma filosofia local-first do resto da gamificação.
/// ============================================================================
enum League { bronze, prata, ouro, diamante }

extension LeagueX on League {
  String get label {
    switch (this) {
      case League.bronze:
        return 'Liga Bronze';
      case League.prata:
        return 'Liga Prata';
      case League.ouro:
        return 'Liga Ouro';
      case League.diamante:
        return 'Liga Diamante';
    }
  }

  String get emoji {
    switch (this) {
      case League.bronze:
        return '🥉';
      case League.prata:
        return '🥈';
      case League.ouro:
        return '🥇';
      case League.diamante:
        return '💎';
    }
  }

  /// Cor característica do tier (combina com a paleta lilás/rosa/preto).
  Color get color {
    switch (this) {
      case League.bronze:
        return const Color(0xFFCD7F32);
      case League.prata:
        return const Color(0xFFB8C4CE);
      case League.ouro:
        return const Color(0xFFF5C542);
      case League.diamante:
        return const Color(0xFF7DE2F5);
    }
  }

  /// XP semanal necessário para SUBIR desta liga ao fim da semana.
  /// (Diamante é o topo — não há promoção além dela.)
  int get promoteXp {
    switch (this) {
      case League.bronze:
        return 300;
      case League.prata:
        return 700;
      case League.ouro:
        return 1200;
      case League.diamante:
        return 0;
    }
  }

  /// XP semanal mínimo para PERMANECER; abaixo disso, cai um degrau
  /// (Bronze nunca rebaixa — a liga acolhe, não pune).
  int get keepXp {
    switch (this) {
      case League.bronze:
        return 0;
      case League.prata:
        return 100;
      case League.ouro:
        return 200;
      case League.diamante:
        return 300;
    }
  }

  League get next {
    switch (this) {
      case League.bronze:
        return League.prata;
      case League.prata:
        return League.ouro;
      case League.ouro:
        return League.diamante;
      case League.diamante:
        return League.diamante;
    }
  }

  League get previous {
    switch (this) {
      case League.bronze:
        return League.bronze;
      case League.prata:
        return League.bronze;
      case League.ouro:
        return League.prata;
      case League.diamante:
        return League.ouro;
    }
  }
}

/// Resolve a liga resultante ao fechar a semana com [weeklyXp].
League resolveWeekOutcome(League current, int weeklyXp) {
  if (current != League.diamante && weeklyXp >= current.promoteXp) {
    return current.next;
  }
  if (weeklyXp < current.keepXp) return current.previous;
  return current;
}
