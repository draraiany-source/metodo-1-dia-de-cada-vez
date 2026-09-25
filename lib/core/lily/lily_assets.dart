/// Catálogo oficial do pacote Lily Fit (alta resolução) em `assets/lily/`.
/// Use sempre [LilyAssets] + [LilyImage] — nunca caminhos soltos.
class LilyAssets {
  LilyAssets._();

  static const String base = 'assets/lily/';

  static const boasVindas = '${base}lily_boas_vindas_acenando.jpg';
  static const joinha = '${base}lily_joinha.jpg';
  static const tomandoAgua = '${base}lily_tomando_agua.jpg';
  static const lembreteHidratacao = '${base}lily_lembrete_hidratacao.jpg';
  static const treinoHalteres = '${base}lily_treino_halteres.jpg';
  static const corrida = '${base}lily_corrida.jpg';
  static const alongamento = '${base}lily_alongamento.jpg';
  static const vitoria = '${base}lily_vitoria.jpg';
  static const trofeu = '${base}lily_comemorando_trofeu.jpg';
  static const metaConcluida = '${base}lily_meta_concluida.jpg';
  static const calendarioCheck = '${base}lily_calendario_check.jpg';
  static const meditacao = '${base}lily_meditacao.jpg';
  static const mostrandoApp = '${base}lily_mostrando_app.jpg';
  static const pratoSaudavel = '${base}lily_prato_saudavel.jpg';
  static const apontandoCima = '${base}lily_apontando_cima.jpg';
  static const apontandoBaixo = '${base}lily_apontando_baixo.jpg';
  static const apontandoEsquerda = '${base}lily_apontando_esquerda.jpg';
  static const apontandoDireita = '${base}lily_apontando_direita.jpg';
  static const apresentandoEsquerda = '${base}lily_apresentando_esquerda.jpg';
  static const apresentandoAberta = '${base}lily_apresentando_aberta.jpg';
  static const tentarNovamente = '${base}lily_tentar_novamente.jpg';
  static const forca = '${base}lily_forca.jpg';
  static const posTreino = '${base}lily_pos_treino.jpg';

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
