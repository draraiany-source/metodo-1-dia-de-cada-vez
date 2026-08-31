import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/coupons_providers.dart';

class RedeemCouponScreen extends ConsumerStatefulWidget {
  const RedeemCouponScreen({super.key});

  @override
  ConsumerState<RedeemCouponScreen> createState() =>
      _RedeemCouponScreenState();
}

class _RedeemCouponScreenState extends ConsumerState<RedeemCouponScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _mensagem;
  bool _sucesso = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resgatar() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _mensagem = null;
    });
    final result =
        await ref.read(couponsRepositoryProvider).redeem(_controller.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _mensagem = result.message;
      _sucesso = result.success;
    });
    if (result.success) {
      await FeedbackService.play(FeedbackEvent.sucesso);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resgatar cupom 🎟️')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tem um cupom promocional? Digite o código abaixo.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código do cupom',
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _resgatar,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Resgatar'),
                ),
              ),
              if (_mensagem != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_sucesso ? AppColors.success : AppColors.danger)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(_mensagem!,
                      style: TextStyle(
                          color:
                              _sucesso ? AppColors.success : AppColors.danger)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
