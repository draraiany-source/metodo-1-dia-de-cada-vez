import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/app_icons.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../personal_amanda/domain/amanda_asset_models.dart';
import '../../personal_amanda/presentation/amanda_image.dart';
import '../domain/pt_models.dart';
import '../providers/pt_providers.dart';
import 'exercise_library_screen.dart';
import 'evolution_pt_screen.dart';
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
      final email = emailController.text.trim().toLowerCase();
      await ref.read(ptRepositoryProvider).createStudent(Student(
            id: '',
            trainerId: trainerId,
            userId: '',
            name: nameController.text.trim(),
            email: email,
            objective: objectiveController.text.trim(),
            startDate: DateTime.now(),
          ));
      ref.invalidate(ptStudentsProvider(trainerId));
      ref.invalidate(ptDashboardStatsProvider(trainerId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(email.isEmpty
              ? 'Aluno cadastrado. Informe o e-mail da conta do app para vincular.'
              : 'Aluno cadastrado. Quando entrar com $email, o treino aparece em Meu Treino.'),
        ));
      }
    }
    nameController.dispose();
    emailController.dispose();
    objectiveController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
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
          onManagePhotos: () =>
              AppNavigation.open(context, Routes.amandaAssetsAdmin),
          onEditProfile: () =>
              AppNavigation.open(context, Routes.amandaProfileEdit),
        );
      },
    );

    if (!wide) {
      return Scaffold(
        backgroundColor: const Color(0xFF0E0E14),
        appBar: PremiumAppBar(
          title: 'Central da Personal',
          actions: [
            IconButton(
              icon: AppIconImage(
                AppIcons.personal,
                size: 24,
                fallbackIcon: Icons.edit_outlined,
              ),
              tooltip: 'Editar Quem Sou Eu',
              onPressed: () =>
                  AppNavigation.open(context, Routes.amandaProfileEdit),
            ),
            IconButton(
              icon: AppIconImage(
                AppIcons.gallery,
                size: 24,
                fallbackIcon: Icons.photo_camera_outlined,
              ),
              tooltip: 'Fotos da Amanda',
              onPressed: () =>
                  AppNavigation.open(context, Routes.amandaAssetsAdmin),
            ),
            IconButton(
              icon: AppIconImage(
                AppIcons.workout,
                size: 24,
                fallbackIcon: Icons.fitness_center,
              ),
              tooltip: 'Biblioteca de exercícios',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ExerciseLibraryScreen(isAdmin: true))),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: () => _novoAluno(context, ref, trainer.id),
          icon: const AppIconImage(
            AppIcons.community,
            size: 22,
            fallbackIcon: Icons.person_add_alt,
          ),
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
                  Text('Amanda Lopes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  SizedBox(height: 2),
                  Text('Personal Trainer',
                      style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: AppIconImage(
                  AppIcons.personal,
                  size: 24,
                  fallbackIcon: Icons.dashboard_outlined,
                ),
                selectedIcon: AppIconImage(
                  AppIcons.personal,
                  size: 24,
                  fallbackIcon: Icons.dashboard_rounded,
                ),
                label: const Text('Visão geral'),
              ),
              NavigationRailDestination(
                icon: AppIconImage(
                  AppIcons.workout,
                  size: 24,
                  fallbackIcon: Icons.fitness_center_outlined,
                ),
                selectedIcon: AppIconImage(
                  AppIcons.workout,
                  size: 24,
                  fallbackIcon: Icons.fitness_center,
                ),
                label: const Text('Exercícios'),
              ),
              NavigationRailDestination(
                icon: AppIconImage(
                  AppIcons.community,
                  size: 24,
                  fallbackIcon: Icons.people_outline,
                ),
                selectedIcon: AppIconImage(
                  AppIcons.community,
                  size: 24,
                  fallbackIcon: Icons.people,
                ),
                label: const Text('Alunos'),
              ),
            ],
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _novoAluno(context, ref, trainer.id),
        icon: const AppIconImage(
          AppIcons.community,
          size: 22,
          fallbackIcon: Icons.person_add_alt,
        ),
        label: const Text('Novo aluno'),
      ),
    );
  }
}

