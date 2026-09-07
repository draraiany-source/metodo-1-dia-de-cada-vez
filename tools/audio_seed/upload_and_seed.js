/**
 * Upload dos 7 MP3s + seed Firestore (Programa 7 Dias).
 *
 * Uso (na pasta tools/audio_seed):
 *   npm i firebase-admin
 *   set GOOGLE_APPLICATION_CREDENTIALS=C:\caminho\serviceAccount.json
 *   node upload_and_seed.js metodo1dia-app.appspot.com
 *
 * Ou com Application Default Credentials (firebase login + gcloud auth).
 */
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const bucketName = process.argv[2] || 'metodo1dia-app.appspot.com';

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  storageBucket: bucketName,
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

async function main() {
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
  if (!audioDir) {
    throw new Error('Pasta de MP3 não encontrada (assets_audio/mp3/assets/audio_programs)');
  }

  console.log(`Bucket: gs://${bucketName}`);
  console.log(`MP3 dir: ${audioDir}`);

  const { id: _ignore, ...programData } = seed.program;
  await db.collection('programs').doc(programId).set(
    {
      ...programData,
      isPremium: !!programData.premium,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`OK programs/${programId}`);

  const privateMap = {};

  for (const audio of seed.audios) {
    const fileName = path.basename(audio.storagePath);
    const localFile = path.join(audioDir, fileName);
    if (!fs.existsSync(localFile)) {
      throw new Error(`MP3 ausente: ${localFile}`);
    }

    await bucket.upload(localFile, {
      destination: audio.storagePath,
      metadata: {
        contentType: 'audio/mpeg',
        cacheControl: 'public,max-age=3600',
      },
    });

    const file = bucket.file(audio.storagePath);
    // URL assinada longa (7 dias) para private map; free também usa getDownloadURL no client.
    const [signedUrl] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 1000 * 60 * 60 * 24 * 365, // 1 ano
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
          audioUrl: '', // free: client usa Storage getDownloadURL(storagePath)
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    console.log(`  ok: ${audio.storagePath}`);
  }

  await db
    .collection('programs')
    .doc(programId)
    .collection('private')
    .doc('audios')
    .set(privateMap, { merge: true });
  console.log(`OK private/audios (${Object.keys(privateMap).length} urls)`);
  console.log('Concluído.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
