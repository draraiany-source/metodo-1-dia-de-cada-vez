/// Categorias de foto da Amanda (Personal Trainer oficial) — cada uma pode
/// ser trocada pelo painel admin sem publicar nova versão do app.
enum AmandaAssetCategory {
  principal,
  profissional,
  categoria,
  banner,
  desafio,
  motivacional,
  premium,
}

extension AmandaAssetCategoryInfo on AmandaAssetCategory {
  String get label => switch (this) {
        AmandaAssetCategory.principal => 'Foto principal',
        AmandaAssetCategory.profissional => 'Fotos profissionais',
        AmandaAssetCategory.categoria => 'Fotos por categoria',
        AmandaAssetCategory.banner => 'Fotos para banners',
        AmandaAssetCategory.desafio => 'Fotos para desafios',
        AmandaAssetCategory.motivacional => 'Fotos motivacionais',
        AmandaAssetCategory.premium => 'Fotos Premium',
      };
}

/// Um asset (foto) da Amanda cadastrado no painel admin.
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
