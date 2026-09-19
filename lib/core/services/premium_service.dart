import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';

/// Estado de assinatura do usuário.
@immutable
class PremiumStatus {
  const PremiumStatus({
    required this.isPremium,
    this.plan,
    this.expiresAt,
  });

  final bool isPremium;
  final String? plan; // 'monthly' | 'yearly' | 'coupon' | ...
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

/// Erro explícito quando a loja ainda não está ligada — a UI mostra a
/// mensagem e **nenhuma** cobrança / desbloqueio falso acontece.
class BillingNotConfiguredException implements Exception {
  const BillingNotConfiguredException([
    this.message =
        'Assinaturas ainda não estão disponíveis na loja. Nenhuma cobrança foi realizada.',
  ]);
  final String message;
  @override
  String toString() => message;
}

/// Usuário cancelou o sheet da loja — não é falha; a UI só fecha o loading.
class PurchaseCancelledException implements Exception {
  const PurchaseCancelledException([
    this.message = 'Compra cancelada.',
  ]);
  final String message;
  @override
  String toString() => message;
}

bool _isPurchaseCancelled(Object error) {
  if (error is PlatformException) {
    try {
      return PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError;
    } catch (_) {
      // Fallback se o helper mudar de assinatura.
      final code = error.code.toLowerCase();
      final msg = (error.message ?? '').toLowerCase();
      return code.contains('purchase_cancelled') ||
          code.contains('cancelled') ||
          msg.contains('purchase was cancelled') ||
          msg.contains('user cancelled');
    }
  }
  return false;
}

DateTime? _parseExpiry(dynamic rawExp) {
  if (rawExp == null) return null;
  if (rawExp is String) return DateTime.tryParse(rawExp);
  try {
    return (rawExp as dynamic).toDate() as DateTime?;
  } catch (_) {
    return null;
  }
}

Future<PremiumStatus> subscriptionStatusForUid(String uid) async {
  if (!FirebaseService.isReady || uid.isEmpty) return PremiumStatus.free;
  try {
    final doc = await FirebaseFirestore.instance
        .collection(AppConstants.cSubscriptions)
        .doc(uid)
        .get();
    final data = doc.data();
    if (data == null) return PremiumStatus.free;
    final status = (data['status'] as String? ?? '').toLowerCase();
    if (status == 'active') {
      return PremiumStatus(
        isPremium: true,
        plan: data['plan'] as String?,
        expiresAt: _parseExpiry(data['nextBillingAt'] ?? data['expiresAt']),
      );
    }
    if (status == 'trial' || status == 'trialing') {
      final end = _parseExpiry(data['trialEndsAt']);
      if (end != null && end.isAfter(DateTime.now())) {
        return PremiumStatus(isPremium: true, plan: 'trial', expiresAt: end);
      }
    }
  } catch (_) {}
  return PremiumStatus.free;
}

PremiumStatus _statusFromFirestoreMap(Map<String, dynamic>? data) {
  if (data == null) return PremiumStatus.free;
  final active = data['isPremium'] == true;
  if (!active) return PremiumStatus.free;
  final plan = data['premiumPlan'] as String?;
  final exp = _parseExpiry(data['premiumExpiresAt']);
  if (exp != null && exp.isBefore(DateTime.now())) {
    return PremiumStatus.free;
  }
  return PremiumStatus(isPremium: true, plan: plan, expiresAt: exp);
}

/// Implementação de desenvolvimento — persiste em SharedPreferences.
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

/// Lê `isPremium` + `premiumExpiresAt` do Firestore (cupons / sync server-side).
class FirestorePremiumService implements PremiumService {
  static const _legacyKeys = [
    'premium_active',
    'premium_plan',
    'premium_expires',
  ];

  Future<void> _clearLegacyLocalGrants() async {
    try {
      final p = await SharedPreferences.getInstance();
      for (final k in _legacyKeys) {
        await p.remove(k);
      }
    } catch (_) {}
  }

