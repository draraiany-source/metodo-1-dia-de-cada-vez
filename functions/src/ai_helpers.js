const admin = require('firebase-admin');

/** ~1.2 MB de binário após decode; base64 cresce ~4/3. */
const MAX_IMAGE_BASE64_CHARS = 1_800_000;
const MAX_AMANDA_MESSAGE_CHARS = 2000;
const MAX_ASSISTANT_MESSAGE_CHARS = 2000;

const AI_QUOTA = {
  amandaChat: 40,
  calorieVision: 15,
  accompanimentAi: 40,
};

function getOpenAiKey() {
  try {
    const cfg = require('firebase-functions').config();
    if (cfg.openai && cfg.openai.key) return cfg.openai.key;
  } catch (_) {
    // config() ausente em emulador/testes
  }
  return process.env.OPENAI_API_KEY || '';
}

function requirePost(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Use POST.', code: 'method_not_allowed' });
    return false;
  }
  return true;
}

function stripDataUrl(imageBase64) {
  if (typeof imageBase64 !== 'string') return '';
  const raw = imageBase64.trim();
  if (!raw) return '';
  const comma = raw.indexOf(',');
  if (raw.startsWith('data:') && comma !== -1) {
    return raw.slice(comma + 1);
  }
  return raw;
}

/**
 * Cota horária por UID (Admin SDK, fora das rules do cliente).
 * Falha aberta se o Firestore de cota cair — não derruba a Function.
 */
async function consumeAiQuota(db, uid, kind) {
  const limit = AI_QUOTA[kind] || 30;
  try {
    const hour = new Date().toISOString().slice(0, 13);
    const ref = db.collection('ai_usage').doc(`${uid}_${kind}_${hour}`);
    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const count = snap.exists ? Number(snap.data().count || 0) : 0;
      if (count >= limit) return false;
      tx.set(
        ref,
        {
          uid,
          kind,
          hour,
          count: count + 1,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return true;
    });
  } catch (e) {
    console.warn('ai quota check failed', e && e.message);
    return true;
  }
}

async function openaiChat(apiKey, body, timeoutMs = 25000) {
  const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(timeoutMs),
  });
  let data = {};
  try {
    data = await openaiRes.json();
  } catch (_) {
    data = {};
  }
  return { ok: openaiRes.ok, status: openaiRes.status, data };
}

module.exports = {
  MAX_IMAGE_BASE64_CHARS,
  MAX_AMANDA_MESSAGE_CHARS,
  MAX_ASSISTANT_MESSAGE_CHARS,
  AI_QUOTA,
  getOpenAiKey,
  requirePost,
  stripDataUrl,
  consumeAiQuota,
  openaiChat,
};
