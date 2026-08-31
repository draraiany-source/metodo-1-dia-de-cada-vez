import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado de gamificação — **fonte única de verdade** de XP, nível e streak.
///
/// Consumido por: Home, Conquistas, Ranking, Missões, Loja, IA Personal
/// Trainer, Health Sync e Calendário de sequência. Antes cada tela lia de um
/// lugar diferente (o `AppUser` trazia valores estáticos da demo), o que fazia
/// os números divergirem entre telas.
///
/// No backend real, o XP também é incrementado por Cloud Functions
/// (`onWorkoutCompleted`); este estado é o espelho local persistido, que dá
/// feedback imediato e sobrevive ao fechamento do app.
@immutable
class GamificationState {
  const GamificationState({
    this.xp = 850,
    this.streak = 8,
    this.lastCheckinDay,
    this.loading = true,
    this.streakJustBroken = false,
    this.previousStreak = 0,
  });

  final int xp;
  final int streak;

  /// True quando a sequência acabou de ser perdida (detectado no boot).
  /// A Lili usa isto para reagir com acolhimento em vez de silêncio.
  final bool streakJustBroken;

  /// Quantos dias a usuária tinha antes de perder — usado na fala da Lili.
  final int previousStreak;

  /// Chave 'YYYY-M-D' do último check-in, usada para manter/quebrar o streak.
  final String? lastCheckinDay;
  final bool loading;

  int get level => (xp ~/ 1000) + 1;
  int get xpInLevel => xp % 1000;
  double get progress => xpInLevel / 1000.0;

  GamificationState copyWith({
    int? xp,
    int? streak,
    String? lastCheckinDay,
    bool? loading,
    bool? streakJustBroken,
    int? previousStreak,
  }) =>
      GamificationState(
        xp: xp ?? this.xp,
        streak: streak ?? this.streak,
        lastCheckinDay: lastCheckinDay ?? this.lastCheckinDay,
        loading: loading ?? this.loading,
        streakJustBroken: streakJustBroken ?? this.streakJustBroken,
        previousStreak: previousStreak ?? this.previousStreak,
      );
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState()) {
    _load();
  }

  static const _kXp = 'gam_xp';
  static const _kStreak = 'gam_streak';
  static const _kLastCheckin = 'gam_last_checkin';

  static String dayKey([DateTime? d]) {
    final n = d ?? DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;

    var streak = p.getInt(_kStreak) ?? 8;
    final last = p.getString(_kLastCheckin);
    var quebrou = false;
    var anterior = 0;

    // Quebra o streak se passou mais de 1 dia sem check-in.
    if (last != null) {
      final ontem = dayKey(DateTime.now().subtract(const Duration(days: 1)));
      final hoje = dayKey();
      if (last != hoje && last != ontem && streak > 0) {
        anterior = streak;
        streak = 0;
        quebrou = true; // a Lili vai acolher, não punir
      }
    }

    if (!mounted) return;
    state = GamificationState(
      xp: p.getInt(_kXp) ?? 850,
      streak: streak,
      lastCheckinDay: last,
      loading: false,
      streakJustBroken: quebrou,
      previousStreak: anterior,
    );
    await _persist();
  }

  Future<void> _persist() async {
    if (!mounted) return;
    final xp = state.xp;
    final streak = state.streak;
    final lastCheckinDay = state.lastCheckinDay;

    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    await p.setInt(_kXp, xp);
    await p.setInt(_kStreak, streak);
    if (lastCheckinDay != null) {
      await p.setString(_kLastCheckin, lastCheckinDay);
    }
  }

  /// Marca a reação de quebra de sequência como já exibida.
  void acknowledgeStreakBreak() {
    if (!state.streakJustBroken) return;
    state = state.copyWith(streakJustBroken: false);
  }

  void addXp(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(xp: state.xp + amount);
    _persist();
  }

  /// Registra o check-in do dia. Incrementa o streak **uma vez por dia**.
  /// Retorna true se o streak avançou.
  bool registerCheckin() {
    final hoje = dayKey();
    if (state.lastCheckinDay == hoje) return false; // já fez hoje

    final ontem = dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final novoStreak = state.lastCheckinDay == ontem ? state.streak + 1 : 1;

    state = state.copyWith(streak: novoStreak, lastCheckinDay: hoje);
    _persist();
    return true;
  }

  @visibleForTesting
  Future<void> reset() async {
    state = const GamificationState(
        xp: 0, streak: 0, lastCheckinDay: null, loading: false);
    final p = await SharedPreferences.getInstance();
    await p.remove(_kXp);
    await p.remove(_kStreak);
    await p.remove(_kLastCheckin);
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier();
});
