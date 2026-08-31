/// Formatação de datas em pt-BR.
///
/// Extraído das telas de Histórico (Loja, Missões) e do Diário, onde a mesma
/// função `_formatDate` estava duplicada três vezes.
class DateFormatBr {
  DateFormatBr._();

  static const List<String> _meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];

  static const List<String> _mesesCompletos = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  static String _pad2(int n) => n.toString().padLeft(2, '0');

  /// Ex.: "15 jan 2026 · 14:30"
  static String dataHora(DateTime d) =>
      '${d.day} ${_meses[d.month - 1]} ${d.year} · ${_pad2(d.hour)}:${_pad2(d.minute)}';

  /// Ex.: "15 jan 2026"
  static String data(DateTime d) => '${d.day} ${_meses[d.month - 1]} ${d.year}';

  /// Ex.: "22 de maio" — usado em cabeçalhos (ex.: tela de Acompanhamento).
  static String diaMesCompleto(DateTime d) =>
      '${d.day} de ${_mesesCompletos[d.month - 1]}';

  /// Ex.: "há 5 min", "agora mesmo"
  static String tempoRelativo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    return 'há ${diff.inDays} dia(s)';
  }
}
