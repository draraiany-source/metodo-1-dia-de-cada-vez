import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_guide.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../rewards/providers/rewards_providers.dart';
import '../providers/missions_providers.dart';

class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: MissionPeriod.values.length, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _claim(MissionDef def) async {
    final result = ref.read(missionsProvider.notifier).claim(def);
    if (!mounted) return;

    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Não foi possível resgatar.')),
      );
      return;
    }

    // Credita XP e moedas nos módulos já existentes.
    ref.read(gamificationProvider.notifier).addXp(result.xp);
    ref.read(rewardsProvider.notifier).earn(result.coins);

    // Feedback sensorial de conquista (háptico + som, se habilitados).
    await FeedbackService.play(FeedbackEvent.conquista);

    if (!mounted) return;

    // Animação de conclusão.
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiliAnimation(AppAssets.animConfetti, size: 120, repeat: false),
            const AnimatedLiliMascot(
                pose: MascotePose.celebrando,
                mood: LiliMood.comemorando,
                height: 130),
            const SizedBox(height: 12),
            Text('Missão concluída!\n${def.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedCounter(
                    value: result.xp,
                    prefix: '+',
                    suffix: ' XP ⚡',
                    style: const TextStyle(color: AppColors.secondary)),
                const Text('  ·  ',
                    style: TextStyle(color: AppColors.secondary)),
                AnimatedCounter(
                    value: result.coins,
                    prefix: '+',
                    suffix: ' 🪙',
                    style: const TextStyle(color: AppColors.secondary)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missões'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () => context.push(Routes.missionsHistory),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            for (final p in MissionPeriod.values)
              Tab(text: '${p.emoji} ${p.label}'),
          ],
        ),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: LiliGuide(mascotHeight: 90),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      for (final period in MissionPeriod.values)
                        _MissionList(
                          defs: MissionsCatalog.byPeriod(period),
                          state: state,
                          onClaim: _claim,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}


class _MissionList extends StatelessWidget {
  const _MissionList({
    required this.defs,
    required this.state,
    required this.onClaim,
  });

  final List<MissionDef> defs;
  final MissionsState state;
  final Future<void> Function(MissionDef) onClaim;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: defs.length,
      itemBuilder: (_, i) {
        final def = defs[i];
        final prog = state.progressOf(def.id);
        final complete = prog.current >= def.target;
        final ratio = def.target == 0
            ? 0.0
            : (prog.current / def.target).clamp(0.0, 1.0).toDouble();

        return FadeInUp(
          delayMs: i * 50,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: prog.claimed
                  ? Border.all(color: AppColors.success)
                  : complete
                      ? Border.all(color: AppColors.secondary)
                      : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(def.emoji,
                              style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(def.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          Text(def.description,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    _ClaimButton(
                      claimed: prog.claimed,
                      complete: complete,
                      onTap: () => onClaim(def),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Barra de progresso animada.
                AnimatedProgressBar(
                  value: ratio,
                  backgroundColor: AppColors.surface2,
                  color: prog.claimed
                      ? AppColors.success
                      : complete
                          ? AppColors.secondary
                          : AppColors.primary,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${prog.current} / ${def.target}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    Text('+${def.xp} XP · +${def.coins} 🪙',
                        style: const TextStyle(
                            color: AppColors.accent, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.claimed,
    required this.complete,
    required this.onTap,
  });

  final bool claimed;
  final bool complete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (claimed) {
      return const Icon(Icons.check_circle, color: AppColors.success);
    }
    if (!complete) {
      return const Icon(Icons.lock_outline, color: AppColors.textTertiary);
    }
    return PopIn(
      child: Pulse(
        child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        child: const Text('Resgatar',
            style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ),
    );
  }
}
