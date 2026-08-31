import '../../models/domain_models.dart';

/// Conteúdo inicial (seeds) portado dos arquivos JSON do KIT MASTER
/// (06_CONTEUDO e 03_FIREBASE/seeds). Usado como dados mockados no modo
/// offline e como fallback antes do Firestore estar populado.
class SeedData {
  SeedData._();

  static const List<Workout> workouts = [
    // ---- Força (Full Body · Pernas · Braços · Costas · Abdômen · Glúteos) ----
    Workout(
      id: 'full_body_iniciante',
      title: 'Treino Full Body',
      emoji: '🏋️',
      durationMin: 40,
      level: 'Intermediário',
      exercises: 5,
      kcal: 220,
      isPremium: false,
      tags: ['Força', 'Corpo todo', 'Casa', 'Peso corporal', 'Condicionamento'],
    ),
    Workout(
      id: 'pernas_aco',
      title: 'Pernas de Aço',
      emoji: '🦵',
      durationMin: 35,
      level: 'Intermediário',
      exercises: 6,
      kcal: 260,
      isPremium: true,
      tags: ['Força', 'Pernas', 'Academia', 'Halteres', 'Hipertrofia'],
    ),
    Workout(
      id: 'bracos_definidos',
      title: 'Braços Definidos',
      emoji: '💪',
      durationMin: 20,
      level: 'Iniciante',
      exercises: 5,
      kcal: 140,
      isPremium: false,
      tags: ['Força', 'Braços', 'Casa', 'Halteres', 'Hipertrofia'],
    ),
    Workout(
      id: 'costas_postura',
      title: 'Costas e Postura',
      emoji: '🧍',
      durationMin: 25,
      level: 'Intermediário',
      exercises: 5,
      kcal: 160,
      isPremium: false,
      tags: ['Força', 'Costas', 'Academia', 'Elástico', 'Condicionamento'],
    ),
    Workout(
      id: 'abdomen_core',
      title: 'Abdômen Definido',
      emoji: '🔥',
      durationMin: 15,
      level: 'Iniciante',
      exercises: 5,
      kcal: 120,
      isPremium: true,
      tags: ['Força', 'Abdômen', 'Casa', 'Peso corporal', 'Condicionamento'],
    ),

    // ---- Cardio (HIIT · Corrida · Caminhada · Bicicleta · Cardio em casa) ----
    Workout(
      id: 'hiit_emagrecimento',
      title: 'HIIT Emagrecimento',
      emoji: '⚡',
      durationMin: 25,
      level: 'Avançado',
      exercises: 6,
      kcal: 300,
      isPremium: true,
      tags: ['Cardio', 'Corpo todo', 'Casa', 'Peso corporal', 'Emagrecimento'],
    ),
    Workout(
      id: 'corrida_leve',
      title: 'Corrida Leve',
      emoji: '🏃',
      durationMin: 20,
      level: 'Iniciante',
      exercises: 1,
      kcal: 200,
      isPremium: false,
      tags: ['Cardio', 'Corpo todo', 'Ar livre', 'Nenhum equipamento', 'Emagrecimento'],
    ),
    Workout(
      id: 'caminhada_queima',
      title: 'Caminhada Queima Gordura',
      emoji: '🚶',
      durationMin: 30,
      level: 'Iniciante',
      exercises: 1,
      kcal: 150,
      isPremium: false,
      tags: ['Cardio', 'Corpo todo', 'Ar livre', 'Nenhum equipamento', 'Emagrecimento'],
    ),
    Workout(
      id: 'bike_indoor',
      title: 'Bicicleta Indoor',
      emoji: '🚴',
      durationMin: 30,
      level: 'Intermediário',
      exercises: 1,
      kcal: 280,
      isPremium: true,
      tags: ['Cardio', 'Pernas', 'Academia', 'Esteira/Bike', 'Condicionamento'],
    ),
    Workout(
      id: 'cardio_casa',
      title: 'Cardio em Casa',
      emoji: '🔥',
      durationMin: 20,
      level: 'Iniciante',
      exercises: 6,
      kcal: 190,
      isPremium: false,
      tags: ['Cardio', 'Corpo todo', 'Casa', 'Peso corporal', 'Emagrecimento'],
    ),

    // ---- Glúteos (em foco · com faixa · e pernas · avançado) ----
    Workout(
      id: 'gluteos_pernas',
      title: 'Glúteos em Foco',
      emoji: '🍑',
      durationMin: 30,
      level: 'Intermediário',
      exercises: 5,
      kcal: 240,
      isPremium: false,
      tags: ['Glúteos', 'Força', 'Pernas', 'Academia', 'Halteres', 'Hipertrofia'],
    ),
    Workout(
      id: 'gluteos_faixa',
      title: 'Glúteos com Faixa',
      emoji: '🍑',
      durationMin: 25,
      level: 'Iniciante',
      exercises: 5,
      kcal: 170,
      isPremium: false,
      tags: ['Glúteos', 'Pernas', 'Casa', 'Elástico', 'Hipertrofia'],
    ),
    Workout(
      id: 'gluteos_e_pernas',
      title: 'Glúteos e Pernas',
      emoji: '🍑',
      durationMin: 40,
      level: 'Intermediário',
      exercises: 6,
      kcal: 300,
      isPremium: true,
      tags: ['Glúteos', 'Pernas', 'Academia', 'Halteres', 'Hipertrofia'],
    ),
    Workout(
      id: 'gluteos_avancado',
      title: 'Glúteos Avançado',
      emoji: '🔥',
      durationMin: 35,
      level: 'Avançado',
      exercises: 7,
      kcal: 330,
      isPremium: true,
      tags: ['Glúteos', 'Pernas', 'Academia', 'Halteres', 'Hipertrofia'],
    ),

    // ---- Mobilidade (fora das 3 categorias principais, aparece em "Para
    // você" e na busca/filtros avançados) ----
    Workout(
      id: 'alongamento_relax',
      title: 'Alongamento',
      emoji: '🧘',
      durationMin: 20,
      level: 'Todos os níveis',
      exercises: 8,
      kcal: 60,
      isPremium: false,
      tags: ['Mobilidade', 'Casa', 'Nenhum equipamento'],
    ),
  ];

