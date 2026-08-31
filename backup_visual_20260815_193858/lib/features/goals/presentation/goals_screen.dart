import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../rewards/providers/rewards_providers.dart';

class Goal {
  Goal({
    required this.id,
    required this.title,
    required this.target,
    this.current = 0,
    this.unit = '',
  });

  final String id;
  final String title;
  final double target;
  double current;
  final String unit;

  double get progress =>
      target <= 0 ? 0 : (current / target).clamp(0.0, 1.0).toDouble();
  bool get done => current >= target;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'target': target,
        'current': current,
        'unit': unit,
      };

  static Goal fromMap(Map<String, dynamic> m) => Goal(
        id: m['id'] as String,
        title: m['title'] as String,
        target: (m['target'] as num).toDouble(),
        current: (m['current'] as num).toDouble(),
        unit: m['unit'] as String? ?? '',
      );
}

/// Metas pessoais — cria, acompanha progresso e conclui. Persiste localmente.
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  static const _kKey = 'user_goals';
  List<Goal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey);
    setState(() {
      if (raw == null) {
        // metas iniciais de exemplo (editáveis)
        _goals = [
          Goal(id: 'g1', title: 'Perder peso', target: 5, unit: 'kg'),
          Goal(id: 'g2', title: 'Treinos no mês', target: 20, unit: 'treinos'),
          Goal(id: 'g3', title: 'Beber água', target: 60, unit: 'litros'),
        ];
      } else {
        // Parse defensivo: metas corrompidas não derrubam a tela.
        _goals = [];
        for (final s in raw) {
          try {
            _goals.add(Goal.fromMap(jsonDecode(s) as Map<String, dynamic>));
          } catch (_) {/* meta inválida descartada */}
        }
      }
      _loading = false;
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _kKey, _goals.map((g) => jsonEncode(g.toMap())).toList());
  }

  void _increment(Goal g, double delta) {
    final wasDone = g.done;
    setState(() => g.current = (g.current + delta).clamp(0, g.target));
    _persist();
    // Recompensa ao concluir a meta pela primeira vez.
    if (!wasDone && g.done) {
      ref.read(rewardsProvider.notifier).earn(AppConstants.coinsPerGoal);
      FeedbackService.play(FeedbackEvent.conquista);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Meta concluída! +${AppConstants.coinsPerGoal} moedas 🪙'),
            backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _addGoal() async {
    final titleC = TextEditingController();
    final targetC = TextEditingController();
    final unitC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Nova meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: targetC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Objetivo (número)'),
            ),
            TextField(
              controller: unitC,
              decoration: const InputDecoration(labelText: 'Unidade (kg, treinos…)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Criar')),
        ],
      ),
    );
    if (ok == true && titleC.text.trim().isNotEmpty) {
      setState(() {
        _goals.add(Goal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: titleC.text.trim(),
          target: double.tryParse(targetC.text) ?? 1,
          unit: unitC.text.trim(),
        ));
      });
      _persist();
    }
    titleC.dispose();
    targetC.dispose();
    unitC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final concluded = _goals.where((g) => g.done).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Metas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                children: [
                  Row(
                    children: [
                      AnimatedLiliMascot(
                          pose: concluded > 0
                              ? MascotePose.trofeu
                              : MascotePose.apontando,
                          mood: concluded > 0
                              ? LiliMood.comemorando
                              : LiliMood.respirando,
                          height: 84),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          concluded > 0
                              ? 'Você já concluiu $concluded meta(s)! Orgulho de você 💜'
                              : 'Defina suas metas e acompanhe seu progresso.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._goals.map((g) => FadeInUp(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radius),
                            border: g.done
                                ? Border.all(color: AppColors.success)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(g.title,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                  ),
                                  if (g.done)
                                    const Icon(Icons.check_circle,
                                        color: AppColors.success),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearPercentIndicator(
                                percent: g.progress,
                                lineHeight: 10,
                                barRadius: const Radius.circular(5),
                                backgroundColor: AppColors.surface2,
                                progressColor: g.done
                                    ? AppColors.success
                                    : AppColors.primary,
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${g.current.toStringAsFixed(g.current % 1 == 0 ? 0 : 1)} / ${g.target.toStringAsFixed(0)} ${g.unit}',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _increment(g, -1),
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: AppColors.textSecondary),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        onPressed: () => _increment(g, 1),
                                        icon: const Icon(
                                            Icons.add_circle,
                                            color: AppColors.primary),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
