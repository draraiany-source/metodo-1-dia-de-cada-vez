import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Estado de assinatura do usuário.
@immutable
class PremiumStatus {
  const PremiumStatus({
    required this.isPremium,
    this.plan,
    this.expiresAt,
  });

  final bool isPremium;
  final String? plan; // 'monthly' | 'yearly'
  final DateTime? expiresAt;

  static const free = PremiumStatus(isPremium: false);

  PremiumStatus copyWith({bool? isPremium, String? plan, DateTime? expiresAt}) =>
      PremiumStatus(
        isPremium: isPremium ?? this.isPremium,
        plan: plan ?? this.plan,
        expiresAt: expiresAt ?? this.expiresAt,
      );
}

/// Contrato de billing. Trocar a implementação por RevenueCat em produção
/// sem alterar a UI (que fala apenas com esta interface).
abstract class PremiumService {
  Future<PremiumStatus> current();
  Future<PremiumStatus> subscribe(String planId);
  Future<PremiumStatus> restore();
}

/// Implementação local (mock) — persiste em SharedPreferences.
///
/// Permite testar todo o fluxo de paywall/desbloqueio SEM chaves de loja.
/// Em produção, substitua por [RevenueCatPremiumService] (ver comentário abaixo).
class LocalPremiumService implements PremiumService {
  static const _kPremium = 'premium_active';
  static const _kPlan = 'premium_plan';
  static const _kExpires = 'premium_expires';

  @override
  Future<PremiumStatus> current() async {
    final p = await SharedPreferences.getInstance();
    final active = p.getBool(_kPremium) ?? false;
    if (!active) return PremiumStatus.free;
    final expStr = p.getString(_kExpires);
    final exp = expStr != null ? DateTime.tryParse(expStr) : null;
    // expira automaticamente
    if (exp != null && exp.isBefore(DateTime.now())) {
      await p.setBool(_kPremium, false);
      return PremiumStatus.free;
    }
    return PremiumStatus(isPremium: true, plan: p.getString(_kPlan), expiresAt: exp);
  }

  @override
  Future<PremiumStatus> subscribe(String planId) async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final exp = planId == 'yearly'
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));
    await p.setBool(_kPremium, true);
    await p.setString(_kPlan, planId);
    await p.setString(_kExpires, exp.toIso8601String());
    return PremiumStatus(isPremium: true, plan: planId, expiresAt: exp);
  }

  @override
  Future<PremiumStatus> restore() => current();
}

/// ---------------------------------------------------------------------------
/// PRODUÇÃO — RevenueCat (descomente após configurar as chaves).
/// 1) Adicione `purchases_flutter: ^8.x` ao pubspec.
/// 2) Configure produtos/entitlement "premium" no RevenueCat + lojas.
/// 3) Troque o provider abaixo para retornar RevenueCatPremiumService().
///
/// class RevenueCatPremiumService implements PremiumService {
///   RevenueCatPremiumService(String apiKey) {
///     Purchases.configure(PurchasesConfiguration(apiKey));
///   }
///   @override Future<PremiumStatus> current() async {
///     final info = await Purchases.getCustomerInfo();
///     final active = info.entitlements.active.containsKey('premium');
///     return PremiumStatus(isPremium: active);
///   }
///   @override Future<PremiumStatus> subscribe(String planId) async {
///     final offerings = await Purchases.getOfferings();
///     final pkg = offerings.current!.availablePackages
///         .firstWhere((p) => p.identifier.contains(planId));
///     final info = await Purchases.purchasePackage(pkg);
///     return PremiumStatus(
///       isPremium: info.entitlements.active.containsKey('premium'),
///       plan: planId,
///     );
///   }
///   @override Future<PremiumStatus> restore() async {
///     final info = await Purchases.restorePurchases();
///     return PremiumStatus(isPremium: info.entitlements.active.containsKey('premium'));
///   }
/// }
/// ---------------------------------------------------------------------------

/// Injeção do serviço.
///
/// Quando as chaves do RevenueCat forem injetadas via `--dart-define`
/// (`AppConfig.billingConfigured == true`), troque o retorno por
/// `RevenueCatPremiumService(...)` — a UI não muda, pois fala só com a interface.
final premiumServiceProvider = Provider<PremiumService>((ref) {
  // if (AppConfig.billingConfigured) return RevenueCatPremiumService();
  return LocalPremiumService();
});

/// Estado observável do premium (usado pela UI para bloquear/desbloquear).
class PremiumNotifier extends StateNotifier<PremiumStatus> {
  PremiumNotifier(this._service) : super(PremiumStatus.free) {
    _load();
  }
  final PremiumService _service;

  Future<void> _load() async {
    // Auditoria/teste: libera tudo sem tocar em nenhuma tela ou lógica de
    // gate — cada tela continua checando `premiumStatusProvider` do jeito
    // que sempre checou; só a origem do valor muda aqui, centralmente.
    if (AppConstants.debugUnlockAllPremiumContent) {
      state = const PremiumStatus(isPremium: true, plan: 'auditoria');
      return;
    }
    state = await _service.current();
  }

  Future<PremiumStatus> subscribe(String planId) async {
    state = await _service.subscribe(planId);
    return state;
  }

  Future<PremiumStatus> restore() async {
    state = await _service.restore();
    return state;
  }
}

final premiumStatusProvider =
    StateNotifierProvider<PremiumNotifier, PremiumStatus>(
        (ref) => PremiumNotifier(ref.watch(premiumServiceProvider)));
