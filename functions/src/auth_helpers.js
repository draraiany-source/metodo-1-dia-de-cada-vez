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

/**
 * Premium ativo: isPremium == true e premiumExpiresAt no futuro (se existir).
 */
function isPremiumActive(userData) {
  if (!userData || userData.isPremium !== true) return false;
  const raw = userData.premiumExpiresAt;
  if (!raw) return true;
  let exp;
  if (typeof raw.toDate === 'function') exp = raw.toDate();
  else if (raw instanceof Date) exp = raw;
  else if (typeof raw === 'string') exp = new Date(raw);
  else if (raw._seconds) exp = new Date(raw._seconds * 1000);
  else return true;
  return exp.getTime() > Date.now();
}

module.exports = {
  setCors,
  handleOptions,
  requireAuth,
  requireAdmin,
  verifyAppCheck,
  isPremiumActive,
};
