/// Modelos do módulo de acompanhamento (chat, agenda, anamnese, notas, IA).
///
/// Reutiliza `pt_students` / `pt_anamnesis` / `pt_assessments` já existentes.
/// Novas coleções usam prefixo `pt_` para as mesmas regras de vínculo.
library;

enum MessageKind { text, image, audio, document, system }

enum MessageStatus { sent, delivered, read }

enum AppointmentStatus {
  requested,
  confirmed,
  completed,
  cancelled,
  rescheduled,
  noShow,
}

enum NoteVisibility { shared, private }

enum CalendarSyncState { synced, pending, error, disconnected }

class AccompanimentConversation {
  const AccompanimentConversation({
    required this.id,
    required this.trainerId,
    required this.studentId,
    required this.studentUserId,
    this.studentName = '',
    this.studentPhoto = '',
    this.lastMessage = '',
    this.lastAt,
    this.unreadForTrainer = 0,
    this.unreadForStudent = 0,
    this.trainerOnline = false,
    this.trainerLastSeen,
  });

  final String id;
  final String trainerId;
  final String studentId;
  final String studentUserId;
  final String studentName;
  final String studentPhoto;
  final String lastMessage;
  final DateTime? lastAt;
  final int unreadForTrainer;
  final int unreadForStudent;
  final bool trainerOnline;
  final DateTime? trainerLastSeen;

  factory AccompanimentConversation.fromMap(
          String id, Map<String, dynamic> m) =>
      AccompanimentConversation(
        id: id,
        trainerId: (m['trainerId'] ?? '') as String,
        studentId: (m['studentId'] ?? '') as String,
        studentUserId: (m['studentUserId'] ?? '') as String,
        studentName: (m['studentName'] ?? '') as String,
        studentPhoto: (m['studentPhoto'] ?? '') as String,
        lastMessage: (m['lastMessage'] ?? '') as String,
        lastAt: DateTime.tryParse(m['lastAt'] as String? ?? ''),
        unreadForTrainer: (m['unreadForTrainer'] as num?)?.toInt() ?? 0,
        unreadForStudent: (m['unreadForStudent'] as num?)?.toInt() ?? 0,
        trainerOnline: (m['trainerOnline'] ?? false) as bool,
        trainerLastSeen:
            DateTime.tryParse(m['trainerLastSeen'] as String? ?? ''),
      );

  Map<String, dynamic> toMap() => {
        'trainerId': trainerId,
        'studentId': studentId,
        'studentUserId': studentUserId,
        'studentName': studentName,
        'studentPhoto': studentPhoto,
        'lastMessage': lastMessage,
        if (lastAt != null) 'lastAt': lastAt!.toIso8601String(),
        'unreadForTrainer': unreadForTrainer,
        'unreadForStudent': unreadForStudent,
        'trainerOnline': trainerOnline,
        if (trainerLastSeen != null)
          'trainerLastSeen': trainerLastSeen!.toIso8601String(),
      };
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.createdAt,
    this.kind = MessageKind.text,
    this.status = MessageStatus.sent,
    this.mediaUrl = '',
    this.mediaName = '',
    this.replyToId = '',
    this.starred = false,
    this.deleted = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole; // student | trainer
  final String text;
  final DateTime createdAt;
  final MessageKind kind;
  final MessageStatus status;
  final String mediaUrl;
  final String mediaName;
  final String replyToId;
  final bool starred;
  final bool deleted;

  bool get fromTrainer => senderRole == 'trainer';

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) =>
      ChatMessage(
        id: id,
        conversationId: (m['conversationId'] ?? '') as String,
        senderId: (m['senderId'] ?? '') as String,
        senderRole: (m['senderRole'] ?? 'student') as String,
        text: (m['text'] ?? '') as String,
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
        kind: MessageKind.values.firstWhere(
          (k) => k.name == m['kind'],
          orElse: () => MessageKind.text,
        ),
        status: MessageStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => MessageStatus.sent,
        ),
        mediaUrl: (m['mediaUrl'] ?? '') as String,
        mediaName: (m['mediaName'] ?? '') as String,
        replyToId: (m['replyToId'] ?? '') as String,
        starred: (m['starred'] ?? false) as bool,
        deleted: (m['deleted'] ?? false) as bool,
      );

  Map<String, dynamic> toMap() => {
        'conversationId': conversationId,
        'senderId': senderId,
        'senderRole': senderRole,
        'text': deleted ? '' : text,
        'createdAt': createdAt.toIso8601String(),
        'kind': kind.name,
        'status': status.name,
        'mediaUrl': deleted ? '' : mediaUrl,
        'mediaName': mediaName,
        'replyToId': replyToId,
        'starred': starred,
        'deleted': deleted,
      };
}

