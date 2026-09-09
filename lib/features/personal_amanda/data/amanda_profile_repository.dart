import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/amanda_profile_models.dart';

const String kAmandaProfileCollection = 'amanda_profile';
const String kAmandaProfileDocId = 'main';

class AmandaProfileRepository {
  bool get isReady => FirebaseService.isReady;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection(kAmandaProfileCollection).doc(kAmandaProfileDocId);

  Future<AmandaProfileContent> fetch() async {
    if (!isReady) return AmandaProfileContent.defaults;
    try {
      final snap = await _doc.get();
      if (!snap.exists) return AmandaProfileContent.defaults;
      return AmandaProfileContent.fromMap(snap.data());
    } catch (_) {
      return AmandaProfileContent.defaults;
    }
  }

  Stream<AmandaProfileContent> watch() {
    if (!isReady) {
      return Stream.value(AmandaProfileContent.defaults);
    }
    return _doc.snapshots().map((snap) {
      if (!snap.exists) return AmandaProfileContent.defaults;
      return AmandaProfileContent.fromMap(snap.data());
    });
  }

  Future<void> save(AmandaProfileContent content) async {
    if (!isReady) {
      throw StateError('Firebase indisponível. Configure o projeto e tente de novo.');
    }
    await _doc.set(content.toMap(), SetOptions(merge: true));
  }
}
