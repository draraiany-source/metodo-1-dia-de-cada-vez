import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../subscriptions/presentation/premium_gate_sheet.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../domain/course_models.dart';
import '../providers/course_providers.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.course});
  final Course course;

  IconData _iconFor(LessonType t) => switch (t) {
        LessonType.video => Icons.play_circle_outline,
        LessonType.audio => Icons.headphones,
        LessonType.pdf => Icons.picture_as_pdf_outlined,
        LessonType.texto => Icons.article_outlined,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final bloqueado = isContentLocked(ref, course.isPremium);
    final favoritos = ref.watch(courseFavoritesProvider);
    final isFavorite = favoritos.contains(course.id);
    final progressoNotifier = ref.watch(courseProgressProvider.notifier);
    final concluidas = ref.watch(courseProgressProvider)[course.id] ?? {};

    return Scaffold(
      appBar: PremiumAppBar(
        title: course.title,
        actions: [
          IconButton(
            icon: FavoriteAssetIcon(active: isFavorite, size: 22),
            onPressed: () =>
                ref.read(courseFavoritesProvider.notifier).toggle(course.id),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Share.share(
                '"${course.title}" com ${course.instructor} — '
                'disponível no Método 1 Dia de Cada Vez 💜'),
          ),
        ],
      ),
      body: bloqueado
          ? PremiumLockBody(contentName: course.title)
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(course.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, height: 1.4)),
                  const SizedBox(height: 12),
                  Text('${course.instructor} · ${course.totalLessons} aulas',
                      style: const TextStyle(color: AppColors.textTertiary)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progressoNotifier.progressFor(course),
                    backgroundColor: AppColors.surface,
                    color: AppColors.success,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '${(progressoNotifier.progressFor(course) * 100).round()}% concluído',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 20),
                  for (final modulo in course.modules) ...[
                    Text(modulo.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 8),
                    ...modulo.lessons.map((licao) {
                      final feita = concluidas.contains(licao.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: ListTile(
                          leading: Icon(_iconFor(licao.type),
                              color: feita
                                  ? AppColors.success
                                  : AppColors.textSecondary),
                          title: Text(licao.title,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: licao.durationSeconds > 0
                              ? Text(
                                  '${(licao.durationSeconds / 60).round()}min',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12))
                              : null,
                          trailing: Checkbox(
                            value: feita,
                            activeColor: AppColors.success,
                            onChanged: (_) => progressoNotifier.markDone(
                                course.id, licao.id),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                  if (course.modules.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                          'Nenhuma aula cadastrada ainda neste curso.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                ],
              ),
            ),
    );
  }
}