class AppointmentService {
  const AppointmentService({
    required this.id,
    required this.trainerId,
    required this.name,
    this.description = '',
    this.durationMinutes = 45,
    this.priceReais,
    this.modality = 'online',
    this.active = true,
  });

  final String id;
  final String trainerId;
  final String name;
  final String description;
  final int durationMinutes;
  final double? priceReais;
  final String modality; // online | presencial
  final bool active;

  factory AppointmentService.fromMap(String id, Map<String, dynamic> m) =>
      AppointmentService(
        id: id,
        trainerId: (m['trainerId'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        durationMinutes: (m['durationMinutes'] as num?)?.toInt() ?? 45,
        priceReais: (m['priceReais'] as num?)?.toDouble(),
        modality: (m['modality'] ?? 'online') as String,
        active: (m['active'] ?? true) as bool,
      );

  Map<String, dynamic> toMap() => {
        'trainerId': trainerId,
        'name': name,
        'description': description,
        'durationMinutes': durationMinutes,
        if (priceReais != null) 'priceReais': priceReais,
        'modality': modality,
        'active': active,
      };
}

class TrainerAvailability {
  const TrainerAvailability({
    required this.trainerId,
    this.timezone = 'America/Sao_Paulo',
    this.weekdaySlots = const {},
    this.blockedDates = const [],
    this.cancelHoursNotice = 24,
    this.rescheduleHoursNotice = 12,
  });

  final String trainerId;
  final String timezone;

  /// weekday 1-7 (DateTime.weekday) → ["08:00","09:00",...]
  final Map<int, List<String>> weekdaySlots;
  final List<String> blockedDates; // yyyy-MM-dd
  final int cancelHoursNotice;
  final int rescheduleHoursNotice;

  factory TrainerAvailability.fromMap(String trainerId, Map<String, dynamic>? m) {
    if (m == null || m.isEmpty) {
      return TrainerAvailability(
        trainerId: trainerId,
        weekdaySlots: {
          for (final d in [1, 2, 3, 4, 5])
            d: const ['08:00', '09:00', '10:30', '14:00', '15:30', '18:00'],
        },
      );
    }
    final raw = m['weekdaySlots'];
    final slots = <int, List<String>>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        final day = int.tryParse('$k') ?? 0;
        if (day >= 1 && day <= 7 && v is List) {
          slots[day] = v.map((e) => '$e').toList();
        }
      });
    }
    return TrainerAvailability(
      trainerId: trainerId,
      timezone: (m['timezone'] ?? 'America/Sao_Paulo') as String,
      weekdaySlots: slots,
      blockedDates: (m['blockedDates'] as List?)?.map((e) => '$e').toList() ??
          const [],
      cancelHoursNotice: (m['cancelHoursNotice'] as num?)?.toInt() ?? 24,
      rescheduleHoursNotice:
          (m['rescheduleHoursNotice'] as num?)?.toInt() ?? 12,
    );
  }

  Map<String, dynamic> toMap() => {
        'trainerId': trainerId,
        'timezone': timezone,
        'weekdaySlots': {
          for (final e in weekdaySlots.entries) '${e.key}': e.value,
        },
        'blockedDates': blockedDates,
        'cancelHoursNotice': cancelHoursNotice,
        'rescheduleHoursNotice': rescheduleHoursNotice,
      };
}

class ConsultancyAppointment {
  const ConsultancyAppointment({
    required this.id,
    required this.trainerId,
    required this.studentId,
    required this.studentUserId,
    required this.serviceId,
    required this.serviceName,
    required this.start,
    required this.end,
    this.modality = 'online',
    this.priceReais,
    this.status = AppointmentStatus.requested,
    this.notes = '',
    this.studentName = '',
    this.googleCalendarEventId = '',
    this.calendarSync = CalendarSyncState.disconnected,
    this.calendarError = '',
  });

  final String id;
  final String trainerId;
  final String studentId;
  final String studentUserId;
  final String serviceId;
  final String serviceName;
  final DateTime start;
  final DateTime end;
  final String modality;
  final double? priceReais;
  final AppointmentStatus status;
  final String notes;
  final String studentName;
  final String googleCalendarEventId;
  final CalendarSyncState calendarSync;
  final String calendarError;

