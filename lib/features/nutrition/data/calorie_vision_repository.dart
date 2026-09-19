import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/cloud_function_http.dart';
import '../domain/food_analysis_models.dart';

/// Limite no cliente antes do encode (a Function recusa ~1,8M chars de base64).
const int kMaxMealPhotoBytes = 1200 * 1024;

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

class CalorieVisionPending implements Exception {
  const CalorieVisionPending([this.message]);
  final String? message;
  @override
  String toString() =>
      message ??
      'A análise de calorias por foto ainda não está disponível no servidor. '
          'A Cloud Function calorieVision precisa da chave OpenAI.';
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
    if (imageBytes.isEmpty) {
      throw const CalorieVisionPending(
        'Foto inválida. Tente outra imagem com os alimentos visíveis.',
      );
    }
    if (imageBytes.length > kMaxMealPhotoBytes) {
      throw const CalorieVisionPending(
        'A foto está grande demais. Tire outra com menos zoom ou escolha uma imagem menor.',
      );
    }

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
      final result = NutritionAnalysisResult.fromApiMap(data);
      if (result.looksLikePlaceholder) {
        throw CalorieVisionPending(
          result.notes?.trim().isNotEmpty == true
              ? result.notes
              : null,
        );
      }
      return result;
    }

    final apiError = functionErrorMessage(res.body);
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Faça login para analisar a refeição e tente novamente.');
    }
    if (res.statusCode == 413) {
      throw CalorieVisionPending(
        apiError ??
            'A foto está grande demais. Tire outra com menos zoom ou escolha uma imagem menor.',
      );
    }
    if (res.statusCode == 429) {
      throw Exception(
        apiError ??
            'Muitas análises neste momento. Aguarde alguns minutos e tente de novo.',
      );
    }
    if (res.statusCode == 503) {
      throw CalorieVisionPending(apiError);
    }
    if (res.statusCode == 502 || res.statusCode == 504) {
      throw Exception(
        apiError ??
            'A análise da imagem falhou. Tente outra foto em instantes.',
      );
    }
    throw Exception(
      apiError ??
          'Não conseguimos analisar essa imagem. Tente novamente.',
    );
  }

  /// Compatibilidade com chamadores antigos.
  Future<CalorieEstimate> estimate(List<int> imageBytes) async {
    final analysis = await analyzeMeal(imageBytes);
    return CalorieEstimate.fromAnalysis(analysis);
  }
}
