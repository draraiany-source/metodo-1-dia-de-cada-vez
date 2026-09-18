// Mapa `byId` é GERADO — não editar à mão.
// Fonte: tools/_map_117_lily_fit.csv + assets/lily/treinos lily fit/
// Thumbnails por id do catálogo oficial (treino_001..treino_117).
//
// ATENÇÃO: o mapa `reatribuicoesAuditoria` abaixo é MANUAL (auditoria de
// imagens de 2026-09-17, ver AUDITORIA_IMAGENS_LILI_FIT.md na raiz).
// Ao regerar `byId`, preserve `reatribuicoesAuditoria`.

/// Assets Lily Fit por exercício do catálogo (117).
class LilyExercicioAssets {
  LilyExercicioAssets._();

  static const String base = 'assets/lily_exercicios/';

  /// Path do asset JPG para o [id] do catálogo, ou null se ausente.
  ///
  /// Consulta primeiro [reatribuicoesAuditoria] (correções manuais da auditoria
  /// de imagens) e só depois o mapa gerado [byId].
  static String? pathForId(String? id) {
    if (id == null || id.isEmpty) return null;
    return reatribuicoesAuditoria[id] ?? byId[id];
  }

  /// Reatribuições aprovadas na auditoria de imagens (AUDITORIA_IMAGENS_LILI_FIT.md).
  ///
  /// Cada entrada aponta um exercício para o arquivo que REALMENTE mostra a
  /// execução correta daquele exercício. Nenhum arquivo foi renomeado ou
  /// apagado: apenas o vínculo id → asset muda, de forma reversível.
  static const Map<String, String> reatribuicoesAuditoria = {
    // ---- Core / mobilidade ----
    // 013 recebe um abdominal (a máquina de abdominal ainda precisa ser gerada);
    // o arquivo 013 mostrava uma cadeira abdutora e foi para o treino_046.
    'treino_013': 'assets/lily_exercicios/treino_014.jpg',
    // 014 (abdominal infra na paralela): 101 mostra elevação de pernas na paralela.
    'treino_014': 'assets/lily_exercicios/treino_101.jpg',
    // 016 x 018 estavam invertidos (superiores x inferiores no espaldar).
    'treino_016': 'assets/lily_exercicios/treino_018.jpg',
    'treino_018': 'assets/lily_exercicios/treino_016.jpg',
    // ---- Aquecimento / inferiores / glúteos ----
    'treino_017': 'assets/lily_exercicios/treino_060.jpg',
    'treino_026': 'assets/lily_exercicios/treino_044.jpg',
    // 029: o step sem peso está no arquivo 031.
    'treino_029': 'assets/lily_exercicios/treino_031.jpg',
    // 031 (afundo com halteres): 040 é a execução mais limpa (a 029 tem a
    // perna de trás deformada). Compartilha com 054 até 054 ter arte de recuo.
    'treino_031': 'assets/lily_exercicios/treino_040.jpg',
    // 030 (agachamento no banco): 033.jpg é o box squat (toque no banco).
    'treino_030': 'assets/lily_exercicios/treino_033.jpg',
    // 033 (agachamento taça / goblet): 027.jpg é goblet com um halter no peito
    // (não é TRX). 027 (agachamento no TRX) espera arte própria.
    'treino_033': 'assets/lily_exercicios/treino_027.jpg',
    // 038 x 039: a profundidade do agachamento no Smith estava invertida.
    'treino_038': 'assets/lily_exercicios/treino_039.jpg',
    'treino_039': 'assets/lily_exercicios/treino_038.jpg',
    // 040 (afundo no Smith): 032.jpg é o afundo nos trilhos do Smith
    // (não é step). 032 (afundo com halteres no step) espera arte própria.
    'treino_040': 'assets/lily_exercicios/treino_032.jpg',
    // 042 (agachamento livre com halteres): 030.jpg é o agachamento com dois
    // halteres nas mãos, sem banco.
    'treino_042': 'assets/lily_exercicios/treino_030.jpg',
    // 044 (agachamento pêndulo): a máquina pêndulo estava no arquivo 069.
    'treino_044': 'assets/lily_exercicios/treino_069.jpg',
    // 046 (cadeira abdutora): a máquina abdutora estava no arquivo 013.
    'treino_046': 'assets/lily_exercicios/treino_013.jpg',
    // 047 (stiff unilateral): o stiff unilateral com halteres estava no 088.
    'treino_047': 'assets/lily_exercicios/treino_088.jpg',
    // 048 e 049 usam a arte de 4 apoios com caneleira (055); a variação com a
    // perna estendida (048) continua pendente de arte própria.
    'treino_048': 'assets/lily_exercicios/treino_055.jpg',
    'treino_049': 'assets/lily_exercicios/treino_055.jpg',
    // 052 (búlgaro com halteres): o arquivo 022 é o búlgaro com dois halteres
    // (não é salto no step). 022 (salto lateral) fica pendente de arte própria.
    'treino_052': 'assets/lily_exercicios/treino_022.jpg',
    // 053 é duplicata de 113 (mesmo vídeo); passa a usar a arte correta do combinado.
    'treino_053': 'assets/lily_exercicios/treino_113.jpg',
    'treino_054': 'assets/lily_exercicios/treino_040.jpg',
    // 055 (coice no cabo, polia baixa): o cabo aparece no arquivo 049.
    'treino_055': 'assets/lily_exercicios/treino_049.jpg',
    'treino_060': 'assets/lily_exercicios/treino_026.jpg',
    // 069 compartilha temporariamente o agachamento livre de 037 até ter arte
    // com a fase de desenvolvimento.
    'treino_069': 'assets/lily_exercicios/treino_037.jpg',
    // ---- Peitoral ----
    // 072 x 075 estavam invertidos (máquina x halteres no banco inclinado).
    'treino_072': 'assets/lily_exercicios/treino_075.jpg',
    'treino_075': 'assets/lily_exercicios/treino_072.jpg',
    // 073 x 074: a pegada neutra no inclinado está no arquivo 074.
    'treino_073': 'assets/lily_exercicios/treino_074.jpg',
    'treino_074': 'assets/lily_exercicios/treino_073.jpg',
    // ---- Costas ----
    // 077 x 080: barra longa reta x barra W estavam trocadas.
    'treino_077': 'assets/lily_exercicios/treino_080.jpg',
    'treino_080': 'assets/lily_exercicios/treino_077.jpg',
    // 084 x 094: remada sentada com triângulo x remada alta com barra.
    'treino_084': 'assets/lily_exercicios/treino_094.jpg',
    'treino_094': 'assets/lily_exercicios/treino_084.jpg',
    // ---- Bíceps ----
    // 086 x 089: polia baixa com barra reta x máquina de rosca.
    'treino_086': 'assets/lily_exercicios/treino_089.jpg',
    'treino_089': 'assets/lily_exercicios/treino_086.jpg',
    // 087, 088 e 090 usam a rosca alternada com halteres (106) até terem arte
    // própria; antes apontavam para polia/execuções erradas.
    'treino_087': 'assets/lily_exercicios/treino_106.jpg',
    'treino_088': 'assets/lily_exercicios/treino_106.jpg',
    'treino_090': 'assets/lily_exercicios/treino_106.jpg',
    // 092 (rosca unilateral na polia baixa): execução unilateral está no 087.
    'treino_092': 'assets/lily_exercicios/treino_087.jpg',
    // ---- Ombros ----
    // 096 (desenvolvimento com halteres): halteres acima da cabeça no 095.
    'treino_096': 'assets/lily_exercicios/treino_095.jpg',
    // 099 (elevação frontal na polia com barra reta): polia + barra no 100.
    'treino_099': 'assets/lily_exercicios/treino_100.jpg',
    // 101 (elevação lateral + desenvolvimento) NÃO usa mais o arquivo 052:
    // 052.jpg é agachamento sumô com braços abertos, não o combinado. O
    // arquivo 101.jpg (elevação de pernas na paralela) ficou com o 014, que
    // é o dono correto. 101 espera arte nova.
    // 106 (elevação lateral com halteres): a elevação lateral real está no 102.
    'treino_106': 'assets/lily_exercicios/treino_102.jpg',
    // ---- Full Body ----
    // 114 é Sumô + Elevação Lateral: 042.jpg (e 052.jpg) mostram exatamente isso.
    'treino_114': 'assets/lily_exercicios/treino_042.jpg',
    // 116 (búlgaro sem peso): 020.jpg é búlgaro no banco, sem halteres.
    'treino_116': 'assets/lily_exercicios/treino_020.jpg',
  };

