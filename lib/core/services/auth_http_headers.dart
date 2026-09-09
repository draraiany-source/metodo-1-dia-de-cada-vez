import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Headers HTTP autenticados para Cloud Functions HTTPS.
///
/// Sempre envia `Authorization: Bearer <idToken>` quando há sessão.
/// Quando App Check estiver ativo, também envia `X-Firebase-AppCheck`.
class AuthHttpHeaders {
  AuthHttpHeaders._();

  static Future<Map<String, String>> forCloudFunction({
    bool requireAuth = true,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (requireAuth) {
        throw StateError('Usuaria nao autenticada.');
      }
      return headers;
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('Nao foi possivel obter o token de autenticacao.');
    }
    headers['Authorization'] = 'Bearer $token';

    try {
      // App Check no Web ainda não é ativado neste app — getToken() quebra
      // com TypeError/FirebaseException via interop JS.
      if (!kIsWeb) {
        final appCheckToken = await FirebaseAppCheck.instance.getToken();
        if (appCheckToken != null && appCheckToken.isNotEmpty) {
          headers['X-Firebase-AppCheck'] = appCheckToken;
        }
      }
    } catch (e) {
      debugPrint('App Check token indisponivel: $e');
    }

    return headers;
  }
}