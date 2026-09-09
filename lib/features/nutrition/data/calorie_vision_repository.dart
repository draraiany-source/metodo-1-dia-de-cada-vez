import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../domain/food_analysis_models.dart';

/// Resultado legado (prato agregado) — mantido para compatibilidade.
class CalorieEstimate {
  const CalorieEstimate({
    required this.name,
    required this.kcal,
    required this.confidence,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.detalhe,
  });

  final String name;
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final String confidence;
  final String? detalhe;

  factory CalorieEstimate.fromMap(Map<String, dynamic> m) => CalorieEstimate(
        name: (m['name'] ?? 'Refeição') as String,
        kcal: ((m['kcal'] ?? m['calories'] ?? 0) as num).round(),
        protein: ((m['protein'] ?? m['protein_g'] ?? 0) as num).round(),
        carbs: ((m['carbs'] ?? m['carbs_g'] ?? 0) as num).round(),
        fat: ((m['fat'] ?? m['fat_g'] ?? 0) as num).round(),
        confidence: (m['confidence'] ?? 'baixa').toString(),
        detalhe: m['detalhe'] as String?,
      );

  factory CalorieEstimate.fromAnalysis(NutritionAnalysisResult r) {
    final t = r.totals;
    final conf = r.foods.isEmpty
        ? 'baixa'
        : r.foods.every((f) => f.confidence >= 0.75)
            ? 'alta'
            : r.foods.every((f) => f.confidence >= 0.45)
                ? 'media'
                : 'baixa';
    return CalorieEstimate(
      name: r.foods.map((f) => f.name).join(' + ').isEmpty
          ? 'Refeição'
          : r.foods.map((f) => f.name).join(' + '),
      kcal: t.kcal,
      protein: t.proteinG,
      carbs: t.carbsG,
      fat: t.fatG,
      confidence: conf,
      detalhe: r.notes,
    );
  }
}

class CalorieVisionUnavailable implements Exception {
  const CalorieVisionUnavailable();
  @override
  String toString() =>
      'A calculadora de calorias por foto ainda não foi configurada '
      '(falta o endpoint da Cloud Function calorieVision).';
}

/// Proxy seguro para a Cloud Function `calorieVision` (chave OpenAI só no servidor).
class CalorieVisionRepository {
  bool get isAvailable {
    final url = _functionUrl;
    return url.isNotEmpty && !url.contains('SEU-PROJETO');
  }

  String get _functionUrl => AppConfig.calorieVisionFunctionUrl.isNotEmpty
      ? AppConfig.calorieVisionFunctionUrl
      : AppConstants.calorieVisionFunctionUrl;

  /// Análise multi-alimento estruturada.
  Future<NutritionAnalysisResult> analyzeMeal(List<int> imageBytes) async {
    if (!isAvailable) throw const CalorieVisionUnavailable();

    final base64Image = base64Encode(imageBytes);
    final headers = await AuthHttpHeaders.forCloudFunction();
    final res = await http
        .post(
          Uri.parse(_functionUrl),
          headers: headers,
          body: jsonEncode({'imageBase64': base64Image}),
        )
        .timeout(const Duration(seconds: 45));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return NutritionAnalysisResult.fromApiMap(data);
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Usuário não autenticado. Faça login e tente novamente.');
    }
    throw Exception('Falha ao estimar calorias (${res.statusCode})');
  }

  /// Compatibilidade com chamadores antigos.
  Future<CalorieEstimate> estimate(List<int> imageBytes) async {
    final analysis = await analyzeMeal(imageBytes);
    return CalorieEstimate.fromAnalysis(analysis);
  }
}
