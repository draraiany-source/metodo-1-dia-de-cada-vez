import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import '../data/health_service.dart';
import '../domain/health_models.dart';

/// Recompensas por sincronizar dados reais.
class HealthRewards {
  HealthRewards._();
  static const int xpPorSync = 20;
  static const int moedasPorSync = 5;
  static const int passosParaBonus = 8000;
  static const int xpBonusPassos = 50;
  static const int moedasBonusPassos = 20;
}

/// Serviço ativo.
///
/// **Hoje**: `LocalHealthService`, alimentado pelos registros manuais do app.
/// **Depois de ativar o pacote `health`**: troque por `PlatformHealthService()`
/// (ver instruções em `health_service.dart`). Nenhuma tela muda.
final healthServiceProvider = Provider<HealthService>((ref) {
  final user = ref.watch(currentUserProvider);
  final missions = ref.watch(missionsProvider);

  // Deriva os registros manuais existentes no app.
  final copos = missions.progressOf('d_agua').current;
  final treinosHoje = missions.progressOf('d_treino').current;

  return LocalHealthService(
    coposDeAgua: copos,
    pesoKg: user?.currentWeight,
    imc: user?.bmi,
    treinosHoje: treinosHoje,
    minutosAtivos: treinosHoje * 30,
  );
});

/// Estado da sincronização.
@immutable
class HealthSyncState {
  const HealthSyncState({
    this.permission = HealthPermission.naoSolicitada,
    this.snapshot,
    this.lastSync,
    this.syncing = false,
    this.autoSync = true,
    this.error,
    this.indisponiveis = const [],
    this.loading = true,
  });

  final HealthPermission permission;
  final HealthSnapshot? snapshot;
  final DateTime? lastSync;
  final bool syncing;
  final bool autoSync;
  final String? error;
  final List<HealthMetric> indisponiveis;
  final bool loading;

  bool get conectado => permission == HealthPermission.concedida;

  HealthSyncState copyWith({
    HealthPermission? permission,
    HealthSnapshot? snapshot,
    DateTime? lastSync,
    bool? syncing,
    bool? autoSync,
    String? error,
    List<HealthMetric>? indisponiveis,
    bool? loading,
    bool clearError = false,
  }) =>
      HealthSyncState(
        permission: permission ?? this.permission,
        snapshot: snapshot ?? this.snapshot,
        lastSync: lastSync ?? this.lastSync,
        syncing: syncing ?? this.syncing,
        autoSync: autoSync ?? this.autoSync,
        error: clearError ? null : (error ?? this.error),
        indisponiveis: indisponiveis ?? this.indisponiveis,
        loading: loading ?? this.loading,
      );
}

class HealthSyncNotifier extends StateNotifier<HealthSyncState> {
  HealthSyncNotifier(this._ref) : super(const HealthSyncState()) {
    _load();
  }

  final Ref _ref;

  static const _kAutoSync = 'health_auto_sync';
  static const _kLastSync = 'health_last_sync';
  static const _kSnapshot = 'health_last_snapshot';
  static const _kLastBonusDay = 'health_last_bonus_day';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;

    final auto = p.getBool(_kAutoSync) ?? true;
    final lastStr = p.getString(_kLastSync);
    final snapStr = p.getString(_kSnapshot);

    HealthSnapshot? snap;
    if (snapStr != null) {
      try {
        snap = HealthSnapshot.fromMap(
            jsonDecode(snapStr) as Map<String, dynamic>);
      } catch (_) {/* ignora snapshot corrompido */}
    }

    final service = _ref.read(healthServiceProvider);
    final perm = await service.permissionStatus();
    if (!mounted) return;

    state = state.copyWith(
      permission: perm,
      autoSync: auto,
      snapshot: snap,
      lastSync: lastStr != null ? DateTime.tryParse(lastStr) : null,
      loading: false,
    );

