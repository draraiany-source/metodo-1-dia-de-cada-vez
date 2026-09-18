import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/firebase_service.dart';

/// Proxy autenticado para a Cloud Function `accompanimentAi`.
///
/// A IA só sugere. Nunca envia mensagem, nunca publica treino, nunca diagnostica.
class AccompanimentAiRepository {
  String get _url {
    const override = String.fromEnvironment('ACCOMPANIMENT_AI_URL');
    if (override.isNotEmpty) return override;
    return AppConstants.accompanimentAiFunctionUrl;
  }

  Future<String> run({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    if (!FirebaseService.isReady) {
      return _offline(action, payload);
    }
    try {
      final headers = await AuthHttpHeaders.forCloudFunction();
      final res = await http
          .post(
            Uri.parse(_url),
            headers: headers,
            body: jsonEncode({'action': action, ...payload}),
          )
          .timeout(const Duration(seconds: 40));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['result'] ?? data['reply'] ?? '') as String;
      }
    } catch (_) {}
    return _offline(action, payload);
  }

  Future<String> studentAssistant(String message) {
    return run(action: 'student_assistant', payload: {'message': message});
  }

  String _offline(String action, Map<String, dynamic> payload) {
    switch (action) {
      case 'student_assistant':
        final m = '${payload['message'] ?? ''}'.toLowerCase();
        if (m.contains('treino')) {
          return 'Você encontra seus treinos em Meu Treino, no menu da Home. '
              'Se a dúvida for sobre carga ou exercício específico, essa decisão precisa da Amanda. '
              'Quer enviar essa dúvida diretamente para ela?';
        }
        if (m.contains('água') || m.contains('agua')) {
          return 'Para registrar água, abra a área Água na Home e toque nos copos da meta do dia.';
        }
        if (m.contains('consult')) {
          return 'Para marcar consultoria, abra Consultoria com Amanda e escolha um horário disponível.';
        }
        if (m.contains('peso') || m.contains('medida')) {
          return 'Peso e medidas ficam em Evolução. Se não houver informação cadastrada, o app mostra isso — nada é inventado.';
        }
        return 'Sou o Assistente virtual com IA do Método, não a Amanda. '
            'Posso ajudar com o aplicativo. Se for orientação individual de treino, '
            'essa decisão precisa da avaliação da Amanda.';
      case 'reply_suggestion':
        return 'Sem problema. Vamos entender como foi sua semana e ajustar a rotina para ficar mais realista. '
            'Quantos dias você acredita que consegue treinar na próxima semana?';
      default:
        return 'Não há informação cadastrada o suficiente para este resumo. '
            'A IA só usa dados existentes no sistema.';
    }
  }
}

class GoogleCalendarRepository {
  String get _url {
    const override = String.fromEnvironment('GOOGLE_CALENDAR_FN_URL');
    if (override.isNotEmpty) return override;
    return AppConstants.googleCalendarFunctionUrl;
  }

  Future<Map<String, dynamic>> call(String action,
      [Map<String, dynamic>? body]) async {
    if (!FirebaseService.isReady) {
      return {'ok': false, 'error': 'Firebase indisponível'};
    }
    final headers = await AuthHttpHeaders.forCloudFunction();
    final res = await http
        .post(
          Uri.parse(_url),
          headers: headers,
          body: jsonEncode({'action': action, ...?body}),
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return {
      'ok': false,
      'error': 'Falha ${res.statusCode}',
      'pending': true,
    };
  }
}