  bool get isActive =>
      status == AppointmentStatus.requested ||
      status == AppointmentStatus.confirmed ||
      status == AppointmentStatus.rescheduled;

  factory ConsultancyAppointment.fromMap(String id, Map<String, dynamic> m) =>
      ConsultancyAppointment(
        id: id,
        trainerId: (m['trainerId'] ?? '') as String,
        studentId: (m['studentId'] ?? '') as String,
        studentUserId: (m['studentUserId'] ?? '') as String,
        serviceId: (m['serviceId'] ?? '') as String,
        serviceName: (m['serviceName'] ?? '') as String,
        start: DateTime.tryParse(m['start'] as String? ?? '') ?? DateTime.now(),
        end: DateTime.tryParse(m['end'] as String? ?? '') ?? DateTime.now(),
        modality: (m['modality'] ?? 'online') as String,
        priceReais: (m['priceReais'] as num?)?.toDouble(),
        status: AppointmentStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => AppointmentStatus.requested,
        ),
        notes: (m['notes'] ?? '') as String,
        studentName: (m['studentName'] ?? '') as String,
        googleCalendarEventId: (m['googleCalendarEventId'] ?? '') as String,
        calendarSync: CalendarSyncState.values.firstWhere(
          (s) => s.name == m['calendarSync'],
          orElse: () => CalendarSyncState.disconnected,
        ),
        calendarError: (m['calendarError'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'trainerId': trainerId,
        'studentId': studentId,
        'studentUserId': studentUserId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'start': start.toUtc().toIso8601String(),
        'end': end.toUtc().toIso8601String(),
        'timezone': 'America/Sao_Paulo',
        'modality': modality,
        if (priceReais != null) 'priceReais': priceReais,
        'status': status.name,
        'notes': notes,
        'studentName': studentName,
        'googleCalendarEventId': googleCalendarEventId,
        'calendarSync': calendarSync.name,
        'calendarError': calendarError,
      };
}

class TrainerNote {
  const TrainerNote({
    required this.id,
    required this.studentId,
    required this.trainerId,
    required this.body,
    required this.visibility,
    required this.updatedAt,
  });

  final String id;
  final String studentId;
  final String trainerId;
  final String body;
  final NoteVisibility visibility;
  final DateTime updatedAt;

