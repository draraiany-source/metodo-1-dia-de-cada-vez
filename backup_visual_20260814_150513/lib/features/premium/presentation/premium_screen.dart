import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/premium_service.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lili_widgets.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  int _plan = 1; // 0 = mensal, 1 = anual
  bool _loading = false;

  static const _benefits = [
    'Todos os treinos premium desbloqueados',
    'Amanda IA ilimitada e personalizada',
    'Planos de corrida avançados',
    'Receitas e planos nutricionais completos',
    'Sem anúncios',
    'Relatórios de evolução detalhados',
  ];

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumStatusProvider).isPremium;
    return Scaffold(
      appBar: AppBar(title: const Text('Premium 👑')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Column(
              children: [
                const AnimatedLiliMascot(
                    pose: MascotePose.rainha,
                    mood: LiliMood.respirando,
                    height: 210),
                const SizedBox(height: 8),
                const Text('Método 1 Dia Premium',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Desbloqueie sua melhor versão, um dia de cada vez.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ..._benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(b,
                            style: const TextStyle(color: Colors.white))),
                  ],
                ),
              )),
          const SizedBox(height: 12),

          _PlanCard(
            title: 'Anual',
            price: 'R\$ ${AppConstants.premiumYearlyPrice.toStringAsFixed(2)}',
            subtitle: 'Equivale a R\$ 16,42/mês · Economize 45%',
            selected: _plan == 1,
            badge: 'MAIS POPULAR',
            onTap: () => setState(() => _plan = 1),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Mensal',
            price: 'R\$ ${AppConstants.premiumMonthlyPrice.toStringAsFixed(2)}',
            subtitle: 'Cobrança mensal · cancele quando quiser',
            selected: _plan == 0,
            onTap: () => setState(() => _plan = 0),
          ),
          const SizedBox(height: 24),

          if (isPremium)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const AnimatedLiliMascot(
                      pose: MascotePose.celebrando,
                      mood: LiliMood.comemorando,
                      height: 56),
                  const SizedBox(width: 12),
                  const Icon(Icons.verified, color: AppColors.success),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Você é Premium 🎉 Aproveite tudo liberado!',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: _loading ? null : _subscribe,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_plan == 1
                      ? 'Assinar plano anual'
                      : 'Assinar plano mensal'),
            ),
          const SizedBox(height: 8),
          if (!isPremium)
            TextButton(
              onPressed: _loading ? null : _restore,
              child: const Text('Restaurar compra'),
            ),
          const Center(
            child: Text(
              'Pagamento processado via loja. Preparado para RevenueCat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe() async {
    setState(() => _loading = true);
    final planId = _plan == 1 ? 'yearly' : 'monthly';
    try {
      await ref.read(premiumStatusProvider.notifier).subscribe(planId);
      await AnalyticsService.subscribe(planId);
      await FeedbackService.play(FeedbackEvent.conquista);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Premium ativado! 🎉'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível assinar: $e')),
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
          content: Text(status.isPremium
              ? 'Assinatura restaurada! 🎉'
              : 'Nenhuma assinatura encontrada.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });
  final String title;
  final String price;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textTertiary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(badge!,
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text(price,
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
