/**
 * Seed Programa 7 Dias usando login do Firebase CLI (sem gcloud ADC).
 * Uso: node upload_and_seed.js [bucket]
 */
const { initializeApp, applicationDefault, cert, getApps } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getStorage } = require('firebase-admin/storage');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const os = require('os');

const PROJECT_ID = 'metodo1dia-app';
const bucketName = process.argv[2] || 'metodo1dia-app.firebasestorage.app';

// OAuth client publico do firebase-tools (mesmo do CLI)
const FB_CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const FB_CLIENT_SECRET = 'j9iVZmc2NZrAnyLXhJbE8wwU';

function loadFirebaseCliRefreshToken() {
  const configPath = path.join(
    os.homedir(),
    '.config',
    'configstore',
    'firebase-tools.json',
  );
  if (!fs.existsSync(configPath)) {
    throw new Error('Firebase CLI nao logado. Rode: firebase login');
  }
  const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const refreshToken = cfg.tokens && cfg.tokens.refresh_token;
  if (!refreshToken) {
    throw new Error(
      'Sem refresh_token do Firebase CLI. Rode: firebase login --reauth',
    );
  }
  return refreshToken;
}

/** ADC authorized_user — aceito pelo Firestore Admin SDK. */
function writeTempAdcFromFirebaseCli() {
  const adc = {
    type: 'authorized_user',
    client_id: FB_CLIENT_ID,
    client_secret: FB_CLIENT_SECRET,
    refresh_token: loadFirebaseCliRefreshToken(),
  };
  const tmp = path.join(
    os.tmpdir(),
    'firebase-adc-metodo1dia-' + process.pid + '.json',
  );
  fs.writeFileSync(tmp, JSON.stringify(adc), { encoding: 'utf8', mode: 0o600 });
  process.env.GOOGLE_APPLICATION_CREDENTIALS = tmp;
  process.on('exit', () => {
    try {
      fs.unlinkSync(tmp);
    } catch (_) {}
  });
  return tmp;
}

function gcloudAdcPath() {
  return path.join(
    process.env.APPDATA || path.join(os.homedir(), 'AppData', 'Roaming'),
    'gcloud',
    'application_default_credentials.json',
  );
}

function init() {
  if (getApps().length) return;
  const opts = { projectId: PROJECT_ID, storageBucket: bucketName };
  const saPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (saPath && fs.existsSync(saPath)) {
    const sa = JSON.parse(fs.readFileSync(saPath, 'utf8'));
    if (sa.type === 'service_account') {
      initializeApp({ credential: cert(sa), ...opts });
      return;
    }
    // ADC authorized_user já apontado por env (ex.: gcloud)
    initializeApp({ credential: applicationDefault(), ...opts });
    return;
  }
  const adc = gcloudAdcPath();
  if (fs.existsSync(adc)) {
    process.env.GOOGLE_APPLICATION_CREDENTIALS = adc;
    initializeApp({ credential: applicationDefault(), ...opts });
    return;
  }
  // Fallback legado (Firebase CLI) — pode falhar com invalid_client
  writeTempAdcFromFirebaseCli();
  initializeApp({ credential: applicationDefault(), ...opts });
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

  console.log('Project: ' + PROJECT_ID);
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
      metadata: {
        contentType: 'audio/mpeg',
        cacheControl: 'public,max-age=3600',
        metadata: { firebaseStorageDownloadTokens: crypto.randomUUID() },
      },
    });

    const token =
      (await bucket.file(audio.storagePath).getMetadata())[0].metadata
        .firebaseStorageDownloadTokens;
    const encoded = encodeURIComponent(audio.storagePath);
    const downloadUrl =
      'https://firebasestorage.googleapis.com/v0/b/' +
      bucketName +
      '/o/' +
      encoded +
      '?alt=media&token=' +
      token;
    privateMap[audio.id] = downloadUrl;

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
  console.error(err && err.message ? err.message : err);
  process.exit(1);
});
