import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/seed_data.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/firebase_service.dart';

/// Repositório da Amanda IA.
///
/// A arquitetura correta (e segura) é: o app chama uma **Cloud Function**
/// (`amandaChat`), que guarda a chave da OpenAI no servidor e faz o proxy.
/// A chave NUNCA fica no app cliente.
///
/// Enquanto a function não estiver publicada, a Amanda responde localmente
/// com mensagens motivacionais + regras simples, mantendo o app funcional.
class AmandaRepository {
  final _rnd = Random();

  String get _functionUrl => AppConfig.amandaFunctionUrl.isNotEmpty
      ? AppConfig.amandaFunctionUrl
      : AppConstants.amandaFunctionUrl;

  Future<String> send(String userMessage, {String userName = 'você'}) async {
    // Se a Cloud Function estiver configurada e o Firebase pronto, usa a IA real.
    if (FirebaseService.isReady && !_functionUrl.contains('SEU-PROJETO')) {
      try {
        return await _callFunction(userMessage, userName);
      } catch (_) {
        // fallback local em caso de erro de rede
      }
    }
    return _localReply(userMessage, userName);
  }

  Future<String> _callFunction(String message, String userName) async {
    final headers = await AuthHttpHeaders.forCloudFunction();
    final res = await http
        .post(
          Uri.parse(_functionUrl),
          headers: headers,
          body: jsonEncode({
            'message': message,
            'userName': userName,
            // O system prompt real fica na Cloud Function (personalidade da Amanda).
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['reply'] ?? _localReply(message, userName)) as String;
    }
    throw Exception('Amanda function error: ${res.statusCode}');
  }

  /// Respostas locais baseadas em palavras-chave + frases motivacionais.
  String _localReply(String message, String userName) {
    final m = message.toLowerCase();

    if (_matches(m, ['água', 'agua', 'beber'])) {
      return 'Bora se hidratar? 💧 Tenta um copo agora. Seu corpo agradece, $userName!';
    }
    if (_matches(m, ['treino', 'treinar', 'exercício', 'exercicio'])) {
      return 'Que orgulho! 💪 Escolhe um treino curtinho hoje — 20 minutos já contam muito. Um dia de cada vez.';
    }
    if (_matches(m, ['corrida', 'correr', 'corri'])) {
      return 'Corrida é liberdade! 🏃 Começa devagar, alterna caminhada e corrida. Você está evoluindo.';
    }
    if (_matches(m, ['triste', 'desanimada', 'cansada', 'desisti'])) {
      return 'Ei, tudo bem não estar 100% hoje. 💜 Você não precisa ser perfeita, só precisa continuar. Estou aqui com você.\n\n${AppConstants.amandaDisclaimer}';
    }
    if (_matches(m, ['comer', 'comida', 'dieta', 'receita'])) {
      return 'Que tal algo simples e gostoso? 🥗 Tenho receitas fit fáceis na aba Nutrição. Comer bem é se cuidar.';
    }
    if (_matches(m, ['oi', 'olá', 'ola', 'bom dia', 'boa tarde', 'boa noite'])) {
      return 'Oi, $userName! 💜 Que bom te ver por aqui. Como você está hoje?';
    }
    if (_matches(m, ['obrigada', 'obrigado', 'valeu'])) {
      return 'Sempre com você! 🤗 Conta comigo todos os dias.';
    }

    // Fallback: frase motivacional aleatória.
    return SeedData.amandaPhrases[_rnd.nextInt(SeedData.amandaPhrases.length)];
  }

  bool _matches(String text, List<String> keys) =>
      keys.any((k) => text.contains(k));
}
