import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/course_models.dart';

class CoursesRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<Course>> fetchAll() async {
    if (!isAvailable) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('courses')
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get();
      return snap.docs.map((d) => Course.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }
}