  /// Exercícios de cada treino (do treinos_iniciais.json + expansão do
  /// catálogo de Força/Glúteos). Treinos sem entrada aqui (majoritariamente
  /// os de Cardio, que são contínuos e não em séries) usam o fallback já
  /// existente em `WorkoutDetailScreen`.
  static const Map<String, List<String>> workoutExercises = {
    'full_body_iniciante': [
      'Agachamento livre',
      'Flexão inclinada',
      'Remada com elástico',
      'Prancha',
      'Polichinelo',
    ],
    'pernas_aco': [
      'Agachamento livre',
      'Afundo alternado',
      'Cadeira extensora',
      'Mesa flexora',
      'Panturrilha em pé',
      'Agachamento sumô',
    ],
    'bracos_definidos': [
      'Rosca direta',
      'Tríceps banco',
      'Elevação lateral',
      'Flexão de braço',
      'Rosca martelo',
    ],
    'costas_postura': [
      'Remada com elástico',
      'Superman',
      'Puxada alta',
      'Remada curvada',
      'Prancha com retração escapular',
    ],
    'abdomen_core': [
      'Prancha',
      'Abdominal curto',
      'Elevação de pernas',
      'Dead bug',
      'Prancha lateral',
    ],
    'gluteos_pernas': [
      'Agachamento sumô',
      'Elevação pélvica',
      'Afundo',
      'Cadeira abdutora',
      'Panturrilha',
    ],
    'gluteos_faixa': [
      'Elevação pélvica com faixa',
      'Agachamento com faixa',
      'Chute lateral com faixa',
      'Caranguejo com faixa',
      'Ponte unilateral',
    ],
    'gluteos_e_pernas': [
      'Agachamento sumô',
      'Elevação pélvica',
      'Afundo búlgaro',
      'Stiff',
      'Cadeira abdutora',
      'Panturrilha',
    ],
    'gluteos_avancado': [
      'Agachamento búlgaro com halteres',
      'Elevação pélvica unilateral',
      'Stiff com halteres',
      'Afundo com salto',
      'Cadeira abdutora com peso',
      'Panturrilha unilateral',
      'Ponte com pausa',
    ],
  };

