import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pt_repository.dart';
import '../domain/pt_models.dart';

final ptRepositoryProvider = Provider((ref) => PtRepository());

final ptStudentsProvider =
    FutureProvider.family<List<Student>, String>((ref, trainerId) {
  return ref.read(ptRepositoryProvider).fetchStudents(trainerId);
});

/// Resolve o perfil do aluno: por userId e, se preciso, auto-vínculo por e-mail.
final ptMyStudentProfileProvider =
    FutureProvider.family<Student?, ({String userId, String email})>((ref, key) {
  return ref.read(ptRepositoryProvider).ensureStudentLinked(
        userId: key.userId,
        email: key.email,
      );
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

final ptAnamnesisProvider =
    FutureProvider.family<StudentAnamnesis, String>((ref, studentId) {
  return ref.read(ptRepositoryProvider).fetchAnamnesis(studentId);
});

final ptSessionsProvider =
    FutureProvider.family<List<WorkoutSessionLog>, String>((ref, studentId) {
  return ref.read(ptRepositoryProvider).fetchSessions(studentId);
});

final ptLoadsProvider =
    FutureProvider.family<List<LoadEntry>, String>((ref, studentId) {
  return ref.read(ptRepositoryProvider).fetchAllLoads(studentId);
});

final ptDashboardStatsProvider =
    FutureProvider.family<TrainerDashboardStats, String>((ref, trainerId) async {
  final students =
      await ref.watch(ptStudentsProvider(trainerId).future);
  return ref.read(ptRepositoryProvider).fetchDashboardStats(
        trainerId: trainerId,
        students: students,
      );
});