    // Sincronização automática ao abrir, se habilitada.
    if (auto) await sync(silent: true);
  }

  Future<void> _persist() async {
    if (!mounted) return;
    final autoSync = state.autoSync;
    final lastSync = state.lastSync;
    final snapshot = state.snapshot;

    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    await p.setBool(_kAutoSync, autoSync);
    if (lastSync != null) {
      await p.setString(_kLastSync, lastSync.toIso8601String());
    }
    if (snapshot != null) {
      await p.setString(_kSnapshot, jsonEncode(snapshot.toMap()));
    }
  }

  Future<void> setAutoSync(bool value) async {
    state = state.copyWith(autoSync: value);
    await _persist();
    if (value) await sync(silent: true);
  }

  /// Solicita permissão à plataforma de saúde.
  Future<HealthPermission> requestPermission() async {
    final service = _ref.read(healthServiceProvider);
    final perm = await service.requestPermission();
    state = state.copyWith(permission: perm);
    if (perm == HealthPermission.concedida) await sync();
    return perm;
  }

  /// Sincronização (manual ou automática).
  ///
  /// `silent = true` não concede recompensas (evita farm ao abrir o app).
  Future<void> sync({bool silent = false}) async {
    if (state.syncing) return;
    if (!mounted) return;
    state = state.copyWith(syncing: true, clearError: true);

    final service = _ref.read(healthServiceProvider);
    final result = await service.read(DateTime.now());
    if (!mounted) return;

    if (!result.ok) {
      state = state.copyWith(
          syncing: false, error: result.error ?? 'Falha ao sincronizar.');
      return;
    }

    state = state.copyWith(
      syncing: false,
      snapshot: result.snapshot,
      lastSync: DateTime.now(),
      indisponiveis: result.metricasIndisponiveis,
    );
    await _persist();
    if (!mounted) return;

    // Alimenta os outros módulos com os dados sincronizados.
    await _propagate(result.snapshot!, silent: silent);
  }

  /// Integra os dados de saúde com missões, moedas, XP.
  Future<void> _propagate(HealthSnapshot snap, {required bool silent}) async {
    if (!mounted) return;
    final missions = _ref.read(missionsProvider.notifier);

    // Hidratação -> missão de água (progresso absoluto em copos de 250ml).
    final ml = snap.get(HealthMetric.hidratacaoMl);
    if (ml != null) {
      missions.setProgress(MissionEvent.copoDeAgua, (ml / 250).round());
    }

    // Peso registrado -> missão semanal.
    if (snap.has(HealthMetric.pesoKg)) {
      missions.report(MissionEvent.pesoRegistrado);
    }

    if (silent) return;

    // Recompensa por sincronizar manualmente.
    _ref.read(gamificationProvider.notifier).addXp(HealthRewards.xpPorSync);
    _ref.read(rewardsProvider.notifier).earn(HealthRewards.moedasPorSync);

    // Bônus diário por meta de passos (1x por dia).
    final passos = snap.get(HealthMetric.passos);
    if (passos != null && passos >= HealthRewards.passosParaBonus) {
      final p = await SharedPreferences.getInstance();
      final hoje = '${snap.date.year}-${snap.date.month}-${snap.date.day}';
      if (p.getString(_kLastBonusDay) != hoje) {
        _ref
            .read(gamificationProvider.notifier)
            .addXp(HealthRewards.xpBonusPassos);
        _ref
            .read(rewardsProvider.notifier)
            .earn(HealthRewards.moedasBonusPassos);
        await p.setString(_kLastBonusDay, hoje);
      }
    }
  }

  /// Ponto de extensão para o Firestore (no-op em modo local).
  void syncToCloud() {
    // if (FirebaseService.isReady) { /* users/{uid}/health */ }
  }
}

final healthSyncProvider =
    StateNotifierProvider<HealthSyncNotifier, HealthSyncState>(
        (ref) => HealthSyncNotifier(ref));

/// Snapshot resumido para o Dashboard (Home) — null se nunca sincronizou.
final healthSummaryProvider = Provider<HealthSnapshot?>((ref) {
  return ref.watch(healthSyncProvider).snapshot;
});
