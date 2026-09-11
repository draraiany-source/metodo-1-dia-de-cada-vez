/// CatÃ¡logo oficial das imagens de treino Lily Fit em `assets/lily_treinos/`.
/// Use sempre [LilyTreinoAssets] + [LilyTreinoImage] â€” nunca caminhos soltos.
class LilyTreinoAssets {
  LilyTreinoAssets._();

  static const String base = 'assets/lily_treinos/';

  static const halteres = '${base}lily_treino_halteres.png';
  static const agachamento = '${base}lily_agachamento.png';
  static const prancha = '${base}lily_prancha.png';
  static const cordaNaval = '${base}lily_corda_naval.png';
  static const kettlebell = '${base}lily_kettlebell.png';
  static const hipThrust = '${base}lily_hip_thrust.png';
  static const coiceGluteo = '${base}lily_coice_gluteo.png';
  static const abducaoFaixa = '${base}lily_abducao_com_faixa.png';
  static const elevacaoLateral = '${base}lily_elevacao_lateral.png';
  static const biceps = '${base}lily_rosca_biceps.png';
  static const triceps = '${base}lily_triceps.png';
  static const remada = '${base}lily_remada.png';
  static const supino = '${base}lily_supino.png';
  static const desenvolvimentoOmbros = '${base}lily_desenvolvimento_ombros.png';
  static const panturrilha = '${base}lily_panturrilha.png';
  static const bicicleta = '${base}lily_bicicleta.png';
  static const esteira = '${base}lily_esteira.png';
  static const caminhada = '${base}lily_caminhada.png';
  static const corrida = '${base}lily_corrida.png';
  static const alongamento = '${base}lily_alongamento.png';

  static const generico1 = '${base}lily_treino_generico_1.png';
  static const generico2 = '${base}lily_treino_generico_2.png';
  static const generico3 = '${base}lily_treino_generico_3.png';
  static const generico4 = '${base}lily_treino_generico_4.png';

  /// Pacote completo (24).
  static const List<String> all = [
    halteres,
    agachamento,
    prancha,
    cordaNaval,
    kettlebell,
    hipThrust,
    coiceGluteo,
    abducaoFaixa,
    elevacaoLateral,
    biceps,
    triceps,
    remada,
    supino,
    desenvolvimentoOmbros,
    panturrilha,
    bicicleta,
    esteira,
    caminhada,
    corrida,
    alongamento,
    generico1,
    generico2,
    generico3,
    generico4,
  ];

  static const List<String> genericos = [
    generico1,
    generico2,
    generico3,
    generico4,
  ];

  /// Resolve imagem pelo nome/slug do exercÃ­cio (PT/EN, acentos opcionais).
  static String resolve(String? nameOrSlug, {int genericSeed = 0}) {
    final key = _normalize(nameOrSlug ?? '');
    if (key.isEmpty) return genericos[genericSeed.abs() % genericos.length];

    for (final entry in _exact.entries) {
      if (key == entry.key || key.contains(entry.key)) {
        return entry.value;
      }
    }
    return genericos[genericSeed.abs() % genericos.length];
  }

  static String _normalize(String raw) {
    var s = raw.toLowerCase().trim();
    const from = 'Ã¡Ã Ã¢Ã£Ã¤Ã©Ã¨ÃªÃ«Ã­Ã¬Ã®Ã¯Ã³Ã²Ã´ÃµÃ¶ÃºÃ¹Ã»Ã¼Ã§Ã±';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }
    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    while (s.contains('__')) {
      s = s.replaceAll('__', '_');
    }
    return s.replaceAll(RegExp(r'^_|_$'), '');
  }

  static const Map<String, String> _exact = {
    'halteres': halteres,
    'halter': halteres,
    'dumbbell': halteres,
    'treino_halteres': halteres,
    'agachamento': agachamento,
    'squat': agachamento,
    'prancha': prancha,
    'plank': prancha,
    'corda_naval': cordaNaval,
    'battle_rope': cordaNaval,
    'battle_ropes': cordaNaval,
    'corda': cordaNaval,
    'kettlebell': kettlebell,
    'kettle': kettlebell,
    'hip_thrust': hipThrust,
    'hipthrust': hipThrust,
    'elevacao_de_quadril': hipThrust,
    'coice': coiceGluteo,
    'coice_gluteo': coiceGluteo,
    'glute_kickback': coiceGluteo,
    'abducao': abducaoFaixa,
    'abducao_com_faixa': abducaoFaixa,
    'abducao_faixa': abducaoFaixa,
    'lateral_leg': abducaoFaixa,
    'elevacao_lateral': elevacaoLateral,
    'lateral_raise': elevacaoLateral,
    'rosca': biceps,
    'biceps': biceps,
    'rosca_biceps': biceps,
    'curl': biceps,
    'triceps': triceps,
    'trÃ­ceps': triceps,
    'remada': remada,
    'row': remada,
    'supino': supino,
    'bench_press': supino,
    'desenvolvimento': desenvolvimentoOmbros,
    'desenvolvimento_ombros': desenvolvimentoOmbros,
    'shoulder_press': desenvolvimentoOmbros,
    'ombros': desenvolvimentoOmbros,
    'panturrilha': panturrilha,
    'calf': panturrilha,
    'bicicleta': bicicleta,
    'bike': bicicleta,
    'spinning': bicicleta,
    'ciclismo': bicicleta,
    'esteira': esteira,
    'treadmill': esteira,
    'caminhada': caminhada,
    'walk': caminhada,
    'walking': caminhada,
    'corrida': corrida,
    'run': corrida,
    'running': corrida,
    'alongamento': alongamento,
    'stretch': alongamento,
    'mobilidade': alongamento,
  };
}