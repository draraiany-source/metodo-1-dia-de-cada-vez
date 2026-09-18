import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gamification/providers/gamification_providers.dart';
import '../../personal_trainer/domain/pt_models.dart';
import '../../personal_trainer/providers/pt_providers.dart';
import '../../running/providers/running_providers.dart';
import '../../workout_timer/data/workout_session_repository.dart';
import '../domain/personal_records.dart';
import '../domain/training_volume.dart';

/// Histórico de cargas da aluna logada (via vínculo PT).
///
/// Vazio quando ela ainda não é aluna da Personal — a tela trata isso com
/// estado vazio, não com erro.
final myLoadHistoryProvider = FutureProvider<List<LoadEntry>>((ref) async {
  final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
  final student = await ref.watch(
    ptMyStudentProfileProvider((userId: user.id, email: user.email)).future,
  );
  if (student == null) return const [];
  return ref.watch(ptLoadsProvider(student.id).future);
});

final myExerciseLoadStatsProvider =
    Provider<List<ExerciseLoadStats>>((ref) {
  final cargas = ref.watch(myLoadHistoryProvider).valueOrNull ?? const [];
  return ExerciseLoadStats.group(cargas);
});

final personalRecordsBoardProvider = Provider<PersonalRecordsBoard>((ref) {
  final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
  final cargas = ref.watch(myLoadHistoryProvider).valueOrNull ?? const [];
  final corridas =
      ref.watch(runningHistoryProvider(user.id)).valueOrNull ?? const [];
  final timer =
      ref.watch(myWorkoutSessionsProvider).valueOrNull ?? const [];
  final gam = ref.watch(gamificationProvider);

  List<WorkoutSessionLog> sessoesPt = const [];
  final student = ref
      .watch(ptMyStudentProfileProvider((userId: user.id, email: user.email)))
      .valueOrNull;
  if (student != null) {
    sessoesPt =
        ref.watch(ptSessionsProvider(student.id)).valueOrNull ?? const [];
  }

  final melhorStreak =
      gam.previousStreak > gam.streak ? gam.previousStreak : gam.streak;

  return PersonalRecordsBoard.build(
    cargas: cargas,
    corridas: corridas,
    sessoesTimer: timer,
    sessoesPt: sessoesPt,
    streakAtual: gam.streak,
    melhorStreak: melhorStreak,
  );
});
