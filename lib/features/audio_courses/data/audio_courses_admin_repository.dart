import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/audio_course_models.dart';

/// Resultado de upload de um arquivo de áudio no Storage.
class AudioChapterUpload {
  const AudioChapterUpload({
    required this.downloadUrl,
    required this.storagePath,
  });
  final String downloadUrl;
  final String storagePath;
}

/// Painel da Amanda / Admin: cursos em áudio no Firestore + MP3 no Storage.
///
/// Caminho Storage: `audio_courses/{courseId}/{chapterId}.{ext}`
/// URL real: `audio_courses/{courseId}/private/chapters` (mapa chapterId → url)
class AudioCoursesAdminRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('audio_courses');

  String newCourseId() {
    try {
      return _col.doc().id;
    } catch (_) {
      return 'course_${DateTime.now().microsecondsSinceEpoch}';
    }
  }

  String newChapterId(String courseId) {
    try {
      return _col.doc(courseId).collection('chapters').doc().id;
    } catch (_) {
      return 'ch_${DateTime.now().microsecondsSinceEpoch}';
    }
  }

  Future<String> createCourse({
    required String title,
    required String teacher,
    required AudioCourseCategory category,
    required String coverUrl,
    required bool isPremium,
    bool active = true,
    String? courseId,
  }) async {
    final ref =
        courseId == null || courseId.isEmpty ? _col.doc() : _col.doc(courseId);
    await ref.set({
      'title': title,
      'teacher': teacher,
      'category': category.name,
      'coverUrl': coverUrl,
      'isPremium': isPremium,
      'active': active,
      'order': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return ref.id;
  }

  Future<void> updateCourse({
    required String courseId,
    String? title,
    String? teacher,
    AudioCourseCategory? category,
    String? coverUrl,
    bool? isPremium,
    bool? active,
    int? order,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) data['title'] = title;
    if (teacher != null) data['teacher'] = teacher;
    if (category != null) data['category'] = category.name;
    if (coverUrl != null) data['coverUrl'] = coverUrl;
    if (isPremium != null) data['isPremium'] = isPremium;
    if (active != null) data['active'] = active;
    if (order != null) data['order'] = order;
    await _col.doc(courseId).set(data, SetOptions(merge: true));
  }

  /// Envia bytes de áudio para o Storage e devolve URL + path.
  Future<AudioChapterUpload> uploadAudioBytes({
    required String courseId,
    required String chapterId,
    required List<int> bytes,
    required String fileName,
    String? contentType,
  }) async {
    final ext = _extFromName(fileName);
    final mime = contentType ?? _mimeForExt(ext);
    final storagePath = 'audio_courses/$courseId/$chapterId.$ext';
    final ref = FirebaseStorage.instance.ref(storagePath);
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(
        contentType: mime,
        customMetadata: {
          'courseId': courseId,
          'chapterId': chapterId,
          'originalName': fileName,
        },
      ),
    );
    final url = await ref.getDownloadURL();
    return AudioChapterUpload(downloadUrl: url, storagePath: storagePath);
  }

  Future<String> addChapter({
    required String courseId,
    required String title,
    required String audioUrl,
    required int durationSeconds,
    required int order,
    String? storagePath,
    String? chapterId,
  }) async {
    final courseRef = _col.doc(courseId);
    final chapterRef = chapterId == null || chapterId.isEmpty
        ? courseRef.collection('chapters').doc()
        : courseRef.collection('chapters').doc(chapterId);
    await chapterRef.set({
      'title': title,
      'durationSeconds': durationSeconds,
      'order': order,
      if (storagePath != null && storagePath.isNotEmpty)
        'storagePath': storagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await courseRef.collection('private').doc('chapters').set(
      {chapterRef.id: audioUrl},
      SetOptions(merge: true),
    );
    return chapterRef.id;
  }

  /// Substitui o arquivo (e opcionalmente título/duração) de um capítulo.
  Future<void> replaceChapterAudio({
    required String courseId,
    required String chapterId,
    required String audioUrl,
    String? storagePath,
    String? title,
    int? durationSeconds,
    String? previousStoragePath,
  }) async {
    final courseRef = _col.doc(courseId);
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) data['title'] = title;
    if (durationSeconds != null) data['durationSeconds'] = durationSeconds;
    if (storagePath != null) data['storagePath'] = storagePath;
    await courseRef
        .collection('chapters')
        .doc(chapterId)
        .set(data, SetOptions(merge: true));
    await courseRef.collection('private').doc('chapters').set(
      {chapterId: audioUrl},
      SetOptions(merge: true),
    );
    if (previousStoragePath != null &&
        previousStoragePath.isNotEmpty &&
        previousStoragePath != storagePath) {
      await _deleteStoragePath(previousStoragePath);
    }
  }

  Future<void> updateChapterMeta({
    required String courseId,
    required String chapterId,
    String? title,
    int? durationSeconds,
    int? order,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) data['title'] = title;
    if (durationSeconds != null) data['durationSeconds'] = durationSeconds;
    if (order != null) data['order'] = order;
    await _col
        .doc(courseId)
        .collection('chapters')
        .doc(chapterId)
        .set(data, SetOptions(merge: true));
  }

  /// Grava a ordem dos capítulos (lista já na ordem desejada).
  Future<void> reorderChapters(
    String courseId,
    List<AudioChapter> naNovaOrdem,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    final courseRef = _col.doc(courseId);
    for (var i = 0; i < naNovaOrdem.length; i++) {
      final ch = naNovaOrdem[i];
      if (ch.id.trim().isEmpty) continue;
      batch.set(
        courseRef.collection('chapters').doc(ch.id),
        {
          'title': ch.title,
          'durationSeconds': ch.duration.inSeconds,
          'order': i,
          if (ch.storagePath.isNotEmpty) 'storagePath': ch.storagePath,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> deleteChapter({
    required String courseId,
    required AudioChapter chapter,
  }) async {
    final courseRef = _col.doc(courseId);
    await courseRef.collection('chapters').doc(chapter.id).delete();
    final privateRef = courseRef.collection('private').doc('chapters');
    final privateSnap = await privateRef.get();
    if (privateSnap.exists) {
      final map = Map<String, dynamic>.from(privateSnap.data() ?? {});
      map.remove(chapter.id);
      if (map.isEmpty) {
        await privateRef.delete();
      } else {
        await privateRef.set(map);
      }
    }
    if (chapter.storagePath.isNotEmpty) {
      await _deleteStoragePath(chapter.storagePath);
    } else if (chapter.audioUrl.contains('firebasestorage.googleapis.com') ||
        chapter.audioUrl.contains('storage.googleapis.com')) {
      try {
        await FirebaseStorage.instance.refFromURL(chapter.audioUrl).delete();
      } catch (_) {/* já removido */}
    }
  }

  Future<void> deleteCourse(String courseId) async {
    final ref = _col.doc(courseId);
    final chapters = await ref.collection('chapters').get();
    for (final c in chapters.docs) {
      final path = (c.data()['storagePath'] as String?)?.trim() ?? '';
      if (path.isNotEmpty) await _deleteStoragePath(path);
      await c.reference.delete();
    }
    try {
      await ref.collection('private').doc('chapters').delete();
    } catch (_) {/* sem private */}
    await ref.delete();
    try {
      final listed =
          await FirebaseStorage.instance.ref('audio_courses/$courseId').listAll();
      for (final item in listed.items) {
        await item.delete();
      }
    } catch (_) {/* pasta vazia ou inexistente */}
  }

  Future<void> _deleteStoragePath(String path) async {
    try {
      await FirebaseStorage.instance.ref(path).delete();
    } catch (_) {/* arquivo já ausente */}
  }

  String _extFromName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.wav')) return 'wav';
    if (lower.endsWith('.m4a')) return 'm4a';
    if (lower.endsWith('.aac')) return 'aac';
    if (lower.endsWith('.ogg')) return 'ogg';
    return 'mp3';
  }

  String _mimeForExt(String ext) => switch (ext) {
        'wav' => 'audio/wav',
        'm4a' => 'audio/mp4',
        'aac' => 'audio/aac',
        'ogg' => 'audio/ogg',
        _ => 'audio/mpeg',
      };
}