  static const List<Recipe> recipes = [
    Recipe(
      id: 'omelete_fit',
      title: 'Omelete Proteica',
      emoji: '🍳',
      category: 'Café da manhã',
      kcal: 290,
      protein: 24,
      carbs: 6,
      fat: 18,
      durationMin: 10,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Low Carb',
      objetivo: 'Emagrecimento',
      tags: ['Low Carb'],
      ingredients: ['2 ovos', 'tomate', 'cebola', 'queijo branco'],
      steps: 'Misture tudo e grelhe em frigideira antiaderente.',
    ),
    Recipe(
      id: 'panqueca_aveia',
      title: 'Panqueca de Aveia',
      emoji: '🥞',
      category: 'Café da manhã',
      kcal: 320,
      protein: 14,
      carbs: 42,
      fat: 9,
      durationMin: 20,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Vegetariana',
      objetivo: 'Emagrecimento',
      tags: ['Emagrecer'],
      ingredients: [
        '1/2 xícara de aveia',
        '1 ovo',
        '1/2 banana amassada',
        'canela a gosto',
      ],
      steps:
          'Bata todos os ingredientes, despeje na frigideira antiaderente e '
          'doure dos dois lados.',
    ),
    Recipe(
      id: 'frango_legumes',
      title: 'Frango com Legumes',
      emoji: '🍗',
      category: 'Almoço',
      kcal: 450,
      protein: 38,
      carbs: 28,
      fat: 16,
      durationMin: 30,
      difficulty: 'Fácil',
      servings: 2,
      dietType: 'Tradicional',
      objetivo: 'Hipertrofia',
      tags: ['Hipertrofia'],
      ingredients: ['frango', 'brócolis', 'cenoura', 'abobrinha'],
      steps: 'Grelhe o frango e refogue os legumes.',
    ),
    Recipe(
      id: 'bowl_proteico',
      title: 'Bowl Proteico',
      emoji: '🥗',
      category: 'Almoço',
      kcal: 380,
      protein: 32,
      carbs: 34,
      fat: 12,
      durationMin: 15,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Tradicional',
      objetivo: 'Hipertrofia',
      tags: ['Hipertrofia'],
      ingredients: [
        '100g de frango grelhado',
        '1/2 xícara de quinoa',
        '1/2 abacate',
        'tomate cereja',
        'folhas verdes',
        'azeite e sal a gosto',
      ],
      steps:
          'Monte o bowl com a quinoa como base, adicione o frango fatiado e '
          'os demais ingredientes, finalizando com azeite e sal.',
    ),
    Recipe(
      id: 'buddha_bowl_vegano',
      title: 'Buddha Bowl Vegano',
      emoji: '🥙',
      category: 'Almoço',
      kcal: 380,
      protein: 16,
      carbs: 52,
      fat: 12,
      durationMin: 20,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Vegana',
      objetivo: 'Saúde',
      tags: ['Veganas'],
      ingredients: [
        'grão-de-bico cozido',
        'batata-doce assada',
        'couve refogada',
        'homus',
        'sementes de gergelim',
      ],
      steps:
          'Distribua o grão-de-bico, a batata-doce e a couve na tigela, '
          'finalize com o homus e as sementes.',
    ),
    Recipe(
      id: 'salada_low_carb',
      title: 'Salada Low Carb com Frango',
      emoji: '🥑',
      category: 'Jantar',
      kcal: 280,
      protein: 22,
      carbs: 10,
      fat: 17,
      durationMin: 15,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Low Carb',
      objetivo: 'Emagrecimento',
      tags: ['Low Carb', 'Emagrecer'],
      ingredients: [
        'frango desfiado',
        'folhas verdes',
        'abacate',
        'tomate cereja',
        'azeite e limão',
      ],
      steps: 'Misture todos os ingredientes e tempere com azeite e limão.',
    ),
    Recipe(
      id: 'frango_air_fryer',
      title: 'Frango Empanado Fit na Air Fryer',
      emoji: '🍽️',
      category: 'Jantar',
      kcal: 320,
      protein: 35,
      carbs: 18,
      fat: 10,
      durationMin: 30,
      difficulty: 'Médio',
      servings: 2,
      dietType: 'Sem glúten',
      objetivo: 'Hipertrofia',
      tags: ['Air Fryer', 'Hipertrofia'],
      ingredients: [
        'filé de frango',
        'farinha de aveia',
        'ovo',
        'temperos a gosto',
      ],
      steps:
          'Empane o frango na farinha de aveia e ovo, e leve à air fryer a '
          '200°C por 15-18 minutos, virando na metade do tempo.',
    ),
    Recipe(
      id: 'sopa_legumes',
      title: 'Sopa de Legumes',
      emoji: '🍲',
      category: 'Jantar',
      kcal: 260,
      protein: 10,
      carbs: 38,
      fat: 6,
      durationMin: 35,
      difficulty: 'Fácil',
      servings: 2,
      dietType: 'Vegana',
      objetivo: 'Emagrecimento',
      tags: ['Emagrecer', 'Veganas'],
      ingredients: [
        'batata',
        'cenoura',
        'abobrinha',
        'chuchu',
        'caldo de legumes caseiro',
      ],
      steps:
          'Cozinhe todos os legumes picados no caldo até ficarem macios e '
          'bata parte da sopa para engrossar naturalmente.',
    ),
    Recipe(
      id: 'batata_doce_air_fryer',
      title: 'Batata Doce Crocante na Air Fryer',
      emoji: '🍠',
      category: 'Lanche',
      kcal: 180,
      protein: 4,
      carbs: 38,
      fat: 2,
      durationMin: 25,
      difficulty: 'Fácil',
      servings: 2,
      dietType: 'Vegana',
      objetivo: 'Saúde',
      tags: ['Air Fryer', 'Veganas'],
      ingredients: ['batata-doce', 'azeite', 'páprica', 'sal a gosto'],
      steps:
          'Corte a batata-doce em fatias finas, tempere e leve à air fryer '
          'a 200°C por 15 minutos, virando na metade do tempo.',
    ),
    Recipe(
      id: 'muffin_chocolate_fit',
      title: 'Muffin de Chocolate Fit',
      emoji: '🧁',
      category: 'Lanche',
      kcal: 210,
      protein: 8,
      carbs: 26,
      fat: 8,
      durationMin: 25,
      difficulty: 'Médio',
      servings: 6,
      dietType: 'Vegetariana',
      objetivo: 'Saúde',
      tags: ['Sobremesas'],
      ingredients: [
        '1 xícara de farinha de aveia',
        '2 ovos',
        '3 colheres de cacau em pó',
        '1/2 xícara de adoçante culinário',
        '1 colher de fermento',
      ],
      steps:
          'Misture os ingredientes secos e depois os úmidos, despeje em '
          'forminhas e asse a 180°C por 20-25 minutos.',
    ),
    Recipe(
      id: 'smoothie_proteico',
      title: 'Smoothie Proteico',
      emoji: '🥤',
      category: 'Lanche',
      kcal: 220,
      protein: 12,
      carbs: 30,
      fat: 4,
      durationMin: 5,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Vegetariana',
      objetivo: 'Manutenção',
      tags: ['Shakes'],
      ingredients: ['iogurte natural', 'banana', 'whey opcional', 'canela'],
      steps: 'Bata tudo no liquidificador.',
    ),
    Recipe(
      id: 'shake_verde',
      title: 'Shake Verde Detox',
      emoji: '🥬',
      category: 'Lanche',
      kcal: 150,
      protein: 6,
      carbs: 24,
      fat: 3,
      durationMin: 5,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Vegana',
      objetivo: 'Saúde',
      tags: ['Shakes', 'Veganas'],
      ingredients: ['couve', 'maçã verde', 'gengibre', 'água de coco'],
      steps: 'Bata todos os ingredientes no liquidificador e sirva gelado.',
    ),
    Recipe(
      id: 'shake_chocolate',
      title: 'Shake de Chocolate Proteico',
      emoji: '🍫',
      category: 'Lanche',
      kcal: 210,
      protein: 20,
      carbs: 18,
      fat: 5,
      durationMin: 5,
      difficulty: 'Fácil',
      servings: 1,
      dietType: 'Vegetariana',
      objetivo: 'Hipertrofia',
      tags: ['Shakes', 'Hipertrofia'],
      ingredients: ['leite', 'whey sabor chocolate', 'cacau em pó', 'gelo'],
      steps: 'Bata todos os ingredientes no liquidificador até ficar cremoso.',
    ),
  ];

