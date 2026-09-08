/// Modelos do catálogo oficial de 117 treinos (treino_001..treino_117).
library;

import 'package:flutter/foundation.dart';

/// Seções visuais conforme documento oficial.
enum TreinoVisualSection {
  cardio,
  core,
  mobilidade,
  inferioresGluteos,
  peitoral,
  costas,
  biceps,
  triceps,
  ombros,
  fullBody,
  panturrilhas,
}

extension TreinoVisualSectionX on TreinoVisualSection {
  String get label => switch (this) {
        TreinoVisualSection.cardio => 'Cardio',
        TreinoVisualSection.core => 'Core / Abdômen',
        TreinoVisualSection.mobilidade => 'Mobilidade / Flexibilidade',
        TreinoVisualSection.inferioresGluteos => 'Membros inferiores / Glúteos',
        TreinoVisualSection.peitoral => 'Peitoral',
        TreinoVisualSection.costas => 'Costas',
        TreinoVisualSection.biceps => 'Bíceps',
        TreinoVisualSection.triceps => 'Tríceps',
        TreinoVisualSection.ombros => 'Ombros',
        TreinoVisualSection.fullBody => 'Full Body / Funcional',
        TreinoVisualSection.panturrilhas => 'Panturrilhas',
      };

  static List<TreinoVisualSection> get ordered => TreinoVisualSection.values;
}

/// Entrada do catálogo oficial.
@immutable
class TreinoCatalogEntry {
  const TreinoCatalogEntry({
    required this.id,
    required this.idOriginal,
    required this.nome,
    required this.categoria,
    required this.grupoMuscular,
    required this.equipamento,
    required this.nivel,
    required this.prescricao,
    required this.intervalo,
    required this.objetivo,
    required this.observacao,
    required this.linkYoutube,
    required this.status,
  });

  final String id;
  final String idOriginal;
  final String nome;
  final String? categoria;
  final String? grupoMuscular;
  final String? equipamento;
  final List<String> nivel;
  final String? prescricao;
  final String? intervalo;
  final String? objetivo;
  final String? observacao;
  final String linkYoutube;
  final String status;

  bool get isReadyForStudent =>
      nome.trim().isNotEmpty &&
      linkYoutube.trim().isNotEmpty &&
      !status.toLowerCase().contains('incompleto');

  bool get needsAdminReview =>
      status.toLowerCase().startsWith('revisar') ||
      status.toLowerCase().contains('confirmar');

  String get nivelLabel => nivel.isEmpty ? '' : nivel.join(' / ');

  TreinoVisualSection get visualSection {
    final cat = _norm(categoria);
    final grupo = _norm(grupoMuscular);
    final hay = '$cat $grupo';

    // Grupo muscular antes de categorias híbridas (ex.: Hipertrofia / Cardio).
    if (grupo.contains('panturrilha') || cat.contains('panturrilha')) {
      return TreinoVisualSection.panturrilhas;
    }
    if (cat.contains('core') ||
        cat.contains('abdomen') ||
        grupo.contains('abdomen') ||
        grupo.contains('core')) {
      return TreinoVisualSection.core;
    }
    if (grupo.contains('peitoral') || cat.contains('peitoral')) {
      return TreinoVisualSection.peitoral;
    }
    if (grupo.contains('costas') ||
        grupo.contains('dorsal') ||
        cat.contains('costas')) {
      return TreinoVisualSection.costas;
    }
    if (grupo.contains('biceps') || cat.contains('biceps')) {
      return TreinoVisualSection.biceps;
    }
    if (grupo.contains('triceps') || cat.contains('triceps')) {
      return TreinoVisualSection.triceps;
    }
    if (grupo.contains('ombro') || cat.contains('ombro')) {
      return TreinoVisualSection.ombros;
    }
    if (cat.contains('membros inferiores') ||
        grupo.contains('gluteo') ||
        grupo.contains('quadriceps') ||
        grupo.contains('posterior') ||
        grupo.contains('isquio') ||
        grupo.contains('adutor') ||
        grupo.contains('abdut') ||
        grupo.contains('membros inferiores')) {
      return TreinoVisualSection.inferioresGluteos;
    }
    if (cat.contains('flexibilidade') ||
        cat.contains('mobilidade') ||
        cat.contains('aquecimento') ||
        hay.contains('along')) {
      return TreinoVisualSection.mobilidade;
    }
    if (cat.contains('full body') ||
        cat.contains('funcional') ||
        cat.contains('emagrecimento')) {
      return TreinoVisualSection.fullBody;
    }
    // Cardio puro (sem hipertrofia) — evita coração em hipertrofia híbrida.
    if (cat.contains('cardio') && !cat.contains('hipertrofia')) {
      return TreinoVisualSection.cardio;
    }
    return TreinoVisualSection.fullBody;
  }