  factory TrainerNote.fromMap(String id, Map<String, dynamic> m) => TrainerNote(
        id: id,
        studentId: (m['studentId'] ?? '') as String,
        trainerId: (m['trainerId'] ?? '') as String,
        body: (m['body'] ?? '') as String,
        visibility: (m['visibility'] == 'shared')
            ? NoteVisibility.shared
            : NoteVisibility.private,
        updatedAt:
            DateTime.tryParse(m['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'trainerId': trainerId,
        'body': body,
        'visibility': visibility.name,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class ConsentRecord {
  const ConsentRecord({
    required this.id,
    required this.userId,
    required this.studentId,
    required this.version,
    required this.acceptedAt,
  });

  final String id;
  final String userId;
  final String studentId;
  final String version;
  final DateTime acceptedAt;

  static const currentVersion = 'anamnese-1.0-2026-09';

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'studentId': studentId,
        'version': version,
        'acceptedAt': acceptedAt.toIso8601String(),
        'purpose':
            'planejamento do acompanhamento, personalização dos treinos, avaliação da evolução e comunicação com a Personal',
      };
}

class AiSettings {
  const AiSettings({
    this.enabled = true,
    this.replySuggestions = true,
    this.anamnesisSummary = true,
    this.evolutionInsights = true,
    this.consultSummary = true,
    this.studentAssistant = true,
    this.workoutDraft = true,
  });

  final bool enabled;
  final bool replySuggestions;
  final bool anamnesisSummary;
  final bool evolutionInsights;
  final bool consultSummary;
  final bool studentAssistant;
  final bool workoutDraft;

  factory AiSettings.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const AiSettings();
    return AiSettings(
      enabled: (m['enabled'] ?? true) as bool,
      replySuggestions: (m['replySuggestions'] ?? true) as bool,
      anamnesisSummary: (m['anamnesisSummary'] ?? true) as bool,
      evolutionInsights: (m['evolutionInsights'] ?? true) as bool,
      consultSummary: (m['consultSummary'] ?? true) as bool,
      studentAssistant: (m['studentAssistant'] ?? true) as bool,
      workoutDraft: (m['workoutDraft'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'replySuggestions': replySuggestions,
        'anamnesisSummary': anamnesisSummary,
        'evolutionInsights': evolutionInsights,
        'consultSummary': consultSummary,
        'studentAssistant': studentAssistant,
        'workoutDraft': workoutDraft,
      };
}

class CalendarConnectionStatus {
  const CalendarConnectionStatus({
    this.connected = false,
    this.accountEmail = '',
    this.calendarId = 'primary',
    this.lastSync,
    this.state = CalendarSyncState.disconnected,
    this.error = '',
  });

  final bool connected;
  final String accountEmail;
  final String calendarId;
  final DateTime? lastSync;
  final CalendarSyncState state;
  final String error;

  factory CalendarConnectionStatus.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const CalendarConnectionStatus();
    return CalendarConnectionStatus(
      connected: (m['connected'] ?? false) as bool,
      accountEmail: (m['accountEmail'] ?? '') as String,
      calendarId: (m['calendarId'] ?? 'primary') as String,
      lastSync: DateTime.tryParse(m['lastSync'] as String? ?? ''),
      state: CalendarSyncState.values.firstWhere(
        (s) => s.name == m['state'],
        orElse: () => (m['connected'] == true)
            ? CalendarSyncState.synced
            : CalendarSyncState.disconnected,
      ),
      error: (m['error'] ?? '') as String,
    );
  }
}

class AnamnesisQuestionnaire {
  const AnamnesisQuestionnaire({
    this.profession = '',
    this.goalFreeText = '',
    this.practicesActivity,
    this.activityType = '',
    this.activityHowLong = '',
    this.timesPerWeek = '',
    this.trainedMusculation,
    this.timeOff = '',
    this.wakeTime = '',
    this.sleepTime = '',
    this.trainWindow = '',
    this.daysAvailable = '',
    this.sessionMinutes = '',
    this.healthConditions = const [],
    this.healthDetails = '',
    this.usesMedication,
    this.medicationDetails = '',
    this.hasPain,
    this.painRegions = const [],
    this.painScale = const {},
    this.painWhen = '',
    this.hadSurgery,
    this.surgeryWhat = '',
    this.surgeryWhen = '',
    this.chestPainOnEffort = false,
    this.fainting = false,
    this.shortness = false,
    this.palpitations = false,
    this.cardiacDiagnosis = false,
    this.exerciseRestriction = false,
    this.waterIntake = '',
    this.sleepQuality,
    this.sleepHours = '',
    this.dietNotes = '',
    this.smoking = '',
    this.alcohol = '',
    this.stress,
    this.energy,
    this.prefersGym = false,
    this.prefersHome = false,
    this.prefersOutdoor = false,
    this.disliked = '',
    this.impossibleExercises = '',
  });

  final String profession;
  final String goalFreeText;
  final bool? practicesActivity;
  final String activityType;
  final String activityHowLong;
  final String timesPerWeek;
  final bool? trainedMusculation;
  final String timeOff;
  final String wakeTime;
  final String sleepTime;
  final String trainWindow;
  final String daysAvailable;
  final String sessionMinutes;
  final List<String> healthConditions;
  final String healthDetails;
  final bool? usesMedication;
  final String medicationDetails;
  final bool? hasPain;
  final List<String> painRegions;
  final Map<String, int> painScale;
  final String painWhen;
  final bool? hadSurgery;
  final String surgeryWhat;
  final String surgeryWhen;
  final bool chestPainOnEffort;
  final bool fainting;
  final bool shortness;
  final bool palpitations;
  final bool cardiacDiagnosis;
  final bool exerciseRestriction;
  final String waterIntake;
  final int? sleepQuality;
  final String sleepHours;
  final String dietNotes;
  final String smoking;
  final String alcohol;
  final int? stress;
  final int? energy;
  final bool prefersGym;
  final bool prefersHome;
  final bool prefersOutdoor;
  final String disliked;
  final String impossibleExercises;

  int get maxPain {
    var m = 0;
    for (final v in painScale.values) {
      if (v > m) m = v;
    }
    return m;
  }

  factory AnamnesisQuestionnaire.fromMap(Map<String, dynamic>? m) {
    if (m == null) return const AnamnesisQuestionnaire();
    final scaleRaw = m['painScale'];
    final scale = <String, int>{};
    if (scaleRaw is Map) {
      scaleRaw.forEach((k, v) {
        scale['$k'] = (v as num?)?.toInt() ?? 0;
      });
    }
    return AnamnesisQuestionnaire(
      profession: (m['profession'] ?? '') as String,
      goalFreeText: (m['goalFreeText'] ?? '') as String,
      practicesActivity: m['practicesActivity'] as bool?,
      activityType: (m['activityType'] ?? '') as String,
      activityHowLong: (m['activityHowLong'] ?? '') as String,
      timesPerWeek: (m['timesPerWeek'] ?? '') as String,
      trainedMusculation: m['trainedMusculation'] as bool?,
      timeOff: (m['timeOff'] ?? '') as String,
      wakeTime: (m['wakeTime'] ?? '') as String,
      sleepTime: (m['sleepTime'] ?? '') as String,
      trainWindow: (m['trainWindow'] ?? '') as String,
      daysAvailable: (m['daysAvailable'] ?? '') as String,
      sessionMinutes: (m['sessionMinutes'] ?? '') as String,
      healthConditions:
          (m['healthConditions'] as List?)?.map((e) => '$e').toList() ??
              const [],
      healthDetails: (m['healthDetails'] ?? '') as String,
      usesMedication: m['usesMedication'] as bool?,
      medicationDetails: (m['medicationDetails'] ?? '') as String,
      hasPain: m['hasPain'] as bool?,
      painRegions:
          (m['painRegions'] as List?)?.map((e) => '$e').toList() ?? const [],
      painScale: scale,
      painWhen: (m['painWhen'] ?? '') as String,
      hadSurgery: m['hadSurgery'] as bool?,
      surgeryWhat: (m['surgeryWhat'] ?? '') as String,
      surgeryWhen: (m['surgeryWhen'] ?? '') as String,
      chestPainOnEffort: (m['chestPainOnEffort'] ?? false) as bool,
      fainting: (m['fainting'] ?? false) as bool,
      shortness: (m['shortness'] ?? false) as bool,
      palpitations: (m['palpitations'] ?? false) as bool,
      cardiacDiagnosis: (m['cardiacDiagnosis'] ?? false) as bool,
      exerciseRestriction: (m['exerciseRestriction'] ?? false) as bool,
      waterIntake: (m['waterIntake'] ?? '') as String,
      sleepQuality: (m['sleepQuality'] as num?)?.toInt(),
      sleepHours: (m['sleepHours'] ?? '') as String,
      dietNotes: (m['dietNotes'] ?? '') as String,
      smoking: (m['smoking'] ?? '') as String,
      alcohol: (m['alcohol'] ?? '') as String,
      stress: (m['stress'] as num?)?.toInt(),
      energy: (m['energy'] as num?)?.toInt(),
      prefersGym: (m['prefersGym'] ?? false) as bool,
      prefersHome: (m['prefersHome'] ?? false) as bool,
      prefersOutdoor: (m['prefersOutdoor'] ?? false) as bool,
      disliked: (m['disliked'] ?? '') as String,
      impossibleExercises: (m['impossibleExercises'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'profession': profession,
        'goalFreeText': goalFreeText,
        'practicesActivity': practicesActivity,
        'activityType': activityType,
        'activityHowLong': activityHowLong,
        'timesPerWeek': timesPerWeek,
        'trainedMusculation': trainedMusculation,
        'timeOff': timeOff,
        'wakeTime': wakeTime,
        'sleepTime': sleepTime,
        'trainWindow': trainWindow,
        'daysAvailable': daysAvailable,
        'sessionMinutes': sessionMinutes,
        'healthConditions': healthConditions,
        'healthDetails': healthDetails,
        'usesMedication': usesMedication,
        'medicationDetails': medicationDetails,
        'hasPain': hasPain,
        'painRegions': painRegions,
        'painScale': painScale,
        'painWhen': painWhen,
        'hadSurgery': hadSurgery,
        'surgeryWhat': surgeryWhat,
        'surgeryWhen': surgeryWhen,
        'chestPainOnEffort': chestPainOnEffort,
        'fainting': fainting,
        'shortness': shortness,
        'palpitations': palpitations,
        'cardiacDiagnosis': cardiacDiagnosis,
        'exerciseRestriction': exerciseRestriction,
        'waterIntake': waterIntake,
        'sleepQuality': sleepQuality,
        'sleepHours': sleepHours,
        'dietNotes': dietNotes,
        'smoking': smoking,
        'alcohol': alcohol,
        'stress': stress,
        'energy': energy,
        'prefersGym': prefersGym,
        'prefersHome': prefersHome,
        'prefersOutdoor': prefersOutdoor,
        'disliked': disliked,
        'impossibleExercises': impossibleExercises,
      };
}
