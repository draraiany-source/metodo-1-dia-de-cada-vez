import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../domain/weekly_challenge_models.dart';
import '../providers/weekly_challenge_providers.dart';

class MyChallengesScreen extends ConsumerStatefulWidget {
  const MyChallengesScreen({super.key});

  @override
  ConsumerState<MyChallengesScreen> createState() => _MyChallengesScreenState();
}

class _MyChallengesScreenState extends ConsumerState<MyChallengesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenges =
        ref.watch(publishedChallengesProvider).valueOrNull ?? const [];
    final progress =
        ref.watch(myChallengeProgressListProvider).valueOrNull ?? const [];
    final byId = {for (final c in challenges) c.id: c};

    List<WeeklyChallengeProgress> of(ParticipationStatus s) =>
        progress.where((p) => p.status == s).toList();

    final inProgress = of(ParticipationStatus.inProgress);
    final done = of(ParticipationStatus.completed);
    final failed = [
      ...of(ParticipationStatus.failed),
      ...progress.where((p) {
        final c = byId[p.challengeId];
        return p.status == ParticipationStatus.inProgress &&
            c != null &&
            c.hasEnded &&
            p.completedCount < c.requiredDays;
      }),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PremiumAppBar(title: 'Meus Desafios'),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            indicatorColor: AppColors.hotPink,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textTertiary,
            tabs: const [
              Tab(text: 'Em andamento'),
              Tab(text: 'Concluídos'),
              Tab(text: 'Não concluídos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _List(items: inProgress, byId: byId, empty: 'Nenhum desafio em andamento.'),
                _List(items: done, byId: byId, empty: 'Você ainda não concluiu um desafio.'),
                _List(items: failed, byId: byId, empty: 'Nenhum desafio pendente.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.items,
    required this.byId,
    required this.empty,
  });
  final List<WeeklyChallengeProgress> items;
  final Map<String, WeeklyChallenge> byId;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppEmptyState(
        title: empty,
        message: 'Quando você participar de um desafio, ele aparece aqui.',
        mascotHeight: 130,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final p = items[i];
        final c = byId[p.challengeId];
        final title = c?.title ?? 'Desafio';
        final goal = c?.requiredDays ?? 5;
        return InkWell(
          onTap: () => context.push('${Routes.weeklyChallenge}/${p.challengeId}'),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3()),
                const SizedBox(height: 4),
                Text(
                  c?.periodLabel ?? '',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progresso: ${p.completedCount} de $goal',
                  style: const TextStyle(color: Colors.white),
                ),
                if (p.achievementTitle.isNotEmpty ||
                    p.status == ParticipationStatus.completed) ...[
                  const SizedBox(height: 6),
                  Text(
                    '🏅 ${p.achievementTitle.isNotEmpty ? p.achievementTitle : (c?.rewardTitle ?? 'Constância')}',
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
