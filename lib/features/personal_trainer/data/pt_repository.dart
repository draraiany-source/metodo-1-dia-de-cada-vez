import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/pt_models.dart';

/// KPIs reais do painel do Personal (calculados a partir de `pt_sessions`).
class TrainerDashboardStats {
  const TrainerDashboardStats({
    required this.activeStudents,
    required this.sessionsToday,
    required this.inactiveStudents,
    required this.completionRatePercent,
    required this.lastSessionByStudentId,
  });

  final int activeStudents;
  final int sessionsToday;
  final int inactiveStudents;
  final int completionRatePercent;
  final Map<String, DateTime> lastSessionByStudentId;

  static const empty = TrainerDashboardStats(
    activeStudents: 0,
    sessionsToday: 0,
    inactiveStudents: 0,
    completionRatePercent: 0,
    lastSessionByStudentId: {},
  );
}

/// Repositório único do módulo Personal Trainer.
class PtRepository {
  bool get isReady => FirebaseService.isReady;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ---------------- Alunos ----------------

  Future<List<Student>> fetchStudents(String trainerId,
      {bool activeOnly = true}) async {
    if (!isReady) return [];
    try {
      Query<Map<String, dynamic>> q = _db
          .collection('pt_students')
          .where('trainerId', isEqualTo: trainerId);
      if (activeOnly) {
        q = q.where('active', isEqualTo: true);
      }
      final snap = await q.get();
      return snap.docs.map((d) => Student.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createStudent(Student s) async {
    final col = _db.collection('pt_students');
    await (s.id.isEmpty ? col.doc() : col.doc(s.id)).set(s.toMap());
  }

  Future<void> updateStudent(Student s) async {
    if (s.id.isEmpty) {
      await createStudent(s);
      return;
    }
    await _db
        .collection('pt_students')
        .doc(s.id)
        .set(s.toMap(), SetOptions(merge: true));
  }

  Future<void> deactivateStudent(String studentId) async {
    if (!isReady || studentId.isEmpty) return;
    await _db.collection('pt_students').doc(studentId).update({'active': false});
  }

  Future<void> activateStudent(String studentId) async {
    if (!isReady || studentId.isEmpty) return;
    await _db.collection('pt_students').doc(studentId).update({'active': true});
  }

  /// Aluno vendo o próprio personal (para a Área do Aluno).
  Future<Student?> fetchStudentByUserId(String userId) async {
    if (!isReady || userId.isEmpty) return null;
    try {
      final snap = await _db
          .collection('pt_students')
          .where('userId', isEqualTo: userId)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return Student.fromMap(snap.docs.first.id, snap.docs.first.data());
    } catch (_) {
      return null;
    }
  }

  /// Busca cadastro pelo e-mail (antes do vínculo de userId).
  Future<Student?> fetchStudentByEmail(String email) async {
    if (!isReady) return null;
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    try {
      final snap = await _db
          .collection('pt_students')
          .where('email', isEqualTo: normalized)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        // fallback: e-mail salvo com capitalização diferente
        final all = await _db
            .collection('pt_students')
            .where('active', isEqualTo: true)
            .limit(50)
            .get();
        for (final d in all.docs) {
          final e = ((d.data()['email'] ?? '') as String).trim().toLowerCase();
          if (e == normalized) return Student.fromMap(d.id, d.data());
        }
        return null;
      }
      return Student.fromMap(snap.docs.first.id, snap.docs.first.data());
    } catch (_) {
      return null;
    }
  }

  /// Aluno vincula a própria conta Auth ao cadastro do Personal (mesmo e-mail).
  Future<Student?> ensureStudentLinked({
    required String userId,
    required String email,
  }) async {
    final byUid = await fetchStudentByUserId(userId);
    if (byUid != null) return byUid;

    final byEmail = await fetchStudentByEmail(email);
    if (byEmail == null) return null;

    if (byEmail.userId.isEmpty || byEmail.userId == userId) {
      await _db.collection('pt_students').doc(byEmail.id).update({
        'userId': userId,
        'email': email.trim().toLowerCase(),
      });
      return byEmail.copyWith(
        userId: userId,
        email: email.trim().toLowerCase(),
      );
    }
    return byEmail.userId == userId ? byEmail : null;
  }

  /// Personal informa o UID do app do aluno (quando o e-mail ainda não bate).
  Future<void> linkStudentUserId(String studentId, String userId) async {
    if (!isReady || studentId.isEmpty) return;
    await _db.collection('pt_students').doc(studentId).update({
      'userId': userId.trim(),
    });
  }

  // ---------------- Banco de exercícios ----------------

  Future<List<Exercise>> fetchExercises() async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_exercises')
          .where('active', isEqualTo: true)
          .get();
      return snap.docs.map((d) => Exercise.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Exercise?> fetchExerciseById(String id) async {
    if (!isReady || id.isEmpty) return null;
    try {
      final doc = await _db.collection('pt_exercises').doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return Exercise.fromMap(doc.id, doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> createExercise(Exercise e) async {
    final col = _db.collection('pt_exercises');
    await (e.id.isEmpty ? col.doc() : col.doc(e.id)).set(e.toMap());
  }

  Future<void> updateExercise(Exercise e) async {
    if (e.id.isEmpty) {
      await createExercise(e);
      return;
    }
    await _db.collection('pt_exercises').doc(e.id).set(e.toMap(), SetOptions(merge: true));
  }

  Future<void> deactivateExercise(String exerciseId) async {
    if (!isReady || exerciseId.isEmpty) return;
    await _db.collection('pt_exercises').doc(exerciseId).update({'active': false});
  }

  /// Upload opcional de vídeo para Storage; devolve a download URL.
  Future<String?> uploadExerciseVideo({
    required String exerciseId,
    required List<int> bytes,
    required String contentType,
    required String fileName,
  }) async {
    if (!isReady || exerciseId.isEmpty || bytes.isEmpty) return null;
    try {
      final ref = FirebaseStorage.instance
          .ref('pt_videos/$exerciseId/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: contentType),
      );
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  // ---------------- Treinos ----------------

  Future<List<WorkoutPlan>> fetchWorkoutPlans(String studentId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_workout_plans')
          .where('studentId', isEqualTo: studentId)
          .where('active', isEqualTo: true)
          .get();
      final list = snap.docs
          .map((d) => WorkoutPlan.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> createWorkoutPlan(WorkoutPlan w) async {
    final col = _db.collection('pt_workout_plans');
    await (w.id.isEmpty ? col.doc() : col.doc(w.id)).set(w.toMap());
  }

  Future<void> duplicateWorkoutPlan(WorkoutPlan original, String newName) async {
    final copy = WorkoutPlan(
      id: '',
      studentId: original.studentId,
      trainerId: original.trainerId,
      name: newName,
      objective: original.objective,
      level: original.level,
      diasSemana: original.diasSemana,
      exercises: original.exercises,
      createdAt: DateTime.now(),
    );
    await createWorkoutPlan(copy);
  }

  Future<void> deactivateWorkoutPlan(String planId) async {
    if (!isReady || planId.isEmpty) return;
    await _db.collection('pt_workout_plans').doc(planId).update({
      'active': false,
    });
  }

  Future<void> updateWorkoutPlan(WorkoutPlan w) async {
    if (w.id.isEmpty) {
      await createWorkoutPlan(w);
      return;
    }
    await _db.collection('pt_workout_plans').doc(w.id).set(w.toMap());
  }

  // ---------------- Avaliações físicas ----------------

  Future<List<PhysicalAssessment>> fetchAssessments(String studentId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_assessments')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date')
          .get();
      return snap.docs
          .map((d) => PhysicalAssessment.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createAssessment(PhysicalAssessment a) async {
    final col = _db.collection('pt_assessments');
    await (a.id.isEmpty ? col.doc() : col.doc(a.id)).set(a.toMap());
  }

  // ---------------- Fotos de evolução ----------------

  Future<List<EvolutionPhoto>> fetchPhotos(String studentId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_photos')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date')
          .get();
      return snap.docs
          .map((d) => EvolutionPhoto.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createPhoto(EvolutionPhoto p) async {
    final col = _db.collection('pt_photos');
    await (p.id.isEmpty ? col.doc() : col.doc(p.id)).set(p.toMap());
  }

  Future<String?> uploadEvolutionPhoto({
    required String studentId,
    required List<int> bytes,
    required String fileName,
  }) async {
    if (!isReady || studentId.isEmpty || bytes.isEmpty) return null;
    try {
      final ref = FirebaseStorage.instance.ref(
          'pt_photos/$studentId/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  // ---------------- Anamnese ----------------

  Future<StudentAnamnesis> fetchAnamnesis(String studentId) async {
    if (!isReady || studentId.isEmpty) {
      return StudentAnamnesis(studentId: studentId, trainerId: '');
    }
    try {
      final doc = await _db.collection('pt_anamnesis').doc(studentId).get();
      return StudentAnamnesis.fromMap(studentId, doc.data());
    } catch (_) {
      return StudentAnamnesis(studentId: studentId, trainerId: '');
    }
  }

  Future<void> saveAnamnesis(StudentAnamnesis a) async {
    if (!isReady || a.studentId.isEmpty) return;
    await _db
        .collection('pt_anamnesis')
        .doc(a.studentId)
        .set(a.toMap(), SetOptions(merge: true));
  }

  // ---------------- Cargas ----------------

  Future<List<LoadEntry>> fetchLoadHistory(
      String studentId, String exerciseId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_loads')
          .where('studentId', isEqualTo: studentId)
          .where('exerciseId', isEqualTo: exerciseId)
          .orderBy('date')
          .get();
      return snap.docs.map((d) => LoadEntry.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<LoadEntry>> fetchAllLoads(String studentId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_loads')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date')
          .get();
      return snap.docs.map((d) => LoadEntry.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> logLoad(LoadEntry l) async {
    final col = _db.collection('pt_loads');
    await (l.id.isEmpty ? col.doc() : col.doc(l.id)).set(l.toMap());
  }

  // ---------------- Sessões concluídas ----------------

  Future<void> logSession(WorkoutSessionLog log) async {
    final col = _db.collection('pt_sessions');
    await (log.id.isEmpty ? col.doc() : col.doc(log.id)).set(log.toMap());
  }

  Future<List<WorkoutSessionLog>> fetchSessions(String studentId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_sessions')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date')
          .get();
      return snap.docs
          .map((d) => WorkoutSessionLog.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<WorkoutSessionLog>> fetchSessionsByTrainer(String trainerId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_sessions')
          .where('trainerId', isEqualTo: trainerId)
          .get();
      final list = snap.docs
          .map((d) => WorkoutSessionLog.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<TrainerDashboardStats> fetchDashboardStats({
    required String trainerId,
    required List<Student> students,
  }) async {
    if (!isReady) {
      return TrainerDashboardStats(
        activeStudents: students.length,
        sessionsToday: 0,
        inactiveStudents: 0,
        completionRatePercent: 0,
        lastSessionByStudentId: const {},
      );
    }

    final sessions = await fetchSessionsByTrainer(trainerId);
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sessionsToday =
        sessions.where((s) => !s.date.isBefore(todayStart)).length;

    final lastByStudent = <String, DateTime>{};
    for (final s in sessions) {
      final prev = lastByStudent[s.studentId];
      if (prev == null || s.date.isAfter(prev)) {
        lastByStudent[s.studentId] = s.date;
      }
    }

    var inactive = 0;
    for (final st in students) {
      final last = lastByStudent[st.id];
      if (last == null || now.difference(last).inDays >= 5) {
        inactive++;
      }
    }

    final withSession = students.where((s) => lastByStudent.containsKey(s.id)).length;
    final completion = students.isEmpty
        ? 0
        : ((withSession / students.length) * 100).round();

    return TrainerDashboardStats(
      activeStudents: students.length,
      sessionsToday: sessionsToday,
      inactiveStudents: inactive,
      completionRatePercent: completion,
      lastSessionByStudentId: lastByStudent,
    );
  }
}
