import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/amanda_asset_models.dart';

class AmandaAssetsRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<AmandaAsset>> fetchAll() async {
    if (!isAvailable) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('amanda_assets')
          .where('active', isEqualTo: true)
          .get();
      return snap.docs
          .map((d) => AmandaAsset.fromMap(d.id, d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
