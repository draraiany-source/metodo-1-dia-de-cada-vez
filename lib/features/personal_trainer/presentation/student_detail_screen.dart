import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';
import 'workout_builder_screen.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  const StudentDetailScreen({super.key, required this.student});
  final Student student;

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen>
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

  Future<void> _novaAvaliacao(BuildContext context) async {
    final controllers = {
      for (final campo in [
        'weightKg',
        'heightM',
        'bodyFatPercent',
        'muscleMassKg',
        'circBraco',
        'circPeitoral',
        'circCintura',
        'circAbdomen',
        'circQuadril',
        'circCoxa',
        'circPanturrilha',
      ])
        campo: TextEditingController(),
    };
    const labels = {
      'weightKg': 'Peso (kg)',
      'heightM': 'Altura (m)',
      'bodyFatPercent': '% de gordura',
      'muscleMassKg': 'Massa muscular (kg)',
      'circBraco': 'Braço (cm)',
      'circPeitoral': 'Peitoral (cm)',
      'circCintura': 'Cintura (cm)',
      'circAbdomen': 'Abdômen (cm)',
      'circQuadril': 'Quadril (cm)',
      'circCoxa': 'Coxa (cm)',
      'circPanturrilha': 'Panturrilha (cm)',
    };

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nova avaliação física',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              for (final campo in controllers.keys) ...[
                Text(labels[campo]!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: controllers[campo],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Salvar avaliação'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      double? d(String k) =>
          double.tryParse(controllers[k]!.text.replaceAll(',', '.'));
      await ref.read(ptRepositoryProvider).createAssessment(PhysicalAssessment(
            id: '',
            studentId: widget.student.id,
            trainerId: widget.student.trainerId,
            date: DateTime.now(),
            weightKg: d('weightKg'),
            heightM: d('heightM'),
            bodyFatPercent: d('bodyFatPercent'),
            muscleMassKg: d('muscleMassKg'),
            circBraco: d('circBraco'),
            circPeitoral: d('circPeitoral'),
            circCintura: d('circCintura'),
            circAbdomen: d('circAbdomen'),
            circQuadril: d('circQuadril'),
            circCoxa: d('circCoxa'),
            circPanturrilha: d('circPanturrilha'),
          ));
      ref.invalidate(ptAssessmentsProvider(widget.student.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Avaliações'),
            Tab(text: 'Fotos'),
            Tab(text: 'Treinos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _AssessmentsTab(
              student: widget.student, onAdd: () => _novaAvaliacao(context)),
          _PhotosTab(student: widget.student),
          _WorkoutsTab(student: widget.student),
        ],
      ),
    );
  }
}

class _AssessmentsTab extends ConsumerWidget {
  const _AssessmentsTab({required this.student, required this.onAdd});
  final Student student;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync = ref.watch(ptAssessmentsProvider(student.id));
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: onAdd,
        child: const AppIconImage(
          AppIcons.bmiMeasure,
          size: 24,
          fallbackIcon: Icons.add,
        ),
      ),
      body: assessmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('Não consegui carregar.',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('Nenhuma avaliação registrada ainda.',
                    style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final a = list[list.length - 1 - i]; // mais recente primeiro
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_fmtDate(a.date),
                              style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 16,
                            runSpacing: 4,
                            children: [
                              if (a.weightKg != null)
                                _chip('${a.weightKg!.toStringAsFixed(1)} kg'),
                              if (a.imc != null)
                                _chip('IMC ${a.imc!.toStringAsFixed(1)}'),
                              if (a.bodyFatPercent != null)
                                _chip('${a.bodyFatPercent!.toStringAsFixed(1)}% gordura'),
                              if (a.muscleMassKg != null)
                                _chip('${a.muscleMassKg!.toStringAsFixed(1)} kg músculo'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _chip(String t) => Text(t,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12));

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _PhotosTab extends ConsumerWidget {
  const _PhotosTab({required this.student});
  final Student student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(ptPhotosProvider(student.id));
    return photosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
          child: Text('Não consegui carregar.',
              style: TextStyle(color: AppColors.textSecondary))),
      data: (photos) => photos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                    'Nenhuma foto de evolução ainda.\n'
                    '(upload via Firebase Storage: pt_photos/{studentId})',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: photos.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(photos[i].url, fit: BoxFit.cover),
              ),
            ),
    );
  }
}

class _WorkoutsTab extends ConsumerWidget {
  const _WorkoutsTab({required this.student});
  final Student student;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WorkoutPlan plan,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Excluir treino?'),
        content: Text(
          '“${plan.name}” deixará de aparecer para a aluna. '
          'Essa ação pode ser revertida no banco depois, se necessário.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(ptRepositoryProvider).deactivateWorkoutPlan(plan.id);
    ref.invalidate(ptWorkoutPlansProvider(student.id));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Treino “${plan.name}” removido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(ptWorkoutPlansProvider(student.id));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => WorkoutBuilderScreen(student: student))),
        icon: const AppIconImage(
          AppIcons.workout,
          size: 22,
          fallbackIcon: Icons.add,
        ),
        label: const Text('Novo treino'),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('Não consegui carregar.',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (plans) => plans.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIconImage(
                        AppIcons.workout,
                        size: 56,
                        fallbackIcon: Icons.fitness_center,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Nenhum treino montado ainda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                WorkoutBuilderScreen(student: student),
                          ),
                        ),
                        icon: const AppIconImage(
                          AppIcons.play,
                          size: 18,
                          fallbackIcon: Icons.add,
                        ),
                        label: const Text('Criar primeiro treino'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: plans.length,
                itemBuilder: (_, i) {
                  final p = plans[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                      child: Row(
                        children: [
                          const AppIconImage(
                            AppIcons.workout,
                            size: 32,
                            fallbackIcon: Icons.fitness_center,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(
                                  '${p.exercises.length} exercícios · ${p.level.label}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                                if (p.diasSemana.isNotEmpty)
                                  Text(
                                    p.diasSemana.join(' · '),
                                    style: const TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => WorkoutBuilderScreen(
                                  student: student,
                                  existingPlan: p,
                                ),
                              ),
                            ),
                            icon: const AppIconImage(
                              AppIcons.edit,
                              size: 20,
                              fallbackIcon: Icons.edit_outlined,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Duplicar',
                            onPressed: () async {
                              await ref
                                  .read(ptRepositoryProvider)
                                  .duplicateWorkoutPlan(
                                      p, '${p.name} (cópia)');
                              ref.invalidate(
                                  ptWorkoutPlansProvider(student.id));
                            },
                            icon: const AppIconImage(
                              AppIcons.checklist,
                              size: 20,
                              fallbackIcon: Icons.copy_outlined,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            onPressed: () => _confirmDelete(context, ref, p),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.danger,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
