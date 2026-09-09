/// Categorias de foto da Amanda (Personal Trainer oficial).
///
/// Cada slot da interface lê uma categoria. O painel admin grava/troca/exclui
/// sem republicar o app. Novos valores entram no fim do enum para não quebrar
/// documentos antigos no Firestore (`fromMap` usa o nome da categoria).
enum AmandaAssetCategory {
  principal,
  profissional,
  categoria,
  banner,
  capa,
  desafio,
  motivacional,
  premium,
  galeria,
  trajetoria,
  treinos,
}

extension AmandaAssetCategoryInfo on AmandaAssetCategory {
  String get label => switch (this) {
        AmandaAssetCategory.principal => 'Foto de perfil',
        AmandaAssetCategory.profissional => 'Foto profissional principal',
        AmandaAssetCategory.categoria => 'Fotos por categoria',
        AmandaAssetCategory.banner => 'Banner da Home',
        AmandaAssetCategory.capa => 'Capa (Quem Sou Eu)',
        AmandaAssetCategory.desafio => 'Fotos para desafios',
        AmandaAssetCategory.motivacional => 'Fotos motivacionais',
        AmandaAssetCategory.premium => 'Fotos Premium',
        AmandaAssetCategory.galeria => 'Galeria (Quem Sou Eu)',
        AmandaAssetCategory.trajetoria => 'Trajetória / eventos',
        AmandaAssetCategory.treinos => 'Treinos e academia',
      };

  String get hint => switch (this) {
        AmandaAssetCategory.principal =>
          'Avatar circular no perfil Quem Sou Eu.',
        AmandaAssetCategory.profissional =>
          'Retrato grande (fallback da capa).',
        AmandaAssetCategory.banner =>
          'Banner grande no topo da Home (BoxFit.cover).',
        AmandaAssetCategory.capa =>
          'Foto de capa no topo da página Quem Sou Eu.',
        AmandaAssetCategory.galeria =>
          'Fotos gerais da galeria profissional.',
        AmandaAssetCategory.trajetoria =>
          'Formação, certificações, eventos e carreira.',
        AmandaAssetCategory.treinos =>
          'Treinos, academia e rotina profissional.',
        _ => 'Exibida nas áreas correspondentes do aplicativo.',
      };
}

/// Um asset (foto) da Amanda cadastrado no painel admin / futuro backend.
class AmandaAsset {
  const AmandaAsset({
    required this.id,
    required this.category,
    required this.url,
    required this.active,
    required this.order,
  });

  final String id;
  final AmandaAssetCategory category;
  final String url;
  final bool active;
  final int order;

  Map<String, dynamic> toMap() => {
        'category': category.name,
        'url': url,
        'active': active,
        'order': order,
      };

  factory AmandaAsset.fromMap(String id, Map<String, dynamic> m) =>
      AmandaAsset(
        id: id,
        category: AmandaAssetCategory.values.firstWhere(
            (c) => c.name == m['category'],
            orElse: () => AmandaAssetCategory.principal),
        url: (m['url'] ?? '') as String,
        active: (m['active'] ?? true) as bool,
        order: (m['order'] ?? 0) as int,
      );
}
