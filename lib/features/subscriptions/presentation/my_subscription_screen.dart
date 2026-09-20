import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/billing_error_mapper.dart';
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
                _kv('Valor', sub?.amountLabel ?? '—'),
                _kv(
                  'Expiração / próxima renovação',
                  _fmt(df, store.expiresAt ?? sub?.nextBillingAt ?? sub?.trialEndsAt),
                ),
                _kv(
                  'Renovação automática',
                  store.source == 'revenuecat'
                      ? (store.willRenew ? 'Sim' : 'Não')
                      : '—',
                ),
                _kv(
                  'Tipo de período',
                  store.periodType ??
                      (life == SubscriptionLifecycle.trial ? 'trial' : '—'),
                ),
                _kv(
                  'Período gratuito',
                  store.periodType == 'trial' ||
                          life == SubscriptionLifecycle.trial
                      ? 'Teste da loja ou 7 dias'
                      : (sub?.trialUsed == true ? 'Já utilizado' : '—'),
                ),
                _kv(
                  'Término do teste gratuito',
                  _fmt(df, sub?.trialEndsAt ??
                      (store.periodType == 'trial' ? store.expiresAt : null)),
                ),
                _kv('Forma de contratação', _sourceLabel(sub, store)),
                _kv(
                  'Plataforma utilizada',
                  _storeLabel(store.store) ??
                      sub?.platformLabel ??
                      '—',
                ),
                _kv('Produto', store.productId ?? sub?.productId ?? '—'),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => _manage(context, store),
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

  String? _storeLabel(String? store) {
    return switch ((store ?? '').toLowerCase()) {
      'playstore' || 'play_store' => 'Google Play',
      'appstore' || 'app_store' => 'Apple App Store',
      'amazon' => 'Amazon',
      'rcbilling' || 'rc_billing' => 'RevenueCat',
      '' => null,
      _ => store,
    };
  }

  String _sourceLabel(SubscriptionRecord? sub, PremiumStatus store) {
    if (sub?.source == 'trial' || sub?.status == SubscriptionLifecycle.trial) {
      return 'Teste gratuito no aplicativo';
    }
    if (store.plan == 'coupon' || sub?.source == 'coupon') return 'Cupom';
    if (store.source == 'revenuecat') return 'Loja (RevenueCat)';
    if (AppConfig.billingConfigured) return 'Loja do aplicativo (pendente)';
    return '—';
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

  Future<void> _manage(BuildContext context, PremiumStatus store) async {
    final fromRc = store.managementUrl;
    final fallback = Theme.of(context).platform == TargetPlatform.iOS
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions';
    final uri = Uri.tryParse(
      (fromRc != null && fromRc.startsWith('http')) ? fromRc : fallback,
    );
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Abra as assinaturas na Google Play ou na App Store para cancelar. '
          'O app não cancela pela própria interface.',
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
            BillingErrorMapper.restoreMessage(foundPremium: status.isPremium),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(BillingErrorMapper.toUserMessage(
            e,
            fallback: 'Não foi possível restaurar as compras agora.',
          )),
        ),
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
