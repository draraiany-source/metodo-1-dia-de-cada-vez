import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/audio_program_repository_impl.dart';
import '../domain/entities/audio_program.dart';
import '../domain/entities/program_progress.dart';
import '../domain/repositories/audio_program_repository.dart';

final audioProgramRepositoryProvider = Provider<AudioProgramRepository>((ref) {
  return AudioProgramRepositoryImpl();
});

final programsListProvider = StreamProvider<List<AudioProgram>>((ref) {
  return ref.watch(audioProgramRepositoryProvider).watchPrograms();
});

final programByIdProvider =
    FutureProvider.family<AudioProgram?, String>((ref, programId) {
  return ref.watch(audioProgramRepositoryProvider).getProgram(programId);
});

final programAudiosProvider =
    StreamProvider.family<List<ProgramAudio>, String>((ref, programId) {
  return ref.watch(audioProgramRepositoryProvider).watchProgramAudios(programId);
});

final programProgressProvider =
    StreamProvider.family<ProgramProgress, String>((ref, programId) {
  return ref.watch(audioProgramRepositoryProvider).watchProgress(programId);
});

final programCompletionLabelProvider =
    Provider.family<String, String>((ref, programId) {
  final progress = ref.watch(programProgressProvider(programId)).value;
  final audios = ref.watch(programAudiosProvider(programId)).value;
  final total = audios?.length ?? 0;
  final done = progress?.completedAudioIds.length ?? 0;
  return '$done de $total dias concluídos';
});
