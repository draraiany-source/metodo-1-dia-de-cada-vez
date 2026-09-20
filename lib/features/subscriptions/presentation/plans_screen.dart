import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_legal.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/billing_error_mapper.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/services/premium_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_models.dart';
import '../providers/subscription_providers.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(effectiveAccessProvider);
    final catalogAsync = ref.watch(storeCatalogProvider);
    final store = catalogAsync.valueOrNull ?? StoreCatalog.empty;
    final width = MediaQuery.sizeOf(context).width;
    final pad = width > 720 ? 32.0 : 20.0;
    final useStoreTrial = AppConfig.billingConfigured;
    final yearlyQuote = store.yearly;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Planos e Assinaturas'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(pad, 12, pad, 32),
        children: [
          _HeroCard(hasPremium: access.hasPremium, lifecycle: access.lifecycle),
          const SizedBox(height: 20),
          if (useStoreTrial)
            _StoreTrialInfo(hasTrial: store.monthly?.hasFreeTrial == true ||
                store.quarterly?.hasFreeTrial == true ||
                store.yearly?.hasFreeTrial == true)
          else
            _TrialCard(
              loading: _loading,
              alreadyUsed: access.subscription?.trialUsed == true,
              active: access.lifecycle == SubscriptionLifecycle.trial,
              onStart: _startTrial,
            ),
          const SizedBox(height: 16),
          _PaidPlanCard(
            info: PlanCatalog.monthly,
            storePrice: store.monthly?.priceString,
            hasStoreTrial: store.monthly?.hasFreeTrial == true,
            loading: _loading,
            buttonLabel: 'ASSINAR MENSAL',
            onSubscribe: () => _subscribe(CatalogPlan.monthly),
          ),
          const SizedBox(height: 16),
          _PaidPlanCard(
            info: PlanCatalog.quarterly,
            storePrice: store.quarterly?.priceString,
            hasStoreTrial: store.quarterly?.hasFreeTrial == true,
            loading: _loading,
            buttonLabel: 'ASSINAR TRIMESTRAL',
            onSubscribe: () => _subscribe(CatalogPlan.quarterly),
          ),
          const SizedBox(height: 16),
          if (yearlyQuote != null)
            _PaidPlanCard(
              info: PlanCatalog.yearly,
              storePrice: yearlyQuote.priceString,
              hasStoreTrial: yearlyQuote.hasFreeTrial,
              loading: _loading,
              buttonLabel: 'ASSINAR ANUAL',
              onSubscribe: () => _subscribe(CatalogPlan.yearly),
            )
          else
            const _YearlyComingSoonCard(),
          const SizedBox(height: 20),
          if (access.hasPremium)
            OutlinedButton(
              onPressed: () => context.push(Routes.mySubscription),
              child: const Text('Ver minha assinatura'),
            ),
          TextButton(
            onPressed: _loading ? null : _restore,
            child: const Text('Restaurar compras'),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              TextButton(
                onPressed: () => context.push(Routes.terms),
                child: const Text('Termos'),
              ),
              TextButton(
                onPressed: () => context.push(Routes.privacy),
                child: const Text('Privacidade'),
              ),
              TextButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.pop();
                  }
                },
                child: const Text('Cancelar / voltar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _billingDisclaimer(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
          if (AppLegal.hasTermsUrl && AppLegal.hasPrivacyUrl)
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(AppLegal.termsUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Abrir termos no navegador'),
            ),
        ],
      ),
    );
  }

  Future<void> _startTrial() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre na sua conta para começar o teste.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(subscriptionRepositoryProvider).startFreeTrial(user.id);
      await ref.read(premiumStatusProvider.notifier).refresh();
      ref.invalidate(mySubscriptionProvider);
      await FeedbackService.play(FeedbackEvent.conquista);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teste de 7 dias ativado. Aproveite o método completo.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on SubscriptionException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível iniciar o teste. $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _subscribe(CatalogPlan plan) async {
    setState(() => _loading = true);
    try {
      await ref.read(premiumStatusProvider.notifier).subscribe(plan.id);
      await AnalyticsService.subscribe(plan.id);
      await FeedbackService.play(FeedbackEvent.conquista);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assinatura registrada.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on PurchaseCancelledException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(BillingErrorMapper.toUserMessage(
          const PurchaseCancelledException(),
        ))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(BillingErrorMapper.toUserMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    try {
      final status = await ref.read(premiumStatusProvider.notifier).restore();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            BillingErrorMapper.restoreMessage(foundPremium: status.isPremium),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(BillingErrorMapper.toUserMessage(
            e,
            fallback: 'Não foi possível restaurar as compras agora.',
          )),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _billingDisclaimer() {
    if (AppConfig.paymentsEnabled) {
      return 'Os preços da App Store e da Google Play têm prioridade. '
          'A cobrança real de produção está autorizada neste build.';
    }
    if (AppConfig.billingSandbox) {
      return 'Modo sandbox (BILLING_SANDBOX). Use testador autorizado da Play '
          'ou Sandbox Apple. PAYMENTS_ENABLED continua false — sem produção.';
    }
    return 'Cobrança real desativada (PAYMENTS_ENABLED=false). '
        'Nenhuma compra de produção será processada. '
        'Preços da loja aparecem quando o RevenueCat estiver configurado.';
  }
}

class _StoreTrialInfo extends StatelessWidget {
  const _StoreTrialInfo({required this.hasTrial});
  final bool hasTrial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teste grátis de 7 dias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasTrial
                ? 'A loja oferece período de introdução. A elegibilidade é da Apple/Google — a mesma conta não reinicia o teste. A cobrança do plano começa ao fim dos 7 dias se você não cancelar em Gerenciar assinatura.'
                : 'O teste de 7 dias será o introductory offer do produto na App Store / Play. Enquanto a offering não trouxer trial, o botão Assinar abre a loja sem inventar preço local.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.hasPremium, required this.lifecycle});
  final bool hasPremium;
  final SubscriptionLifecycle lifecycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const AppIconImage(
            AppIcons.premium,
            size: 56,
            fallbackIcon: Icons.workspace_premium_rounded,
          ),
          const SizedBox(height: 12),
          const Text(
            'Planos e Assinaturas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasPremium
                ? 'Status atual: ${lifecycle.labelPt}'
                : 'Escolha como viver o Método 1 Dia de Cada Vez por completo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.92), height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _TrialCard extends StatelessWidget {
  const _TrialCard({
    required this.loading,
    required this.alreadyUsed,
    required this.active,
    required this.onStart,
  });
  final bool loading;
  final bool alreadyUsed;
  final bool active;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teste grátis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '7 dias gratuitos',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Conheça todos os recursos do Método 1 Dia de Cada Vez antes de escolher seu plano.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: loading || alreadyUsed || active ? null : onStart,
              child: Text(
                active
                    ? 'TESTE EM ANDAMENTO'
                    : alreadyUsed
                        ? 'TESTE JÁ UTILIZADO'
                        : 'COMEÇAR 7 DIAS GRÁTIS',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaidPlanCard extends StatelessWidget {
  const _PaidPlanCard({
    required this.info,
    required this.loading,
    required this.buttonLabel,
    required this.onSubscribe,
    this.storePrice,
    this.hasStoreTrial = false,
  });
  final CatalogPlanInfo info;
  final bool loading;
  final String buttonLabel;
  final VoidCallback onSubscribe;
  final String? storePrice;
  final bool hasStoreTrial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: info.highlight ? AppColors.secondary : AppColors.border,
          width: info.highlight ? 2 : 1,
        ),
        boxShadow: info.highlight
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  info.plan.labelPt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (info.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.vibeGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    info.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: storePrice ??
                      info.fallbackPriceLabel ??
                      'Preço da loja',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: storePrice == null ? ' ${info.periodLabel}' : '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (storePrice != null)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Preço da App Store / Google Play',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ),
          if (hasStoreTrial)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Inclui teste grátis da loja. A cobrança começa depois, se não cancelar.',
                style: TextStyle(color: AppColors.secondary, fontSize: 12),
              ),
            ),
          if (info.equivalentMonthly != null) ...[
            const SizedBox(height: 6),
            Text(
              'Equivale a aproximadamente R\$ ${info.equivalentMonthly!.toStringAsFixed(2).replaceAll('.', ',')} por mês',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
          if (info.savingsVsMonthly != null && info.savingsVsMonthly! > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Economize R\$ ${info.savingsVsMonthly!.toStringAsFixed(2).replaceAll('.', ',')} comparado a 3 mensalidades',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...info.benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: info.highlight
                  ? FilledButton.styleFrom(backgroundColor: AppColors.secondary)
                  : null,
              onPressed: loading ? null : onSubscribe,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _YearlyComingSoonCard extends StatelessWidget {
  const _YearlyComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plano Anual',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Plano anual — em breve',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'O valor será definido quando o produto estiver cadastrado na App Store e na Google Play. Nenhum preço foi inventado.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: null,
              child: const Text('INDISPONÍVEL'),
            ),
          ),
        ],
      ),
    );
  }
}
