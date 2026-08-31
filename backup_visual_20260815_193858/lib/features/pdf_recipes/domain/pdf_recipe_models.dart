enum PdfRecipeCategory {
  cafeDaManha,
  almoco,
  jantar,
  lanches,
  sobremesasFit,
  lowCarb,
  hipertrofia,
  emagrecimento,
  vegetarianas,
  veganas,
  airFryer,
}

extension PdfRecipeCategoryInfo on PdfRecipeCategory {
  String get label => switch (this) {
        PdfRecipeCategory.cafeDaManha => 'Café da manhã',
        PdfRecipeCategory.almoco => 'Almoço',
        PdfRecipeCategory.jantar => 'Jantar',
        PdfRecipeCategory.lanches => 'Lanches',
        PdfRecipeCategory.sobremesasFit => 'Sobremesas Fit',
        PdfRecipeCategory.lowCarb => 'Low Carb',
        PdfRecipeCategory.hipertrofia => 'Hipertrofia',
        PdfRecipeCategory.emagrecimento => 'Emagrecimento',
        PdfRecipeCategory.vegetarianas => 'Vegetarianas',
        PdfRecipeCategory.veganas => 'Veganas',
        PdfRecipeCategory.airFryer => 'Air Fryer',
      };
}

enum RecipeDifficulty { facil, medio, dificil }

extension RecipeDifficultyInfo on RecipeDifficulty {
  String get label => switch (this) {
        RecipeDifficulty.facil => 'Fácil',
        RecipeDifficulty.medio => 'Médio',
        RecipeDifficulty.dificil => 'Difícil',
      };
}

/// Receita cujo conteúdo completo mora num PDF (a lista mostra só os
/// metadados/macros; o preparo em si é aberto no visualizador de PDF).
class PdfRecipe {
  const PdfRecipe({
    required this.id,
    required this.title,
    required this.category,
    required this.coverUrl,
    required this.pdfUrl,
    required this.minutes,
    required this.difficulty,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isPremium = false,
  });

  final String id;
  final String title;
  final PdfRecipeCategory category;
  final String coverUrl;
  final String pdfUrl;
  final int minutes;
  final RecipeDifficulty difficulty;
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final bool isPremium;

  factory PdfRecipe.fromMap(String id, Map<String, dynamic> m) {
    return PdfRecipe(
      id: id,
      title: (m['title'] ?? '') as String,
      category: PdfRecipeCategory.values.firstWhere(
          (c) => c.name == m['category'],
          orElse: () => PdfRecipeCategory.almoco),
      coverUrl: (m['coverUrl'] ?? '') as String,
      pdfUrl: (m['pdfUrl'] ?? '') as String,
      minutes: (m['minutes'] ?? 0) as int,
      difficulty: RecipeDifficulty.values.firstWhere(
          (d) => d.name == m['difficulty'],
          orElse: () => RecipeDifficulty.facil),
      kcal: (m['kcal'] ?? 0) as int,
      protein: (m['protein'] ?? 0) as int,
      carbs: (m['carbs'] ?? 0) as int,
      fat: (m['fat'] ?? 0) as int,
      isPremium: (m['isPremium'] ?? false) as bool,
    );
  }
}
