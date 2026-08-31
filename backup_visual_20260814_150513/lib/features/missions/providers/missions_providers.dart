import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Periodicidade da missão.
enum MissionPeriod { diaria, semanal, mensal }

extension MissionPeriodX on MissionPeriod {
  String get label => switch (this) {
        MissionPeriod.diaria => 'Diárias',
        MissionPeriod.semanal => 'Semanais',
        MissionPeriod.mensal => 'Mensais',
      };

  String get emoji => switch (this) {
        MissionPeriod.diaria => '☀️',
        MissionPeriod.semanal => '📅',
        MissionPeriod.mensal => '🗓️',
      };
}

/// Tipos de evento que fazem missões progredirem.
///
/// As telas existentes apenas chamam `report(evento)` — o módulo de
/// missões cuida do resto. Acoplamento mínimo, nada é alterado nelas.
enum MissionEvent {
  treinoConcluido,
  checkinFeito,
  copoDeAgua,
  refeicaoRegistrada,
  pesoRegistrado,
  corridaConcluida,
  desafioConcluido,
  streakDia,
}

/// Definição estática de uma missão.
@immutable
class MissionDef {
  const MissionDef({
    required this.id,
    required this.title,
    required this.description,
    required this.period,
    required this.event,
    required this.target,
    required this.xp,
    required this.coins,
    this.emoji = '🎯',
  });

  final String id;
  final String title;
  final String description;
  final MissionPeriod period;
  final MissionEvent event;
  final int target;
  final int xp;
  final int coins;
  final String emoji;
}

/// Progresso de uma missão (persistido).
@immutable
class MissionProgress {
  const MissionProgress({
    required this.id,
    this.current = 0,
    this.claimed = false,
  });

  final String id;
  final int current;
  final bool claimed;

  MissionProgress copyWith({int? current, bool? claimed}) => MissionProgress(
        id: id,
        current: current ?? this.current,
        claimed: claimed ?? this.claimed,
      );

  Map<String, dynamic> toMap() =>
      {'id': id, 'current': current, 'claimed': claimed};

  static MissionProgress fromMap(Map<String, dynamic> m) => MissionProgress(
        id: m['id'] as String,
        current: m['current'] as int,
        claimed: m['claimed'] as bool,
      );
}

/// Registro do histórico de missões concluídas.
@immutable
class MissionRecord {
  const MissionRecord({
    required this.id,
    required this.title,
    required this.xp,
    required this.coins,
    required this.date,
  });

  final String id;
  final String title;
  final int xp;
  final int coins;
  final DateTime date;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'xp': xp,
        'coins': coins,
        'date': date.toIso8601String(),
      };

  static MissionRecord fromMap(Map<String, dynamic> m) => MissionRecord(
        id: m['id'] as String,
        title: m['title'] as String,
        xp: m['xp'] as int,
        coins: m['coins'] as int,
        date: DateTime.parse(m['date'] as String),
      );
}

/// Catálogo de missões — cobre treinos, hidratação, alimentação, peso,
/// streak e desafios.
class MissionsCatalog {
  MissionsCatalog._();

