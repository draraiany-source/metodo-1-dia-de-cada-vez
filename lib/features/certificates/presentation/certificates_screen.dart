import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../running/providers/running_providers.dart';
import '../data/certificate_pdf_service.dart';
import '../domain/certificate_models.dart';

class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final gamification = ref.watch(gamificationProvider);
    final runningAsync = ref.watch(runningHistoryProvider(user.id));
    final totalKm = runningAsync.maybeWhen(
      data: (sessions) => sessions.fold<double>(0, (s, r) => s + r.distanceKm),
      orElse: () => user.totalKm,
    );
    final memberDays = user.memberSince != null
        ? DateTime.now().difference(user.memberSince!).inDays
        : 0;

    final ctx = CertificateContext(
      user: user,
      streak: gamification.streak,
      totalWorkouts: user.totalWorkouts,
      totalKm: totalKm,
      memberDays: memberDays,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Certificados 🏆')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const Text(
              'Cada conquista vira um certificado — baixe ou compartilhe.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ...CertificatesCatalog.all.map((cert) {
              final unlocked = cert.isUnlocked(ctx);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: unlocked
                      ? Border.all(color: AppColors.secondary.withOpacity(0.4))
                      : null,
                ),
                child: Row(
                  children: [
                    Opacity(
                      opacity: unlocked ? 1 : 0.35,
                      child: Text(cert.emoji,
                          style: const TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cert.title,
                              style: TextStyle(
                                  color: unlocked
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(cert.description,
                              style: const TextStyle(
                                  color: AppColors.textTertiary, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (unlocked)
                      IconButton(
                        icon: const Icon(Icons.ios_share,
                            color: AppColors.secondary),
                        onPressed: () => CertificatePdfService.shareCertificate(
                          cert: cert,
                          userName: user.name,
                        ),
                      )
                    else
                      const Icon(Icons.lock_outline,
                          color: AppColors.textTertiary, size: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
