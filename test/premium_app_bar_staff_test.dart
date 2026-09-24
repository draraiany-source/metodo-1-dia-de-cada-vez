import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:metodo_1_dia/core/auth/staff_sign_out_button.dart';
import 'package:metodo_1_dia/core/router/premium_app_bar.dart';

void main() {
  testWidgets('PremiumAppBar staff: Voltar + Sair visíveis', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: PremiumAppBar(
              title: 'Filha Admin',
              showStaffSignOut: true,
            ),
            body: SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Voltar'), findsOneWidget);
    expect(find.byType(StaffSignOutButton), findsOneWidget);
    expect(find.byTooltip('Sair da conta'), findsOneWidget);
  });

  testWidgets('PremiumAppBar raiz: sem Voltar, com Sair explícito', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: PremiumAppBar(
              title: 'Raiz',
              isRoleRoot: true,
              showBack: false,
              actions: [StaffSignOutButton()],
            ),
            body: SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Voltar'), findsNothing);
    expect(find.text('Sair da conta'), findsOneWidget);
  });
}