class _PersonalBody extends ConsumerWidget {
  const _PersonalBody({
    required this.trainer,
    required this.students,
    required this.totalStudents,
    required this.query,
    required this.onQuery,
    required this.onNewStudent,
    required this.onOpenLibrary,
    required this.onManagePhotos,
    required this.onEditProfile,
  });

  final AppUser trainer;
  final List<Student> students;
  final int totalStudents;
  final String query;
  final ValueChanged<String> onQuery;
  final VoidCallback onNewStudent;
  final VoidCallback onOpenLibrary;
  final VoidCallback onManagePhotos;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = resolveUserRole(
      isPersonalTrainer: trainer.isPersonalTrainer,
      isAdmin: trainer.isAdmin,
    );
    final statsAsync = ref.watch(ptDashboardStatsProvider(trainer.id));
    final stats = statsAsync.valueOrNull;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          children: [
            _AmandaProfessionalHeader(
              trainerFirstName: trainer.name.split(' ').first,
              isAdmin: role == UserRole.admin,
              onOpenLibrary: onOpenLibrary,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(builder: (context, c) {
              final cols = c.maxWidth >= 800 ? 4 : 2;
              final items = [
                _Kpi(
                  label: 'Alunos ativos',
                  value: '${stats?.activeStudents ?? totalStudents}',
                  iconAsset: AppIcons.community,
                  fallbackIcon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                ),
                _Kpi(
                  label: 'Treinos de hoje',
                  value: '${stats?.sessionsToday ?? '…'}',
                  iconAsset: AppIcons.workout,
                  fallbackIcon: Icons.fitness_center_rounded,
                  color: AppColors.secondary,
                ),
                _Kpi(
                  label: 'Sem treinar (5d+)',
                  value: '${stats?.inactiveStudents ?? '…'}',
                  iconAsset: AppIcons.notifications,
                  fallbackIcon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
                _Kpi(
                  label: 'Com histórico',
                  value: '${stats?.completionRatePercent ?? 0}%',
                  iconAsset: AppIcons.checklist,
                  fallbackIcon: Icons.assignment_turned_in_outlined,
                  color: AppColors.info,
                ),
              ];
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.15,
                children: items,
              );
            }),
            const SizedBox(height: 16),
            const Text('Atalhos',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ShortcutChip(
                  label: 'Novo aluno',
                  icon: Icons.person_add_alt,
                  onTap: onNewStudent,
                ),
                _ShortcutChip(
                  label: 'Criar treino',
                  icon: Icons.fitness_center,
                  onTap: () {
                    if (students.isEmpty) {
                      onNewStudent();
                      return;
                    }
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => StudentDetailScreen(student: students.first),
                    ));
                  },
                ),
                _ShortcutChip(
                  label: 'Biblioteca',
                  icon: Icons.menu_book_outlined,
                  onTap: onOpenLibrary,
                ),
                _ShortcutChip(
                  label: 'Evolução',
                  icon: Icons.show_chart,
                  onTap: () {
                    if (students.isEmpty) return;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => EvolutionPtScreen(student: students.first),
                    ));
                  },
                ),
                _ShortcutChip(
                  label: 'Receitas',
                  icon: Icons.restaurant_outlined,
                  onTap: () =>
                      AppNavigation.open(context, Routes.recipes),
                ),
                _ShortcutChip(
                  label: 'Mensagens',
                  icon: Icons.chat_bubble_outline,
                  onTap: () => AppNavigation.open(context, Routes.trainerInbox),
                ),
                _ShortcutChip(
                  label: 'Agenda',
                  icon: Icons.event_available,
                  onTap: () => AppNavigation.open(context, Routes.trainerAgenda),
                ),
                _ShortcutChip(
                  label: 'Google Calendar',
                  icon: Icons.sync,
                  onTap: () =>
                      AppNavigation.open(context, Routes.googleCalendarSettings),
                ),
                _ShortcutChip(
                  label: 'IA da Personal',
                  icon: Icons.auto_awesome,
                  onTap: () => AppNavigation.open(context, Routes.aiSettings),
                ),
                _ShortcutChip(
                  label: 'Áudios',
                  icon: Icons.headphones_outlined,
                  onTap: () =>
                      AppNavigation.open(context, Routes.audiosMeditations),
                ),
                _ShortcutChip(
                  label: 'Perfil',
                  icon: Icons.person_outline,
                  onTap: onEditProfile,
                ),
                _ShortcutChip(
                  label: 'Fotos',
                  icon: Icons.photo_library_outlined,
                  onTap: onManagePhotos,
                ),
                _ShortcutChip(
                  label: 'Quem Sou Eu',
                  icon: Icons.badge_outlined,
                  onTap: () =>
                      AppNavigation.open(context, Routes.amandaProfile),
                ),
                _ShortcutChip(
                  label: 'Config',
                  icon: Icons.settings_outlined,
                  onTap: () =>
                      AppNavigation.open(context, Routes.settings),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onEditProfile,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.edit_note_rounded,
                            color: AppColors.secondary),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Editar Quem Sou Eu',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            SizedBox(height: 4),
                            Text(
                              'Apresentação, história, método, redes e contato.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      AppIconImage(
                        AppIcons.next,
                        size: 18,
                        fallbackIcon: Icons.chevron_right_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onManagePhotos,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const AmandaImage(
                        category: AmandaAssetCategory.profissional,
                        size: 52,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        fallbacks: [AmandaAssetCategory.principal],
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fotos da Amanda',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15)),
                            SizedBox(height: 4),
                            Text(
                              'Capa, perfil, galeria, treinos e trajetória.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35),
                            ),
                          ],
                        ),
                      ),
                      const AppIconImage(
                        AppIcons.gallery,
                        size: 22,
                        fallbackIcon: Icons.photo_library_outlined,
                      ),
                      const SizedBox(width: 4),
                      AppIconImage(
                        AppIcons.next,
                        size: 18,
                        fallbackIcon: Icons.chevron_right_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const AppIconImage(
                  AppIcons.community,
                  size: 22,
                  fallbackIcon: Icons.people_alt_rounded,
                ),
                const SizedBox(width: 8),
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
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: AppIconImage(
                    AppIcons.search,
                    size: 20,
                    fallbackIcon: Icons.search,
                  ),
                ),
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
                    const AppIconImage(
                      AppIcons.community,
                      size: 44,
                      fallbackIcon: Icons.people_outline,
                    ),
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
                        icon: const AppIconImage(
                          AppIcons.community,
                          size: 18,
                          fallbackIcon: Icons.person_add_alt,
                        ),
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

