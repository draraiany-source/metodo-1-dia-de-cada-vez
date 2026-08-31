import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/course_models.dart';
import '../providers/course_providers.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});

  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  CourseCategory? _filtro;

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);
    final favoritos = ref.watch(courseFavoritesProvider);
    final progresso = ref.watch(courseProgressProvider.notifier);
    final user = ref.watch(currentUserProvider) ?? AppUser.demo();

    return Scaffold(
      appBar: AppBar(title: const Text('Cursos 📖')),
      body: SafeArea(
        child: coursesAsync.when(
          loading: () => const AppListSkeleton(),
          error: (_, __) =>
              AppErrorState(onRetry: () => ref.invalidate(coursesProvider)),
          data: (courses) {
            final filtrados = _filtro == null
                ? courses
                : courses.where((c) => c.category == _filtro).toList();

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Módulos, aulas e material completo',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _Chip(
                                  label: 'Todos',
                                  selected: _filtro == null,
                                  onTap: () => setState(() => _filtro = null)),
                              ...CourseCategory.values.map((c) => _Chip(
                                    label: c.label,
                                    selected: _filtro == c,
                                    onTap: () => setState(() => _filtro = c),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (courses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: ComingSoonView(
                              emoji: '📖',
                              title: 'Nenhum curso disponível ainda',
                              description:
                                  'Assim que os cursos forem cadastrados, eles aparecem aqui automaticamente.',
                            ),
                          )
                        else if (filtrados.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text('Nenhum curso nessa categoria ainda.',
                                  style:
                                      TextStyle(color: AppColors.textSecondary)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _CourseCard(
                        course: filtrados[i],
                        isFavorite: favoritos.contains(filtrados[i].id),
                        locked: filtrados[i].isPremium && !user.isPremium,
                        progresso: progresso.progressFor(filtrados[i]),
                      ),
                      childCount: filtrados.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
          label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.isFavorite,
    required this.locked,
    required this.progresso,
  });
  final Course course;
  final bool isFavorite;
  final bool locked;
  final double progresso;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CourseDetailScreen(course: course))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  course.coverUrl.isEmpty
                      ? Container(
                          color: AppColors.background,
                          child: const Icon(Icons.play_lesson_outlined,
                              color: AppColors.textTertiary, size: 40))
                      : CachedNetworkImage(
                          imageUrl: course.coverUrl, fit: BoxFit.cover),
                  if (locked)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                          child:
                              Icon(Icons.lock, color: Colors.white, size: 28)),
                    ),
                  if (isFavorite)
                    const Positioned(
                        right: 8,
                        top: 8,
                        child: Icon(Icons.favorite,
                            color: AppColors.secondary, size: 18)),
                ],
              ),
            ),
            if (progresso > 0)
              LinearProgressIndicator(
                value: progresso,
                minHeight: 3,
                backgroundColor: AppColors.background,
                color: AppColors.success,
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${course.instructor} · ${course.totalLessons} aulas · ${course.category.label}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
