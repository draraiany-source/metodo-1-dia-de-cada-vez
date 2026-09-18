import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/firebase_service.dart';
import '../../personal_trainer/domain/pt_models.dart';
import '../domain/accompaniment_models.dart';
import '../domain/anamnesis_attention.dart';
import '../domain/appointment_overlap.dart';

class AccompanimentRepository {
  bool get isReady => FirebaseService.isReady;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection('pt_conversations');
  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('pt_messages');
  CollectionReference<Map<String, dynamic>> get _services =>
      _db.collection('pt_appointment_services');
  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('pt_appointments');
  CollectionReference<Map<String, dynamic>> get _notes =>
      _db.collection('pt_trainer_notes');
  CollectionReference<Map<String, dynamic>> get _consents =>
      _db.collection('pt_consents');
  CollectionReference<Map<String, dynamic>> get _aiLogs =>
      _db.collection('pt_ai_logs');

  // ---------- Chat ----------

  Future<AccompanimentConversation> ensureConversation({
    required Student student,
  }) async {
    if (!isReady) {
      return AccompanimentConversation(
        id: 'local-${student.id}',
        trainerId: student.trainerId,
        studentId: student.id,
        studentUserId: student.userId,
        studentName: student.name,
        studentPhoto: student.photoUrl,
      );
    }
    final existing = await _conversations
        .where('trainerId', isEqualTo: student.trainerId)
        .where('studentId', isEqualTo: student.id)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return AccompanimentConversation.fromMap(
        existing.docs.first.id,
        existing.docs.first.data(),
      );
    }
    final doc = _conversations.doc();
    final conv = AccompanimentConversation(
      id: doc.id,
      trainerId: student.trainerId,
      studentId: student.id,
      studentUserId: student.userId,
      studentName: student.name,
      studentPhoto: student.photoUrl,
    );
    await doc.set(conv.toMap());
    return conv;
  }

  Stream<List<AccompanimentConversation>> watchTrainerInbox(String trainerId) {
    if (!isReady) return Stream.value(const []);
    return _conversations
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => AccompanimentConversation.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => (b.lastAt ?? DateTime(2000))
          .compareTo(a.lastAt ?? DateTime(2000)));
      return list;
    });
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    if (!isReady) return Stream.value(const []);
    return _messages
        .where('conversationId', isEqualTo: conversationId)
        .snapshots()
        .map((s) {
      final list =
          s.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  Future<void> sendMessage({
    required AccompanimentConversation conv,
    required String senderId,
    required String senderRole,
    required String text,
    MessageKind kind = MessageKind.text,
    String mediaUrl = '',
    String mediaName = '',
    String replyToId = '',
  }) async {
    if (!isReady) return;
    final doc = _messages.doc();
    final msg = ChatMessage(
      id: doc.id,
      conversationId: conv.id,
      senderId: senderId,
      senderRole: senderRole,
      text: text,
      createdAt: DateTime.now().toUtc(),
      kind: kind,
      mediaUrl: mediaUrl,
      mediaName: mediaName,
      replyToId: replyToId,
    );
    await doc.set(msg.toMap());
    final unreadTrainer =
        senderRole == 'student' ? conv.unreadForTrainer + 1 : 0;
    final unreadStudent =
        senderRole == 'trainer' ? conv.unreadForStudent + 1 : 0;
    await _conversations.doc(conv.id).set({
      'lastMessage': text.isEmpty ? mediaName : text,
      'lastAt': DateTime.now().toUtc().toIso8601String(),
      'unreadForTrainer': unreadTrainer,
      'unreadForStudent': unreadStudent,
      'studentName': conv.studentName,
      'studentPhoto': conv.studentPhoto,
      'trainerId': conv.trainerId,
      'studentId': conv.studentId,
      'studentUserId': conv.studentUserId,
    }, SetOptions(merge: true));
  }

  Future<String> uploadChatFile({
    required String conversationId,
    required String studentId,
    required XFile file,
    required String folder,
  }) async {
    final bytes = await file.readAsBytes();
    return uploadChatBytes(
      conversationId: conversationId,
      studentId: studentId,
      bytes: bytes,
      filename: file.name,
      folder: folder,
      contentType: file.mimeType,
    );
  }

  Future<String> uploadChatBytes({
    required String conversationId,
    required String studentId,
    required Uint8List bytes,
    required String filename,
    required String folder,
    String? contentType,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('pt_chat/$studentId/$conversationId/$folder/$filename');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType ?? 'application/octet-stream'),
    );
    return ref.getDownloadURL();
  }

  Future<void> markRead({
    required String conversationId,
    required bool asTrainer,
  }) async {
    if (!isReady) return;
    await _conversations.doc(conversationId).set({
      asTrainer ? 'unreadForTrainer' : 'unreadForStudent': 0,
    }, SetOptions(merge: true));
  }

  Future<void> toggleStar(String messageId, bool starred) async {
    if (!isReady) return;
    await _messages.doc(messageId).update({'starred': starred});
  }

  Future<void> deleteOwnMessage({
    required String messageId,
    required String senderId,
  }) async {
    if (!isReady) return;
    final snap = await _messages.doc(messageId).get();
    if (snap.data()?['senderId'] != senderId) return;
    await _messages.doc(messageId).update({
      'deleted': true,
      'text': '',
      'mediaUrl': '',
    });
  }

  Future<void> setTrainerPresence(String trainerId, bool online) async {
    if (!isReady) return;
    final snap =
        await _conversations.where('trainerId', isEqualTo: trainerId).get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.set(
        d.reference,
        {
          'trainerOnline': online,
          'trainerLastSeen': DateTime.now().toUtc().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    }
    if (snap.docs.isNotEmpty) await batch.commit();
  }

  // ---------- Agenda ----------

  Future<List<AppointmentService>> fetchServices(String trainerId) async {
    if (!isReady) return _defaultServices(trainerId);
    try {
      final snap =
          await _services.where('trainerId', isEqualTo: trainerId).get();
      if (snap.docs.isEmpty) {
        final seeded = _defaultServices(trainerId);
        for (final s in seeded) {
          await _services.doc(s.id).set(s.toMap());
        }
        return seeded;
      }
      return snap.docs
          .map((d) => AppointmentService.fromMap(d.id, d.data()))
          .where((s) => s.active)
          .toList();
    } catch (_) {
      return _defaultServices(trainerId);
    }
  }

  Future<void> upsertService(AppointmentService s) async {
    if (!isReady) return;
    await (s.id.isEmpty ? _services.doc() : _services.doc(s.id)).set(s.toMap());
  }

  Future<TrainerAvailability> fetchAvailability(String trainerId) async {
    if (!isReady) return TrainerAvailability.fromMap(trainerId, null);
    final doc =
        await _db.collection('pt_availability').doc(trainerId).get();
    return TrainerAvailability.fromMap(trainerId, doc.data());
  }

  Future<void> saveAvailability(TrainerAvailability a) async {
    if (!isReady) return;
    await _db.collection('pt_availability').doc(a.trainerId).set(a.toMap());
  }

  Future<List<ConsultancyAppointment>> fetchAppointments({
    required String trainerId,
    String? studentId,
  }) async {
    if (!isReady) return [];
    try {
      Query<Map<String, dynamic>> q =
          _appointments.where('trainerId', isEqualTo: trainerId);
      if (studentId != null) {
        q = q.where('studentId', isEqualTo: studentId);
      }
      final snap = await q.get();
      final list = snap.docs
          .map((d) => ConsultancyAppointment.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => a.start.compareTo(b.start));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<DateTime>> availableSlots({
    required String trainerId,
    required DateTime day,
    required int durationMinutes,
    Set<String> busyFromCalendar = const {},
  }) async {
    final avail = await fetchAvailability(trainerId);
    final key =
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    if (avail.blockedDates.contains(key)) return [];
    final hours = avail.weekdaySlots[day.weekday] ?? const <String>[];
    final existing = await fetchAppointments(trainerId: trainerId);
    final occupied = existing
        .where((a) => a.isActive)
        .map((a) => TimeRange(a.start.toLocal(), a.end.toLocal()));
    final out = <DateTime>[];
    for (final h in hours) {
      final parts = h.split(':');
      if (parts.length < 2) continue;
      final start = DateTime(
        day.year,
        day.month,
        day.day,
        int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts[1]) ?? 0,
      );
      final stamp =
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      if (busyFromCalendar.contains(stamp)) continue;
      final conflict = AppointmentOverlap.conflicts(
        start: start,
        durationMinutes: durationMinutes,
        occupied: occupied,
      );
      if (!conflict) out.add(start);
    }
    return out;
  }

  Future<ConsultancyAppointment?> bookAppointment(
    ConsultancyAppointment draft,
  ) async {
    if (!isReady) return draft;
    final existing = await fetchAppointments(trainerId: draft.trainerId);
    final occupied = existing
        .where((a) => a.isActive)
        .map((a) => TimeRange(a.start, a.end));
    if (AppointmentOverlap.conflicts(
      start: draft.start,
      durationMinutes: draft.end.difference(draft.start).inMinutes,
      occupied: occupied,
    )) {
      return null;
    }
    final doc = _appointments.doc();
    final saved = ConsultancyAppointment(
      id: doc.id,
      trainerId: draft.trainerId,
      studentId: draft.studentId,
      studentUserId: draft.studentUserId,
      serviceId: draft.serviceId,
      serviceName: draft.serviceName,
      start: draft.start.toUtc(),
      end: draft.end.toUtc(),
      modality: draft.modality,
      priceReais: draft.priceReais,
      status: AppointmentStatus.confirmed,
      studentName: draft.studentName,
      calendarSync: CalendarSyncState.pending,
    );
    await doc.set(saved.toMap());
    return saved;
  }

  Future<void> updateAppointmentStatus(
    String id,
    AppointmentStatus status, {
    DateTime? start,
    DateTime? end,
    CalendarSyncState? calendarSync,
    String? calendarError,
  }) async {
    if (!isReady) return;
    await _appointments.doc(id).set({
      'status': status.name,
      if (start != null) 'start': start.toUtc().toIso8601String(),
      if (end != null) 'end': end.toUtc().toIso8601String(),
      if (calendarSync != null) 'calendarSync': calendarSync.name,
      if (calendarError != null) 'calendarError': calendarError,
    }, SetOptions(merge: true));
  }

  Future<CalendarConnectionStatus> fetchCalendarStatus(String trainerId) async {
    if (!isReady) return const CalendarConnectionStatus();
    final doc =
        await _db.collection('pt_calendar_connections').doc(trainerId).get();
    return CalendarConnectionStatus.fromMap(doc.data());
  }

  // ---------- Notas / consentimento ----------

  Future<List<TrainerNote>> fetchNotes(String studentId,
      {bool includePrivate = false}) async {
    if (!isReady) return [];
    try {
      final snap =
          await _notes.where('studentId', isEqualTo: studentId).get();
      var list =
          snap.docs.map((d) => TrainerNote.fromMap(d.id, d.data())).toList();
      if (!includePrivate) {
        list = list.where((n) => n.visibility == NoteVisibility.shared).toList();
      }
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNote(TrainerNote note) async {
    if (!isReady) return;
    await (note.id.isEmpty ? _notes.doc() : _notes.doc(note.id))
        .set(note.toMap());
  }

  Future<bool> hasConsent({required String userId, required String studentId}) async {
    if (!isReady) return false;
    final snap = await _consents
        .where('userId', isEqualTo: userId)
        .where('studentId', isEqualTo: studentId)
        .where('version', isEqualTo: ConsentRecord.currentVersion)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> saveConsent({
    required String userId,
    required String studentId,
  }) async {
    if (!isReady) return;
    final rec = ConsentRecord(
      id: '',
      userId: userId,
      studentId: studentId,
      version: ConsentRecord.currentVersion,
      acceptedAt: DateTime.now().toUtc(),
    );
    await _consents.doc().set(rec.toMap());
  }

  Future<void> logAiAction({
    required String trainerId,
    required String type,
    required String prompt,
    required String result,
    String studentId = '',
    bool approved = false,
  }) async {
    if (!isReady) return;
    await _aiLogs.doc().set({
      'trainerId': trainerId,
      'studentId': studentId,
      'type': type,
      'prompt': prompt,
      'result': result,
      'approved': approved,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<AiSettings> fetchAiSettings(String trainerId) async {
    if (!isReady) return const AiSettings();
    final doc = await _db.collection('pt_ai_settings').doc(trainerId).get();
    return AiSettings.fromMap(doc.data());
  }

  Future<void> saveAiSettings(String trainerId, AiSettings s) async {
    if (!isReady) return;
    await _db.collection('pt_ai_settings').doc(trainerId).set(s.toMap());
  }

  AttentionResult scoreQuestionnaire(AnamnesisQuestionnaire q) {
    return AnamnesisAttention.evaluate(AnamnesisAttentionInput(
      healthConditions: q.healthConditions,
      usesMedication: q.usesMedication == true,
      painRegions: q.painRegions,
      maxPainScale: q.maxPain,
      hadSurgery: q.hadSurgery == true,
      chestPainOnEffort: q.chestPainOnEffort,
      fainting: q.fainting,
      disproportionateShortness: q.shortness,
      palpitations: q.palpitations,
      cardiacDiagnosis: q.cardiacDiagnosis,
      exerciseRestriction: q.exerciseRestriction,
      pregnant: q.healthConditions.any((c) => c.toLowerCase().contains('gesta')),
      postpartum: q.healthConditions.any((c) => c.toLowerCase().contains('parto')),
    ));
  }

  List<AppointmentService> _defaultServices(String trainerId) => [
        AppointmentService(
          id: 'svc-inicial',
          trainerId: trainerId,
          name: 'Consulta inicial',
          description: 'Primeira conversa para alinhar objetivos e rotina.',
          durationMinutes: 60,
        ),
        AppointmentService(
          id: 'svc-reavaliacao',
          trainerId: trainerId,
          name: 'Reavaliação',
          description: 'Revisão de medidas, treinos e próxima fase.',
          durationMinutes: 45,
        ),
        AppointmentService(
          id: 'svc-ajuste',
          trainerId: trainerId,
          name: 'Ajuste de treino',
          description: 'Ajustes pontuais no plano atual.',
          durationMinutes: 30,
        ),
        AppointmentService(
          id: 'svc-online',
          trainerId: trainerId,
          name: 'Consultoria online',
          description: 'Atendimento por vídeo.',
          durationMinutes: 45,
          modality: 'online',
        ),
        AppointmentService(
          id: 'svc-individual',
          trainerId: trainerId,
          name: 'Orientação individual',
          description: 'Dúvidas e direcionamento da semana.',
          durationMinutes: 30,
        ),
      ];
}