  static const List<MissionDef> all = [
    // ---------- DIÁRIAS ----------
    MissionDef(
      id: 'd_treino',
      title: 'Treine hoje',
      description: 'Conclua 1 treino.',
      period: MissionPeriod.diaria,
      event: MissionEvent.treinoConcluido,
      target: 1,
      xp: 40,
      coins: 15,
      emoji: '💪',
    ),
    MissionDef(
      id: 'd_agua',
      title: 'Hidrate-se',
      description: 'Beba 8 copos de água.',
      period: MissionPeriod.diaria,
      event: MissionEvent.copoDeAgua,
      target: 8,
      xp: 30,
      coins: 10,
      emoji: '💧',
    ),
    MissionDef(
      id: 'd_checkin',
      title: 'Check-in do dia',
      description: 'Registre seus hábitos.',
      period: MissionPeriod.diaria,
      event: MissionEvent.checkinFeito,
      target: 1,
      xp: 25,
      coins: 10,
      emoji: '✅',
    ),
    MissionDef(
      id: 'd_refeicao',
      title: 'Alimentação consciente',
      description: 'Registre 3 refeições.',
      period: MissionPeriod.diaria,
      event: MissionEvent.refeicaoRegistrada,
      target: 3,
      xp: 30,
      coins: 10,
      emoji: '🥗',
    ),

    // ---------- SEMANAIS ----------
    MissionDef(
      id: 's_treinos',
      title: 'Semana ativa',
      description: 'Conclua 4 treinos nesta semana.',
      period: MissionPeriod.semanal,
      event: MissionEvent.treinoConcluido,
      target: 4,
      xp: 150,
      coins: 60,
      emoji: '🏋️',
    ),
    MissionDef(
      id: 's_streak',
      title: 'Constância',
      description: 'Mantenha 5 dias de sequência.',
      period: MissionPeriod.semanal,
      event: MissionEvent.streakDia,
      target: 5,
      xp: 120,
      coins: 50,
      emoji: '🔥',
    ),
    MissionDef(
      id: 's_peso',
      title: 'Acompanhe seu peso',
      description: 'Registre seu peso 1x na semana.',
      period: MissionPeriod.semanal,
      event: MissionEvent.pesoRegistrado,
      target: 1,
      xp: 80,
      coins: 30,
      emoji: '⚖️',
    ),
    MissionDef(
      id: 's_corrida',
      title: 'Pé na estrada',
      description: 'Complete 2 corridas.',
      period: MissionPeriod.semanal,
      event: MissionEvent.corridaConcluida,
      target: 2,
      xp: 130,
      coins: 55,
      emoji: '🏃',
    ),

    // ---------- MENSAIS ----------
    MissionDef(
      id: 'm_treinos',
      title: 'Mês transformador',
      description: 'Conclua 16 treinos no mês.',
      period: MissionPeriod.mensal,
      event: MissionEvent.treinoConcluido,
      target: 16,
      xp: 500,
      coins: 200,
      emoji: '🏆',
    ),
    MissionDef(
      id: 'm_desafios',
      title: 'Superação',
      description: 'Conclua 2 desafios no mês.',
      period: MissionPeriod.mensal,
      event: MissionEvent.desafioConcluido,
      target: 2,
      xp: 400,
      coins: 160,
      emoji: '🚀',
    ),
    MissionDef(
      id: 'm_streak',
      title: 'Corrente inquebrável',
      description: 'Mantenha 20 dias de sequência.',
      period: MissionPeriod.mensal,
      event: MissionEvent.streakDia,
      target: 20,
      xp: 600,
      coins: 250,
      emoji: '💎',
    ),
  ];

  static List<MissionDef> byPeriod(MissionPeriod p) =>
      all.where((m) => m.period == p).toList();

  static MissionDef byId(String id) => all.firstWhere((m) => m.id == id);
}

/// Estado do módulo de missões.
@immutable
class MissionsState {
  const MissionsState({
    this.progress = const {},
    this.history = const [],
    this.loading = true,
  });

  /// id da missão -> progresso
  final Map<String, MissionProgress> progress;
  final List<MissionRecord> history;
  final bool loading;

  MissionProgress progressOf(String id) =>
      progress[id] ?? MissionProgress(id: id);

  MissionsState copyWith({
    Map<String, MissionProgress>? progress,
    List<MissionRecord>? history,
    bool? loading,
  }) =>
      MissionsState(
        progress: progress ?? this.progress,
        history: history ?? this.history,
        loading: loading ?? this.loading,
      );
}

/// Resultado de um resgate de recompensa.
class ClaimResult {
  ClaimResult({required this.ok, this.xp = 0, this.coins = 0, this.error});
  final bool ok;
  final int xp;
  final int coins;
  final String? error;
}

/// Notifier das missões: progresso, renovação automática e histórico.
///
/// **Renovação automática**: as missões diárias zeram a cada novo dia; as
/// semanais a cada nova semana (segunda-feira); as mensais a cada novo mês.
/// Isso é resolvido comparando as "chaves de período" salvas.
///
/// **Firebase**: `syncToCloud()` é o ponto de extensão — hoje é no-op,
/// mantendo o app 100% funcional em modo local.
class MissionsNotifier extends StateNotifier<MissionsState> {
  MissionsNotifier() : super(const MissionsState()) {
    _load();
  }

  static const _kProgress = 'missions_progress';
  static const _kHistory = 'missions_history';
  static const _kDayKey = 'missions_day_key';
  static const _kWeekKey = 'missions_week_key';
  static const _kMonthKey = 'missions_month_key';