  static String _norm(String? v) => (v ?? '')
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ã', 'a')
      .replaceAll('õ', 'o')
      .replaceAll('ç', 'c')
      .replaceAll('–', '-')
      .replaceAll('—', '-');

  factory TreinoCatalogEntry.fromMap(Map<String, dynamic> m) {
    final rawNivel = m['nivel'];
    final niveis = rawNivel is List
        ? rawNivel.map((e) => e.toString()).toList()
        : rawNivel == null
            ? <String>[]
            : [rawNivel.toString()];

    return TreinoCatalogEntry(
      id: m['id'] as String,
      idOriginal: (m['id_original'] ?? m['id']).toString(),
      nome: (m['nome'] ?? '').toString(),
      categoria: m['categoria'] as String?,
      grupoMuscular: m['grupo_muscular'] as String?,
      equipamento: m['equipamento'] as String?,
      nivel: niveis,
      prescricao: m['prescricao'] as String?,
      intervalo: m['intervalo'] as String?,
      objetivo: m['objetivo'] as String?,
      observacao: m['observacao'] as String?,
      linkYoutube: (m['link_youtube'] ?? '').toString(),
      status: (m['status'] ?? 'pronto').toString(),
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        'id': id,
        'id_original': idOriginal,
        'nome': nome,
        'categoria': categoria,
        'grupo_muscular': grupoMuscular,
        'equipamento': equipamento,
        'nivel': nivel,
        'prescricao': prescricao,
        'intervalo': intervalo,
        'objetivo': objetivo,
        'observacao': observacao,
        'link_youtube': linkYoutube,
        'status': status,
      };
}

/// Filtros avançados do catálogo.
@immutable
class TreinoCatalogFilters {
  const TreinoCatalogFilters({
    this.categoria,
    this.nivel,
    this.grupoMuscular,
    this.equipamento,
    this.objetivo,
  });

  final String? categoria;
  final String? nivel;
  final String? grupoMuscular;
  final String? equipamento;
  final String? objetivo;

  bool get isEmpty =>
      categoria == null &&
      nivel == null &&
      grupoMuscular == null &&
      equipamento == null &&
      objetivo == null;

  int get activeCount =>
      [categoria, nivel, grupoMuscular, equipamento, objetivo]
          .where((v) => v != null)
          .length;

  bool matches(TreinoCatalogEntry t) {
    if (categoria != null && (t.categoria ?? '') != categoria) return false;
    if (nivel != null && !t.nivel.contains(nivel!)) return false;
    if (grupoMuscular != null && (t.grupoMuscular ?? '') != grupoMuscular) {
      return false;
    }
    if (equipamento != null && (t.equipamento ?? '') != equipamento) {
      return false;
    }
    if (objetivo != null && (t.objetivo ?? '') != objetivo) return false;
    return true;
  }

  TreinoCatalogFilters copyWith({
    String? Function()? categoria,
    String? Function()? nivel,
    String? Function()? grupoMuscular,
    String? Function()? equipamento,
    String? Function()? objetivo,
  }) =>
      TreinoCatalogFilters(
        categoria: categoria != null ? categoria() : this.categoria,
        nivel: nivel != null ? nivel() : this.nivel,
        grupoMuscular:
            grupoMuscular != null ? grupoMuscular() : this.grupoMuscular,
        equipamento: equipamento != null ? equipamento() : this.equipamento,
        objetivo: objetivo != null ? objetivo() : this.objetivo,
      );
}

/// Metadados do catálogo carregado.
@immutable
class TreinoCatalogSnapshot {
  const TreinoCatalogSnapshot({
    required this.version,
    required this.totalTreinos,
    required this.treinos,
    required this.pendenciasNaoImportar,
  });

  final String version;
  final int totalTreinos;
  final List<TreinoCatalogEntry> treinos;
  final List<Map<String, dynamic>> pendenciasNaoImportar;

  List<TreinoCatalogEntry> get forStudent =>
      treinos.where((t) => t.isReadyForStudent).toList(growable: false);

  List<TreinoCatalogEntry> get needsReview =>
      treinos.where((t) => t.needsAdminReview).toList(growable: false);
}
