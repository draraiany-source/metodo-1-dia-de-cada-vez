import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Converte erros Firebase (e genéricos) em mensagens amigáveis em PT-BR.
/// Nunca exponha [toString] cru de [FirebaseException] na UI.
class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  static String toUserMessage(
    Object error, {
    String fallback =
        'Não conseguimos concluir agora. Verifique a conexão e tente de novo.',
  }) {
    if (error is FirebaseException) {
      return _fromCode(error.code, error.message) ?? fallback;
    }

    final raw = error.toString();
    // TypeError típico do Flutter Web quando FirebaseException cruza interop JS.
    if (raw.contains('FirebaseException') ||
        raw.contains('JavaScriptObject') ||
        raw.contains('FirebaseError')) {
      return 'Houve um problema ao falar com o servidor. '
          'Tente novamente em instantes.';
    }
    if (raw.contains('SocketException') ||
        raw.contains('network') ||
        raw.contains('Failed host lookup') ||
        raw.contains('ClientException')) {
      return 'Sem conexão com a internet. Conecte-se e tente novamente.';
    }
    if (raw.contains('TimeoutException') || raw.contains('timeout')) {
      return 'A operação demorou demais. Tente novamente.';
    }
    if (raw.contains('permission-denied') ||
        raw.contains('PERMISSION_DENIED')) {
      return 'Você não tem permissão para esta ação.';
    }

    if (kDebugMode) {
      debugPrint('FirebaseErrorMapper (debug): $error');
    }
    return fallback;
  }

  static void showSnack(BuildContext context, Object error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(toUserMessage(error))),
    );
  }

  static String? _fromCode(String code, String? message) {
    return switch (code) {
      'permission-denied' => 'Você não tem permissão para esta ação.',
      'unauthenticated' || 'user-not-found' =>
        'Faça login para continuar.',
      'unavailable' || 'deadline-exceeded' =>
        'Serviço temporariamente indisponível. Tente novamente.',
      'not-found' => 'Conteúdo não encontrado.',
      'already-exists' => 'Este registro já existe.',
      'resource-exhausted' => 'Muitas tentativas. Aguarde um momento.',
      'failed-precondition' =>
        'Não foi possível concluir. Atualize o app ou tente mais tarde.',
      'cancelled' => 'Operação cancelada.',
      'invalid-argument' => 'Dados inválidos. Revise e tente novamente.',
      'network-request-failed' =>
        'Sem conexão com a internet. Conecte-se e tente novamente.',
      _ => message != null &&
              message.isNotEmpty &&
              !message.contains('FirebaseException')
          ? message
          : null,
    };
  }
}
