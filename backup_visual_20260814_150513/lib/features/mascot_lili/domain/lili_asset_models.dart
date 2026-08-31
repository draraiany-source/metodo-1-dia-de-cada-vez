/// Categorias de asset dinâmico da Lili — cobre poses, emoções e estados de
/// UI. Um [MascotePose] estático (as 15 poses locais já existentes) é
/// mapeado numa dessas categorias por `liliCategoryForPose`, então quando
/// alguém cadastra uma imagem/animação pra categoria certa no painel admin,
/// TODAS as telas que já usam aquela pose passam a exibi-la automaticamente
/// — sem precisar tocar em nenhuma tela existente.
enum LiliAssetCategory {
  feliz,
  animada,
  correndo,
  treinando,
  alongando,
  dormindo,
  comemorando,
  pensando,
  incentivando,
  conquista,
  missao,
  desafio,
  loading,
  telaVazia,
  erro,
  premium,
}

extension LiliAssetCategoryInfo on LiliAssetCategory {
  String get label => switch (this) {
        LiliAssetCategory.feliz => 'Feliz',
        LiliAssetCategory.animada => 'Animada',
        LiliAssetCategory.correndo => 'Correndo',
        LiliAssetCategory.treinando => 'Treinando',
        LiliAssetCategory.alongando => 'Alongando',
        LiliAssetCategory.dormindo => 'Dormindo',
        LiliAssetCategory.comemorando => 'Comemorando',
        LiliAssetCategory.pensando => 'Pensando',
        LiliAssetCategory.incentivando => 'Incentivando',
        LiliAssetCategory.conquista => 'Conquista',
        LiliAssetCategory.missao => 'Missão',
        LiliAssetCategory.desafio => 'Desafio',
        LiliAssetCategory.loading => 'Loading',
        LiliAssetCategory.telaVazia => 'Tela vazia',
        LiliAssetCategory.erro => 'Erro',
        LiliAssetCategory.premium => 'Premium',
      };
}

enum LiliAssetType { imagem, lottie, rive }

/// Um asset dinâmico cadastrado pelo painel admin — substitui (quando
/// ativo) a arte estática local pra sua categoria.
class LiliAsset {
  const LiliAsset({
    required this.id,
    required this.category,
    required this.type,
    required this.url,
    required this.active,
    required this.order,
  });

  final String id;
  final LiliAssetCategory category;
  final LiliAssetType type;
  final String url;
  final bool active;
  final int order;

  Map<String, dynamic> toMap() => {
        'category': category.name,
        'type': type.name,
        'url': url,
        'active': active,
        'order': order,
      };

  factory LiliAsset.fromMap(String id, Map<String, dynamic> m) => LiliAsset(
        id: id,
        category: LiliAssetCategory.values.firstWhere(
            (c) => c.name == m['category'],
            orElse: () => LiliAssetCategory.feliz),
        type: LiliAssetType.values.firstWhere((t) => t.name == m['type'],
            orElse: () => LiliAssetType.imagem),
        url: (m['url'] ?? '') as String,
        active: (m['active'] ?? true) as bool,
        order: (m['order'] ?? 0) as int,
      );
}
