import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/firebase_service.dart';
import '../../ebooks/data/ebooks_repository.dart' show ContentUrlResult;
import '../domain/pdf_recipe_models.dart';

/// Busca receitas em PDF no Firestore (`pdf_recipes`). Sem Firebase
/// configurado, ou sem conteúdo cadastrado ainda, devolve lista vazia.
///
/// SEGURANÇA (§28): o documento público contém apenas metadados
/// (title, category, coverUrl, minutes, difficulty, kcal, protein, carbs,
/// fat). O arquivo real fica em `pdf_recipes/{id}/private/file.pdfUrl`,
/// ilegível pelo cliente; a URL é resolvida exclusivamente pela Cloud
/// Function `getContentUrl`, que valida autenticação e direito Premium no
/// servidor. NUNCA voltar a ler `pdfUrl` do documento público.
class PdfRecipesRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<PdfRecipe>> fetchAll() async {
    if (!isAvailable) return [];
    try {
      final snap =
          await FirebaseFirestore.instance.collection('pdf_recipes').get();
      return snap.docs
          .map((d) => PdfRecipe.fromMap(d.id, d.data()))
          .where((r) => r.active)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Resolve a URL real do PDF via Cloud Function `getContentUrl`
  /// (mesmo fluxo protegido dos e-books). Sem fallback público.
  Future<ContentUrlResult> resolveFileUrl(String recipeId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const ContentUrlResult(error: 'Entre na sua conta pra abrir.');
    }
    final functionUrl = AppConstants.getContentUrlFunctionUrl;
    if (functionUrl.contains('SEU-PROJETO')) {
      return const ContentUrlResult(
          error: 'Receitas ainda não configuradas neste app.');
    }
    try {
      final headers = await AuthHttpHeaders.forCloudFunction();
      final res = await http
          .post(
            Uri.parse(functionUrl),
            headers: headers,
            body: jsonEncode({'collection': 'pdf_recipes', 'docId': recipeId}),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['url'] != null) {
        return ContentUrlResult(url: data['url'] as String);
      }
      return ContentUrlResult(
          error:
              (data['error'] ?? 'Não foi possível abrir a receita.') as String);
    } catch (_) {
      return const ContentUrlResult(
          error: 'Não consegui carregar a receita agora.');
    }
  }
}
