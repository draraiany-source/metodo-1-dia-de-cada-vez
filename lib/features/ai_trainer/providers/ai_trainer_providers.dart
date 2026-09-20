import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/auth_providers.dart';
import '../../evolution/providers/weight_history_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../health_sync/domain/health_models.dart';
import '../../health_sync/providers/health_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import '../data/ai_trainer_repository.dart';
import '../domain/trainer_engine.dart';

/// Uma mensagem do chat.
@immutable
class TrainerMessage {
  const TrainerMessage({
    required this.text,
    required this.fromUser,
    required this.date,
  });

  final String text;
  final bool fromUser;
  final DateTime date;

  Map<String, dynamic> toMap() =>
      {'text': text, 'fromUser': fromUser, 'date': date.toIso8601String()};

  static TrainerMessage fromMap(Map<String, dynamic> m) => TrainerMessage(
        text: m['text'] as String,
        fromUser: m['fromUser'] as bool,
        date: DateTime.parse(m['date'] as String),
      );
}

final aiTrainerRepositoryProvider =
    Provider<AiTrainerRepository>((ref) => AiTrainerRepository());

// ---------------------------------------------------------------------------
// PERFIL DO USUÁRIO PARA A IA (persistido)
// ---------------------------------------------------------------------------

class TrainerProfileNotifier extends StateNotifier<TrainerProfile> {
  TrainerProfileNotifier() : super(const TrainerProfile()) {
    _load();
  }

  static const _kKey = 'trainer_profile';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kKey);
    if (raw != null) {
      try {
        state = TrainerProfile.fromMap(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {/* mantém default */}
    }
  }

  Future<void> update(TrainerProfile profile) async {
    state = profile;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKey, jsonEncode(profile.toMap()));
    syncToCloud();
  }

  /// Ponto de extensão para Firestore (no-op em modo local).
  void syncToCloud() {
    // if (FirebaseService.isReady) { /* users/{uid}.trainerProfile */ }
  }
}

final trainerProfileProvider =
    StateNotifierProvider<TrainerProfileNotifier, TrainerProfile>(
        (ref) => TrainerProfileNotifier());

// ---------------------------------------------------------------------------
// CONTEXTO VIVO (streak, missões, moedas, nível) — lido dos módulos existentes
// ---------------------------------------------------------------------------

final trainerContextProvider = Provider<TrainerContext>((ref) {
  final user = ref.watch(currentUserProvider);
  final gam = ref.watch(gamificationProvider);
  final rewards = ref.watch(rewardsProvider);
  final claimable = ref.watch(claimableMissionsProvider);

  // Progresso de treinos da semana vindo das missões (missão 's_treinos').
  final missions = ref.watch(missionsProvider);
  final treinosSemana = missions.progressOf('s_treinos').current;

  // Dados de saúde sincronizados (0 quando indisponíveis).
  final health = ref.watch(healthSyncProvider).snapshot;
  final passos = health?.get(HealthMetric.passos)?.round() ?? 0;
  final kcal = health?.get(HealthMetric.caloriasKcal)?.round() ?? 0;

  return TrainerContext(
    streak: gam.streak, // fonte única (antes lia AppUser estático)
    missoesProntas: claimable,
    moedas: rewards.coins,
    nivel: gam.level,
    treinosNaSemana: treinosSemana,
    historicoPeso: ref
        .watch(weightHistoryProvider)
        .map((e) => e.weight)
        .toList(),
    userName: (user?.name ?? 'você').split(' ').first,
    passosHoje: passos,
    caloriasHoje: kcal,
    fonteSaude: health?.source.label,
  );
});

// ---------------------------------------------------------------------------
// CHAT + HISTÓRICO (persistido)
// ---------------------------------------------------------------------------

@immutable
class TrainerChatState {
  const TrainerChatState({
    this.messages = const [],
    this.thinking = false,
    this.loading = true,
    this.lastReplyOffline = false,
  });

  final List<TrainerMessage> messages;
  final bool thinking;
  final bool loading;
  final bool lastReplyOffline;

  TrainerChatState copyWith({
    List<TrainerMessage>? messages,
    bool? thinking,
    bool? loading,
    bool? lastReplyOffline,
  }) =>
      TrainerChatState(
        messages: messages ?? this.messages,
        thinking: thinking ?? this.thinking,
        loading: loading ?? this.loading,
        lastReplyOffline: lastReplyOffline ?? this.lastReplyOffline,
      );
}

class TrainerChatNotifier extends StateNotifier<TrainerChatState> {
  TrainerChatNotifier(this._ref) : super(const TrainerChatState()) {
    _load();
  }

  final Ref _ref;
  static const _kKey = 'trainer_chat_history';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_kKey) ?? [];
    // Parse defensivo: uma mensagem corrompida não pode quebrar o chat.
    final msgs = <TrainerMessage>[];
    for (final s in raw) {
      try {
        msgs.add(TrainerMessage.fromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* mensagem inválida descartada */}
    }
    state = TrainerChatState(messages: msgs, loading: false);
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    // guarda as últimas 200 mensagens
    final toSave = state.messages.length > 200
        ? state.messages.sublist(state.messages.length - 200)
        : state.messages;
    await p.setStringList(
        _kKey, toSave.map((m) => jsonEncode(m.toMap())).toList());
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg =
        TrainerMessage(text: text.trim(), fromUser: true, date: DateTime.now());
    state = state.copyWith(
        messages: [...state.messages, userMsg], thinking: true);
    await _persist();

    final repo = _ref.read(aiTrainerRepositoryProvider);
    final profile = _ref.read(trainerProfileProvider);
    final context = _ref.read(trainerContextProvider);

    final result =
        await repo.ask(text, profile: profile, context: context);

    final botMsg = TrainerMessage(
        text: result.reply, fromUser: false, date: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, botMsg],
      thinking: false,
      lastReplyOffline: result.usedOfflineFallback,
    );
    await _persist();
  }

  Future<void> clear() async {
    state = const TrainerChatState(messages: [], loading: false);
    final p = await SharedPreferences.getInstance();
    await p.remove(_kKey);
  }
}

final trainerChatProvider =
    StateNotifierProvider<TrainerChatNotifier, TrainerChatState>(
        (ref) => TrainerChatNotifier(ref));
