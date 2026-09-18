import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../personal_trainer/domain/pt_models.dart';
import '../data/accompaniment_ai_repository.dart';
import '../data/accompaniment_repository.dart';
import '../domain/accompaniment_models.dart';

final accompanimentRepositoryProvider =
    Provider((ref) => AccompanimentRepository());

final accompanimentAiProvider =
    Provider((ref) => AccompanimentAiRepository());

final googleCalendarRepositoryProvider =
    Provider((ref) => GoogleCalendarRepository());

final trainerInboxProvider =
    StreamProvider.family<List<AccompanimentConversation>, String>(
        (ref, trainerId) {
  return ref.watch(accompanimentRepositoryProvider).watchTrainerInbox(trainerId);
});

final conversationMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  return ref.watch(accompanimentRepositoryProvider).watchMessages(conversationId);
});

final appointmentServicesProvider =
    FutureProvider.family<List<AppointmentService>, String>((ref, trainerId) {
  return ref.watch(accompanimentRepositoryProvider).fetchServices(trainerId);
});

final trainerAvailabilityProvider =
    FutureProvider.family<TrainerAvailability, String>((ref, trainerId) {
  return ref.watch(accompanimentRepositoryProvider).fetchAvailability(trainerId);
});

final trainerAppointmentsProvider =
    FutureProvider.family<List<ConsultancyAppointment>, String>(
        (ref, trainerId) {
  return ref
      .watch(accompanimentRepositoryProvider)
      .fetchAppointments(trainerId: trainerId);
});

final studentAppointmentsProvider = FutureProvider.family<
    List<ConsultancyAppointment>,
    ({String trainerId, String studentId})>((ref, key) {
  return ref.watch(accompanimentRepositoryProvider).fetchAppointments(
        trainerId: key.trainerId,
        studentId: key.studentId,
      );
});

final trainerNotesProvider = FutureProvider.family<List<TrainerNote>,
    ({String studentId, bool includePrivate})>((ref, key) {
  return ref.watch(accompanimentRepositoryProvider).fetchNotes(
        key.studentId,
        includePrivate: key.includePrivate,
      );
});

final aiSettingsProvider =
    FutureProvider.family<AiSettings, String>((ref, trainerId) {
  return ref.watch(accompanimentRepositoryProvider).fetchAiSettings(trainerId);
});

final calendarStatusProvider =
    FutureProvider.family<CalendarConnectionStatus, String>((ref, trainerId) {
  return ref
      .watch(accompanimentRepositoryProvider)
      .fetchCalendarStatus(trainerId);
});

final conversationForStudentProvider =
    FutureProvider.family<AccompanimentConversation, Student>((ref, student) {
  return ref
      .watch(accompanimentRepositoryProvider)
      .ensureConversation(student: student);
});
