import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:metodo_1_dia/features/nutrition/data/mock/nutrition_dashboard_mock.dart';
import 'package:metodo_1_dia/features/nutrition/presentation/nutrition_dashboard_screen.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR', null);
  });

  Future<void> pumpDashboard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const NutritionDashboardScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('NutritionDashboardScreen exibe dados mockados B1', (tester) async {
    final mock = NutritionDashboardViewData.mock();
    await pumpDashboard(tester);

    expect(find.text('Nutricao IA'), findsOneWidget);
    expect(find.textContaining('Fotografar minha refeicao'), findsOneWidget);
    expect(find.text('Refeicoes de hoje'), findsOneWidget);
    expect(find.text('${mock.consumed.kcal}'), findsOneWidget);
    expect(find.textContaining('Meta ${mock.goals.calories} kcal'), findsOneWidget);
    expect(find.textContaining('Almo'), findsOneWidget);
  });

  testWidgets('Botao de foto informa etapa futura', (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.textContaining('Fotografar minha refeicao'));
    await tester.pumpAndSettle();
    expect(find.textContaining('etapa futura'), findsOneWidget);
  });
}