class _AmandaProfessionalHeader extends StatelessWidget {
  const _AmandaProfessionalHeader({
    required this.trainerFirstName,
    required this.isAdmin,
    required this.onOpenLibrary,
  });

  final String trainerFirstName;
  final bool isAdmin;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceElevated,
            AppColors.secondary.withOpacity(0.18),
            AppColors.primary.withOpacity(0.22),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AmandaImage(
            category: AmandaAssetCategory.profissional,
            size: 78,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            fallbacks: [
              AmandaAssetCategory.principal,
              AmandaAssetCategory.banner,
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Central da Personal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Olá, $trainerFirstName',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Amanda Lopes',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAdmin
                      ? 'Treinadora Pessoal · Administração'
                      : 'Treinadora Pessoal On-line · Emagrecimento & hipertrofia',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onOpenLibrary,
                      icon: const AppIconImage(
                        AppIcons.workout,
                        size: 16,
                        fallbackIcon: Icons.library_books_outlined,
                      ),
                      label: const Text('Biblioteca'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const AppIconImage(
            AppIcons.personal,
            size: 28,
            fallbackIcon: Icons.sports_gymnastics_rounded,
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.color,
  });

  final String label;
  final String value;
  final String iconAsset;
  final IconData fallbackIcon;
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
            alignment: Alignment.center,
            child: AppIconImage(
              iconAsset,
              size: 22,
              fallbackIcon: fallbackIcon,
            ),
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
                AppIconImage(
                  AppIcons.next,
                  size: 18,
                  fallbackIcon: Icons.chevron_right,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: AppColors.secondary),
      label: Text(label),
      backgroundColor: AppColors.surface2,
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12.5),
    );
  }
}
