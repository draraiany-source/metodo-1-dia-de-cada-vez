import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/treino_catalog_models.dart';

/// Caminho do JSON oficial (117 treinos).
const kTreinoCatalogAssetPath =
    'assets/content/treinos_catalogo_oficial.json';

/// Repositório local-first do catálogo oficial.
/// Firestore sync fica preparado via [toFirestoreMap] sem escrita automática.
class TreinoCatalogRepository {
  TreinoCatalogRepository({this.assetPath = kTreinoCatalogAssetPath});

  final String assetPath;
  TreinoCatalogSnapshot? _cache;

  void clearCache() => _cache = null;

  Future<TreinoCatalogSnapshot> load({bool forceReload = false}) async {
    if (_cache != null && !forceReload) return _cache!;

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = (decoded['treinos'] as List<dynamic>)
          .map((e) => TreinoCatalogEntry.fromMap(e as Map<String, dynamic>))
          .toList();

      _upsertById(list);

      _cache = TreinoCatalogSnapshot(
        version: (decoded['versao_catalogo'] ?? '1.0').toString(),
        totalTreinos: decoded['total_treinos'] as int? ?? list.length,
        treinos: list,
        pendenciasNaoImportar: List<Map<String, dynamic>>.from(
          decoded['pendencias_nao_importar'] as List<dynamic>? ?? const [],
        ),
      );
      return _cache!;
    } on FlutterError catch (e) {
      throw TreinoCatalogLoadException(
        'Asset não encontrado ($assetPath): ${e.message}',
      );
    } on FormatException catch (e) {
      throw TreinoCatalogLoadException('JSON inválido: $e');
    } catch (e) {
      throw TreinoCatalogLoadException('Falha ao carregar catálogo: $e');
    }
  }

  /// Garante um único registro por [TreinoCatalogEntry.id] (último vence).
  void _upsertById(List<TreinoCatalogEntry> list) {
    final map = <String, TreinoCatalogEntry>{};
    for (final t in list) {
      map[t.id] = t;
    }
    list
      ..clear()
      ..addAll(map.values);
    list.sort((a, b) => a.id.compareTo(b.id));
  }

  /// Opções distintas para filtros (somente treinos visíveis ao aluno).
  Future<TreinoCatalogFilterOptions> filterOptions() async {
    final snap = await load();
    final student = snap.forStudent;

    String? pick(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      return v.trim();
    }

    final categorias = <String>{};
    final niveis = <String>{};
    final grupos = <String>{};
    final equipamentos = <String>{};
    final objetivos = <String>{};

    for (final t in student) {
      final c = pick(t.categoria);
      if (c != null) categorias.add(c);
      niveis.addAll(t.nivel.map((n) => n.trim()).where((n) => n.isNotEmpty));
      final g = pick(t.grupoMuscular);
      if (g != null) grupos.add(g);
      final e = pick(t.equipamento);
      if (e != null) equipamentos.add(e);
      final o = pick(t.objetivo);
      if (o != null) objetivos.add(o);
    }

    int sort(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    return TreinoCatalogFilterOptions(
      categorias: categorias.toList()..sort(sort),
      niveis: niveis.toList()..sort(sort),
      gruposMusculares: grupos.toList()..sort(sort),
      equipamentos: equipamentos.toList()..sort(sort),
      objetivos: objetivos.toList()..sort(sort),
    );
  }

  /// Validação interna usada em testes e diagnóstico.
  TreinoCatalogValidation validate(TreinoCatalogSnapshot snap) {
    final ids = snap.treinos.map((t) => t.id).toList();
    final unique = ids.toSet();
    final expected =
        List.generate(117, (i) => 'treino_${(i + 1).toString().padLeft(3, '0')}');
    final missing = expected.where((id) => !unique.contains(id)).toList();
    final duplicates = ids.where((id) => ids.indexOf(id) != ids.lastIndexOf(id)).toSet();
    final invalidLinks = snap.treinos
        .where((t) =>
            !t.linkYoutube.startsWith('http') ||
            !t.linkYoutube.contains('youtube'))
        .map((t) => t.id)
        .toList();

    return TreinoCatalogValidation(
      total: snap.treinos.length,
      uniqueIds: unique.length,
      missingIds: missing,
      duplicateIds: duplicates.toList(),
      invalidYoutubeIds: invalidLinks,
      reviewCount: snap.needsReview.length,
      studentCount: snap.forStudent.length,
    );
  }
}

class TreinoCatalogLoadException implements Exception {
  TreinoCatalogLoadException(this.message);
  final String message;
  @override
  String toString() => message;
}

class TreinoCatalogFilterOptions {
  const TreinoCatalogFilterOptions({
    required this.categorias,
    required this.niveis,
    required this.gruposMusculares,
    required this.equipamentos,
    required this.objetivos,
  });

  final List<String> categorias;
  final List<String> niveis;
  final List<String> gruposMusculares;
  final List<String> equipamentos;
  final List<String> objetivos;
}

class TreinoCatalogValidation {
  const TreinoCatalogValidation({
    required this.total,
    required this.uniqueIds,
    required this.missingIds,
    required this.duplicateIds,
    required this.invalidYoutubeIds,
    required this.reviewCount,
    required this.studentCount,
  });

  final int total;
  final int uniqueIds;
  final List<String> missingIds;
  final List<String> duplicateIds;
  final List<String> invalidYoutubeIds;
  final int reviewCount;
  final int studentCount;

  bool get isValid =>
      total == 117 &&
      uniqueIds == 117 &&
      missingIds.isEmpty &&
      duplicateIds.isEmpty &&
      invalidYoutubeIds.isEmpty &&
      studentCount == 117;
}
