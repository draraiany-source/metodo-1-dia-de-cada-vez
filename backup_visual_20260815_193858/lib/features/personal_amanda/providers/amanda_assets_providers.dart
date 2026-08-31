import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/amanda_assets_repository.dart';
import '../domain/amanda_asset_models.dart';

final amandaAssetsRepositoryProvider =
    Provider((ref) => AmandaAssetsRepository());

final amandaAssetsProvider = FutureProvider<List<AmandaAsset>>((ref) {
  return ref.read(amandaAssetsRepositoryProvider).fetchAll();
});

AmandaAsset? bestAmandaAssetFor(
    List<AmandaAsset> all, AmandaAssetCategory category) {
  final candidatos =
      all.where((a) => a.category == category && a.active).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  return candidatos.isEmpty ? null : candidatos.first;
}
