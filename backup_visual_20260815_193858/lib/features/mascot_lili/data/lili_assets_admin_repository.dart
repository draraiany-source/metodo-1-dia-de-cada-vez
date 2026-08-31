import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/lili_asset_models.dart';

/// Escrita do painel admin — upload de imagem (Firebase Storage) ou URL
/// direta (útil pra Lottie/Rive já hospedados em outro lugar), e o CRUD
/// do documento em `lili_assets`.
class LiliAssetsAdminRepository {
  Future<String> uploadImageBytes(
      List<int> bytes, String category, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref('public/lili_assets/$category/$fileName');
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  Future<void> create(LiliAsset asset) async {
    final col = FirebaseFirestore.instance.collection('lili_assets');
    final ref = asset.id.isEmpty ? col.doc() : col.doc(asset.id);
    await ref.set(asset.toMap());
  }

  Future<void> toggleActive(String id, bool active) async {
    await FirebaseFirestore.instance
        .collection('lili_assets')
        .doc(id)
        .update({'active': active});
  }

  Future<void> delete(String id) async {
    await FirebaseFirestore.instance
        .collection('lili_assets')
        .doc(id)
        .delete();
  }
}
