/**
 * Seed do Programa 7 Dias no Firestore (+ opcional upload Storage).
 *
 * Uso:
 *   1) Coloque os 7 MP3 em tools/audio_seed/mp3/ com os nomes oficiais
 *   2) firebase login (conta admin do projeto metodo1dia-app)
 *   3) node tools/audio_seed/seed_programa_7_dias.js
 *
 * Variáveis opcionais:
 *   GOOGLE_APPLICATION_CREDENTIALS=path/to/serviceAccount.json
 *   SKIP_UPLOAD=1   — só grava metadados Firestore
 */
const fs = require('fs');
const path = require('path');

const PROGRAM_ID = 'programa_7_dias_um_dia_de_cada_vez';
const STORAGE_PREFIX = 'audio_programs/programa_7_dias';

const DAYS = [
  {
    id: '01_como_vencer_a_procrastinacao',
    day: 1,
    title: 'Como Vencer a Procrastinação',
    description:
      'Aprenda a sair do adiamento e começar com pequenas atitudes possíveis hoje.',
    file: '01_como_vencer_a_procrastinacao.mp3',
  },
  {
    id: '02_como_criar_disciplina',
    day: 2,
    title: 'Como Criar Disciplina',
    description:
      'Entenda como construir disciplina mesmo nos dias em que a motivação estiver baixa.',
    file: '02_como_criar_disciplina.mp3',
  },
  {
    id: '03_como_vencer_a_preguica',
    day: 3,
    title: 'Como Vencer a Preguiça',
    description:
      'Estratégias simples para vencer a inércia e colocar o corpo e a mente em movimento.',
    file: '03_como_vencer_a_preguica.mp3',
  },
  {
    id: '04_como_manter_a_constancia',
    day: 4,
    title: 'Como Manter a Constância',
    description:
      'Descubra como continuar mesmo quando os resultados ainda parecem pequenos.',
    file: '04_como_manter_a_constancia.mp3',
  },
  {
    id: '05_como_voltar_depois_de_errar',
    day: 5,
    title: 'Como Voltar Depois de Errar',
    description:
      'Aprenda a retomar sem culpa e sem abandonar todo o processo por causa de um deslize.',
    file: '05_como_voltar_depois_de_errar.mp3',
  },
  {
    id: '06_como_criar_habitos_saudaveis',
    day: 6,
    title: 'Como Criar Hábitos Saudáveis',
    description:
      'Transforme pequenas escolhas em uma rotina mais saudável e sustentável.',
    file: '06_como_criar_habitos_saudaveis.mp3',
  },
  {
    id: '07_como_acreditar_em_voce',
    day: 7,
    title: 'Como Acreditar em Você',
    description:
      'Fortaleça sua confiança e reconheça que você é capaz de continuar evoluindo.',
    file: '07_como_acreditar_em_voce.mp3',
  },
];

async function main() {
  let admin;
  try {
    admin = require('firebase-admin');
  } catch (_) {
    console.error('Instale firebase-admin: npm i firebase-admin (na pasta tools/audio_seed ou functions)');
    process.exit(1);
  }

  if (!admin.apps.length) {
    admin.initializeApp({
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET || 'metodo1dia-app.appspot.com',
    });
  }

  const db = admin.firestore();
  const bucket = admin.storage().bucket();
  const skipUpload = process.env.SKIP_UPLOAD === '1';
  const mp3Dir = path.join(__dirname, 'mp3');

  const now = admin.firestore.FieldValue.serverTimestamp();

  await db.collection('programs').doc(PROGRAM_ID).set(
    {
      title: 'Programa 7 Dias — Um Dia de Cada Vez',
      description:
        'Sequência de 7 áudios para foco, disciplina, mudança de hábitos, constância e autoconfiança.',
      category: 'Foco, Disciplina e Mudança de Hábitos',
      author: 'Amanda Lopes',
      coverUrl: '',
      active: true,
      premium: false,
      isPremium: false,
      totalDays: 7,
      orderIndex: 0,
      updatedAt: now,
      createdAt: now,
    },
    { merge: true },
  );
  console.log('OK programs/' + PROGRAM_ID);

  const privateMap = {};
  const missing = [];

  for (const day of DAYS) {
    const storagePath = `${STORAGE_PREFIX}/${day.file}`;
    let audioUrl = '';

    const localFile = path.join(mp3Dir, day.file);
    if (!skipUpload && fs.existsSync(localFile)) {
      await bucket.upload(localFile, {
        destination: storagePath,
        metadata: { contentType: 'audio/mpeg', cacheControl: 'public,max-age=3600' },
      });
      const file = bucket.file(storagePath);
      await file.makePublic().catch(() => {});
      audioUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
      privateMap[day.id] = audioUrl;
      console.log('UPLOAD', storagePath);
    } else {
      missing.push(day.file);
      console.warn('MP3 ausente:', day.file);
    }

    await db
      .collection('programs')
      .doc(PROGRAM_ID)
      .collection('audios')
      .doc(day.id)
      .set(
        {
          day: day.day,
          order: day.day,
          title: day.title,
          description: day.description,
          audioUrl: audioUrl,
          storagePath,
          coverUrl: '',
          durationSeconds: 0,
          active: true,
          premium: false,
          updatedAt: now,
        },
        { merge: true },
      );
  }

  if (Object.keys(privateMap).length > 0) {
    await db
      .collection('programs')
      .doc(PROGRAM_ID)
      .collection('private')
      .doc('audios')
      .set(privateMap, { merge: true });
    console.log('OK private/audios (' + Object.keys(privateMap).length + ' urls)');
  }

  console.log('\nResumo:');
  console.log('  Metadados Firestore: OK');
  console.log('  MP3 enviados:', Object.keys(privateMap).length);
  console.log('  MP3 faltando:', missing.length ? missing.join(', ') : 'nenhum');
  if (missing.length) {
    console.log('\nColoque os MP3 em tools/audio_seed/mp3/ e rode de novo.');
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
