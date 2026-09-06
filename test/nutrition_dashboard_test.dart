import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:metodo_1_dia/core/router/app_router.dart';
import 'package:metodo_1_dia/features/nutrition/data/mock/nutrition_dashboard_mock.dart';
import 'package:metodo_1_dia/features/nutrition/domain/daily_log.dart';
import 'package:metodo_1_dia/features/nutrition/domain/nutrition_enums.dart';
import 'package:metodo_1_dia/features/nutrition/domain/user_goals.dart';
import 'package:metodo_1_dia/features/nutrition/domain/water_log_entry.dart';
import 'package:metodo_1_dia/features/nutrition/presentation/nutrition_dashboard_screen.dart';
import 'package:metodo_1_dia/features/nutrition/providers/nutrition_dashboard_providers.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('pt_BR', null);
  });

  final day = DateTime(2026, 9, 5);
  final sample = NutritionDashboardViewData(
    date: day,
    goals: UserGoals(
      calories: 2000,
      proteinG: 100,
      carbsG: 200,
      fatG: 65,
      waterMl: 2000,
      objective: NutritionObjective.manutencao,
      updatedAt: day,
    ),
    log: DailyLog(
      date: day,
      meals: const [],
      water: WaterLogEntry(date: day, consumedMl: 0, goalMl: 2000),
    ),
    isMock: false,
  );

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
        GoRoute(
          path: Routes.calorieScanner,
          builder: (_, __) => const Scaffold(
            body: Text('scanner-stub'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nutritionDashboardProvider.overrideWith((ref) async => sample),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('NutritionDashboardScreen exibe dados reais do provider',
      (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Nutricao IA'), findsOneWidget);
    expect(find.textContaining('Fotografar minha refeicao'), findsOneWidget);
    expect(find.text('Refeicoes de hoje'), findsOneWidget);
    expect(find.text('${sample.consumed.kcal}'), findsOneWidget);
    expect(
        find.textContaining('Meta ${sample.goals.calories} kcal'), findsOneWidget);
    expect(find.textContaining('Nenhuma refeicao registrada'), findsOneWidget);
  });

  testWidgets('Botao de foto navega para scanner de calorias', (tester) async {
    await pumpDashboard(tester);
    await tester.tap(find.textContaining('Fotografar minha refeicao'));
    await tester.pumpAndSettle();
    expect(find.text('scanner-stub'), findsOneWidget);
  });
}
