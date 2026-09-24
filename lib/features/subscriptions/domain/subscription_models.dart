import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';

/// Ciclo de vida da assinatura (produto).
enum SubscriptionLifecycle {
  free,
  trial,
  active,
  cancelled,
  expired,
  pending,
  billingIssue,
}

extension SubscriptionLifecycleX on SubscriptionLifecycle {
  String get firestoreValue => switch (this) {
        SubscriptionLifecycle.free => 'free',
        SubscriptionLifecycle.trial => 'trial',
        SubscriptionLifecycle.active => 'active',
        SubscriptionLifecycle.cancelled => 'cancelled',
        SubscriptionLifecycle.expired => 'expired',
        SubscriptionLifecycle.pending => 'pending',
        SubscriptionLifecycle.billingIssue => 'billing_issue',
      };

  String get labelPt => switch (this) {
        SubscriptionLifecycle.free => 'Gratuito',
        SubscriptionLifecycle.trial => 'Teste gratuito',
        SubscriptionLifecycle.active => 'Ativo',
        SubscriptionLifecycle.cancelled => 'Cancelado',
        SubscriptionLifecycle.expired => 'Expirado',
        SubscriptionLifecycle.pending => 'Pendente',
        SubscriptionLifecycle.billingIssue => 'Pagamento com problema',
      };

  static SubscriptionLifecycle parse(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'trial' || 'trialing' || 'teste' => SubscriptionLifecycle.trial,
      'active' || 'ativo' => SubscriptionLifecycle.active,
      'cancelled' || 'canceled' || 'cancelado' =>
        SubscriptionLifecycle.cancelled,
      'expired' || 'expirado' => SubscriptionLifecycle.expired,
      'pending' || 'pendente' => SubscriptionLifecycle.pending,
      'billing_issue' || 'past_due' || 'problema' =>
        SubscriptionLifecycle.billingIssue,
      _ => SubscriptionLifecycle.free,
    };
  }
}

enum CatalogPlan { trial, monthly, quarterly, yearly }

extension CatalogPlanX on CatalogPlan {
  String get id => switch (this) {
        CatalogPlan.trial => 'trial',
        CatalogPlan.monthly => 'monthly',
        CatalogPlan.quarterly => 'quarterly',
        CatalogPlan.yearly => 'yearly',
      };

  String get labelPt => switch (this) {
        CatalogPlan.trial => 'Teste grátis',
        CatalogPlan.monthly => 'Plano Mensal',
        CatalogPlan.quarterly => 'Plano Trimestral',
        CatalogPlan.yearly => 'Plano Anual',
      };

  String get storeProductId => switch (this) {
        CatalogPlan.trial => '',
        CatalogPlan.monthly => AppConfig.productMonthly,
        CatalogPlan.quarterly => AppConfig.productQuarterly,
        CatalogPlan.yearly => AppConfig.productYearly,
      };

  static CatalogPlan parse(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'monthly' || 'mensal' => CatalogPlan.monthly,
      'quarterly' || 'trimestral' => CatalogPlan.quarterly,
      'yearly' || 'anual' || 'annual' => CatalogPlan.yearly,
      'trial' || 'teste' => CatalogPlan.trial,
      _ => CatalogPlan.trial,
    };
  }
}

class CatalogPlanInfo {
  const CatalogPlanInfo({
    required this.plan,
    required this.benefits,
    this.fallbackPrice,
    this.periodLabel = '',
    this.highlight = false,
    this.comingSoon = false,
    this.badge,
    this.equivalentMonthly,
    this.savingsVsMonthly,
    this.savingsComparisonLabel,
    this.billingClarity,
  });

  final CatalogPlan plan;
  final List<String> benefits;
  final double? fallbackPrice;
  final String periodLabel;
  final bool highlight;
  final bool comingSoon;
  final String? badge;
  final double? equivalentMonthly;
  final double? savingsVsMonthly;
  /// Ex.: "comparado a 3 mensalidades" / "comparado a 12 mensalidades".
  final String? savingsComparisonLabel;
  /// Texto curto lembrando a periodicidade da cobrança (ex. anual).
  final String? billingClarity;

