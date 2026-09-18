/// Pacote visual Personal / Consultoria / IA.
///
/// PNGs locais em `assets/icons/personal-ai/`. Use sempre estas constantes
/// (ou [AppIcons] aliases) + [AppIconImage] / [FeatureIconCard].
library;

class PersonalAiIcons {
  PersonalAiIcons._();

  static const String _base = 'assets/icons/personal-ai/';

  static const String chatAmanda = '${_base}01_chat_com_amanda.png';
  static const String agendaConsultoria = '${_base}02_agenda_consultoria.png';
  static const String areaPersonal = '${_base}03_area_da_personal.png';
  static const String anamnese = '${_base}04_anamnese.png';
  static const String analisarIA = '${_base}05_analisar_com_ia.png';
  static const String assistenteIA = '${_base}06_assistente_ia.png';
  static const String insightsIA = '${_base}07_insights_ia.png';
  static const String sugestaoResposta = '${_base}08_sugestao_de_resposta.png';
  static const String resumoConversa = '${_base}09_resumo_da_conversa.png';
  static const String pontosAtencao = '${_base}10_pontos_de_atencao.png';

  static const Map<String, String> personalAiIcons = {
    'chatAmanda': chatAmanda,
    'agendaConsultoria': agendaConsultoria,
    'areaPersonal': areaPersonal,
    'anamnese': anamnese,
    'analisarIA': analisarIA,
    'assistenteIA': assistenteIA,
    'insightsIA': insightsIA,
    'sugestaoResposta': sugestaoResposta,
    'resumoConversa': resumoConversa,
    'pontosAtencao': pontosAtencao,
  };

  static const List<String> assets = [
    chatAmanda,
    agendaConsultoria,
    areaPersonal,
    anamnese,
    analisarIA,
    assistenteIA,
    insightsIA,
    sugestaoResposta,
    resumoConversa,
    pontosAtencao,
  ];
}
