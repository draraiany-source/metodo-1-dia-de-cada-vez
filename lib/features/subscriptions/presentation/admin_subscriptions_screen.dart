import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/subscription_models.dart';
import '../providers/subscription_providers.dart';
import 'premium_gate_sheet.dart';

class AdminSubscriptionsScreen extends ConsumerStatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  ConsumerState<AdminSubscriptionsScreen> createState() =>
      _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState
    extends ConsumerState<AdminSubscriptionsScreen> {
  SubscriptionLifecycle? _filter;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final role = user == null
        ? UserRole.aluno
        : resolveUserRole(
            isPersonalTrainer: user.isPersonalTrainer,
            isAdmin: user.isAdmin,
          );
    if (role != UserRole.admin) {
      return const Scaffold(
        appBar: PremiumAppBar(
          title: 'Assinaturas',
          showStaffSignOut: true,
        ),
        body: PremiumEmptyOrError(
          message: 'Acesso restrito ao Admin Técnico.',
        ),
      );
    }

    final asyncList = ref.watch(adminSubscriptionsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(
        title: 'Assinaturas',
        showStaffSignOut: true,
      ),
      body: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => PremiumEmptyOrError(
          message: 'Não foi possível carregar as assinaturas.',
          retry: () => ref.invalidate(adminSubscriptionsProvider),
        ),
        data: (all) {
          final counts = _counts(all);
          final filtered = _filter == null
              ? all
              : all.where((s) => s.status == _filter).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _metric('Registros', '${all.length}'),
                  _metric('Teste grátis', '${counts.trial}'),
                  _metric('Mensal', '${counts.monthly}'),
                  _metric('Trimestral', '${counts.quarterly}'),
                  _metric('Anual', '${counts.yearly}'),
                  _metric('Cancelados', '${counts.cancelled}'),
                  _metric('Expirados', '${counts.expired}'),
                  _metric('Gratuitos*', '${counts.freeHint}'),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '* Gratuitos = registros sem plano pago/teste ativo. '
                'O total de usuários do app está em Usuários e papéis. '
                'Assinatura paga não pode ser editada aqui sem auditoria no servidor.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('Todos', _filter == null, () => setState(() => _filter = null)),
                    ...SubscriptionLifecycle.values.map(
                      (s) => _chip(
                        s.labelPt,
                        _filter == s,
                        () => setState(() => _filter = s),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const PremiumEmptyOrError(
                  message: 'Nenhum registro neste filtro.',
                )
              else
                ...filtered.map(_row),
            ],
          );
        },
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      width: 108,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _row(SubscriptionRecord s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          s.userId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        subtitle: Text(
          '${s.plan.labelPt} · ${s.status.labelPt}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.lock_outline, color: AppColors.textTertiary, size: 18),
      ),
    );
  }

  _Counts _counts(List<SubscriptionRecord> all) {
    var trial = 0, monthly = 0, quarterly = 0, yearly = 0, cancelled = 0, expired = 0, freeHint = 0;
    for (final s in all) {
      if (s.trialActive) trial++;
      if (s.paidActive && s.plan == CatalogPlan.monthly) monthly++;
      if (s.paidActive && s.plan == CatalogPlan.quarterly) quarterly++;
      if (s.paidActive && s.plan == CatalogPlan.yearly) yearly++;
      if (s.status == SubscriptionLifecycle.cancelled) cancelled++;
      if (s.status == SubscriptionLifecycle.expired) expired++;
      if (!s.hasPremiumAccess) freeHint++;
    }
    return _Counts(
      trial: trial,
      monthly: monthly,
      quarterly: quarterly,
      yearly: yearly,
      cancelled: cancelled,
      expired: expired,
      freeHint: freeHint,
    );
  }
}

class _Counts {
  const _Counts({
    required this.trial,
    required this.monthly,
    required this.quarterly,
    required this.yearly,
    required this.cancelled,
    required this.expired,
    required this.freeHint,
  });
  final int trial;
  final int monthly;
  final int quarterly;
  final int yearly;
  final int cancelled;
  final int expired;
  final int freeHint;
}
