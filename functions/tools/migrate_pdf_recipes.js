/**
 * MIGRAÇÃO §28 — pdf_recipes: mover a URL do PDF para o subdocumento privado.
 *
 * O que faz, para cada doc de `pdf_recipes`:
 *   1. Lê `pdfUrl` do documento público (se existir).
 *   2. Grava `pdf_recipes/{id}/private/file` = { pdfUrl } (merge).
 *   3. Remove `pdfUrl` do documento público.
 * Idempotente: docs já migrados (sem pdfUrl público) são ignorados.
 *
 * COMO RODAR (na sua máquina, com credencial admin):
 *   cd functions
 *   npm install            # garante firebase-admin
 *   GOOGLE_APPLICATION_CREDENTIALS=caminho/para/serviceAccount.json \
 *     node tools/migrate_pdf_recipes.js            # dry-run (só mostra)
 *   GOOGLE_APPLICATION_CREDENTIALS=... \
 *     node tools/migrate_pdf_recipes.js --apply    # executa de verdade
 *
 * DEPOIS da migração, faça o deploy das regras/índices/funções:
 *   firebase deploy --only firestore:rules,firestore:indexes,functions
 */
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

const APPLY = process.argv.includes('--apply');

async function main() {
  const snap = await db.collection('pdf_recipes').get();
  console.log(`pdf_recipes: ${snap.size} documento(s). Modo: ${APPLY ? 'APPLY' : 'DRY-RUN'}`);

  let migrated = 0;
  let skipped = 0;

  for (const doc of snap.docs) {
    const data = doc.data();
    const url = data.pdfUrl;
    if (!url) {
      skipped += 1;
      continue; // já migrado ou sem arquivo — nada a fazer
    }
    console.log(`- ${doc.id}: migrando pdfUrl -> private/file`);
    if (APPLY) {
      await doc.ref.collection('private').doc('file').set({ pdfUrl: url }, { merge: true });
      await doc.ref.update({ pdfUrl: admin.firestore.FieldValue.delete() });
    }
    migrated += 1;
  }

  console.log(`Concluído. Migrados: ${migrated} · Ignorados: ${skipped}`);
  if (!APPLY) console.log('Nada foi escrito (dry-run). Rode com --apply para aplicar.');
}

main().catch((e) => {
  console.error('Migração falhou:', e);
  process.exit(1);
});
