/**
 * Grava (merge) os 3 Shorts da biblioteca na coleção Firestore `videos`.
 * Não apaga documentos existentes. Só cria/atualiza os ids yt_*.
 *
 * Uso (na raiz do repo, com Firebase CLI autenticado):
 *   node tools/upsert_youtube_shorts.cjs
 */
const fs = require('fs');
const path = require('path');

async function main() {
  const admin = require(
    path.join(__dirname, '..', 'functions', 'node_modules', 'firebase-admin'),
  );

  if (!admin.apps.length) {
    admin.initializeApp({ projectId: 'metodo1dia-app' });
  }

  const seedPath = path.join(
    __dirname,
    '..',
    'assets',
    'content',
    'videos_biblioteca.json',
  );
  const seed = JSON.parse(fs.readFileSync(seedPath, 'utf8'));
  const videos = (seed.videos || []).filter((v) =>
    String(v.id || '').startsWith('yt_'),
  );
  if (videos.length === 0) {
    throw new Error('Nenhum vídeo yt_* no seed.');
  }

  const db = admin.firestore();
  const agora = new Date().toISOString();

  for (const v of videos) {
    const payload = {
      category: v.category || 'metodo1Dia',
      subcategory: v.subcategory || 'shorts',
      name: v.name,
      description: v.description || '',
      teacher: v.teacher || 'Amanda Lopes',
      thumbnailUrl: v.thumbnailUrl || '',
      youtubeUrl: v.youtubeUrl,
      videoId: v.videoId || '',
      durationSeconds: v.durationSeconds || 0,
      level: v.level || 'iniciante',
      isPremium: Boolean(v.isPremium),
      order: v.order ?? 0,
      active: v.active !== false,
      publishedAt: v.publishedAt || agora,
      createdAt: v.publishedAt || agora,
      updatedAt: agora,
    };
    await db.collection('videos').doc(v.id).set(payload, { merge: true });
    console.log('upsert ok', v.id, v.videoId);
  }
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
