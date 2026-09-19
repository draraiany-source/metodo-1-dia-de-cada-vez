import 'dart:convert';

/// Extrai `error` amigável do JSON da Cloud Function. Nunca devolve stack.
String? functionErrorMessage(String body) {
  try {
    final data = jsonDecode(body);
    if (data is Map && data['error'] is String) {
      final text = (data['error'] as String).trim();
      if (text.isNotEmpty) return text;
    }
  } catch (_) {}
  return null;
}

bool looksLikeAmandaPlaceholder(String reply) {
  final t = reply.toLowerCase();
  return t.contains('configure a chave') ||
      t.contains('amanda em modo básico') ||
      t.contains('amanda em modo basico') ||
      t.contains('openai na cloud function');
}
