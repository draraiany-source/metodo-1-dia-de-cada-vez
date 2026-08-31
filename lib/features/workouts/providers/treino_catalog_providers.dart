import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/treino_catalog_repository.dart';
import '../domain/treino_catalog_models.dart';

final treinoCatalogRepositoryProvider = Provider<TreinoCatalogRepository>(
  (ref) => TreinoCatalogRepository(),
);

final treinoCatalogSnapshotProvider =
    FutureProvider<TreinoCatalogSnapshot>((ref) async {
  final repo = ref.watch(treinoCatalogRepositoryProvider);
  return repo.load();
});

final treinoCatalogStudentProvider =
    FutureProvider<List<TreinoCatalogEntry>>((ref) async {
  final repo = ref.watch(treinoCatalogRepositoryProvider);
  final snap = await repo.load();
  return snap.forStudent;
});

final treinoCatalogFilterOptionsProvider =
    FutureProvider<TreinoCatalogFilterOptions>((ref) async {
  final repo = ref.watch(treinoCatalogRepositoryProvider);
  return repo.filterOptions();
});

final treinoCatalogValidationProvider =
    FutureProvider<TreinoCatalogValidation>((ref) async {
  final repo = ref.watch(treinoCatalogRepositoryProvider);
  final snap = await repo.load();
  return repo.validate(snap);
});
