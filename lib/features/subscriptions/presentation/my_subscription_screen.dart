import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/premium_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/subscription_models.dart';
import '../providers/subscription_providers.dart';
import 'premium_gate_sheet.dart';

class MySubscriptionScreen extends ConsumerWidget {
  const MySubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final asyncSub = ref.watch(mySubscriptionProvider);
    final access = ref.watch(effectiveAccessProvider);
    final store = ref.watch(premiumStatusProvider);
    final df = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Minha Assinatura'),
      body: asyncSub.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => PremiumEmptyOrError(
          message: 'Não foi possível carregar sua assinatura.',
          retry: () => ref.invalidate(mySubscriptionProvider),
        ),
        data: (sub) {
          if (user == null) {
            return const PremiumEmptyOrError(
              message: 'Entre na sua conta para ver a assinatura.',
            );
          }
          final life = access.lifecycle;
          final planLabel = _planLabel(sub, store, life);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _StatusHero(lifecycle: life, planLabel: planLabel),
              const SizedBox(height: 16),
              _InfoCard(children: [
                _kv('Plano atual', planLabel),
                _kv('Status', life.labelPt),
                _kv('Valor', sub?.amountLabel ?? _catalogValue(sub, store)),
                _kv(
                  'Data de início',
                  _fmt(df, sub?.startedAt ?? store.expiresAt),
                ),
                _kv(
                  'Próxima cobrança',
                  _fmt(df, sub?.nextBillingAt ?? store.expiresAt),
                ),
                _kv(
                  'Período gratuito',
                  sub?.trialUsed == true || life == SubscriptionLifecycle.trial
                      ? '7 dias'
                      : 'Não iniciado',
                ),
                _kv(
                  'Término do teste gratuito',
                  _fmt(df, sub?.trialEndsAt),
                ),
                _kv(
                  'Forma de contratação',
                  _sourceLabel(sub, store),
                ),
                _kv(
                  'Plataforma utilizada',
                  sub?.platformLabel ?? 'Ainda não contratado na loja',
                ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => _manage(context),
                  child: const Text('Gerenciar assinatura'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _restore(context, ref),
                  child: const Text('Restaurar compras'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.push(Routes.premium),
                child: const Text('Ver planos'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _planLabel(
    SubscriptionRecord? sub,
    PremiumStatus store,
    SubscriptionLifecycle life,
  ) {
    if (life == SubscriptionLifecycle.free) return 'Gratuito';
    if (life == SubscriptionLifecycle.trial) return 'Teste grátis (7 dias)';
    if (sub != null && sub.plan != CatalogPlan.trial) return sub.plan.labelPt;
    if (store.plan == 'monthly') return CatalogPlan.monthly.labelPt;
    if (store.plan == 'quarterly') return CatalogPlan.quarterly.labelPt;
    if (store.plan == 'yearly') return CatalogPlan.yearly.labelPt;
    if (store.plan == 'coupon') return 'Premium (cupom)';
    return 'Premium';
  }

  String _catalogValue(SubscriptionRecord? sub, PremiumStatus store) {
    if (sub?.plan == CatalogPlan.monthly) {
      return PlanCatalog.monthly.fallbackPriceLabel ?? '—';
    }
    if (sub?.plan == CatalogPlan.quarterly) {
      return PlanCatalog.quarterly.fallbackPriceLabel ?? '—';
    }
    if (store.plan == 'monthly') {
      return PlanCatalog.monthly.fallbackPriceLabel ?? '—';
    }
    if (store.plan == 'quarterly') {
      return PlanCatalog.quarterly.fallbackPriceLabel ?? '—';
    }
    return '—';
  }

  String _sourceLabel(SubscriptionRecord? sub, PremiumStatus store) {
    if (sub?.source == 'trial' || sub?.status == SubscriptionLifecycle.trial) {
      return 'Teste gratuito no aplicativo';
    }
    if (store.plan == 'coupon' || sub?.source == 'coupon') return 'Cupom';
    if (AppConfig.billingConfigured) return 'Loja do aplicativo (RevenueCat)';
    return 'Ainda não contratado';
  }

  String _fmt(DateFormat df, DateTime? d) => d == null ? '—' : df.format(d.toLocal());

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _manage(BuildContext context) async {
    final uri = Theme.of(context).platform == TargetPlatform.iOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    if (AppConfig.paymentsEnabled) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A gestão na loja será liberada quando a cobrança real estiver ativa.',
        ),
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    try {
      final status = await ref.read(premiumStatusProvider.notifier).restore();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isPremium
                ? 'Compras restauradas.'
                : 'Nenhuma compra encontrada nesta loja.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível restaurar: $e')),
      );
    }
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.lifecycle, required this.planLabel});
  final SubscriptionLifecycle lifecycle;
  final String planLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            planLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            lifecycle.labelPt,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}
