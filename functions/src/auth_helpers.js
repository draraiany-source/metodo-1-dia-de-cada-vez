const admin = require('firebase-admin');

/**
 * Helpers de autenticação / App Check para HTTPS Cloud Functions.
 *
 * ENFORCE_APP_CHECK=true → exige X-Firebase-AppCheck válido.
 * Sem a flag, o token é verificado quando presente (modo transição).
 */

function setCors(res, extraHeaders = []) {
  const allow = [
    'Content-Type',
    'Authorization',
    'X-Firebase-AppCheck',
    ...extraHeaders,
  ];
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', allow.join(', '));
}

function handleOptions(req, res) {
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

/**
 * Verifica Bearer ID token. Retorna uid ou responde 401 e retorna null.
 */
async function requireAuth(req, res) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  if (!token) {
    res.status(401).json({ error: 'Não autenticada.' });
    return null;
  }
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    return decoded.uid;
  } catch (e) {
    console.warn('verifyIdToken falhou', e.message);
    res.status(401).json({ error: 'Token inválido ou expirado.' });
    return null;
  }
}

/**
 * Exige membership em `admins/{uid}` (Admin Técnico).
 */
async function requireAdmin(uid, res) {
  const snap = await admin.firestore().collection('admins').doc(uid).get();
  if (!snap.exists) {
    res.status(403).json({ success: false, message: 'Acesso restrito ao Admin Técnico.' });
    return false;
  }
  return true;
}

/**
 * Verifica App Check. Em produção (ENFORCE_APP_CHECK=true) é obrigatório.
 */
async function verifyAppCheck(req, res) {
  const enforce =
    process.env.ENFORCE_APP_CHECK === 'true' ||
    process.env.ENFORCE_APP_CHECK === '1';
  const appCheckToken = req.header('X-Firebase-AppCheck');

  if (!appCheckToken) {
    if (enforce) {
      res.status(401).json({ error: 'App Check obrigatório.' });
      return false;
    }
    return true;
  }

  try {
    await admin.appCheck().verifyToken(appCheckToken);
    return true;
  } catch (e) {
    console.warn('App Check inválido', e.message);
    if (enforce) {
      res.status(401).json({ error: 'App Check inválido.' });
      return false;
    }
    // Em transição: loga e segue se houver Bearer válido.
    return true;
  }
}

function toDate(raw) {
  if (!raw) return null;
  if (typeof raw.toDate === 'function') return raw.toDate();
  if (raw instanceof Date) return raw;
  if (typeof raw === 'string') return new Date(raw);
  if (raw._seconds) return new Date(raw._seconds * 1000);
  return null;
}

/**
 * Premium ativo: isPremium == true e premiumExpiresAt no futuro (se existir).
 */
function isPremiumActive(userData) {
  if (!userData || userData.isPremium !== true) return false;
  const raw = userData.premiumExpiresAt;
  if (!raw) return true;
  const exp = toDate(raw);
  if (!exp) return true;
  return exp.getTime() > Date.now();
}

/**
 * Premium efetivo: flag do usuário OU assinatura/teste válido em subscriptions/{uid}.
 */
async function hasPremiumAccess(uid, userData) {
  if (isPremiumActive(userData)) return true;
  if (!uid) return false;
  const snap = await admin.firestore().collection('subscriptions').doc(uid).get();
  if (!snap.exists) return false;
  const d = snap.data() || {};
  const status = String(d.status || '').toLowerCase();
  if (status === 'active') return true;
  if (status === 'trial' || status === 'trialing') {
    const end = toDate(d.trialEndsAt);
    return !!(end && end.getTime() > Date.now());
  }
  return false;
}

module.exports = {
  setCors,
  handleOptions,
  requireAuth,
  requireAdmin,
  verifyAppCheck,
  isPremiumActive,
  hasPremiumAccess,
};
