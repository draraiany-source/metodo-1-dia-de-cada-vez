import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pt_repository.dart';
import '../domain/pt_models.dart';

final ptRepositoryProvider = Provider((ref) => PtRepository());

final ptStudentsProvider =
    FutureProvider.family<List<Student>, String>((ref, trainerId) {
  return ref.read(ptRepositoryProvider).fetchStudents(trainerId);
});

final ptMyStudentProfileProvider =
    FutureProvider.family<Student?, String>((ref, userId) {
  return ref.read(ptRepositoryProvider).fetchStudentByUserId(userId);
});

final ptExercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.read(ptRepositoryProvider).fetchExercises();
});

final ptWorkoutPlansProvider =
    FutureProvider.family<List<WorkoutPlan>, String>((ref, studentId) {
  return ref.read(ptRepositoryProvider).fetchWorkoutPlans(studentId);
});

final ptAssessmentsProvider =
    FutureProvider.family<List<PhysicalAssessment>, String>((ref, studentId) {
  return ref.read(ptRepositoryProvider).fetchAssessments(studentId);
});

final ptPhotosProvider =
    FutureProvider.family<List<EvolutionPhoto>, String>((ref, studentId) {
  return ref.read(ptRepositoryProvider).fetchPhotos(studentId);
});

final ptSessionsProvider =
    FutureProvider.family<List<WorkoutSessionLog>, String>((ref, studentId) {
  return ref.read(ptRepositoryProvider).fetchSessions(studentId);
});