  String? get fallbackPriceLabel {
    final p = fallbackPrice;
    if (p == null) return null;
    return 'R\$ ${_formatBrl(p)}';
  }

  static String _formatBrl(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final dec = parts[1];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      final fromEnd = intPart.length - i;
      if (i > 0 && fromEnd % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return '${buf.toString()},$dec';
  }
}

/// Catálogo oficial. Preço da loja tem prioridade quando [PAYMENTS_ENABLED].
class PlanCatalog {
  PlanCatalog._();

  static const trialDays = 7;

  static const benefits = [
    'acesso completo ao aplicativo',
    'treinos',
    'desafios semanais',
    'acompanhamento de evolução',
    'controle de hidratação',
    'metas',
    'conteúdos exclusivos',
    'áudios motivacionais',
    'atualizações futuras',
  ];

  static const monthly = CatalogPlanInfo(
    plan: CatalogPlan.monthly,
    fallbackPrice: AppConstants.premiumMonthlyPrice,
    periodLabel: 'por mês',
    benefits: benefits,
  );

  static const quarterly = CatalogPlanInfo(
    plan: CatalogPlan.quarterly,
    fallbackPrice: AppConstants.premiumQuarterlyPrice,
    periodLabel: 'a cada 3 meses',
    highlight: true,
    badge: 'MAIS ESCOLHIDO',
    equivalentMonthly: AppConstants.premiumQuarterlyEquivalentMonthly,
    savingsVsMonthly: AppConstants.premiumQuarterlySavingsVsMonthly,
    savingsComparisonLabel: 'comparado a 3 mensalidades',
    billingClarity: 'Cobrança a cada 3 meses.',
    benefits: benefits,
  );

  static const yearly = CatalogPlanInfo(
    plan: CatalogPlan.yearly,
    fallbackPrice: AppConstants.premiumYearlyPrice,
    periodLabel: 'por ano',
    equivalentMonthly: AppConstants.premiumYearlyEquivalentMonthly,
    savingsVsMonthly: AppConstants.premiumYearlySavingsVsMonthly,
    savingsComparisonLabel: 'comparado a 12 mensalidades',
    billingClarity:
        'Cobrança anual. O valor mensal abaixo é só equivalência.',
    benefits: benefits,
  );

  static const trial = CatalogPlanInfo(
    plan: CatalogPlan.trial,
    benefits: benefits,
  );

  static const allPaid = [monthly, quarterly, yearly];
}

class SubscriptionRecord {
  const SubscriptionRecord({
    required this.userId,
    required this.plan,
    required this.status,
    this.amount,
    this.currency = 'BRL',
    this.startedAt,
    this.nextBillingAt,
    this.trialStartedAt,
    this.trialEndsAt,
    this.trialUsed = false,
    this.platform = 'none',
    this.productId = '',
    this.source = 'catalog',
  });

  final String userId;
  final CatalogPlan plan;
  final SubscriptionLifecycle status;
  final double? amount;
  final String currency;
  final DateTime? startedAt;
  final DateTime? nextBillingAt;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final bool trialUsed;
  final String platform;
  final String productId;
  final String source;

  bool get trialActive {
    if (status != SubscriptionLifecycle.trial) return false;
    final end = trialEndsAt;
    return end != null && end.isAfter(DateTime.now());
  }

  bool get paidActive => status == SubscriptionLifecycle.active;

  bool get hasPremiumAccess => trialActive || paidActive;

  String get platformLabel => switch (platform) {
        'apple' || 'ios' || 'app_store' => 'Apple App Store',
        'google' || 'android' || 'play' => 'Google Play',
        'coupon' => 'Cupom',
        'admin' => 'Administrador (teste)',
        _ => 'Ainda não contratado na loja',
      };

  String get planLabel => plan.labelPt;

