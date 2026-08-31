import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/ebook_models.dart';

class EbooksAdminRepository {
  Future<void> create(Ebook ebook, String fileUrl) async {
    final ref = FirebaseFirestore.instance.collection('ebooks').doc();
    await ref.set(ebook.toMap());
    await ref.collection('private').doc('file').set({'fileUrl': fileUrl});
  }

  Future<void> delete(String ebookId) async {
    final ref = FirebaseFirestore.instance.collection('ebooks').doc(ebookId);
    await ref.collection('private').doc('file').delete();
    await ref.delete();
  }
}
