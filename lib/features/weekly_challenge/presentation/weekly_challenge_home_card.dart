import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/lily/lily_image.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/weekly_challenge_models.dart';
import '../providers/weekly_challenge_providers.dart';

/// Card em destaque da Home — Desafio da Semana.
class WeeklyChallengeHomeCard extends ConsumerWidget {
  const WeeklyChallengeHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(featuredWeeklyChallengeProvider);
    if (challenge == null) return const SizedBox.shrink();
    final progressAsync = ref.watch(challengeProgressProvider(challenge.id));
    final progress = progressAsync.valueOrNull;
    final joined = progress != null &&
        progress.status != ParticipationStatus.notStarted;
    final completed = progress?.completedCount ?? 0;
    final ratio = (completed / challenge.requiredDays).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('${Routes.weeklyChallenge}/${challenge.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1024),
                Color(0xFF12081C),
                Color(0xFF1A1018),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.hotPink.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'DESAFIO DA SEMANA',
                        style: TextStyle(
                          color: AppColors.hotPink,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${challenge.category.emoji} ${challenge.periodLabel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 110,
                      child: challenge.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                challenge.imageUrl,
                                height: 110,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => LilyImage(
                                  asset: challenge.resolvedLilyAsset,
                                  height: 110,
                                  semanticLabel: 'Lily Fit',
                                ),
                              ),
                            )
                          : LilyImage(
                              asset: challenge.resolvedLilyAsset,
                              height: 110,
                              semanticLabel: 'Lily Fit',
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: AppTextStyles.h3(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            challenge.shortDescription,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.35,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      joined
                          ? 'Progresso: $completed de ${challenge.requiredDays} dias'
                          : 'Objetivo: ${challenge.requiredDays} de ${challenge.totalDays} dias',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceElevated,
                    color: AppColors.hotPink,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => context
                        .push('${Routes.weeklyChallenge}/${challenge.id}'),
                    child: Text(
                      joined ? 'Continuar desafio' : 'Participar do desafio',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
