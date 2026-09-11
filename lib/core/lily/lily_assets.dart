/// Catálogo oficial do pacote Lily Fit (alta resolução) em `assets/lily/`.
/// Use sempre [LilyAssets] + [LilyImage] — nunca caminhos soltos.
class LilyAssets {
  LilyAssets._();

  static const String base = 'assets/lily/';

  static const boasVindas = '${base}lily_boas_vindas_acenando.png';
  static const joinha = '${base}lily_joinha.png';
  static const tomandoAgua = '${base}lily_tomando_agua.png';
  static const lembreteHidratacao = '${base}lily_lembrete_hidratacao.png';
  static const treinoHalteres = '${base}lily_treino_halteres.png';
  static const corrida = '${base}lily_corrida.png';
  static const alongamento = '${base}lily_alongamento.png';
  static const vitoria = '${base}lily_vitoria.png';
  static const trofeu = '${base}lily_comemorando_trofeu.png';
  static const metaConcluida = '${base}lily_meta_concluida.png';
  static const calendarioCheck = '${base}lily_calendario_check.png';
  static const meditacao = '${base}lily_meditacao.png';
  static const mostrandoApp = '${base}lily_mostrando_app.png';
  static const pratoSaudavel = '${base}lily_prato_saudavel.png';
  static const apontandoCima = '${base}lily_apontando_cima.png';
  static const apontandoBaixo = '${base}lily_apontando_baixo.png';
  static const apontandoEsquerda = '${base}lily_apontando_esquerda.png';
  static const apontandoDireita = '${base}lily_apontando_direita.png';
  static const apresentandoEsquerda = '${base}lily_apresentando_esquerda.png';
  static const apresentandoAberta = '${base}lily_apresentando_aberta.png';
  static const tentarNovamente = '${base}lily_tentar_novamente.png';
  static const forca = '${base}lily_forca.png';
  static const posTreino = '${base}lily_pos_treino.png';

  /// Lista completa do pacote (23).
  static const List<String> all = [
    boasVindas,
    joinha,
    tomandoAgua,
    lembreteHidratacao,
    treinoHalteres,
    corrida,
    alongamento,
    vitoria,
    trofeu,
    metaConcluida,
    calendarioCheck,
    meditacao,
    mostrandoApp,
    pratoSaudavel,
    apontandoCima,
    apontandoBaixo,
    apontandoEsquerda,
    apontandoDireita,
    apresentandoEsquerda,
    apresentandoAberta,
    tentarNovamente,
    forca,
    posTreino,
  ];
}

/// Escala padronizada da Lily (px de altura).
class LilySizes {
  LilySizes._();
  static const double small = 140;
  static const double medium = 220;
  static const double highlight = 320;
  static const double heroMax = 420;
}
