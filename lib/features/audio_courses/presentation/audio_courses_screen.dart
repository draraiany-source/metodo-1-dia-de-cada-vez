import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/favorites/unified_favorites.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/audio_courses_repository.dart';
import '../domain/audio_course_models.dart';
import '../providers/audio_course_providers.dart';
import 'audio_course_player_screen.dart';

class AudioCoursesScreen extends ConsumerStatefulWidget {
  const AudioCoursesScreen({
    super.key,
    this.title = 'Cursos em áudio 🎧',
    this.subtitle = 'Mentalidade, hábitos e bem-estar, no seu ritmo',
    this.onlyCategories,
  });

  final String title;
  final String subtitle;

  /// Se informado, mostra só essas categorias (usado por Meditações e
  /// Biblioteca da Lili Fit, que são recortes desta mesma biblioteca —
  /// evita duplicar model/repositório/provider/tela pra cada uma).
  final Set<AudioCourseCategory>? onlyCategories;

  @override
  ConsumerState<AudioCoursesScreen> createState() =>
      _AudioCoursesScreenState();
}

class _AudioCoursesScreenState extends ConsumerState<AudioCoursesScreen> {
  AudioCourseCategory? _filtro;

  List<AudioCourseCategory> get _categoriasDisponiveis =>
      widget.onlyCategories?.toList() ?? AudioCourseCategory.values;

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(audioCoursesProvider);
    final favoritos = ref.watch(audioFavoritesProvider);

    return Scaffold(
      appBar: PremiumAppBar(title: widget.title),
      body: SafeArea(
        child: coursesAsync.when(
          loading: () => const AppListSkeleton(),
          error: (error, _) => AppErrorState(
            message: error is AudioCoursesFetchException
                ? error.userMessage
                : FirebaseErrorMapper.toUserMessage(error),
            onRetry: () => ref.invalidate(audioCoursesProvider),
          ),
          data: (allCourses) {
            final courses = widget.onlyCategories == null
                ? allCourses
                : allCourses
                    .where((c) => widget.onlyCategories!.contains(c.category))
                    .toList();
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
                        Text(widget.subtitle,
                            style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _CategoryChip(
                                label: 'Todos',
                                selected: _filtro == null,
                                onTap: () => setState(() => _filtro = null),
                              ),
                              ..._categoriasDisponiveis.map((c) => _CategoryChip(
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
                              emoji: '🎧',
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course, required this.isFavorite});
  final AudioCourse course;
  final bool isFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutos = course.duracaoTotal.inMinutes;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: course.coverUrl.isEmpty
              ? Container(
                  width: 56,
                  height: 56,
                  color: AppColors.background,
                  child: const Icon(Icons.headphones,
                      color: AppColors.textTertiary),
                )
              : CachedNetworkImage(imageUrl: course.coverUrl,
                  width: 56, height: 56, fit: BoxFit.cover),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(course.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            IconButton(
              icon: FavoriteAssetIcon(active: isFavorite, size: 22),
              onPressed: () async {
                await ref
                    .read(audioFavoritesProvider.notifier)
                    .toggle(course.id);
                const meditationCats = {
                  AudioCourseCategory.meditacao,
                  AudioCourseCategory.respiracao,
                  AudioCourseCategory.ansiedade,
                  AudioCourseCategory.sono,
                };
                if (meditationCats.contains(course.category)) {
                  await ref
                      .read(unifiedFavoritesProvider.notifier)
                      .toggle(FavoriteKind.meditation, course.id);
                }
              },
            ),
          ],
        ),
        subtitle: Text(
          '${course.teacher} · ${course.chapters.length} capítulos · ${minutos}min',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AudioCoursePlayerScreen(course: course),
          )),
          child: const Text('Começar'),
        ),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AudioCoursePlayerScreen(course: course),
        )),
      ),
    );
  }
}