  /// Devolve a receita "oficial" de cada tipo de refeição do plano do dia —
  /// mesmo padrão já usado para o treino de hoje (`workouts` rotacionado por
  /// dia da semana): nada de texto solto dentro do widget, tudo lido daqui.
  static Recipe? recipeForCategory(String category) {
    for (final r in recipes) {
      if (r.category == category) return r;
    }
    return null;
  }

  static List<Habit> defaultHabits() => [
        Habit(id: 'agua', title: 'Beber 2L de água', emoji: '💧'),
        Habit(id: 'treino', title: 'Concluir treino', emoji: '💪'),
        Habit(id: 'alimentacao', title: 'Comer bem', emoji: '🥗'),
        Habit(id: 'sono', title: 'Dormir 7-8h', emoji: '😴'),
        Habit(id: 'cardio', title: 'Fez cardio/corrida', emoji: '🏃'),
      ];

  static const List<Challenge> challenges = [
    Challenge(
      id: 'desafio_7',
      title: 'Desafio 7 dias',
      description: 'Concluir 1 hábito saudável por dia',
      goal: 7,
      progress: 3,
      rewardXp: 200,
    ),
    Challenge(
      id: 'desafio_21',
      title: 'Desafio 21 dias',
      description: 'Rotina com treino, água e alimentação',
      goal: 21,
      progress: 8,
      rewardXp: 800,
    ),
    Challenge(
      id: 'primeiros_5k',
      title: 'Primeiros 5 km',
      description: 'Completar o plano de corrida até 5 km',
      goal: 5,
      progress: 2,
      rewardXp: 1000,
    ),
  ];

