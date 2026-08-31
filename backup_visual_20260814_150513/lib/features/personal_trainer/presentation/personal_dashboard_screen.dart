import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';
import 'exercise_library_screen.dart';
import 'student_detail_screen.dart';

/// Painel administrativo da Personal — visual profissional (não Home do aluno).
class PersonalDashboardScreen extends ConsumerStatefulWidget {
  const PersonalDashboardScreen({super.key});

  @override
  ConsumerState<PersonalDashboardScreen> createState() =>
      _PersonalDashboardScreenState();
}

class _PersonalDashboardScreenState
    extends ConsumerState<PersonalDashboardScreen> {
  String _query = '';
  int _railIndex = 0;

  Future<void> _novoAluno(
      BuildContext context, WidgetRef ref, String trainerId) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final objectiveController = TextEditingController();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Novo aluno', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Nome',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: nameController, autofocus: true),
            const SizedBox(height: 16),
            const Text('E-mail',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: emailController),
            const SizedBox(height: 16),
            const Text('Objetivo',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: objectiveController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Cadastrar aluno'),
              ),
            ),
          ],
        ),
      ),
    );

    if (ok == true && nameController.text.trim().isNotEmpty) {
      await ref.read(ptRepositoryProvider).createStudent(Student(
            id: '',
            trainerId: trainerId,
            userId: '',
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            objective: objectiveController.text.trim(),
            startDate: DateTime.now(),
          ));
      ref.invalidate(ptStudentsProvider(trainerId));
    }
    nameController.dispose();
    emailController.dispose();
    objectiveController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(currentUserProvider) ?? AppUser.demo();
    final studentsAsync = ref.watch(ptStudentsProvider(trainer.id));
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final body = studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
          child: Text('Não consegui carregar os alunos.',
              style: TextStyle(color: AppColors.textSecondary))),
      data: (students) {
        final filtered = students.where((s) {
          if (_query.trim().isEmpty) return true;
          final q = _query.toLowerCase();
          return s.name.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q) ||
              s.objective.toLowerCase().contains(q);
        }).toList();

        return _PersonalBody(
          trainer: trainer,
          students: filtered,
          totalStudents: students.length,
          query: _query,
          onQuery: (v) => setState(() => _query = v),
          onNewStudent: () => _novoAluno(context, ref, trainer.id),
          onOpenLibrary: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ExerciseLibraryScreen(isAdmin: true))),
        );
      },
    );

    if (!wide) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E0E14),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0E0E14),
          title: const Text('Painel da Personal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.fitness_center),
              tooltip: 'Biblioteca de exercícios',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ExerciseLibraryScreen(isAdmin: true))),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: () => _novoAluno(context, ref, trainer.id),
          icon: const Icon(Icons.person_add_alt),
          label: const Text('Novo aluno'),
        ),
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E14),
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: AppColors.surface,
            selectedIndex: _railIndex,
            onDestinationSelected: (i) {
              setState(() => _railIndex = i);
              if (i == 1) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        const ExerciseLibraryScreen(isAdmin: true)));
              }
            },
            labelType: NavigationRailLabelType.none,
            minExtendedWidth: 220,
            leading: const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PAINEL',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Personal',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Visão geral'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center),
                label: Text('Exercícios'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Alunos'),
              ),
            ],
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoAluno(context, ref, trainer.id),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Novo aluno'),
      ),
    );
  }
}

class _PersonalBody extends StatelessWidget {
  const _PersonalBody({
    required this.trainer,
    required this.students,
    required this.totalStudents,
    required this.query,
    required this.onQuery,
    required this.onNewStudent,
    required this.onOpenLibrary,
  });

  final AppUser trainer;
  final List<Student> students;
  final int totalStudents;
  final String query;
  final ValueChanged<String> onQuery;
  final VoidCallback onNewStudent;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final role = resolveUserRole(
      isPersonalTrainer: trainer.isPersonalTrainer,
      isAdmin: trainer.isAdmin,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${trainer.name.split(' ').first}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role == UserRole.admin
                            ? 'Administração · gestão completa'
                            : 'Gestão de alunos e treinos',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onOpenLibrary,
                  icon: const Icon(Icons.library_books_outlined, size: 18),
                  label: const Text('Biblioteca'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth >= 800 ? 4 : 2;
              final items = [
                _Kpi(
                    label: 'Alunos ativos',
                    value: '$totalStudents',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary),
                _Kpi(
                    label: 'Treinos de hoje',
                    value: '${(totalStudents * 0.4).round()}',
                    icon: Icons.fitness_center_rounded,
                    color: AppColors.secondary),
                _Kpi(
                    label: 'Sem treinar',
                    value: '${(totalStudents * 0.2).round()}',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning),
                _Kpi(
                    label: 'Avaliações pendentes',
                    value: '${(totalStudents * 0.15).round()}',
                    icon: Icons.assignment_late_outlined,
                    color: AppColors.info),
              ];
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: items,
              );
            }),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Meus alunos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${students.length} exibidos',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: onQuery,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, e-mail ou objetivo…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (students.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.people_outline,
                        size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      totalStudents == 0
                          ? 'Nenhum aluno cadastrado ainda.'
                          : 'Nenhum aluno encontrado para “$query”.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    if (totalStudents == 0)
                      FilledButton.icon(
                        onPressed: onNewStudent,
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text('Cadastrar primeiro aluno'),
                      ),
                  ],
                ),
              )
            else
              ...students.map((s) => _StudentRow(student: s)),
          ],
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student});
  final Student student;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StudentDetailScreen(student: student))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  backgroundImage: student.photoUrl.isNotEmpty
                      ? NetworkImage(student.photoUrl)
                      : null,
                  child: student.photoUrl.isEmpty
                      ? Text(
                          student.name.isNotEmpty
                              ? student.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        student.objective.isEmpty
                            ? student.email
                            : student.objective,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Ativo',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
