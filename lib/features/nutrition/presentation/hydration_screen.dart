import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/mascot/mascot_sizes.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../auth/providers/auth_providers.dart';
import '../../missions/providers/missions_providers.dart';
import '../domain/nutrition_models.dart';
import '../providers/water_log_providers.dart';

/// Meta de água — progresso em ml, atalhos rápidos e histórico com horário.
class HydrationScreen extends ConsumerStatefulWidget {
  const HydrationScreen({super.key});

  @override
  ConsumerState<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends ConsumerState<HydrationScreen>
    with WidgetsBindingObserver {
  static const _quickMl = [200, 300, 500];
  static const _goalPresets = [1500, 2000, 2500, 3000];

  String? _toast;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Garante reset visual ao abrir num novo dia local.
    Future.microtask(() => ref.read(waterDayProvider.notifier).ensureToday());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(waterDayProvider.notifier).ensureToday();
    }
  }

  int _goalMl(WaterDayState day, double? weight) {
    return day.customGoalMl ?? WaterCalculator.goalMlFor(weight);
  }

  Future<void> _add(int ml) async {
    await ref.read(waterDayProvider.notifier).addMl(ml);
    final glasses = ref.read(waterDayProvider).glassesApprox;
    ref
        .read(missionsProvider.notifier)
        .setProgress(MissionEvent.copoDeAgua, glasses);
    FeedbackService.play(FeedbackEvent.toqueLeve);
    if (!mounted) return;
    setState(() => _toast = '+$ml ml registrados');
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _remove(WaterSip sip) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remover registro'),
        content: Text(
          'Deseja remover este registro de água?\n${sip.ml} ml',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(waterDayProvider.notifier).removeSip(sip.id);
    final glasses = ref.read(waterDayProvider).glassesApprox;
    ref
        .read(missionsProvider.notifier)
        .setProgress(MissionEvent.copoDeAgua, glasses);
    FeedbackService.play(FeedbackEvent.toqueLeve);
  }

  Future<void> _customAmount() async {
    final controller = TextEditingController();
    final ml = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surfaceDeep,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            24 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Adicionar outra quantidade',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Quantidade (ml)',
                  hintText: 'Ex.: 180',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final v = int.tryParse(controller.text.trim()) ?? 0;
                  Navigator.pop(ctx, v);
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        );
      },
    );
    if (ml != null && ml >= 30 && ml <= 2000) {
      await _add(ml);
    } else if (ml != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor entre 30 e 2000 ml.')),
      );
    }
  }

  Future<void> _editGoal(int currentGoal) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Meta diária',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in _goalPresets)
                      ChoiceChip(
                        label: Text('$g ml'),
                        selected: currentGoal == g,
                        onSelected: (_) async {
                          await ref
                              .read(waterDayProvider.notifier)
                              .setCustomGoalMl(g);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ActionChip(
                      label: const Text('Personalizada'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _customGoalInput(currentGoal);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _customGoalInput(int current) async {
    final c = TextEditingController(text: '$current');
    final v = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Meta personalizada'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'ml'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(c.text.trim())),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (v != null && v >= 500 && v <= 8000) {
      await ref.read(waterDayProvider.notifier).setCustomGoalMl(v);
    }
  }

  String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _fmtMl(int ml) {
    if (ml >= 1000) {
      final l = ml / 1000;
      return '$ml ml (${l.toStringAsFixed(l.truncateToDouble() == l ? 0 : 1)} L)';
    }
    return '$ml ml';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final day = ref.watch(waterDayProvider);
    final goalMl = _goalMl(day, user?.currentWeight);
    final consumed = day.totalMl;
    final remaining = (goalMl - consumed).clamp(0, goalMl);
    final percent = goalMl == 0 ? 0.0 : (consumed / goalMl).clamp(0.0, 1.0);
    final bateu = consumed >= goalMl;
    final cupsLeft = (remaining / 250).ceil();
    final history = day.newestFirst;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Meta de água',
        actions: [
          IconButton(
            tooltip: 'Alterar meta',
            onPressed: () => _editGoal(goalMl),
            icon: const Icon(Icons.tune_rounded, color: Colors.white70),
          ),
          IconButton(
            tooltip: 'Lembretes',
            onPressed: () =>
                AppNavigation.open(context, Routes.reminders),
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white70),
          ),
        ],
      ),
      body: SafeArea(
        child: AppPage(
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_toast != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      AppIconImage(
                        AppIcons.hydrationCheck,
                        size: 22,
                        fit: BoxFit.contain,
                        fallbackIcon: Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 10),
                      Text(_toast!,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FadeInUp(
                child: AppCard(
                  glow: bateu,
                  child: Column(
                    children: [
                      Text('Meta do dia', style: AppTextStyles.caption()),
                      const SizedBox(height: 8),
                      Text(
                        '$consumed ml de $goalMl ml',
                        style: AppTextStyles.h2(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bateu
                            ? 'Meta concluída hoje. Excelente!'
                            : 'Faltam $remaining ml para sua meta de hoje.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(),
                      ),
                      const SizedBox(height: 20),
                      CircularPercentIndicator(
                        radius: 88,
                        lineWidth: 11,
                        percent: percent,
                        animation: true,
                        animationDuration: 650,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: AppColors.surface2,
                        progressColor: AppColors.info,
                        center: Padding(
                          padding: const EdgeInsets.all(16),
                          child: AppIconImage(
                            AppIcons.hydrationProgress,
                            size: 72,
                            fit: BoxFit.contain,
                            fallbackIcon: Icons.water_drop_rounded,
                            semanticLabel: 'Progresso de hidratação',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(percent * 100).round()}%',
                        style: AppTextStyles.title(color: AppColors.info),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FadeInUp(
                delayMs: 30,
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
                  child: Row(
                    children: [
                      AnimatedLiliMascot(
                        pose: bateu
                            ? MascotePose.celebrando
                            : MascotePose.hidratacao,
                        mood: bateu
                            ? LiliMood.comemorando
                            : LiliMood.respirando,
                        height: MascotSizes.small,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bateu
                              ? 'Meta de água batida. Seu corpo agradece.'
                              : cupsLeft <= 1
                                  ? 'Falta cerca de 1 copo para bater sua meta de hoje.'
                                  : 'Faltam $cupsLeft copos para bater sua meta de hoje.',
                          style: AppTextStyles.body(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Adicionar água', style: AppTextStyles.h3()),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final ml in _quickMl)
                    _QuickChip(
                      label: '+$ml ml',
                      onTap: () => _add(ml),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _customAmount,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Adicionar outra quantidade'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.45)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                      child: Text('Histórico do dia',
                          style: AppTextStyles.h3())),
                  Text(
                    '${history.length} registro${history.length == 1 ? '' : 's'}',
                    style: AppTextStyles.caption(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (history.isEmpty)
                const _EmptyHistory()
              else ...[
                for (final sip in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HistoryTile(
                      time: _fmtTime(sip.at),
                      amount: _fmtMl(sip.ml),
                      onDelete: () => _remove(sip),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Total hoje: $consumed ml',
                  style: AppTextStyles.bodySecondary(),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.time,
    required this.amount,
    required this.onDelete,
  });

  final String time;
  final String amount;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          child: AppIconImage(
            AppIcons.hydrationCheck,
            size: 22,
            fit: BoxFit.contain,
            fallbackIcon: Icons.water_drop_rounded,
          ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textTertiary, size: 20),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          AppIconImage(
            AppIcons.hydrationBottle,
            size: 48,
            fit: BoxFit.contain,
            fallbackIcon: Icons.water_drop_outlined,
          ),
          SizedBox(height: 10),
          Text(
            'Ainda não há registros de água hoje.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Use os atalhos 200, 300 ou 500 ml para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
