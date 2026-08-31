/// ============================================================================
/// CONFIGURAÇÃO CENTRAL DA MASCOTE — ponto ÚNICO de troca.
///
/// Para substituir a mascote no futuro, altere APENAS este arquivo:
///   1. Coloque as novas artes em `assets/mascot/png/` (nomes em
///      [MascotAssets.newPoseFile]).
///   2. Defina [useNewMascot] = true.
///   3. Defina [_newName] com o nome definitivo.
/// Nenhuma tela referencia nome ou caminho diretamente.
/// ============================================================================
class MascotConfig {
  MascotConfig._();

  /// FLAG DE TRANSIÇÃO (§14 do plano de substituição).
  /// `true` = arte oficial nova em `assets/mascot/png/` (entregue pelo dono do
  ///          projeto, 1024² RGBA), com fallback automático para a arte em
  ///          `assets/images/mascote/` — que também já contém a arte nova.
  static const bool useNewMascot = true;

  /// Nome atual (legado), exibido enquanto [useNewMascot] == false.
  static const String _legacyName = 'Lili Fit';
  static const String _legacyShortName = 'Lili';

  /// A arte nova É a Lili Fit oficial — a personagem não mudou de nome.
  /// Por isso o nome permanece "Lili Fit" mesmo com [useNewMascot] = true.
  static const String _newName = 'Lili Fit';
  static const String _newShortName = 'Lili';

  /// Nome completo exibido nas telas (ex.: "Biblioteca Lili Fit").
  static String get name => useNewMascot ? _newName : _legacyName;

  /// Nome curto para frases (ex.: "a Lili te acompanha").
  static String get shortName => useNewMascot ? _newShortName : _legacyShortName;
}
