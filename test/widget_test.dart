import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/config/app_legal.dart';

void main() {
  test('AppLegal usa URLs e e-mail oficiais', () {
    expect(AppLegal.hasPrivacyUrl, isTrue);
    expect(
      AppLegal.privacyPolicyUrl,
      'https://metodo1dia-app.web.app/privacidade.html',
    );
    expect(AppLegal.hasTermsUrl, isTrue);
    expect(
      AppLegal.termsUrl,
      'https://metodo1dia-app.web.app/termos.html',
    );
    expect(AppLegal.hasSupportEmail, isTrue);
    expect(AppLegal.supportEmail, '1diadecadavezsuporte@gmail.com');
    expect(AppLegal.inAppPrivacySummary.contains('Firebase'), isTrue);
    expect(AppLegal.inAppTermsSummary.isNotEmpty, isTrue);
  });
}
