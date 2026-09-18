import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../accompaniment/presentation/chat_thread_screen.dart';
import '../../accompaniment/providers/accompaniment_providers.dart';
import '../../evolution/domain/training_volume.dart';
import '../../evolution/presentation/load_history_screen.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';
import 'evolution_pt_screen.dart';
import 'student_anamnesis_screen.dart';
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
  late Student _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _editarAluno() async {
    final name = TextEditingController(text: _student.name);
    final email = TextEditingController(text: _student.email);
    final phone = TextEditingController(text: _student.phone);
    final objective = TextEditingController(text: _student.objective);
    final notes = TextEditingController(text: _student.notes);
    final age = TextEditingController(
        text: _student.age == null ? '' : '${_student.age}');
    final weight = TextEditingController(
        text: _student.weightKg == null
            ? ''
            : _student.weightKg!.toStringAsFixed(1));
    final height = TextEditingController(
        text: _student.heightM == null
            ? ''
            : _student.heightM!.toStringAsFixed(2));
    var sex = _student.sex;
    var level = _student.level;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Editar aluno', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'E-mail')),
                TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telefone'), keyboardType: TextInputType.phone),
                TextField(controller: age, decoration: const InputDecoration(labelText: 'Idade'), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  value: sex.isEmpty ? null : sex,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: const [
                    DropdownMenuItem(value: 'feminino', child: Text('Feminino')),
                    DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'outro', child: Text('Outro')),
                  ],
                  onChanged: (v) => setSheet(() => sex = v ?? ''),
                ),
                TextField(controller: weight, decoration: const InputDecoration(labelText: 'Peso (kg)'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                TextField(controller: height, decoration: const InputDecoration(labelText: 'Altura (m)'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                DropdownButtonFormField<NivelTreino>(
                  value: level,
                  decoration: const InputDecoration(labelText: 'Nível'),
                  items: [
                    for (final l in NivelTreino.values)
                      DropdownMenuItem(value: l, child: Text(l.label)),
                  ],
                  onChanged: (v) => setSheet(() => level = v ?? level),
                ),
                TextField(controller: objective, decoration: const InputDecoration(labelText: 'Objetivo')),
                TextField(controller: notes, decoration: const InputDecoration(labelText: 'Observações'), maxLines: 3),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true && name.text.trim().isNotEmpty) {
      final updated = _student.copyWith(
        name: name.text.trim(),
        email: email.text.trim().toLowerCase(),
        phone: phone.text.trim(),
        age: int.tryParse(age.text.trim()),
        sex: sex,
        weightKg: double.tryParse(weight.text.replaceAll(',', '.')),
        heightM: double.tryParse(height.text.replaceAll(',', '.')),
        level: level,
        objective: objective.text.trim(),
        notes: notes.text.trim(),
      );
      await ref.read(ptRepositoryProvider).updateStudent(updated);
      ref.invalidate(ptStudentsProvider(_student.trainerId));
      if (mounted) setState(() => _student = updated);
    }
  }

  Future<void> _arquivarAluno() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Arquivar aluno?'),
        content: const Text(
          'O aluno deixa de aparecer na lista ativa e não vê mais o treino.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(ptRepositoryProvider).deactivateStudent(_student.id);
    ref.invalidate(ptStudentsProvider(_student.trainerId));
    ref.invalidate(ptDashboardStatsProvider(_student.trainerId));
    if (mounted) Navigator.pop(context);
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
            studentId: _student.id,
            trainerId: _student.trainerId,
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
      ref.invalidate(ptAssessmentsProvider(_student.id));
    }
  }

  Future<void> _vincularConta() async {
    final controller = TextEditingController(text: _student.userId);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Vincular conta do aluno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E-mail cadastrado: ${_student.email.isEmpty ? '(não informado)' : _student.email}\n\n'
              'Se o aluno já usa o app, ele vincula automaticamente ao abrir '
              'Meu Treino com o mesmo e-mail. Ou cole o UID da conta Firebase:',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'UID do usuário'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (ok == true && controller.text.trim().isNotEmpty) {
      await ref
          .read(ptRepositoryProvider)
          .linkStudentUserId(_student.id, controller.text.trim());
      if (mounted) {
        setState(() => _student = _student.copyWith(userId: controller.text.trim()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta vinculada.')),
        );
      }
    }
    controller.dispose();
  }

  Future<void> _abrirChat() async {
    try {
      final conv = await ref
          .read(accompanimentRepositoryProvider)
          .ensureConversation(student: _student);
      if (!mounted) return;
      context.push(
        '${Routes.trainerInbox}/chat/${conv.id}',
        extra: ChatThreadRouteArgs(
          conversation: conv,
          isTrainer: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o chat. $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          IconButton(
            tooltip: 'Editar dados',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editarAluno,
          ),
          IconButton(
            tooltip: 'Anamnese',
            icon: const Icon(Icons.assignment_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StudentAnamnesisScreen(student: _student),
            )),
          ),
          IconButton(
            tooltip: 'Evolução',
            icon: const Icon(Icons.show_chart),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EvolutionPtScreen(student: _student),
            )),
          ),
          IconButton(
            tooltip: 'Cargas',
            icon: const Icon(Icons.fitness_center_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LoadHistoryScreen(studentId: _student.id),
            )),
          ),
          IconButton(
            tooltip: 'Vincular conta',
            icon: const Icon(Icons.link),
            onPressed: _vincularConta,
          ),
          IconButton(
            tooltip: 'Arquivar',
            icon: const Icon(Icons.archive_outlined),
            onPressed: _arquivarAluno,
          ),
          PopupMenuButton<String>(
            tooltip: 'Acompanhamento',
            onSelected: (v) async {
              if (v == 'chat') {
                await _abrirChat();
              } else if (v == 'agenda') {
                if (mounted) context.push(Routes.trainerAgenda);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'chat', child: Text('Chat com aluna')),
              PopupMenuItem(
                  value: 'agenda', child: Text('Agenda / consultoria')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Avaliações'),
            Tab(text: 'Fotos'),
            Tab(text: 'Treinos'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _AssessmentsTab(
              student: _student, onAdd: () => _novaAvaliacao(context)),
          _PhotosTab(student: _student),
          _WorkoutsTab(student: _student),
          _SessionsHistoryTab(student: _student),
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

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    var tipo = FotoTipo.frente;
    final picker = ImagePicker();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nova foto de evolução',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16)),
              const SizedBox(height: 12),
              DropdownButtonFormField<FotoTipo>(
                value: tipo,
                items: FotoTipo.values
                    .map((t) => DropdownMenuItem(
                        value: t, child: Text(t.name.toUpperCase())))
                    .toList(),
                onChanged: (v) => setSheet(() => tipo = v ?? tipo),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Escolher da galeria'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    final x = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 82, maxWidth: 1600);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final url = await ref.read(ptRepositoryProvider).uploadEvolutionPhoto(
          studentId: student.id,
          bytes: bytes,
          fileName: '${tipo.name}.jpg',
        );
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha no upload. Verifique o Storage.')),
        );
      }
      return;
    }
    await ref.read(ptRepositoryProvider).createPhoto(EvolutionPhoto(
          id: '',
          studentId: student.id,
          trainerId: student.trainerId,
          date: DateTime.now(),
          tipo: tipo,
          url: url,
        ));
    ref.invalidate(ptPhotosProvider(student.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(ptPhotosProvider(student.id));
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _upload(context, ref),
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('Não consegui carregar.',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                    'Nenhuma foto de evolução ainda.\n'
                    'Toque em + para enviar frontal, lateral, costas ou outras.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          final first = photos.first;
          final last = photos.last;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (photos.length >= 2) ...[
                const Text('Comparação',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 0.75,
                              child: Image.network(first.url, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Primeira\n${first.date.day}/${first.date.month}/${first.date.year}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 0.75,
                              child: Image.network(last.url, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Atual\n${last.date.day}/${last.date.month}/${last.date.year}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const Text('Galeria',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: photos.length,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(photos[i].url, fit: BoxFit.cover),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SessionsHistoryTab extends ConsumerWidget {
  const _SessionsHistoryTab({required this.student});
  final Student student;

  String _diffLabel(String d) => switch (d) {
        'muito_leve' => 'Muito leve',
        'adequado' => 'Adequado',
        'dificil' => 'Difícil',
        'muito_dificil' => 'Muito difícil',
        _ => d.isEmpty ? '—' : d,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(ptSessionsProvider(student.id));
    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
          child: Text('Não consegui carregar.',
              style: TextStyle(color: AppColors.textSecondary))),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Text('Nenhum treino concluído ainda.',
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        final ordered = [...list]..sort((a, b) => b.date.compareTo(a.date));
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: ordered.length,
          itemBuilder: (_, i) {
            final s = ordered[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(s.workoutName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${s.date.day.toString().padLeft(2, '0')}/'
                  '${s.date.month.toString().padLeft(2, '0')}/'
                  '${s.date.year} · ${s.completedExerciseIds.length} exercícios'
                  '${s.totalVolumeKg != null ? ' · ${TrainingVolume.formatVolume(s.totalVolumeKg!)}' : ''}'
                  '${s.difficulty.isNotEmpty ? ' · ${_diffLabel(s.difficulty)}' : ''}'
                  '${s.feltPain == true ? ' · sentiu dor' : ''}'
                  '${s.feedbackNotes.isNotEmpty ? '\n${s.feedbackNotes}' : ''}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ),
            );
          },
        );
      },
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
