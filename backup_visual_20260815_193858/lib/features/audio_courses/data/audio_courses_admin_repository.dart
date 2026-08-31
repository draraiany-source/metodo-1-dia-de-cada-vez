import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/audio_course_models.dart';

class AudioCoursesAdminRepository {
  Future<String> createCourse({
    required String title,
    required String teacher,
    required AudioCourseCategory category,
    required String coverUrl,
    required bool isPremium,
  }) async {
    final ref =
        await FirebaseFirestore.instance.collection('audio_courses').add({
      'title': title,
      'teacher': teacher,
      'category': category.name,
      'coverUrl': coverUrl,
      'isPremium': isPremium,
      'order': 0,
    });
    return ref.id;
  }

  Future<void> addChapter({
    required String courseId,
    required String title,
    required String audioUrl,
    required int durationSeconds,
    required int order,
  }) async {
    final courseRef =
        FirebaseFirestore.instance.collection('audio_courses').doc(courseId);
    // Metadados (sem a URL) ficam públicos, igual antes.
    final chapterRef = await courseRef.collection('chapters').add({
      'title': title,
      'durationSeconds': durationSeconds,
      'order': order,
    });
    // A URL real fica isolada — só a Cloud Function `getContentUrl` lê.
    await courseRef.collection('private').doc('chapters').set(
      {chapterRef.id: audioUrl},
      SetOptions(merge: true),
    );
  }

  Future<void> deleteCourse(String courseId) async {
    final ref =
        FirebaseFirestore.instance.collection('audio_courses').doc(courseId);
    final chapters = await ref.collection('chapters').get();
    for (final c in chapters.docs) {
      await c.reference.delete();
    }
    await ref.collection('private').doc('chapters').delete();
    await ref.delete();
  }
}
