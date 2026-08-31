// Enums compartilhados do modulo Nutricao IA (Etapa 1).
enum FoodDataSource {
  taco,
  tbca,
  usda,
  openFoodFacts,
  manual,
  localSeed,
  iaOnly,
}

extension FoodDataSourceX on FoodDataSource {
  String get label => switch (this) {
        FoodDataSource.taco => 'TACO',
        FoodDataSource.tbca => 'TBCA',
        FoodDataSource.usda => 'USDA',
        FoodDataSource.openFoodFacts => 'Open Food Facts',
        FoodDataSource.manual => 'Manual',
        FoodDataSource.localSeed => 'Base local',
        FoodDataSource.iaOnly => 'Estimativa IA',
      };
}

/// Origem de um item dentro de uma refeição (Parte A.3 do spec).
enum MealItemSource {
  iaEstimate,
  userConfirmed,
  manual,
  iaOnly,
}

extension MealItemSourceX on MealItemSource {
  String get label => switch (this) {
        MealItemSource.iaEstimate => 'Estimativa IA',
        MealItemSource.userConfirmed => 'Confirmado',
        MealItemSource.manual => 'Manual',
        MealItemSource.iaOnly => 'IA (sem base)',
      };

  /// Nenhuma estimativa da IA é persistida como confirmada sem revisão.
  bool get isConfirmed => this == MealItemSource.userConfirmed;
}

/// Unidades de medida para porções (Parte A.2 / B5).
enum FoodUnit {
  gram,
  unit,
  tablespoon,
  teaspoon,
  cup,
  slice,
  portion,
  ml,
}

extension FoodUnitX on FoodUnit {
  String get label => switch (this) {
        FoodUnit.gram => 'g',
        FoodUnit.unit => 'unidade',
        FoodUnit.tablespoon => 'colher de sopa',
        FoodUnit.teaspoon => 'colher de chá',
        FoodUnit.cup => 'xícara',
        FoodUnit.slice => 'fatia',
        FoodUnit.portion => 'porção',
        FoodUnit.ml => 'ml',
      };

  String get shortLabel => switch (this) {
        FoodUnit.gram => 'g',
        FoodUnit.unit => 'un',
        FoodUnit.tablespoon => 'cs',
        FoodUnit.teaspoon => 'cc',
        FoodUnit.cup => 'xíc',
        FoodUnit.slice => 'fatia',
        FoodUnit.portion => 'porção',
        FoodUnit.ml => 'ml',
      };
}

/// Objetivo nutricional da usuária (Parte A.2 / B14).
enum NutritionObjective {
  emagrecimento,
  manutencao,
  ganhoMassa,
}

extension NutritionObjectiveX on NutritionObjective {
  String get label => switch (this) {
        NutritionObjective.emagrecimento => 'Emagrecimento',
        NutritionObjective.manutencao => 'Manutenção',
        NutritionObjective.ganhoMassa => 'Ganho de massa',
      };
}

/// Confiança retornada pela IA de visão (Parte D.3).
enum AiConfidence {
  high,
  medium,
  low,
}

extension AiConfidenceX on AiConfidence {
  static AiConfidence? tryParse(String? raw) {
    if (raw == null) return null;
    final normalized = raw.toLowerCase();
    for (final value in AiConfidence.values) {
      if (value.name == normalized) return value;
    }
    return null;
  }

  String get label => switch (this) {
        AiConfidence.high => 'Alta',
        AiConfidence.medium => 'Média',
        AiConfidence.low => 'Baixa',
      };
}
