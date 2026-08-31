import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../missions/providers/missions_providers.dart';

/// ============================================================================
/// CARTÃO "META DO DIA" — cartão-herói em rosa intenso com anel de progresso.
///
/// O percentual é 100% real: média da conclusão das três missões diárias que
/// já existem no app — treino (`d_treino`), alimentação (`d_refeicao`) e água
/// (`d_agua`). Nenhum número é inventado; se as missões ainda não carregaram,
/// o cartão mostra um estado neutro em vez de um valor falso.
/// ============================================================================
class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  static const _trackedIds = ['d_treino', 'd_refeicao', 'd_agua'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);

    double ratioOf(String id) {
      final def = MissionsCatalog.all.firstWhere((m) => m.id == id);
      final current = missions.progressOf(id).current;
      return (current / def.target).clamp(0.0, 1.0);
    }

    final ratios = _trackedIds.map(ratioOf).toList();
    final percent = missions.loading
        ? 0.0
        : ratios.reduce((a, b) => a + b) / ratios.length;
    final percentLabel = missions.loading
        ? '—'
        : '${(percent * 100).round()}%';

    return FadeInUp(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC81F63).withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Base do gradiente rosa (identidade da marca).
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroPinkGradient,
                ),
              ),
              // Camada de "vidro" — brilho diagonal sutil (glassmorphism).
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.16),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.55],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Meta do dia',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const SizedBox(height: 4),
                          const Text('Treino + Alimentação + Água',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 16),
                          PressableScale(
                            onTap: () => context.push(Routes.plan),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text('Ver meu plano',
                                  style: TextStyle(
                                      color: Color(0xFFC81F63),
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircularPercentIndicator(
                      radius: 42,
                      lineWidth: 8,
                      percent: percent,
                      animation: true,
                      animationDuration: 700,
                      backgroundColor: Colors.white24,
                      progressColor: Colors.white,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Text(percentLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
