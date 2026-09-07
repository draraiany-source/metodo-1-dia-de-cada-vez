/**
 * Upload dos 7 MP3s + seed Firestore (Programa 7 Dias).
 * Uso: node upload_and_seed.js [bucket]
 */
const { initializeApp, applicationDefault, cert, getApps } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getStorage } = require('firebase-admin/storage');
const fs = require('fs');
const path = require('path');

const bucketName = process.argv[2] || 'metodo1dia-app.appspot.com';

function init() {
  if (getApps().length) return;
  const saPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (saPath && fs.existsSync(saPath)) {
    const sa = JSON.parse(fs.readFileSync(saPath, 'utf8'));
    initializeApp({ credential: cert(sa), projectId: 'metodo1dia-app', storageBucket: bucketName });
    return;
  }
  initializeApp({ credential: applicationDefault(), projectId: 'metodo1dia-app', storageBucket: bucketName });
}

async function main() {
  init();
  const db = getFirestore();
  const bucket = getStorage().bucket();
  const seed = JSON.parse(
    fs.readFileSync(path.join(__dirname, 'seed_data.json'), 'utf8'),
  );
  const programId = seed.program.id;
  const audioDirCandidates = [
    path.join(__dirname, 'assets_audio'),
    path.join(__dirname, 'mp3'),
    path.join(__dirname, '..', '..', 'assets', 'audio_programs'),
  ];
  const audioDir = audioDirCandidates.find((d) => fs.existsSync(d));
  if (!audioDir) throw new Error('Pasta de MP3 nao encontrada');

  console.log('Bucket: gs://' + bucketName);
  console.log('MP3 dir: ' + audioDir);

  const { id: _ignore, ...programData } = seed.program;
  await db.collection('programs').doc(programId).set(
    {
      ...programData,
      isPremium: !!programData.premium,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log('OK programs/' + programId);

  const privateMap = {};
  for (const audio of seed.audios) {
    const fileName = path.basename(audio.storagePath);
    const localFile = path.join(audioDir, fileName);
    if (!fs.existsSync(localFile)) throw new Error('MP3 ausente: ' + localFile);

    await bucket.upload(localFile, {
      destination: audio.storagePath,
      metadata: { contentType: 'audio/mpeg', cacheControl: 'public,max-age=3600' },
    });

    const file = bucket.file(audio.storagePath);
    const [signedUrl] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 1000 * 60 * 60 * 24 * 365,
    });
    privateMap[audio.id] = signedUrl;

    const { id, ...data } = audio;
    await db
      .collection('programs')
      .doc(programId)
      .collection('audios')
      .doc(id)
      .set(
        {
          ...data,
          audioUrl: '',
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    console.log('  ok: ' + audio.storagePath);
  }

  await db
    .collection('programs')
    .doc(programId)
    .collection('private')
    .doc('audios')
    .set(privateMap, { merge: true });
  console.log('OK private/audios (' + Object.keys(privateMap).length + ' urls)');
  console.log('Concluido.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});