  // ---- chaves de período ----
  static String dayKey([DateTime? d]) {
    final n = d ?? DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  static String weekKey([DateTime? d]) {
    final n = d ?? DateTime.now();
    // segunda-feira da semana corrente
    final monday = n.subtract(Duration(days: n.weekday - 1));
    return '${monday.year}-${monday.month}-${monday.day}';
  }

  static String monthKey([DateTime? d]) {
    final n = d ?? DateTime.now();
    return '${n.year}-${n.month}';
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();

    final raw = p.getStringList(_kProgress) ?? [];
    final map = <String, MissionProgress>{};
    for (final s in raw) {
      try {
        final mp =
            MissionProgress.fromMap(jsonDecode(s) as Map<String, dynamic>);
        map[mp.id] = mp;
      } catch (_) {
        // entrada corrompida é ignorada (missão volta ao progresso zero)
      }
    }

    final history = <MissionRecord>[];
    for (final s in p.getStringList(_kHistory) ?? <String>[]) {
      try {
        history.add(
            MissionRecord.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* registro inválido descartado */}
    }
    history.sort((a, b) => b.date.compareTo(a.date));

    // Renovação automática por período.
    final savedDay = p.getString(_kDayKey);
    final savedWeek = p.getString(_kWeekKey);
    final savedMonth = p.getString(_kMonthKey);

    void resetPeriod(MissionPeriod period) {
      for (final def in MissionsCatalog.byPeriod(period)) {
        map[def.id] = MissionProgress(id: def.id);
      }
    }

    var changed = false;
    if (savedDay != dayKey()) {
      resetPeriod(MissionPeriod.diaria);
      await p.setString(_kDayKey, dayKey());
      changed = true;
    }
    if (savedWeek != weekKey()) {
      resetPeriod(MissionPeriod.semanal);
      await p.setString(_kWeekKey, weekKey());
      changed = true;
    }
    if (savedMonth != monthKey()) {
      resetPeriod(MissionPeriod.mensal);
      await p.setString(_kMonthKey, monthKey());
      changed = true;
    }

    state = MissionsState(progress: map, history: history, loading: false);
    if (changed) await _persist();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_kProgress,
        state.progress.values.map((v) => jsonEncode(v.toMap())).toList());
    await p.setStringList(
        _kHistory, state.history.map((r) => jsonEncode(r.toMap())).toList());
    syncToCloud();
  }

  /// Ponto de extensão para Firestore (no-op em modo local).
  void syncToCloud() {
    // if (FirebaseService.isReady) { /* users/{uid}/missions */ }
  }

  /// Reporta um evento — avança todas as missões que o escutam.
  ///
  /// Ex.: ao concluir um treino, chame `report(MissionEvent.treinoConcluido)`.
  void report(MissionEvent event, {int amount = 1}) {
    final map = Map<String, MissionProgress>.from(state.progress);
    var touched = false;

    for (final def in MissionsCatalog.all.where((m) => m.event == event)) {
      final cur = map[def.id] ?? MissionProgress(id: def.id);
      if (cur.claimed) continue; // já resgatada neste período
      if (cur.current >= def.target) continue; // já completa, aguardando resgate
      final next = (cur.current + amount).clamp(0, def.target);
      map[def.id] = cur.copyWith(current: next);
      touched = true;
    }

    if (touched) {
      state = state.copyWith(progress: map);
      _persist();
    }
  }

  /// Define o progresso absoluto (útil para streak e água, que são estados).
  void setProgress(MissionEvent event, int value) {
    final map = Map<String, MissionProgress>.from(state.progress);
    var touched = false;
    for (final def in MissionsCatalog.all.where((m) => m.event == event)) {
      final cur = map[def.id] ?? MissionProgress(id: def.id);
      if (cur.claimed) continue;
      final next = value.clamp(0, def.target);
      if (next != cur.current) {
        map[def.id] = cur.copyWith(current: next);
        touched = true;
      }
    }
    if (touched) {
      state = state.copyWith(progress: map);
      _persist();
    }
  }

  bool isComplete(MissionDef def) =>
      state.progressOf(def.id).current >= def.target;

  bool isClaimed(MissionDef def) => state.progressOf(def.id).claimed;

  /// Resgata a recompensa de uma missão concluída.
  /// Retorna o XP/moedas para a UI creditar nos providers correspondentes.
  ClaimResult claim(MissionDef def) {
    final cur = state.progressOf(def.id);
    if (cur.claimed) {
      return ClaimResult(ok: false, error: 'Recompensa já resgatada.');
    }
    if (cur.current < def.target) {
      return ClaimResult(ok: false, error: 'Missão ainda não concluída.');
    }

    final map = Map<String, MissionProgress>.from(state.progress);
    map[def.id] = cur.copyWith(claimed: true);

    final history = [
      MissionRecord(
        id: def.id,
        title: def.title,
        xp: def.xp,
        coins: def.coins,
        date: DateTime.now(),
      ),
      ...state.history,
    ];

    state = state.copyWith(progress: map, history: history);
    _persist();
    return ClaimResult(ok: true, xp: def.xp, coins: def.coins);
  }

  /// Quantas missões estão prontas para resgate (usado em badges de menu).
  int get claimableCount => MissionsCatalog.all
      .where((d) => isComplete(d) && !isClaimed(d))
      .length;

  Future<void> reset() async {
    state = const MissionsState(progress: {}, history: [], loading: false);
    await _persist();
  }
}

final missionsProvider =
    StateNotifierProvider<MissionsNotifier, MissionsState>(
        (ref) => MissionsNotifier());

/// Quantidade de missões prontas para resgate (para badge na navegação).
final claimableMissionsProvider = Provider<int>((ref) {
  ref.watch(missionsProvider); // recomputa quando o estado muda
  return ref.read(missionsProvider.notifier).claimableCount;
});