  /// Mapa id → asset. Sempre JPG em lily_exercicios/.
  static const Map<String, String> byId = {
    'treino_001': 'assets/lily_exercicios/treino_001.jpg',
    'treino_002': 'assets/lily_exercicios/treino_002.jpg',
    'treino_003': 'assets/lily_exercicios/treino_003.jpg',
    'treino_004': 'assets/lily_exercicios/treino_004.jpg',
    'treino_005': 'assets/lily_exercicios/treino_005.jpg',
    'treino_006': 'assets/lily_exercicios/treino_006.jpg',
    'treino_007': 'assets/lily_exercicios/treino_007.jpg',
    'treino_008': 'assets/lily_exercicios/treino_008.jpg',
    'treino_009': 'assets/lily_exercicios/treino_009.jpg',
    'treino_010': 'assets/lily_exercicios/treino_010.jpg',
    'treino_011': 'assets/lily_exercicios/treino_011.jpg',
    'treino_012': 'assets/lily_exercicios/treino_012.jpg',
    'treino_013': 'assets/lily_exercicios/treino_013.jpg',
    'treino_014': 'assets/lily_exercicios/treino_014.jpg',
    'treino_015': 'assets/lily_exercicios/treino_015.jpg',
    'treino_016': 'assets/lily_exercicios/treino_016.jpg',
    'treino_017': 'assets/lily_exercicios/treino_017.jpg',
    'treino_018': 'assets/lily_exercicios/treino_018.jpg',
    'treino_019': 'assets/lily_exercicios/treino_019.jpg',
    'treino_020': 'assets/lily_exercicios/treino_020.jpg',
    'treino_021': 'assets/lily_exercicios/treino_021.jpg',
    'treino_022': 'assets/lily_exercicios/treino_022.jpg',
    'treino_023': 'assets/lily_exercicios/treino_023.jpg',
    'treino_024': 'assets/lily_exercicios/treino_024.jpg',
    'treino_025': 'assets/lily_exercicios/treino_025.jpg',
    'treino_026': 'assets/lily_exercicios/treino_026.jpg',
    'treino_027': 'assets/lily_exercicios/treino_027.jpg',
    'treino_028': 'assets/lily_exercicios/treino_028.jpg',
    'treino_029': 'assets/lily_exercicios/treino_029.jpg',
    'treino_030': 'assets/lily_exercicios/treino_030.jpg',
    'treino_031': 'assets/lily_exercicios/treino_031.jpg',
    'treino_032': 'assets/lily_exercicios/treino_032.jpg',
    'treino_033': 'assets/lily_exercicios/treino_033.jpg',
    'treino_034': 'assets/lily_exercicios/treino_034.jpg',
    'treino_035': 'assets/lily_exercicios/treino_035.jpg',
    'treino_036': 'assets/lily_exercicios/treino_036.jpg',
    'treino_037': 'assets/lily_exercicios/treino_037.jpg',
    'treino_038': 'assets/lily_exercicios/treino_038.jpg',
    'treino_039': 'assets/lily_exercicios/treino_039.jpg',
    'treino_040': 'assets/lily_exercicios/treino_040.jpg',
    'treino_041': 'assets/lily_exercicios/treino_041.jpg',
    'treino_042': 'assets/lily_exercicios/treino_042.jpg',
    'treino_043': 'assets/lily_exercicios/treino_043.jpg',
    'treino_044': 'assets/lily_exercicios/treino_044.jpg',
    'treino_045': 'assets/lily_exercicios/treino_045.jpg',
    'treino_046': 'assets/lily_exercicios/treino_046.jpg',
    'treino_047': 'assets/lily_exercicios/treino_047.jpg',
    'treino_048': 'assets/lily_exercicios/treino_048.jpg',
    'treino_049': 'assets/lily_exercicios/treino_049.jpg',
    'treino_050': 'assets/lily_exercicios/treino_050.jpg',
    'treino_051': 'assets/lily_exercicios/treino_051.jpg',
    'treino_052': 'assets/lily_exercicios/treino_052.jpg',
    'treino_053': 'assets/lily_exercicios/treino_053.jpg',
    'treino_054': 'assets/lily_exercicios/treino_054.jpg',
    'treino_055': 'assets/lily_exercicios/treino_055.jpg',
    'treino_056': 'assets/lily_exercicios/treino_056.jpg',
    'treino_057': 'assets/lily_exercicios/treino_057.jpg',
    'treino_058': 'assets/lily_exercicios/treino_058.jpg',
    'treino_059': 'assets/lily_exercicios/treino_059.jpg',
    'treino_060': 'assets/lily_exercicios/treino_060.jpg',
    'treino_061': 'assets/lily_exercicios/treino_061.jpg',
    'treino_062': 'assets/lily_exercicios/treino_062.jpg',
    'treino_063': 'assets/lily_exercicios/treino_063.jpg',
    'treino_064': 'assets/lily_exercicios/treino_064.jpg',
    'treino_065': 'assets/lily_exercicios/treino_065.jpg',
    'treino_066': 'assets/lily_exercicios/treino_066.jpg',
    'treino_067': 'assets/lily_exercicios/treino_067.jpg',
    'treino_068': 'assets/lily_exercicios/treino_068.jpg',
    'treino_069': 'assets/lily_exercicios/treino_069.jpg',
    'treino_070': 'assets/lily_exercicios/treino_070.jpg',
    'treino_071': 'assets/lily_exercicios/treino_071.jpg',
    'treino_072': 'assets/lily_exercicios/treino_072.jpg',
    'treino_073': 'assets/lily_exercicios/treino_073.jpg',
    'treino_074': 'assets/lily_exercicios/treino_074.jpg',
    'treino_075': 'assets/lily_exercicios/treino_075.jpg',
    'treino_076': 'assets/lily_exercicios/treino_076.jpg',
    'treino_077': 'assets/lily_exercicios/treino_077.jpg',
    'treino_078': 'assets/lily_exercicios/treino_078.jpg',
    'treino_079': 'assets/lily_exercicios/treino_079.jpg',
    'treino_080': 'assets/lily_exercicios/treino_080.jpg',
    'treino_081': 'assets/lily_exercicios/treino_081.jpg',
    'treino_082': 'assets/lily_exercicios/treino_082.jpg',
    'treino_083': 'assets/lily_exercicios/treino_083.jpg',
    'treino_084': 'assets/lily_exercicios/treino_084.jpg',
    'treino_085': 'assets/lily_exercicios/treino_085.jpg',
    'treino_086': 'assets/lily_exercicios/treino_086.jpg',
    'treino_087': 'assets/lily_exercicios/treino_087.jpg',
    'treino_088': 'assets/lily_exercicios/treino_088.jpg',
    'treino_089': 'assets/lily_exercicios/treino_089.jpg',
    'treino_090': 'assets/lily_exercicios/treino_090.jpg',
    'treino_091': 'assets/lily_exercicios/treino_091.jpg',
    'treino_092': 'assets/lily_exercicios/treino_092.jpg',
    'treino_093': 'assets/lily_exercicios/treino_093.jpg',
    'treino_094': 'assets/lily_exercicios/treino_094.jpg',
    'treino_095': 'assets/lily_exercicios/treino_095.jpg',
    'treino_096': 'assets/lily_exercicios/treino_096.jpg',
    'treino_097': 'assets/lily_exercicios/treino_097.jpg',
    'treino_098': 'assets/lily_exercicios/treino_098.jpg',
    'treino_099': 'assets/lily_exercicios/treino_099.jpg',
    'treino_100': 'assets/lily_exercicios/treino_100.jpg',
    'treino_101': 'assets/lily_exercicios/treino_101.jpg',
    'treino_102': 'assets/lily_exercicios/treino_102.jpg',
    'treino_103': 'assets/lily_exercicios/treino_103.jpg',
    'treino_104': 'assets/lily_exercicios/treino_104.jpg',
    'treino_105': 'assets/lily_exercicios/treino_105.jpg',
    'treino_106': 'assets/lily_exercicios/treino_106.jpg',
    'treino_107': 'assets/lily_exercicios/treino_107.jpg',
    'treino_108': 'assets/lily_exercicios/treino_108.jpg',
    'treino_109': 'assets/lily_exercicios/treino_109.jpg',
    'treino_110': 'assets/lily_exercicios/treino_110.jpg',
    'treino_111': 'assets/lily_exercicios/treino_111.jpg',
    'treino_112': 'assets/lily_exercicios/treino_112.jpg',
    'treino_113': 'assets/lily_exercicios/treino_113.jpg',
    'treino_114': 'assets/lily_exercicios/treino_114.jpg',
    'treino_115': 'assets/lily_exercicios/treino_115.jpg',
    'treino_116': 'assets/lily_exercicios/treino_116.jpg',
    'treino_117': 'assets/lily_exercicios/treino_117.jpg',
  };
}
