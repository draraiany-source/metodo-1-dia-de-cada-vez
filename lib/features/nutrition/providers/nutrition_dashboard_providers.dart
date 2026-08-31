import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/nutrition_dashboard_mock.dart';

/// Estado do Dashboard B1 — mock na Etapa 2; trocado por repositorios reais depois.
final nutritionDashboardProvider = Provider<NutritionDashboardViewData>(
  (_) => NutritionDashboardViewData.mock(),
);
