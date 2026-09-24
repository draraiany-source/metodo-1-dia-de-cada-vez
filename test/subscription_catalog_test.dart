import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/config/app_config.dart';
import 'package:metodo_1_dia/core/constants/app_constants.dart';
import 'package:metodo_1_dia/features/subscriptions/domain/subscription_models.dart';

void main() {
  group('PlanCatalog', () {
    test('preços de catálogo mensal, trimestral e anual', () {
      expect(PlanCatalog.monthly.fallbackPrice, 199.00);
      expect(PlanCatalog.quarterly.fallbackPrice, 399.00);
      expect(PlanCatalog.yearly.fallbackPrice, 1490.00);
      expect(PlanCatalog.yearly.comingSoon, isFalse);
      expect(PlanCatalog.monthly.periodLabel, 'por mês');
      expect(PlanCatalog.quarterly.periodLabel, 'a cada 3 meses');
      expect(PlanCatalog.yearly.periodLabel, 'por ano');
    });

    test('equivalentes e economias calculados a partir dos preços oficiais', () {
      expect(PlanCatalog.quarterly.equivalentMonthly, closeTo(133.00, 0.001));
      expect(PlanCatalog.quarterly.savingsVsMonthly, closeTo(198.00, 0.01));
      expect(PlanCatalog.yearly.equivalentMonthly, closeTo(124.17, 0.001));
      expect(PlanCatalog.yearly.savingsVsMonthly, closeTo(898.00, 0.01));
      expect(
        PlanCatalog.yearly.billingClarity,
        contains('Cobrança anual'),
      );
    });

    test('rótulos BRL com milhar no anual', () {
      expect(PlanCatalog.yearly.fallbackPriceLabel, 'R\$ 1.490,00');
      expect(PlanCatalog.monthly.fallbackPriceLabel, 'R\$ 199,00');
      expect(PlanCatalog.quarterly.fallbackPriceLabel, 'R\$ 399,00');
    });

    test('IDs seguem o padrão já existente no AppConfig', () {
      expect(CatalogPlan.monthly.storeProductId, AppConfig.productMonthly);
      expect(CatalogPlan.quarterly.storeProductId, AppConfig.productQuarterly);
      expect(CatalogPlan.yearly.storeProductId, AppConfig.productYearly);
      expect(AppConfig.productMonthly, 'metodo1dia_premium_mensal');
      expect(AppConfig.productQuarterly, 'metodo1dia_premium_trimestral');
      expect(AppConfig.productYearly, 'metodo1dia_premium_anual');
      expect(AppConstants.premiumMonthlyId, AppConfig.productMonthly);
    });

    test('cobrança real e sandbox desligados por padrão', () {
      expect(AppConfig.paymentsEnabled, isFalse);
      expect(AppConfig.billingSandbox, isFalse);
      expect(AppConfig.storePurchasesAllowed, isFalse);
      expect(AppConfig.premiumEntitlement, 'premium');
      expect(AppConfig.defaultOffering, 'default');
    });
  });

  group('resolveHasPremiumAccess', () {
    test('usuário gratuito sem assinatura', () {
      expect(
        resolveHasPremiumAccess(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: null,
        ),
        isFalse,
      );
    });

    test('teste gratuito ativo', () {
      final sub = SubscriptionRecord(
        userId: 'u1',
        plan: CatalogPlan.trial,
        status: SubscriptionLifecycle.trial,
        trialUsed: true,
        trialEndsAt: DateTime.now().add(const Duration(days: 3)),
      );
      expect(
        resolveHasPremiumAccess(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        isTrue,
      );
      expect(
        resolveLifecycle(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        SubscriptionLifecycle.trial,
      );
    });

    test('teste gratuito expirado não libera', () {
      final sub = SubscriptionRecord(
        userId: 'u1',
        plan: CatalogPlan.trial,
        status: SubscriptionLifecycle.trial,
        trialUsed: true,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(
        resolveHasPremiumAccess(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        isFalse,
      );
      expect(
        resolveLifecycle(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        SubscriptionLifecycle.expired,
      );
    });

    test('mensal ativo', () {
      final sub = SubscriptionRecord(
        userId: 'u1',
        plan: CatalogPlan.monthly,
        status: SubscriptionLifecycle.active,
        amount: 199.00,
        nextBillingAt: DateTime.now().add(const Duration(days: 20)),
      );
      expect(
        resolveHasPremiumAccess(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        isTrue,
      );
      expect(
        resolveLifecycle(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        SubscriptionLifecycle.active,
      );
    });

    test('trimestral ativo', () {
      final sub = SubscriptionRecord(
        userId: 'u1',
        plan: CatalogPlan.quarterly,
        status: SubscriptionLifecycle.active,
      );
      expect(sub.hasPremiumAccess, isTrue);
      expect(sub.planLabel, 'Plano Trimestral');
    });

    test('assinatura cancelada ainda no período', () {
      final end = DateTime.now().add(const Duration(days: 5));
      final sub = SubscriptionRecord(
        userId: 'u1',
        plan: CatalogPlan.monthly,
        status: SubscriptionLifecycle.cancelled,
        nextBillingAt: end,
      );
      expect(
        resolveLifecycle(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        SubscriptionLifecycle.cancelled,
      );
    });

    test('assinatura expirada', () {
      final sub = SubscriptionRecord(
        userId: 'u1',
        plan: CatalogPlan.monthly,
        status: SubscriptionLifecycle.expired,
      );
      expect(sub.hasPremiumAccess, isFalse);
      expect(
        resolveLifecycle(
          userFlagPremium: false,
          userExpiresAt: null,
          subscription: sub,
        ),
        SubscriptionLifecycle.expired,
      );
    });

    test('flag isPremium do usuário com validade futura', () {
      expect(
        resolveHasPremiumAccess(
          userFlagPremium: true,
          userExpiresAt: DateTime.now().add(const Duration(days: 10)),
          subscription: null,
        ),
        isTrue,
      );
    });

    test('mesmo usuário não reinicia teste se trialUsed', () {
      final sub = SubscriptionRecord(
        userId: 'u1',
        plan: CatalogPlan.trial,
        status: SubscriptionLifecycle.expired,
        trialUsed: true,
        trialEndsAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(sub.trialUsed, isTrue);
      expect(sub.trialActive, isFalse);
    });
  });

  group('SubscriptionLifecycle', () {
    test('rótulos em português', () {
      expect(SubscriptionLifecycle.free.labelPt, 'Gratuito');
      expect(SubscriptionLifecycle.trial.labelPt, 'Teste gratuito');
      expect(SubscriptionLifecycle.active.labelPt, 'Ativo');
      expect(SubscriptionLifecycle.cancelled.labelPt, 'Cancelado');
      expect(SubscriptionLifecycle.expired.labelPt, 'Expirado');
      expect(SubscriptionLifecycle.pending.labelPt, 'Pendente');
      expect(SubscriptionLifecycle.billingIssue.labelPt, 'Pagamento com problema');
    });
  });
}