  @override
  Future<PremiumStatus> current() async {
    await _clearLegacyLocalGrants();
    if (!FirebaseService.isReady) return PremiumStatus.free;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return PremiumStatus.free;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(AppConstants.cUsers)
          .doc(uid)
          .get();
      final fromUser = _statusFromFirestoreMap(doc.data());
      final fromSub = await subscriptionStatusForUid(uid);
      if (fromUser.isPremium) return fromUser;
      return fromSub;
    } catch (_) {
      return PremiumStatus.free;
    }
  }

  @override
  Future<PremiumStatus> subscribe(String planId) async {
    throw const BillingNotConfiguredException(
      'Cobrança real desativada nesta fase. Nenhuma compra foi processada. '
      'Use o teste grátis de 7 dias ou aguarde App Store / Google Play.',
    );
  }

  @override
  Future<PremiumStatus> restore() => current();
}

/// RevenueCat (Play Billing / StoreKit) + OR com status Firestore (cupons).
class RevenueCatPremiumService implements PremiumService {
  RevenueCatPremiumService();

  static bool _configured = false;

  /// Chamar uma vez após Firebase.init quando [AppConfig.billingConfigured].
  static Future<void> ensureConfigured() async {
    if (_configured || !AppConfig.billingConfigured) return;
    if (kIsWeb) return;

    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? (AppConfig.revenueCatIosKey.isNotEmpty
            ? AppConfig.revenueCatIosKey
            : AppConfig.revenueCatAndroidKey)
        : (AppConfig.revenueCatAndroidKey.isNotEmpty
            ? AppConfig.revenueCatAndroidKey
            : AppConfig.revenueCatIosKey);
    if (apiKey.isEmpty) return;

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
    final config = PurchasesConfiguration(apiKey);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) config.appUserID = uid;
    await Purchases.configure(config);
    _configured = true;
  }

  Future<void> _ensureConfigured() async {
    if (!_configured) await ensureConfigured();
    if (!_configured) {
      throw const BillingNotConfiguredException(
        'Chaves RevenueCat ausentes. Passe --dart-define=REVENUECAT_ANDROID_KEY=... '
        '(e/ou REVENUECAT_IOS_KEY).',
      );
    }
  }

  PremiumStatus _fromCustomerInfo(CustomerInfo info) {
    final ent = info.entitlements.all[AppConfig.premiumEntitlement];
    if (ent == null || !ent.isActive) return PremiumStatus.free;
    DateTime? exp;
    if (ent.expirationDate != null) {
      exp = DateTime.tryParse(ent.expirationDate!);
    }
    final productId = ent.productIdentifier;
    String? plan;
    if (productId.contains('anual') || productId.contains('yearly')) {
      plan = 'yearly';
    } else if (productId.contains('trimestral') ||
        productId.contains('quarterly')) {
      plan = 'quarterly';
    } else if (productId.contains('mensal') || productId.contains('monthly')) {
      plan = 'monthly';
    } else {
      plan = productId;
    }
    return PremiumStatus(isPremium: true, plan: plan, expiresAt: exp);
  }

  Future<PremiumStatus> _firestoreStatus() async {
    return FirestorePremiumService().current();
  }

  PremiumStatus _merge(PremiumStatus a, PremiumStatus b) {
    if (!a.isPremium && !b.isPremium) return PremiumStatus.free;
    if (a.isPremium && !b.isPremium) return a;
    if (!a.isPremium && b.isPremium) return b;
    // Ambos ativos: pega a expiração mais longe.
    DateTime? exp;
    if (a.expiresAt != null && b.expiresAt != null) {
      exp = a.expiresAt!.isAfter(b.expiresAt!) ? a.expiresAt : b.expiresAt;
    } else {
      exp = a.expiresAt ?? b.expiresAt;
    }
    return PremiumStatus(
      isPremium: true,
      plan: a.plan ?? b.plan,
      expiresAt: exp,
    );
  }

  @override
  Future<PremiumStatus> current() async {
    final firestore = await _firestoreStatus();
    if (!AppConfig.billingConfigured) return firestore;
    try {
      await _ensureConfigured();
      final info = await Purchases.getCustomerInfo();
      return _merge(_fromCustomerInfo(info), firestore);
    } catch (e) {
      debugPrint('RevenueCat current falhou: $e');
      return firestore;
    }
  }

  String _productIdFor(String planId) {
    return switch (planId) {
      'yearly' || 'anual' => AppConfig.productYearly,
      'quarterly' || 'trimestral' => AppConfig.productQuarterly,
      _ => AppConfig.productMonthly,
    };
  }

  @override
  Future<PremiumStatus> subscribe(String planId) async {
    if (!AppConfig.paymentsEnabled) {
      throw const BillingNotConfiguredException(
        'Cobrança real desativada (PAYMENTS_ENABLED=false). '
        'Nenhuma compra foi processada.',
      );
    }
    if (planId == 'yearly' || planId == 'anual') {
      throw const BillingNotConfiguredException(
        'Plano anual — em breve. O valor ainda não foi definido.',
      );
    }
    await _ensureConfigured();
    final productId = _productIdFor(planId);

    try {
      final products = await Purchases.getProducts([productId]);
      if (products.isEmpty) {
        final offerings = await Purchases.getOfferings();
        final pkg = switch (planId) {
          'yearly' || 'anual' => offerings.current?.annual,
          'quarterly' || 'trimestral' => offerings.current?.threeMonth,
          _ => offerings.current?.monthly,
        };
        if (pkg == null) {
          throw BillingNotConfiguredException(
            'Produto/oferta "$productId" não encontrado no RevenueCat. '
            'Confira IDs na Play Console / App Store Connect.',
          );
        }
        final info = await Purchases.purchasePackage(pkg);
        return _merge(_fromCustomerInfo(info), await _firestoreStatus());
      }

      final info = await Purchases.purchaseStoreProduct(products.first);
      return _merge(_fromCustomerInfo(info), await _firestoreStatus());
    } on BillingNotConfiguredException {
      rethrow;
    } on PurchaseCancelledException {
      rethrow;
    } catch (e) {
      if (_isPurchaseCancelled(e)) {
        throw const PurchaseCancelledException();
      }
      rethrow;
    }
  }

  @override
  Future<PremiumStatus> restore() async {
    await _ensureConfigured();
    try {
      final info = await Purchases.restorePurchases();
      return _merge(_fromCustomerInfo(info), await _firestoreStatus());
    } catch (e) {
      if (_isPurchaseCancelled(e)) {
        throw const PurchaseCancelledException();
      }
      rethrow;
    }
  }
}

