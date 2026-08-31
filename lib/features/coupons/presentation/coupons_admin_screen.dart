import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/coupon_models.dart';
import '../providers/coupons_providers.dart';

class CouponsAdminScreen extends ConsumerWidget {
  const CouponsAdminScreen({super.key});

  Future<void> _novoCupom(BuildContext context, WidgetRef ref) async {
    final codeController = TextEditingController();
    final valueController = TextEditingController(text: '100');
    final limitController = TextEditingController(text: '1');
    var reward = CouponReward.coins;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novo cupom', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              const Text('Código',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 16),
              const Text('Recompensa',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButtonFormField<CouponReward>(
                value: reward,
                items: CouponReward.values
                    .map((r) =>
                        DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setSheetState(() => reward = v ?? reward),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Valor',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                            controller: valueController,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Limite de uso',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                            controller: limitController,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Criar cupom'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true && codeController.text.trim().isNotEmpty) {
      await ref.read(couponsRepositoryProvider).create(Coupon(
            code: codeController.text.trim(),
            reward: reward,
            value: int.tryParse(valueController.text) ?? 0,
            usageLimit: int.tryParse(limitController.text) ?? 1,
            usageCount: 0,
          ));
      ref.invalidate(couponsListProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cupons (admin) 🎟️')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoCupom(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: couponsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
              child: Text('Não consegui carregar os cupons.',
                  style: TextStyle(color: AppColors.textSecondary))),
          data: (coupons) => coupons.isEmpty
              ? const Center(
                  child: Text('Nenhum cupom cadastrado ainda.',
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: coupons.length,
                  itemBuilder: (_, i) {
                    final c = coupons[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.code,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                Text(
                                  '${c.value} ${c.reward.label} · ${c.usageCount}/${c.usageLimit} usados'
                                  '${c.valid ? '' : ' · inválido'}',
                                  style: TextStyle(
                                      color: c.valid
                                          ? AppColors.textSecondary
                                          : AppColors.danger,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.danger),
                            onPressed: () async {
                              await ref
                                  .read(couponsRepositoryProvider)
                                  .delete(c.code);
                              ref.invalidate(couponsListProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
