import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/amanda_asset_models.dart';

class AmandaAssetsAdminRepository {
  Future<String> uploadImageBytes(
      List<int> bytes, String category, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref('public/amanda_assets/$category/$fileName');
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  Future<void> create(AmandaAsset asset) async {
    final col = FirebaseFirestore.instance.collection('amanda_assets');
    final ref = asset.id.isEmpty ? col.doc() : col.doc(asset.id);
    await ref.set(asset.toMap());
  }

  Future<void> toggleActive(String id, bool active) async {
    await FirebaseFirestore.instance
        .collection('amanda_assets')
        .doc(id)
        .update({'active': active});
  }

  Future<void> delete(String id) async {
    await FirebaseFirestore.instance
        .collection('amanda_assets')
        .doc(id)
        .delete();
  }
}
