import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lili_assets_repository.dart';
import '../domain/lili_asset_models.dart';

final liliAssetsRepositoryProvider =
    Provider((ref) => LiliAssetsRepository());

/// Todos os assets ativos, recarregados quando `ref.invalidate` é chamado
/// (o admin faz isso depois de qualquer alteração).
final liliAssetsProvider = FutureProvider<List<LiliAsset>>((ref) {
  return ref.read(liliAssetsRepositoryProvider).fetchAll();
});

/// Melhor asset ativo pra uma categoria (menor `order`), ou null se não
/// houver nenhum cadastrado — quem consome cai pro estático local.
LiliAsset? bestLiliAssetFor(List<LiliAsset> all, LiliAssetCategory category) {
  final candidatos =
      all.where((a) => a.category == category && a.active).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
  return candidatos.isEmpty ? null : candidatos.first;
}