/// Injeção do serviço — RevenueCat quando chaves via --dart-define; senão Firestore.
final premiumServiceProvider = Provider<PremiumService>((ref) {
  if (AppConfig.billingConfigured) {
    return RevenueCatPremiumService();
  }
  return FirestorePremiumService();
});

/// Estado observável do premium (usado pela UI para bloquear/desbloquear).
class PremiumNotifier extends StateNotifier<PremiumStatus> {
  PremiumNotifier(this._service) : super(PremiumStatus.free) {
    _load();
  }
  final PremiumService _service;

  Future<void> _load() async {
    if (AppConstants.debugUnlockAllPremiumContent) {
      state = const PremiumStatus(isPremium: true, plan: 'auditoria');
      return;
    }
    state = await _service.current();
  }

  Future<void> refresh() async {
    if (AppConstants.debugUnlockAllPremiumContent) {
      state = const PremiumStatus(isPremium: true, plan: 'auditoria');
      return;
    }
    state = await _service.current();
  }

  Future<PremiumStatus> subscribe(String planId) async {
    if (planId == 'yearly' || planId == 'anual') {
      throw const BillingNotConfiguredException(
        'Plano anual — em breve. O valor ainda não foi definido.',
      );
    }
    if (!AppConfig.paymentsEnabled) {
      throw const BillingNotConfiguredException(
        'Cobrança real desativada (PAYMENTS_ENABLED=false). '
        'Nenhuma compra foi processada.',
      );
    }
    final status = await _service.subscribe(planId);
    state = status;
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
