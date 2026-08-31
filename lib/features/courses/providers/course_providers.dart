import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/courses_repository.dart';
import '../domain/course_models.dart';

final coursesRepositoryProvider = Provider((ref) => CoursesRepository());

final coursesProvider = FutureProvider<List<Course>>((ref) {
  return ref.read(coursesRepositoryProvider).fetchAll();
});

class CourseFavoritesNotifier extends StateNotifier<Set<String>> {
  CourseFavoritesNotifier() : super({}) {
    _load();
  }
  static const _key = 'course_favorites';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getStringList(_key) ?? []).toSet();
  }

  Future<void> toggle(String id) async {
    final Set<String> set = <String>{...state};
    set.contains(id) ? set.remove(id) : set.add(id);
    state = set;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, set.toList());
  }
}

final courseFavoritesProvider =
    StateNotifierProvider<CourseFavoritesNotifier, Set<String>>((ref) {
  return CourseFavoritesNotifier();
});

/// Progresso do curso — aulas concluídas por curso (chave: courseId,
/// valor: set de lessonIds concluídos).
class CourseProgressNotifier extends StateNotifier<Map<String, Set<String>>> {
  CourseProgressNotifier() : super({}) {
    _load();
  }
  static const _key = 'course_progress';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state =
          map.map((k, v) => MapEntry(k, (v as List).cast<String>().toSet()));
    } catch (_) {/* progresso corrompido descartado */}
  }

  Future<void> markDone(String courseId, String lessonId) async {
    final Set<String> set = <String>{
      ...(state[courseId] ?? <String>{}),
      lessonId,
    };
    state = {...state, courseId: set};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((k, v) => MapEntry(k, v.toList()))));
  }

  double progressFor(Course course) {
    if (course.totalLessons == 0) return 0;
    final done = state[course.id]?.length ?? 0;
    return (done / course.totalLessons).clamp(0, 1);
  }
}

final courseProgressProvider =
    StateNotifierProvider<CourseProgressNotifier, Map<String, Set<String>>>(
        (ref) {
  return CourseProgressNotifier();
});
