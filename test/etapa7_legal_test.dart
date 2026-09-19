import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/config/app_legal.dart';

void main() {
  test('contatos oficiais não são placeholder', () {
    expect(AppLegal.hasSupportEmail, isTrue);
    expect(AppLegal.supportEmail, '1diadecadavezsuporte@gmail.com');
    expect(AppLegal.hasPrivacyUrl, isTrue);
    expect(AppLegal.hasTermsUrl, isTrue);
    expect(AppLegal.privacyPolicyUrl, contains('privacidade.html'));
    expect(AppLegal.termsUrl, contains('termos.html'));
  });

  test('HTML legal não vaza e-mail pessoal nem documento duplicado', () {
    final privacy = File('public/privacidade.html').readAsStringSync();
    final terms = File('public/termos.html').readAsStringSync();

    expect(privacy.toLowerCase(), contains('1diadecadavezsuporte@gmail.com'));
    expect(terms.toLowerCase(), contains('1diadecadavezsuporte@gmail.com'));
    expect(privacy.contains('dra.raiany@gmail.com'), isFalse);
    expect(terms.contains('dra.raiany@gmail.com'), isFalse);
    expect(terms.contains('há 1 minuto'), isFalse);
    expect('<html'.allMatches(privacy.toLowerCase()).length, 1);
    expect('</html>'.allMatches(privacy.toLowerCase()).length, 1);
    expect(privacy, contains('subscriptions'));
    expect(privacy, contains('pt_messages'));
    expect(terms.toLowerCase(), contains('não garante'));
  });

  test('resumo de exclusão não promete apagar tudo', () {
    expect(AppLegal.accountDeletionSummary, contains('assinatura da loja'));
    expect(AppLegal.accountDeletionSummary, contains('pt_students'));
  });
}
