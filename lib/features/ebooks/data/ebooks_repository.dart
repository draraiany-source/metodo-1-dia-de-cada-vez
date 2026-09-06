import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/ebook_models.dart';

class ContentUrlResult {
  const ContentUrlResult({this.url, this.error});
  final String? url;
  final String? error;
  bool get ok => url != null;
}

class EbooksRepository {
  bool get isAvailable => FirebaseService.isReady;

  Future<List<Ebook>> fetchAll() async {
    if (!isAvailable) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('ebooks')
          .where('active', isEqualTo: true)
          .orderBy('order')
          .get();
      return snap.docs.map((d) => Ebook.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  /// Resolve a URL real do PDF via Cloud Function `getContentUrl`
  /// (protegida — mesma lógica de `getVideoUrl`, generalizada).
  Future<ContentUrlResult> resolveFileUrl(String ebookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const ContentUrlResult(error: 'Entre na sua conta pra ler.');
    }
    final functionUrl = AppConstants.getContentUrlFunctionUrl;
    if (functionUrl.contains('SEU-PROJETO')) {
      return const ContentUrlResult(
          error: 'Biblioteca ainda não configurada neste app.');
    }
    try {
      final headers = await AuthHttpHeaders.forCloudFunction();
      final res = await http
          .post(
            Uri.parse(functionUrl),
            headers: headers,
            body: jsonEncode({'collection': 'ebooks', 'docId': ebookId}),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['url'] != null) {
        return ContentUrlResult(url: data['url'] as String);
      }
      return ContentUrlResult(
          error: (data['error'] ?? 'Não foi possível abrir o e-book.')
              as String);
    } catch (_) {
      return const ContentUrlResult(
          error: 'Não consegui carregar o e-book agora.');
    }
  }
}
