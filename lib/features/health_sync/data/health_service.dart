import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

import '../domain/health_models.dart';

/// Contrato de acesso aos dados de saúde da plataforma.
///
/// A UI fala **apenas** com esta interface. Trocar de implementação
/// (local → pacote `health`) não exige mudança em nenhuma tela.
abstract class HealthService {
  /// Plataforma de saúde correspondente ao sistema atual.
  HealthSource get source;

  /// Se a plataforma está disponível neste dispositivo.
  Future<bool> isAvailable();

  /// Status atual da permissão.
  Future<HealthPermission> permissionStatus();

  /// Pede permissão ao usuário. Retorna o status resultante.
  Future<HealthPermission> requestPermission();

  /// Lê os dados de saúde do dia informado.
  Future<SyncResult> read(DateTime day);

  /// Escreve um valor de volta na plataforma (ex.: peso, hidratação).
  /// Retorna false se não suportado.
  Future<bool> write(HealthMetric metric, double value, DateTime when);
}

/// Implementação **ativa hoje**: não depende de nenhum pacote nativo.
///
/// Ela não inventa dados. Compõe o snapshot a partir dos **registros manuais**
/// que o próprio app já possui (água, peso, treinos), garantindo que o app
/// funcione integralmente mesmo sem permissão ou sem Health Connect/HealthKit.
///
/// É exatamente o comportamento pedido: "caso o usuário não conceda permissão,
/// o aplicativo continua funcionando normalmente com os registros manuais".
class LocalHealthService implements HealthService {
  LocalHealthService({
    this.coposDeAgua = 0,
    this.pesoKg,
    this.imc,
    this.treinosHoje = 0,
    this.minutosAtivos = 0,
  });

  /// Dados vindos dos módulos manuais do app.
  final int coposDeAgua;
  final double? pesoKg;
  final double? imc;
  final int treinosHoje;
  final int minutosAtivos;

  @override
  HealthSource get source => HealthSource.manual;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<HealthPermission> permissionStatus() async =>
      HealthPermission.indisponivel;

  @override
  Future<HealthPermission> requestPermission() async =>
      HealthPermission.indisponivel;

  @override
  Future<SyncResult> read(DateTime day) async {
    final valores = <HealthMetric, double>{};

    if (coposDeAgua > 0) {
      valores[HealthMetric.hidratacaoMl] = coposDeAgua * 250.0;
    }
    if (pesoKg != null) valores[HealthMetric.pesoKg] = pesoKg!;
    if (imc != null) valores[HealthMetric.imc] = imc!;
    if (treinosHoje > 0) valores[HealthMetric.treinos] = treinosHoje.toDouble();
    if (minutosAtivos > 0) {
      valores[HealthMetric.minutosAtivos] = minutosAtivos.toDouble();
    }

    // Métricas que só a plataforma de saúde fornece.
    const indisponiveis = [
      HealthMetric.passos,
      HealthMetric.distanciaKm,
      HealthMetric.caloriasKcal,
      HealthMetric.frequenciaCardiaca,
    ];

    return SyncResult(
      ok: true,
      snapshot: HealthSnapshot(
        date: day,
        source: HealthSource.manual,
        valores: valores,
      ),
      metricasIndisponiveis: indisponiveis,
    );
  }

  @override
  Future<bool> write(HealthMetric metric, double value, DateTime when) async =>
      false;
}

/// Detecta qual plataforma de saúde seria usada neste dispositivo.
///
/// Usa apenas `package:flutter/foundation.dart` (kIsWeb +
/// defaultTargetPlatform) — nunca `dart:io` — para que a detecção
/// funcione em Android, iOS **e** Flutter Web sem lançar exceções.
HealthSource detectPlatformSource() {
  if (kIsWeb) return HealthSource.manual;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return HealthSource.healthConnect;
    case TargetPlatform.iOS:
      return HealthSource.appleHealth;
    default:
      return HealthSource.manual;
  }
}

