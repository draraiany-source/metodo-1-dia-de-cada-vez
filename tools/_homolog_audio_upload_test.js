/**
 * Homologação: sobe 1 MP3 de teste (active:false), valida HTTP, remove.
 * NÃO deixa conteúdo fictício publicado para alunas.
 */
const fs = require('fs');
const path = require('path');
const { createRequire } = require('module');
const { randomUUID } = require('crypto');

const req = createRequire(path.resolve(__dirname, 'audio_seed/package.json'));
const { initializeApp, applicationDefault, getApps } = req('firebase-admin/app');
const { getFirestore, FieldValue } = req('firebase-admin/firestore');
const { getStorage } = req('firebase-admin/storage');

async function main() {
  const PROJECT = 'metodo1dia-app';
  const MP3 = path.join(__dirname, '_test_audio_homolog_NOT_PUBLISH.mp3');
  if (!fs.existsSync(MP3)) {
    console.error('MISSING_TEST_MP3', MP3);
    process.exit(2);
  }

  if (!getApps().length) {
    initializeApp({
      credential: applicationDefault(),
      storageBucket: `${PROJECT}.firebasestorage.app`,
      projectId: PROJECT,
    });
  }

  const db = getFirestore();
  const bucket = getStorage().bucket();
  const courseId = `teste_homolog_${Date.now()}`;
  const chapterId = `ch_${Date.now()}`;
  const storagePath = `audio_courses/${courseId}/${chapterId}.mp3`;
  const bytes = fs.readFileSync(MP3);

  console.log('UPLOAD_START', storagePath, bytes.length);
  const file = bucket.file(storagePath);
  const token = randomUUID();
  await file.save(bytes, {
    resumable: false,
    contentType: 'audio/mpeg',
    metadata: {
      metadata: {
        purpose: 'homolog_test_not_publish',
        courseId,
        chapterId,
        firebaseStorageDownloadTokens: token,
      },
    },
  });

  const encoded = encodeURIComponent(storagePath);
  const downloadUrl =
    `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encoded}?alt=media&token=${token}`;

  await db.collection('audio_courses').doc(courseId).set({
    title: '[TESTE HOMOLOG] NÃO PUBLICAR — remover',
    teacher: 'Sistema Homologação',
    category: 'motivacao',
    coverUrl: '',
    isPremium: false,
    active: false,
    order: 9999,
    updatedAt: FieldValue.serverTimestamp(),
  });
  await db
    .collection('audio_courses')
    .doc(courseId)
    .collection('chapters')
    .doc(chapterId)
    .set({
      title: 'Faixa teste homolog',
      durationSeconds: 1,
      order: 0,
      storagePath,
      updatedAt: FieldValue.serverTimestamp(),
    });
  await db
    .collection('audio_courses')
    .doc(courseId)
    .collection('private')
    .doc('chapters')
    .set({ [chapterId]: downloadUrl }, { merge: true });

  const res = await fetch(downloadUrl, { method: 'GET' });
  const buf = Buffer.from(await res.arrayBuffer());
  console.log('PLAYBACK_HTTP', res.status, 'bytes', buf.length);

  await db
    .collection('audio_courses')
    .doc(courseId)
    .collection('chapters')
    .doc(chapterId)
    .delete();
  try {
    await db
      .collection('audio_courses')
      .doc(courseId)
      .collection('private')
      .doc('chapters')
      .delete();
  } catch (_) {}
  await db.collection('audio_courses').doc(courseId).delete();
  try {
    await file.delete();
  } catch (_) {}

  console.log('CLEANUP_OK', courseId);
  console.log(
    JSON.stringify({
      ok: res.status === 200 && buf.length > 0,
      courseId,
      storagePath,
      httpStatus: res.status,
      bytes: buf.length,
      activeWas: false,
      cleaned: true,
      note: 'active:false — nunca visível para alunas; removido após teste',
    }),
  );
}

main().catch((e) => {
  console.error('FAIL', e && e.stack ? e.stack : e);
  process.exit(1);
});
