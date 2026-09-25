import '../../../core/constants/seed_data.dart';
import 'recipe_neon_icons.dart';

/// Prioridade visual das receitas:
/// 1) URL de rede ([Recipe.photoUrl]) quando http(s)
/// 2) ícone neon específico da receita
/// 3) ícone de receita semelhante na mesma categoria (sem repetir se possível)
/// 4) placeholder saudável neon ([RecipeNeonIcons.placeholder])
///
/// Nunca usa coração, halter, emoji, treino ou ilustrações JPEG genéricas.
class RecipeImageResolver {
  RecipeImageResolver._();

  static const String placeholder = RecipeNeonIcons.placeholder;

  /// Associação auditada seed → ícone mais específico (todos únicos).
  static const Map<String, String> _byId = {
    'omelete_fit': RecipeNeonIcons.omeleteEspinafreTomates,
    'panqueca_aveia': RecipeNeonIcons.panquecasFrutasMel,
    'frango_legumes': RecipeNeonIcons.frangoLegumes,
    'bowl_proteico': RecipeNeonIcons.tigelaFrango,
    'buddha_bowl_vegano': RecipeNeonIcons.bowlQuinoa,
    'salada_low_carb': RecipeNeonIcons.bowlSaladaFrango,
    'frango_air_fryer': RecipeNeonIcons.frangoLegumesIcon,
    'sopa_legumes': RecipeNeonIcons.sopaLegumes,
    'batata_doce_air_fryer': RecipeNeonIcons.batatasAssadas,
    'muffin_chocolate_fit': RecipeNeonIcons.muffinChocolate,
    'smoothie_proteico': RecipeNeonIcons.smoothieFrutas,
    'shake_verde': RecipeNeonIcons.sucoVerdeDetox,
    // Sem shake de chocolate no pacote — melhor fallback de bebida cremosa.
    'shake_chocolate': RecipeNeonIcons.parfaitIogurte,
  };

  /// IDs com match direto do tipo de prato (não fallback de categoria).
  static const Set<String> specificMatchIds = {
    'omelete_fit',
    'panqueca_aveia',
    'frango_legumes',
    'bowl_proteico',
    'buddha_bowl_vegano',
    'salada_low_carb',
    'frango_air_fryer',
    'sopa_legumes',
    'batata_doce_air_fryer',
    'muffin_chocolate_fit',
    'smoothie_proteico',
    'shake_verde',
  };

  /// Ainda precisam de arte nova (pacote não tem o prato exato).
  static const List<RecipeImageNeed> needsSpecificPhoto = [
    RecipeImageNeed(
      recipeId: 'shake_chocolate',
      title: 'Shake de Chocolate Proteico',
      category: 'Lanche',
      neededImage: 'Shake/bebida de chocolate proteico (estilo neon)',
      suggestedFile:
          'assets/images/recipes/neon/41_shake_chocolate_proteico_neon.png',
      currentFallback: '14_parfait_de_iogurte_com_neon_vibrante.jpg',
    ),
  ];

  static bool hasNetworkPhoto(Recipe recipe) {
    final url = recipe.photoUrl?.trim() ?? '';
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static String? networkUrl(Recipe recipe) =>
      hasNetworkPhoto(recipe) ? recipe.photoUrl!.trim() : null;

  static bool isSpecificMatch(Recipe recipe) =>
      specificMatchIds.contains(recipe.id);

  /// Asset local (específico → categoria semelhante → placeholder neon).
  static String assetFor(Recipe recipe) {
    final byId = _byId[recipe.id];
    if (byId != null && byId.isNotEmpty) return byId;
    return _categoryAsset(recipe);
  }

  static String _categoryAsset(Recipe recipe) {
    final tags = recipe.tags.map((t) => t.toLowerCase()).toList();
    final title = recipe.title.toLowerCase();
    final cat = recipe.category.toLowerCase();

    if (title.contains('sopa')) return RecipeNeonIcons.sopaCaseira;
    if (title.contains('muffin') || tags.contains('sobremesas')) {
      return RecipeNeonIcons.muffinChocolate;
    }
    if (title.contains('smoothie') || title.contains('shake')) {
      if (title.contains('verde') || title.contains('detox')) {
        return RecipeNeonIcons.sucoDetoxVerde;
      }
      return RecipeNeonIcons.smoothieFrutas;
    }
    if (title.contains('omelete') || title.contains('ovo')) {
      return RecipeNeonIcons.omeleteGourmet;
    }
    if (title.contains('panqueca')) return RecipeNeonIcons.panquecasFrutas;
    if (title.contains('batata')) return RecipeNeonIcons.batatasAssadas;
    if (title.contains('salada')) return RecipeNeonIcons.saladaSaudavel;
    if (title.contains('bowl') || title.contains('buddha')) {
      return tags.contains('veganas')
          ? RecipeNeonIcons.bowlQuinoa
          : RecipeNeonIcons.bowlSaladaFrango;
    }
    if (title.contains('frango') || title.contains('chicken')) {
      return RecipeNeonIcons.frangoLegumesIcon;
    }
    if (title.contains('peixe') || title.contains('salm')) {
      return RecipeNeonIcons.salmaoGrelhado;
    }
    if (title.contains('aveia')) return RecipeNeonIcons.aveiaFrutas;
    if (title.contains('wrap')) return RecipeNeonIcons.wrapFrango;
    if (title.contains('sandu')) return RecipeNeonIcons.sanduicheIntegral;
    if (title.contains('tapioca')) return RecipeNeonIcons.tapioca;

    if (tags.contains('shakes')) return RecipeNeonIcons.smoothieFrutas;
    if (tags.contains('veganas')) return RecipeNeonIcons.bowlQuinoa;
    if (tags.contains('low carb')) return RecipeNeonIcons.saladaSaudavel;

    if (cat.contains('café') || cat.contains('cafe')) {
      return RecipeNeonIcons.ovosMexidos;
    }
    if (cat.contains('almoço') || cat.contains('almoco')) {
      return RecipeNeonIcons.tigelaFrango;
    }
    if (cat.contains('jantar')) return RecipeNeonIcons.sopaCaseira;
    if (cat.contains('lanche')) return RecipeNeonIcons.mixCastanhas;

    return placeholder;
  }

  /// Ícones neon usam contain sobre fundo escuro.
  static bool useContainFit(String assetPath) {
    final p = assetPath.toLowerCase();
    return p.contains('/recipes/neon/') ||
        p.contains('/neon/') ||
        p.endsWith('.png');
  }
}

class RecipeImageNeed {
  const RecipeImageNeed({
    required this.recipeId,
    required this.title,
    required this.category,
    required this.neededImage,
    required this.suggestedFile,
    this.currentFallback,
  });

  final String recipeId;
  final String title;
  final String category;
  final String neededImage;
  final String suggestedFile;
  final String? currentFallback;
}
