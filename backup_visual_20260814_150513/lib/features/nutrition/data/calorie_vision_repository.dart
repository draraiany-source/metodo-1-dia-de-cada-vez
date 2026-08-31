import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';

/// Resultado da estimativa de calorias a partir de uma foto de comida.
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

  /// 'alta' | 'media' | 'baixa' — a IA nunca tem certeza absoluta a partir
  /// de uma única foto, então sempre exibimos isso e permitimos ajuste manual.
  final String confidence;
  final String? detalhe;

  factory CalorieEstimate.fromMap(Map<String, dynamic> m) => CalorieEstimate(
        name: (m['name'] ?? 'Refeição') as String,
        kcal: ((m['kcal'] ?? 0) as num).round(),
        protein: ((m['protein'] ?? 0) as num).round(),
        carbs: ((m['carbs'] ?? 0) as num).round(),
        fat: ((m['fat'] ?? 0) as num).round(),
        confidence: (m['confidence'] ?? 'baixa') as String,
        detalhe: m['detalhe'] as String?,
      );
}

class CalorieVisionUnavailable implements Exception {
  const CalorieVisionUnavailable();
  @override
  String toString() =>
      'A calculadora de calorias por foto ainda não foi configurada '
      '(falta o endpoint da Cloud Function calorieVision).';
}

/// Repositório da calculadora de calorias por foto.
///
/// **Produção**: chama a Cloud Function `calorieVision`, que guarda a chave
/// da OpenAI no servidor (nunca no app) e usa um modelo com visão para
/// estimar o prato e as calorias. Configure `AppConfig.calorieVisionFunctionUrl`
/// (via --dart-define) e faça o deploy da function em `functions/src/index.js`.
///
/// **Sem chave configurada**: lança [CalorieVisionUnavailable] — a tela
/// trata isso oferecendo o registro manual, sem quebrar o app.
class CalorieVisionRepository {
  bool get isAvailable => AppConfig.calorieVisionConfigured;

  String get _functionUrl => AppConfig.calorieVisionFunctionUrl.isNotEmpty
      ? AppConfig.calorieVisionFunctionUrl
      : AppConstants.calorieVisionFunctionUrl;

  /// [imageBytes] já deve vir comprimido (ver [ImagePicker.imageQuality])
  /// para manter a chamada rápida e barata.
  Future<CalorieEstimate> estimate(List<int> imageBytes) async {
    if (!isAvailable) throw const CalorieVisionUnavailable();

    final base64Image = base64Encode(imageBytes);
    final res = await http
        .post(
          Uri.parse(_functionUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'imageBase64': base64Image}),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return CalorieEstimate.fromMap(data);
    }
    throw Exception('Falha ao estimar calorias (${res.statusCode})');
  }
}