  String? get amountLabel {
    if (amount == null) return null;
    return 'R\$ ${amount!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  factory SubscriptionRecord.free(String userId) => SubscriptionRecord(
        userId: userId,
        plan: CatalogPlan.trial,
        status: SubscriptionLifecycle.free,
      );

  factory SubscriptionRecord.fromMap(String userId, Map<String, dynamic> m) {
    return SubscriptionRecord(
      userId: (m['userId'] as String?) ?? userId,
      plan: CatalogPlanX.parse(m['plan'] as String?),
      status: SubscriptionLifecycleX.parse(m['status'] as String?),
      amount: (m['amount'] as num?)?.toDouble(),
      currency: (m['currency'] as String?) ?? 'BRL',
      startedAt: _toDate(m['startedAt'] ?? m['trialStartedAt']),
      nextBillingAt: _toDate(m['nextBillingAt']),
      trialStartedAt: _toDate(m['trialStartedAt'] ?? m['startedAt']),
      trialEndsAt: _toDate(m['trialEndsAt']),
      trialUsed: m['trialUsed'] == true,
      platform: (m['platform'] as String?) ?? 'none',
      productId: (m['productId'] as String?) ?? '',
      source: (m['source'] as String?) ?? 'catalog',
    );
  }

  Map<String, dynamic> toTrialCreateMap() {
    final now = DateTime.now();
    final end = now.add(const Duration(days: PlanCatalog.trialDays));
    return {
      'userId': userId,
      'plan': 'trial',
      'status': 'trial',
      'trialUsed': true,
      'startedAt': now.toIso8601String(),
      'trialStartedAt': now.toIso8601String(),
      'trialEndsAt': end.toIso8601String(),
      'platform': 'none',
      'source': 'trial',
      'productId': '',
    };
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    try {
      return (raw as dynamic).toDate() as DateTime?;
    } catch (_) {
      return null;
    }
  }
}

/// Acesso efetivo: loja/cupom OU teste válido. Nunca só o frontend.
bool resolveHasPremiumAccess({
  required bool userFlagPremium,
  required DateTime? userExpiresAt,
  required SubscriptionRecord? subscription,
  bool debugUnlock = false,
}) {
  if (debugUnlock) return true;
  if (userFlagPremium) {
    if (userExpiresAt == null || userExpiresAt.isAfter(DateTime.now())) {
      return true;
    }
  }
  return subscription?.hasPremiumAccess ?? false;
}

SubscriptionLifecycle resolveLifecycle({
  required bool userFlagPremium,
  required DateTime? userExpiresAt,
  required SubscriptionRecord? subscription,
}) {
  final now = DateTime.now();
  if (subscription != null) {
    if (subscription.status == SubscriptionLifecycle.billingIssue) {
      return SubscriptionLifecycle.billingIssue;
    }
    if (subscription.status == SubscriptionLifecycle.pending) {
      return SubscriptionLifecycle.pending;
    }
    if (subscription.status == SubscriptionLifecycle.cancelled) {
      final next = subscription.nextBillingAt;
      if (next != null && next.isAfter(now)) {
        return SubscriptionLifecycle.cancelled;
      }
      return SubscriptionLifecycle.expired;
    }
    if (subscription.trialActive) return SubscriptionLifecycle.trial;
    if (subscription.paidActive) return SubscriptionLifecycle.active;
    if (subscription.status == SubscriptionLifecycle.trial &&
        subscription.trialEndsAt != null &&
        subscription.trialEndsAt!.isBefore(now)) {
      return SubscriptionLifecycle.expired;
    }
    if (subscription.status == SubscriptionLifecycle.expired) {
      return SubscriptionLifecycle.expired;
    }
  }
  if (userFlagPremium) {
    if (userExpiresAt == null || userExpiresAt.isAfter(now)) {
      return SubscriptionLifecycle.active;
    }
    return SubscriptionLifecycle.expired;
  }
  return SubscriptionLifecycle.free;
}
