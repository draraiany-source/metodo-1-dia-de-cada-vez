import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:metodo_1_dia/core/services/premium_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('LocalPremiumService: assina e expira corretamente', () async {
    // Usa um container Riverpod isolado.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(premiumServiceProvider);
    final antes = await service.current();
    expect(antes.isPremium, isFalse);

    final depois = await service.subscribe('yearly');
    expect(depois.isPremium, isTrue);
    expect(depois.plan, 'yearly');
    expect(depois.expiresAt!.isAfter(DateTime.now()), isTrue);
  });

  test('PremiumStatus.free é não-premium', () {
    expect(PremiumStatus.free.isPremium, isFalse);
  });

  testWidgets('MaterialApp mínimo monta sem erros', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: Text('Lili Fit'))),
      ),
    );
    expect(find.text('Lili Fit'), findsOneWidget);
  });
}
