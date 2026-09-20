import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/amanda_asset_models.dart';

class AmandaAssetUpload {
  const AmandaAssetUpload({required this.url, required this.storagePath});
  final String url;
  final String storagePath;
}

class AmandaAssetsAdminRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('amanda_assets');

  Future<AmandaAssetUpload> uploadImageBytes(
      List<int> bytes, String category, String fileName) async {
    final storagePath = 'public/amanda_assets/$category/$fileName';
    final ref = FirebaseStorage.instance.ref(storagePath);
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    return AmandaAssetUpload(url: url, storagePath: storagePath);
  }

  Future<void> create(AmandaAsset asset) async {
    final ref = asset.id.isEmpty ? _col.doc() : _col.doc(asset.id);
    await ref.set(asset.toMap(), SetOptions(merge: true));
  }

  Future<void> update(AmandaAsset asset) async {
    if (asset.id.trim().isEmpty) {
      throw StateError('Foto sem id — não dá para atualizar.');
    }
    await _col.doc(asset.id).set(asset.toMap(), SetOptions(merge: true));
  }

  Future<void> toggleActive(String id, bool active) async {
    await _col.doc(id).set({'active': active}, SetOptions(merge: true));
  }

  Future<void> delete(AmandaAsset asset) async {
    await _col.doc(asset.id).delete();
    await _deleteStorage(asset);
  }

  Future<void> _deleteStorage(AmandaAsset asset) async {
    try {
      if (asset.storagePath.trim().isNotEmpty) {
        await FirebaseStorage.instance.ref(asset.storagePath).delete();
        return;
      }
      if (asset.url.contains('firebasestorage.googleapis.com') ||
          asset.url.contains('storage.googleapis.com')) {
        await FirebaseStorage.instance.refFromURL(asset.url).delete();
      }
    } catch (_) {/* arquivo já ausente ou URL externa */}
  }
}
