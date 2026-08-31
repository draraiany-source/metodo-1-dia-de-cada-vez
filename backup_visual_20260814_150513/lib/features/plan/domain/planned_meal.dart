import '../../../core/constants/seed_data.dart';
import '../../nutrition/domain/nutrition_models.dart';

/// Associa cada slot do plano do dia (café, almoço, lanche, jantar) à
/// receita real do catálogo ([SeedData.recipes]) — o mesmo padrão já usado
/// para o treino de hoje (`SeedData.workouts` rotacionado por dia da
/// semana). Nada de nome/prato fixo dentro do widget: a tela só lê daqui.
extension PlannedMealX on MealType {
  /// Categoria de receita correspondente no catálogo.
  String get recipeCategory => switch (this) {
        MealType.cafeDaManha => 'Café da manhã',
        MealType.lancheDaManha => 'Lanche',
        MealType.almoco => 'Almoço',
        MealType.lancheDaTarde => 'Lanche',
        MealType.jantar => 'Jantar',
        MealType.ceia => 'Lanche',
        MealType.lancheExtra => 'Lanche',
      };

  /// A receita "oficial" desse slot no plano do dia — `null` apenas se o
  /// catálogo não tiver nenhuma receita daquela categoria cadastrada.
  Recipe? get plannedRecipe => SeedData.recipeForCategory(recipeCategory);
}
