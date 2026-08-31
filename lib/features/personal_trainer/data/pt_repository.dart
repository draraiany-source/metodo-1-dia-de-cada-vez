import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/pt_models.dart';

/// Repositório único do módulo Personal Trainer — todas as coleções giram
/// em torno de `trainerId`/`studentId`, então concentrar aqui evita
/// duplicar a checagem de `FirebaseService.isReady` em 8 arquivos.
class PtRepository {
  bool get isReady => FirebaseService.isReady;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ---------------- Alunos ----------------

  Future<List<Student>> fetchStudents(String trainerId) async {
    if (!isReady) return [];
    try {
      final snap = await _db
          .collection('pt_students')
          .where('trainerId', isEqualTo: trainerId)
          .where('active', isEqualTo: true)
          .get();
      return snap.docs.map((d) => Student.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createStudent(Student s) async {
    final col = _db.collection('pt_students');
    await (s.id.isEmpty ? col.doc() : col.doc(s.id)).set(s.toMap());
  }

  /// Aluno vendo o próprio personal (para a Área do Aluno).
  Future<Student?> fetchStudentByUserId(String userId) async {
    if (!isReady) return null;
    try {
      final snap = await _db
          .collection('pt_students')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return Student.fromMap(snap.docs.first.id, snap.docs.first.data());
    } catch (_) {
      return null;
    }
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

  Future<void> createExercise(Exercise e) async {
    final col = _db.collection('pt_exercises');
    await (e.id.isEmpty ? col.doc() : col.doc(e.id)).set(e.toMap());
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
      return snap.docs
          .map((d) => WorkoutPlan.fromMap(d.id, d.data()))
          .toList();
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

  /// Soft-delete — marca o plano como inativo (não remove do Firestore).
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
}