// =============================================================================
// IMPLEMENTAÇÃO REAL — Health Connect / Google Fit / Apple Health
// =============================================================================
//
// Está comentada porque o pacote `health` ainda não foi adicionado ao pubspec.
// Ela é a implementação definitiva: descomente e o app passa a ler dados reais,
// **sem alterar nenhuma tela** (a UI depende só da interface HealthService).
//
// ---------------------------------------------------------------------------
// PASSO 1 — pubspec.yaml
//   dependencies:
//     health: ^11.1.0        # Health Connect (Android) + HealthKit (iOS)
//   depois: flutter pub get
//
// PASSO 2 — Android (android/app/src/main/AndroidManifest.xml)
//   Ver release_config/health_permissions.md (gerado por este módulo).
//   Resumo: permissões READ_STEPS, READ_DISTANCE, READ_TOTAL_CALORIES_BURNED,
//   READ_HEART_RATE, READ_WEIGHT, READ_EXERCISE, READ_HYDRATION +
//   a activity de rationale do Health Connect. minSdk 26.
//
// PASSO 3 — iOS (ios/Runner/Info.plist + Xcode)
//   Ative a capability "HealthKit" no Xcode e adicione:
//   NSHealthShareUsageDescription / NSHealthUpdateUsageDescription.
//
// PASSO 4 — troque o provider:
//   Em health_providers.dart, faça `healthServiceProvider` retornar
//   `PlatformHealthService()` em vez de `LocalHealthService(...)`.
// ---------------------------------------------------------------------------
//
// import 'package:health/health.dart';
//
// class PlatformHealthService implements HealthService {
//   PlatformHealthService() : _health = Health();
//   final Health _health;
//
//   static const _types = <HealthDataType>[
//     HealthDataType.STEPS,
//     HealthDataType.DISTANCE_DELTA,
//     HealthDataType.TOTAL_CALORIES_BURNED,
//     HealthDataType.HEART_RATE,
//     HealthDataType.WEIGHT,
//     HealthDataType.BODY_MASS_INDEX,
//     HealthDataType.WORKOUT,
//     HealthDataType.EXERCISE_TIME,
//     HealthDataType.WATER,
//   ];
//
//   @override
//   HealthSource get source => detectPlatformSource();
//
//   @override
//   Future<bool> isAvailable() async {
//     if (Platform.isAndroid) {
//       final status = await _health.getHealthConnectSdkStatus();
//       return status == HealthConnectSdkStatus.sdkAvailable;
//     }
//     return Platform.isIOS;
//   }
//
//   @override
//   Future<HealthPermission> permissionStatus() async {
//     if (!await isAvailable()) return HealthPermission.indisponivel;
//     final granted = await _health.hasPermissions(_types) ?? false;
//     return granted ? HealthPermission.concedida : HealthPermission.naoSolicitada;
//   }
//
//   @override
//   Future<HealthPermission> requestPermission() async {
//     if (!await isAvailable()) return HealthPermission.indisponivel;
//     final ok = await _health.requestAuthorization(_types);
//     return ok ? HealthPermission.concedida : HealthPermission.negada;
//   }
//
//   @override
//   Future<SyncResult> read(DateTime day) async {
//     final start = DateTime(day.year, day.month, day.day);
//     final end = start.add(const Duration(days: 1));
//     final indisponiveis = <HealthMetric>[];
//     final valores = <HealthMetric, double>{};
//
//     try {
//       final steps = await _health.getTotalStepsInInterval(start, end);
//       if (steps != null) valores[HealthMetric.passos] = steps.toDouble();
//
//       final points = await _health.getHealthDataFromTypes(
//         types: _types,
//         startTime: start,
//         endTime: end,
//       );
//
//       double sum(HealthDataType t) => points
//           .where((p) => p.type == t)
//           .fold(0.0, (s, p) => s + (p.value as NumericHealthValue).numericValue);
//
//       double? last(HealthDataType t) {
//         final f = points.where((p) => p.type == t).toList();
//         if (f.isEmpty) return null;
//         f.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
//         return (f.last.value as NumericHealthValue).numericValue.toDouble();
//       }
//
//       final dist = sum(HealthDataType.DISTANCE_DELTA);
//       if (dist > 0) valores[HealthMetric.distanciaKm] = dist / 1000;
//
//       final kcal = sum(HealthDataType.TOTAL_CALORIES_BURNED);
//       if (kcal > 0) valores[HealthMetric.caloriasKcal] = kcal;
//
//       final hr = last(HealthDataType.HEART_RATE);
//       if (hr != null) {
//         valores[HealthMetric.frequenciaCardiaca] = hr;
//       } else {
//         indisponiveis.add(HealthMetric.frequenciaCardiaca);
//       }
//
//       final peso = last(HealthDataType.WEIGHT);
//       if (peso != null) valores[HealthMetric.pesoKg] = peso;
//
//       final imc = last(HealthDataType.BODY_MASS_INDEX);
//       if (imc != null) valores[HealthMetric.imc] = imc;
//
//       final treinos = points.where((p) => p.type == HealthDataType.WORKOUT).length;
//       if (treinos > 0) valores[HealthMetric.treinos] = treinos.toDouble();
//
//       final ativo = sum(HealthDataType.EXERCISE_TIME);
//       if (ativo > 0) valores[HealthMetric.minutosAtivos] = ativo;
//
//       final agua = sum(HealthDataType.WATER);
//       if (agua > 0) {
//         valores[HealthMetric.hidratacaoMl] = agua * 1000; // litros -> ml
//       } else {
//         indisponiveis.add(HealthMetric.hidratacaoMl);
//       }
//
//       return SyncResult(
//         ok: true,
//         snapshot: HealthSnapshot(date: day, source: source, valores: valores),
//         metricasIndisponiveis: indisponiveis,
//       );
//     } catch (e) {
//       return SyncResult(ok: false, error: e.toString());
//     }
//   }
//
//   @override
//   Future<bool> write(HealthMetric metric, double value, DateTime when) async {
//     final type = switch (metric) {
//       HealthMetric.pesoKg => HealthDataType.WEIGHT,
//       HealthMetric.hidratacaoMl => HealthDataType.WATER,
//       _ => null,
//     };
//     if (type == null) return false;
//     final v = metric == HealthMetric.hidratacaoMl ? value / 1000 : value;
//     return _health.writeHealthData(
//       value: v,
//       type: type,
//       startTime: when,
//       endTime: when,
//     );
//   }
// }