  static const List<Achievement> achievements = [
    Achievement(
        id: 'primeiro_treino',
        title: 'Primeiro treino',
        emoji: '🏅',
        unlocked: true),
    Achievement(
        id: 'sete_dias', title: '7 dias seguidos', emoji: '🔥', unlocked: true),
    Achievement(
        id: 'primeira_corrida',
        title: 'Primeira corrida',
        emoji: '🏃',
        unlocked: true),
    Achievement(
        id: 'dez_treinos', title: '10 treinos', emoji: '💪', unlocked: false),
    Achievement(
        id: 'meta_peso', title: 'Meta de peso', emoji: '🎯', unlocked: false),
    Achievement(
        id: 'cinco_km', title: '5 km corridos', emoji: '🏆', unlocked: false),
  ];

  /// Frases motivacionais da Amanda (mensagens_motivacionais.json).
  static const List<String> amandaPhrases = [
    'Um dia de cada vez. Você está evoluindo.',
    'Hoje não precisa ser perfeito, só precisa começar.',
    'Seu corpo sente quando você se escolhe.',
    'Pequenas escolhas repetidas mudam tudo.',
    'Vamos cuidar de você hoje?',
  ];
}

/// Modelo de receita (mantido aqui por proximidade com os seeds).
class Recipe {
  final String id;
  final String title;
  final String emoji;

  /// Categoria de REFEIÇÃO (café da manhã / almoço / lanche / jantar) —
  /// usada pelo plano do dia (`PlannedMealX`) pra escolher a receita de
  /// cada horário. Não confundir com [tags], que é a categoria/objetivo
  /// usada na tela Receitas (Emagrecer, Hipertrofia, Low Carb, etc.).
  final String category;

  final int kcal;
  final int protein;
  final List<String> ingredients;
  final String steps;

  // ---- Campos usados pela tela Receitas (todos com default seguro pra não
  // quebrar nenhum literal `Recipe(...)` já existente no projeto) ----

  /// Tempo de preparo, em minutos.
  final int durationMin;

  /// 'Fácil' · 'Médio' · 'Avançada'.
  final String difficulty;

  /// Quantas porções a receita rende.
  final int servings;

  /// Tipo de dieta: Tradicional, Low Carb, Vegana, Vegetariana, Carnívora,
  /// Sem lactose, Sem glúten.
  final String dietType;

  /// Objetivo: Emagrecimento, Hipertrofia, Manutenção, Saúde.
  final String objetivo;

  /// Carboidratos e gorduras em gramas (junto com [protein] e [kcal],
  /// compõem as informações nutricionais mostradas no detalhe).
  final int carbs;
  final int fat;

  /// Categorias livres da tela Receitas (Emagrecer, Hipertrofia, Low Carb,
  /// Veganas, Air Fryer, Sobremesas, Shakes) — uma receita pode pertencer a
  /// mais de uma.
  final List<String> tags;

  /// Foto real do prato, quando cadastrada. `null`/vazio → a UI usa o
  /// [emoji] como placeholder (mesmo padrão do `Workout.photoUrl`).
  final String? photoUrl;

  const Recipe({
    required this.id,
    required this.title,
    required this.emoji,
    required this.category,
    required this.kcal,
    required this.protein,
    required this.ingredients,
    required this.steps,
    this.durationMin = 15,
    this.difficulty = 'Fácil',
    this.servings = 1,
    this.dietType = 'Tradicional',
    this.objetivo = 'Saúde',
    this.carbs = 0,
    this.fat = 0,
    this.tags = const [],
    this.photoUrl,
  });
}
