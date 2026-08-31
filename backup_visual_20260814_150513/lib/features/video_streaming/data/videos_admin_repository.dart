import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/video_models.dart';

/// Operações de escrita do admin — separa explicitamente o documento
/// público (metadados) da URL de streaming privada, pra manter a proteção
/// Premium real (ver `VideosRepository` e a Cloud Function `getVideoUrl`).
class VideosAdminRepository {
  Future<void> create(VideoContent video, String streamUrl) async {
    final ref = FirebaseFirestore.instance.collection('videos').doc();
    await ref.set(video.toMap());
    await ref.collection('private').doc('stream').set({'videoUrl': streamUrl});
  }

  Future<void> delete(String videoId) async {
    final ref = FirebaseFirestore.instance.collection('videos').doc(videoId);
    await ref.collection('private').doc('stream').delete();
    await ref.delete();
  }
}
