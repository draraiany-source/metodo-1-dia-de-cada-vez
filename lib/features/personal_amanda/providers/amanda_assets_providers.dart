import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/amanda_assets_repository.dart';
import '../data/amanda_profile_repository.dart';
import '../domain/amanda_asset_models.dart';
import '../domain/amanda_profile_models.dart';

final amandaAssetsRepositoryProvider =
    Provider((ref) => AmandaAssetsRepository());

final amandaAssetsProvider = FutureProvider<List<AmandaAsset>>((ref) {
  return ref.read(amandaAssetsRepositoryProvider).fetchAll();
});

final amandaProfileRepositoryProvider =
    Provider((ref) => AmandaProfileRepository());

final amandaProfileContentProvider =
    StreamProvider<AmandaProfileContent>((ref) {
  return ref.watch(amandaProfileRepositoryProvider).watch();
});

List<AmandaAsset> amandaAssetsFor(
  List<AmandaAsset> all,
  AmandaAssetCategory category, {
  int? limit,
}) {
  final list = all
      .where((a) => a.category == category && a.active && a.url.isNotEmpty)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  if (limit == null || list.length <= limit) return list;
  return list.take(limit).toList();
}

/// Galeria unificada Quem Sou Eu (galeria + trajetória + treinos).
List<AmandaAsset> amandaPublicGallery(List<AmandaAsset> all) {
  final cats = {
    AmandaAssetCategory.galeria,
    AmandaAssetCategory.trajetoria,
    AmandaAssetCategory.treinos,
    AmandaAssetCategory.profissional,
    AmandaAssetCategory.motivacional,
  };
  final list = all
      .where((a) => cats.contains(a.category) && a.active && a.url.isNotEmpty)
      .toList()
    ..sort((a, b) {
      final byCat = a.category.index.compareTo(b.category.index);
      if (byCat != 0) return byCat;
      return a.order.compareTo(b.order);
    });
  return list;
}

AmandaAsset? bestAmandaAssetFor(
  List<AmandaAsset> all,
  AmandaAssetCategory category, {
  List<AmandaAssetCategory> fallbacks = const [],
}) {
  for (final cat in [category, ...fallbacks]) {
    final candidatos = amandaAssetsFor(all, cat);
    if (candidatos.isNotEmpty) return candidatos.first;
  }
  return null;
}

AmandaAsset? amandaAssetAt(
  List<AmandaAsset> all,
  AmandaAssetCategory category,
  int index,
) {
  final list = amandaAssetsFor(all, category);
  if (index < 0 || index >= list.length) return null;
  return list[index];
}
