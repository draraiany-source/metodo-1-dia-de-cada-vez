import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/league_models.dart';
import 'gamification_providers.dart';

/// Estado da liga semanal.
@immutable
class LeagueState {
  const LeagueState({
    this.league = League.bronze,
    this.weeklyXp = 0,
    this.justPromoted = false,
    this.justDemoted = false,
    this.loading = true,
  });

  final League league;

  /// XP acumulado nesta semana (segunda 00:00 → agora).
  final int weeklyXp;

  /// Flags de transição — a UI exibe a celebração/acolhimento UMA vez
  /// e chama [LeagueNotifier.acknowledge].
  final bool justPromoted;
  final bool justDemoted;
  final bool loading;

  /// Progresso 0..1 até a promoção (1.0 quando já garantida ou no topo).
  double get progressToNext {
    final need = league.promoteXp;
    if (need <= 0) return 1.0;
    return (weeklyXp / need).clamp(0.0, 1.0);
  }

  int get xpToNext =>
      league.promoteXp <= 0 ? 0 : (league.promoteXp - weeklyXp).clamp(0, 1 << 30);

  /// Dias restantes até o fechamento da semana (domingo inclusive).
  int get daysLeftInWeek => DateTime.sunday - _clampWeekday(DateTime.now().weekday) + 1;

  static int _clampWeekday(int w) => w.clamp(DateTime.monday, DateTime.sunday);

  LeagueState copyWith({
    League? league,
    int? weeklyXp,
    bool? justPromoted,
    bool? justDemoted,
    bool? loading,
  }) =>
      LeagueState(
        league: league ?? this.league,
        weeklyXp: weeklyXp ?? this.weeklyXp,
        justPromoted: justPromoted ?? this.justPromoted,
        justDemoted: justDemoted ?? this.justDemoted,
        loading: loading ?? this.loading,
      );
}

/// Chave 'YYYY-Www' da semana ISO simplificada (segunda como início).
String weekKey([DateTime? d]) {
  final now = d ?? DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));
  return '${monday.year}-${monday.month}-${monday.day}';
}

/// ============================================================================
/// Notifier da liga. Estratégia (local-first, sem servidor):
///  - Guarda um SNAPSHOT do XP total no início da semana; weeklyXp =
///    xpTotal - snapshot (deriva do provider central, fonte única de XP).
///  - Na virada de semana, aplica [resolveWeekOutcome] (sobe/mantém/cai),
///    persiste a nova liga e reinicia o snapshot.
/// ============================================================================
class LeagueNotifier extends StateNotifier<LeagueState> {
  LeagueNotifier(this._readTotalXp) : super(const LeagueState()) {
    _init();
  }

  /// Lê o XP total atual da fonte única (injetado pelo provider).
  final int Function() _readTotalXp;

  int? _weekStartXp;

  static const _kLeague = 'league_tier';
  static const _kWeekKey = 'league_week_key';
  static const _kWeekStartXp = 'league_week_start_xp';

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    var league = League.values[(p.getInt(_kLeague) ?? 0)
        .clamp(0, League.values.length - 1)];
    var savedWeek = p.getString(_kWeekKey);
    var startXp = p.getInt(_kWeekStartXp);

    final total = _readTotalXp();
    final thisWeek = weekKey();

    var promoted = false;
    var demoted = false;

    if (savedWeek == null || startXp == null) {
      // Primeira execução: começa a contar a semana a partir de agora.
      savedWeek = thisWeek;
      startXp = total;
    } else if (savedWeek != thisWeek) {
      // Semana virou: fecha a anterior e abre a nova.
      final lastWeekXp = (total - startXp).clamp(0, 1 << 30);
      final novo = resolveWeekOutcome(league, lastWeekXp);
      promoted = novo.index > league.index;
      demoted = novo.index < league.index;
      league = novo;
      savedWeek = thisWeek;
      startXp = total;
    }

    await p.setInt(_kLeague, league.index);
    await p.setString(_kWeekKey, savedWeek);
    await p.setInt(_kWeekStartXp, startXp);

    _weekStartXp = startXp;
    if (!mounted) return;
    state = LeagueState(
      league: league,
      weeklyXp: (total - startXp).clamp(0, 1 << 30),
      justPromoted: promoted,
      justDemoted: demoted,
      loading: false,
    );
  }

  /// Chamado pelo provider sempre que o XP central muda.
  void onXpChanged(int totalXp) {
    final s = _weekStartXp;
    if (s == null || state.loading || !mounted) return;
    state = state.copyWith(weeklyXp: (totalXp - s).clamp(0, 1 << 30));
  }

  /// UI confirma que exibiu a celebração/acolhimento da transição.
  void acknowledge() {
    if (!state.justPromoted && !state.justDemoted) return;
    state = state.copyWith(justPromoted: false, justDemoted: false);
  }
}

final leagueProvider =
    StateNotifierProvider<LeagueNotifier, LeagueState>((ref) {
  final notifier =
      LeagueNotifier(() => ref.read(gamificationProvider).xp);
  ref.listen<GamificationState>(gamificationProvider, (prev, next) {
    notifier.onXpChanged(next.xp);
  });
  return notifier;
});
