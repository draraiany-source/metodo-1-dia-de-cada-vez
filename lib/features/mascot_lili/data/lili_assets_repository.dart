import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firebase_service.dart';
import '../domain/lili_asset_models.dart';

/// Busca os assets dinâmicos da Lili no Firestore (`lili_assets`).
/// Sem Firebase configurado, ou sem nada cadastrado, devolve lista vazia —
/// quem consome (o widget `LiliMascot`) cai pra arte estática local, nunca
/// quebra layout.
class LiliAssetsRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<LiliAsset>> fetchAll() async {
    if (!isAvailable) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('lili_assets')
          .where('active', isEqualTo: true)
          .get();
      return snap.docs.map((d) => LiliAsset.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }
}
