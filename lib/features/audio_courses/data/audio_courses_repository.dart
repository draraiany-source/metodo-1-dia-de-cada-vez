import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_http_headers.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/firebase_error_mapper.dart';
import '../domain/audio_course_models.dart';

class ChapterUrlResult {
  const ChapterUrlResult({this.url, this.error});
  final String? url;
  final String? error;
  bool get ok => url != null;
}

/// Erro tipado para a UI (retry + mensagem amigável).
class AudioCoursesFetchException implements Exception {
  AudioCoursesFetchException(this.userMessage, {this.cause});
  final String userMessage;
  final Object? cause;
  @override
  String toString() => userMessage;
}

/// Busca cursos em áudio no Firestore (`audio_courses` + subcoleção
/// `chapters`, só metadados). Sem Firebase configurado, ou sem conteúdo
/// cadastrado ainda, devolve lista vazia — a tela mostra um estado vazio
/// amigável, não quebra.
///
/// A URL real de cada capítulo NÃO fica mais no documento público (era uma
/// brecha: um curso Premium com a URL exposta permitia assistir sem
/// assinar, mesmo com o botão escondido). Agora fica em
/// `audio_courses/{id}/private/chapters` (mapa chapterId -> url), só
/// resolvida pela Cloud Function `getContentUrl` — mesmo padrão já usado
/// em vídeos/e-books/cursos.
///
/// Estrutura esperada no Firestore:
/// ```
/// audio_courses/{courseId}
///   title, teacher, category, coverUrl, isPremium, order
/// audio_courses/{courseId}/chapters/{chapterId}
///   title, durationSeconds, order   (SEM audioUrl)
/// audio_courses/{courseId}/private/chapters
///   { chapterId: audioUrl, ... }
/// ```
class AudioCoursesRepository {
  bool get isAvailable => FirebaseService.isReady;

  /// Lista para alunas — só cursos com `active != false`.
  Future<List<AudioCourse>> fetchAll() async =>
      _fetch(includeInactive: false);

  /// Lista para o painel da Amanda/Admin — inclui rascunhos e testes.
  Future<List<AudioCourse>> fetchAllForAdmin() async =>
      _fetch(includeInactive: true);

  Future<List<AudioCourse>> _fetch({required bool includeInactive}) async {
    if (!isAvailable) return [];
    try {
      final db = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> coursesSnap;
      try {
        coursesSnap =
            await db.collection('audio_courses').orderBy('order').get();
      } catch (e) {
        debugPrint('audio_courses orderBy falhou ($e); fallback sem order.');
        coursesSnap = await db.collection('audio_courses').get();
      }
      final courses = <AudioCourse>[];
      for (final doc in coursesSnap.docs) {
        try {
          QuerySnapshot<Map<String, dynamic>> chaptersSnap;
          try {
            chaptersSnap = await doc.reference
                .collection('chapters')
                .orderBy('order')
                .get();
          } catch (_) {
            chaptersSnap = await doc.reference.collection('chapters').get();
          }
          final chapters = chaptersSnap.docs
              .map((c) => AudioChapter.fromMap(c.id, c.data()))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
          final course = AudioCourse.fromMap(doc.id, doc.data(), chapters);
          if (!includeInactive && !course.active) continue;
          courses.add(course);
        } catch (e) {
          debugPrint('Audio course parse falhou ${doc.id}: $e');
        }
      }
      courses.sort((a, b) => a.order.compareTo(b.order));
      return courses;
    } catch (e) {
      throw AudioCoursesFetchException(
        FirebaseErrorMapper.toUserMessage(
          e,
          fallback:
              'Não foi possível carregar os cursos. Verifique a conexão e tente novamente.',
        ),
        cause: e,
      );
    }
  }

  /// Resolve a URL real de um capítulo via Cloud Function (protegida —
  /// valida Premium no servidor antes de devolver).
  Future<ChapterUrlResult> resolveChapterUrl(
      String courseId, String chapterId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const ChapterUrlResult(error: 'Entre na sua conta pra ouvir.');
    }
    const functionUrl = AppConstants.getContentUrlFunctionUrl;
    if (functionUrl.contains('SEU-PROJETO')) {
      return const ChapterUrlResult(
          error: 'Biblioteca ainda não configurada neste app.');
    }
    try {
      final headers = await AuthHttpHeaders.forCloudFunction();
      final res = await http
          .post(
            Uri.parse(functionUrl),
            headers: headers,
            body: jsonEncode({'collection': 'audio_courses', 'docId': courseId}),
          )
          .timeout(const Duration(seconds: 12));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['data'] != null) {
        final chapters = data['data'] as Map<String, dynamic>;
        final url = chapters[chapterId] as String?;
        if (url == null || url.isEmpty) {
          return const ChapterUrlResult(
              error:
                  'Este áudio ainda não foi publicado. Tente outro ou volte mais tarde.');
        }
        return ChapterUrlResult(url: url);
      }
      if (res.statusCode == 401) {
        return const ChapterUrlResult(
            error: 'Sessão expirada. Entre de novo pra ouvir.');
      }
      if (res.statusCode == 403) {
        return const ChapterUrlResult(
            error: 'Conteúdo Premium. Assine para liberar este áudio.');
      }
      if (res.statusCode == 404) {
        return const ChapterUrlResult(
            error:
                'Áudio não encontrado na biblioteca. Pode ainda não estar cadastrado.');
      }
      return ChapterUrlResult(
          error: (data['error'] ??
                  'Não foi possível carregar o áudio. Tente de novo.')
              as String);
    } on TimeoutException {
      return const ChapterUrlResult(
          error: 'Demorou demais para carregar. Verifique a conexão.');
    } catch (_) {
      return const ChapterUrlResult(
          error: 'Não consegui carregar o áudio agora. A tela continua ok — tente outro.');
    }
  }
}
