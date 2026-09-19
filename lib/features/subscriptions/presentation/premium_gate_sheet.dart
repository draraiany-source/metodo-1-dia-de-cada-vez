import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/subscription_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal único de conteúdo Premium — não bloqueia o app; o usuário volta.
Future<void> showPremiumGate(
  BuildContext context, {
  String? contentName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => PremiumGateSheet(contentName: contentName),
  );
}

class PremiumGateSheet extends StatelessWidget {
  const PremiumGateSheet({super.key, this.contentName});
  final String? contentName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.workspace_premium_rounded,
              size: 48, color: AppColors.secondary),
          const SizedBox(height: 14),
          const Text(
            'Conteúdo Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            contentName == null
                ? 'Este recurso faz parte da experiência completa do Método 1 Dia de Cada Vez.'
                : '“$contentName” faz parte da experiência completa do Método 1 Dia de Cada Vez.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.push(Routes.premium);
              },
              child: const Text('VER PLANOS'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('AGORA NÃO'),
          ),
        ],
      ),
    );
  }
}

/// Helper para telas: se não for Premium, abre o modal e retorna false.
bool ensurePremiumAccess(BuildContext context, WidgetRef ref, {String? name}) {
  final access = ref.read(effectiveAccessProvider);
  if (access.hasPremium) return true;
  final user = ref.read(currentUserProvider);
  if (user != null && user.isPremium) return true;
  showPremiumGate(context, contentName: name);
  return false;
}

class PremiumLockBody extends StatelessWidget {
  const PremiumLockBody({super.key, this.contentName});
  final String? contentName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 48, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text(
            'Conteúdo Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            contentName == null
                ? 'Este recurso faz parte da experiência completa do Método 1 Dia de Cada Vez.'
                : '“$contentName” faz parte da experiência completa do Método 1 Dia de Cada Vez.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => context.push(Routes.premium),
              child: const Text('VER PLANOS'),
            ),
          ),
          TextButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.pop();
              }
            },
            child: const Text('AGORA NÃO'),
          ),
        ],
      ),
    );
  }
}

class PremiumEmptyOrError extends StatelessWidget {
  const PremiumEmptyOrError({
    super.key,
    required this.message,
    this.retry,
  });
  final String message;
  final VoidCallback? retry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, color: AppColors.textTertiary, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          if (retry != null) ...[
            const SizedBox(height: 16),
            TextButton(onPressed: retry, child: const Text('Tentar de novo')),
          ],
        ],
      ),
    );
  }
}
