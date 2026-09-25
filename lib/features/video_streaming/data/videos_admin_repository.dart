import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/video_models.dart';

/// Operações de escrita da biblioteca de vídeos (Painel da Personal).
///
/// Vídeos do YouTube guardam a URL no próprio documento público (`youtubeUrl`).
/// Vídeos legados auto-hospedados continuam com a URL de streaming em
/// `videos/{id}/private/stream`, para manter a proteção Premium no servidor
/// (ver `VideosRepository.resolveStreamUrl` e a Cloud Function `getVideoUrl`).
class VideosAdminRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('videos');

  /// Cria ou atualiza. Quando [video] tem `id`, grava nesse id — é assim que um
  /// vídeo semeado do asset local é "adotado" pelo Firestore na primeira edição,
  /// sem virar duplicata.
  Future<String> upsert(VideoContent video, {String? streamUrl}) async {
    final ref = video.id.trim().isEmpty ? _col.doc() : _col.doc(video.id.trim());
    await ref.set(video.toMap(), SetOptions(merge: true));
    if (streamUrl != null && streamUrl.trim().isNotEmpty) {
      await ref
          .collection('private')
          .doc('stream')
          .set({'videoUrl': streamUrl.trim()}, SetOptions(merge: true));
    }
    return ref.id;
  }

  /// Publicar / despublicar (soft-delete): esconde das alunas sem apagar nada.
  Future<void> setActive(String videoId, bool active) async {
    await _col.doc(videoId).set({'active': active}, SetOptions(merge: true));
  }

  /// Id novo para um vídeo que ainda não existe. Precisamos dele ANTES de salvar
  /// porque a capa é enviada para um caminho que inclui o id do vídeo.
  ///
  /// Nunca lança: o editor chama isso no `initState`, e sem o Firebase pronto
  /// um throw aqui derrubaria a tela em vez de deixar a Amanda preencher o
  /// formulário e ver o erro só ao salvar.
  String newId() {
    try {
      return _col.doc().id;
    } catch (_) {
      return 'video_${DateTime.now().microsecondsSinceEpoch}';
    }
  }

  /// Grava a nova ordem da lista.
  ///
  /// Reaproveita os valores de `order` já existentes (só permuta), para não
  /// colidir com outras categorias da mesma coleção (ex.: meditações 1–7 vs
  /// shorts 10–12).
  Future<void> reorder(List<VideoContent> naNovaOrdem) async {
    final batch = FirebaseFirestore.instance.batch();
    final slots = naNovaOrdem.map((v) => v.order).toList()..sort();
    for (var i = 0; i < naNovaOrdem.length; i++) {
      final v = naNovaOrdem[i];
      if (v.id.trim().isEmpty) continue;
      batch.set(
        _col.doc(v.id),
        v.copyWith(order: slots[i]).toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> delete(String videoId) async {
    final ref = _col.doc(videoId);
    // O doc privado pode não existir (vídeo do YouTube) — ignorar a falha.
    try {
      await ref.collection('private').doc('stream').delete();
    } catch (_) {/* sem stream privado */}
    await ref.delete();
  }

  /// Envia a capa e devolve a URL pública. `videoId` entra no caminho para que
  /// trocar a capa do mesmo vídeo sobrescreva o arquivo anterior.
  Future<String> uploadCover(
    String videoId,
    List<int> bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final ext = contentType.endsWith('png') ? 'png' : 'jpg';
    final ref = FirebaseStorage.instance
        .ref('public/video_covers/$videoId/cover.$ext');
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }
}
