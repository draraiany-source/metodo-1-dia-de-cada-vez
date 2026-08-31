enum EbookCategory {
  nutricao,
  treino,
  mentalidade,
  receitas,
  motivacional,
  habitos,
  geral,
}

extension EbookCategoryInfo on EbookCategory {
  String get label => switch (this) {
        EbookCategory.nutricao => 'Nutrição',
        EbookCategory.treino => 'Treino',
        EbookCategory.mentalidade => 'Mentalidade',
        EbookCategory.receitas => 'Receitas',
        EbookCategory.motivacional => 'Motivacional',
        EbookCategory.habitos => 'Hábitos',
        EbookCategory.geral => 'Geral',
      };
}

/// Metadados públicos de um e-book — o PDF em si (arquivo grande) NÃO fica
/// aqui. Fica em `ebooks/{id}/private/file`, só resolvido pela Cloud
/// Function `getContentUrl` (mesmo padrão de proteção usado nos vídeos).
class Ebook {
  const Ebook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    required this.description,
    required this.pages,
    required this.isPremium,
    required this.order,
    required this.active,
  });

  final String id;
  final String title;
  final String author;
  final EbookCategory category;
  final String coverUrl;
  final String description;
  final int pages;
  final bool isPremium;
  final int order;
  final bool active;

  Map<String, dynamic> toMap() => {
        'title': title,
        'author': author,
        'category': category.name,
        'coverUrl': coverUrl,
        'description': description,
        'pages': pages,
        'isPremium': isPremium,
        'order': order,
        'active': active,
      };

  factory Ebook.fromMap(String id, Map<String, dynamic> m) => Ebook(
        id: id,
        title: (m['title'] ?? '') as String,
        author: (m['author'] ?? '') as String,
        category: EbookCategory.values.firstWhere(
            (c) => c.name == m['category'],
            orElse: () => EbookCategory.geral),
        coverUrl: (m['coverUrl'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        pages: (m['pages'] ?? 0) as int,
        isPremium: (m['isPremium'] ?? false) as bool,
        order: (m['order'] ?? 0) as int,
        active: (m['active'] ?? true) as bool,
      );
}
