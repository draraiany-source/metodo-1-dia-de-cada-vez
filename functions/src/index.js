const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {
  setCors,
  handleOptions,
  requireAuth,
  requireAdmin,
  requirePersonalOrAdmin,
  verifyAppCheck,
  hasPremiumAccess,
} = require('./auth_helpers');
const {
  MAX_IMAGE_BASE64_CHARS,
  MAX_AMANDA_MESSAGE_CHARS,
  MAX_ASSISTANT_MESSAGE_CHARS,
  getOpenAiKey,
  requirePost,
  stripDataUrl,
  consumeAiQuota,
  openaiChat,
} = require('./ai_helpers');

admin.initializeApp();
const db = admin.firestore();

/** Gen-1 defaults explícitos: 60s / 256MB / us-central1. */
const httpsAi = functions
  .runWith({ timeoutSeconds: 60, memory: '256MB' })
  .https.onRequest;

exports.onWorkoutCompleted = functions.firestore
  .document('workout_history/{historyId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = data.userId;
    const xp = data.xp || 50;

    const userRef = db.collection('users').doc(userId);
    await userRef.set({
      xp: admin.firestore.FieldValue.increment(xp),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return null;
  });

exports.onRunningSessionCreated = functions.firestore
  .document('running_sessions/{sessionId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = data.userId;

    await db.collection('users').doc(userId).set({
      totalKm: admin.firestore.FieldValue.increment(data.distanceKm || 0),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return null;
  });

// ---------------------------------------------------------------------------
// Sistema de Indicação (Módulo 7) — concede a recompensa no servidor.
//
// O app só escreve `referredByCode` no próprio doc ao criar a conta; quem
// GANHA a recompensa é sempre resolvido e creditado aqui, nunca pelo
// cliente (evita autoconcessão de XP/moedas).
// ---------------------------------------------------------------------------
const REFERRAL_REWARD_XP = 100;
const REFERRAL_REWARD_COINS = 50;

exports.onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const code = data.referredByCode;
    if (!code) return null;

    const codeDoc = await db.collection('referral_codes').doc(code).get();
    if (!codeDoc.exists) return null;

    const ownerUid = codeDoc.data().ownerUid;
    if (!ownerUid || ownerUid === context.params.userId) return null; // não pode indicar a si mesma

    await db.collection('users').doc(ownerUid).set({
      xp: admin.firestore.FieldValue.increment(REFERRAL_REWARD_XP),
      coins: admin.firestore.FieldValue.increment(REFERRAL_REWARD_COINS),
      referralCount: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return null;
  });

// ---------------------------------------------------------------------------
// Amanda IA — proxy seguro para a OpenAI.
//
// A chave da OpenAI fica SOMENTE aqui no servidor (configure com:
//   firebase functions:config:set openai.key="sk-..."   (Gen 1)
// ou use variáveis de ambiente / Secret Manager em Gen 2).
//
// O app cliente chama esta função em AppConstants.amandaFunctionUrl.
// ---------------------------------------------------------------------------
const AMANDA_SYSTEM_PROMPT = `
Você é a Amanda, personal trainer virtual do app "Método 1 Dia de Cada Vez".
Personalidade: acolhedora, motivadora, objetiva, feminina, sem julgamentos.
Fale em português do Brasil, de forma calorosa e breve.
Foco: emagrecimento saudável, treino, corrida, alimentação, hábitos e constância.
Limite importante: você NÃO substitui médico, nutricionista ou psicólogo.
Quando o assunto for clínico, emocional grave ou nutrição específica,
oriente gentilmente a procurar um profissional.
`;

/**
 * Monta o conteúdo enviado ao modelo, incluindo perfil físico e contexto de
 * gamificação quando o app os enviar (retrocompatível: campos são opcionais).
 */
function buildUserContent(message, userName, profile, context) {
  const linhas = [`A usuária ${userName || 'da usuária'} disse: ${message}`];

  if (profile) {
    linhas.push(
      '',
      'PERFIL FÍSICO:',
      `- Idade: ${profile.idade} anos`,
      `- Peso: ${profile.pesoKg} kg | Altura: ${profile.alturaM} m`,
      `- Sexo: ${profile.sexo}`,
      `- Objetivo: ${profile.objetivo}`,
      `- Nível: ${profile.nivel}`,
      `- Treinos/semana: ${profile.diasPorSemana}`,
      `- Limitações físicas: ${(profile.limitacoes || []).join(', ') || 'nenhuma'}`
    );
  }

  if (context) {
    linhas.push(
      '',
      'CONTEXTO:',
      `- Sequência (streak): ${context.streak} dias`,
      `- Nível de gamificação: ${context.nivel}`,
      `- Moedas: ${context.moedas}`,
      `- Missões prontas para resgate: ${context.missoesProntas}`,
      `- Treinos nesta semana: ${context.treinosNaSemana}`,
      `- Histórico de peso (kg): ${(context.historicoPeso || []).join(', ')}`,
      `- Passos hoje: ${context.passosHoje || 0}`,
      `- Calorias hoje: ${context.caloriasHoje || 0} kcal`
    );
    linhas.push(
      '',
      'Use o perfil e o contexto para personalizar. Respeite as limitações físicas ao sugerir exercícios. Se o peso estiver estável há ~3 semanas, aponte o platô e sugira ajustes.'
    );
  }

  return linhas.join('\n');
}


exports.amandaChat = httpsAi(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;
  if (!requirePost(req, res)) return;

  const uid = await requireAuth(req, res);
  if (!uid) return;
  if (!(await verifyAppCheck(req, res))) return;

  try {
    const { message, userName, profile, context } = req.body || {};
    const text = typeof message === 'string' ? message.trim() : '';
    if (!text) {
      return res.status(400).json({ error: 'Mensagem vazia.', code: 'empty_message' });
    }
    if (text.length > MAX_AMANDA_MESSAGE_CHARS) {
      return res.status(400).json({
        error: 'Mensagem longa demais. Envie um texto mais curto.',
        code: 'message_too_long',
      });
    }

    if (!(await consumeAiQuota(db, uid, 'amandaChat'))) {
      return res.status(429).json({
        error: 'Muitas perguntas neste momento. Aguarde alguns minutos e tente de novo.',
        code: 'rate_limited',
      });
    }

    const apiKey = getOpenAiKey();
    if (!apiKey) {
      console.warn('amandaChat: OPENAI_API_KEY ausente');
      return res.status(503).json({
        error: 'A Amanda IA na nuvem ainda não está configurada no servidor.',
        code: 'openai_not_configured',
      });
    }

    const { ok, status, data } = await openaiChat(apiKey, {
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: AMANDA_SYSTEM_PROMPT },
        {
          role: 'user',
          content: buildUserContent(text, userName, profile, context),
        },
      ],
      max_tokens: 300,
      temperature: 0.8,
    });

    const reply =
      data.choices && data.choices[0] && data.choices[0].message
        ? data.choices[0].message.content
        : '';

    if (!ok || !reply.trim()) {
      console.error('amandaChat openai', status, data && data.error);
      return res.status(502).json({
        error: 'A IA não conseguiu responder agora. Tente novamente em instantes.',
        code: 'openai_error',
      });
    }

    return res.status(200).json({ reply: reply.trim() });
  } catch (e) {
    console.error('amandaChat error', e && e.name, e && e.message);
    const timedOut = e && (e.name === 'TimeoutError' || e.name === 'AbortError');
    return res.status(timedOut ? 504 : 500).json({
      error: timedOut
        ? 'A resposta demorou demais. Tente novamente.'
        : 'Erro temporário ao preparar a resposta. Tente novamente.',
      code: timedOut ? 'timeout' : 'internal',
    });
  }
});

// ---------------------------------------------------------------------------
// Calorias por foto — proxy seguro para a OpenAI Vision.
//
// Mesmo padrão da Amanda: a chave da OpenAI fica SOMENTE aqui no servidor.
// Reaproveita a mesma chave (functions.config().openai.key /
// process.env.OPENAI_API_KEY) — não precisa configurar nada novo se a
// Amanda já estiver funcionando.
//
// O app cliente chama esta função em AppConfig.calorieVisionFunctionUrl.
// ---------------------------------------------------------------------------
const CALORIE_VISION_PROMPT = `
Você é um assistente que estima calorias e macronutrientes a partir de uma foto de comida.
Responda SOMENTE com um JSON válido, sem texto antes ou depois, neste formato:
{
  "foods": [
    {
      "name": "nome do alimento em português",
      "estimated_grams": 120,
      "calories": 156,
      "protein_g": 3.0,
      "carbs_g": 34.0,
      "fat_g": 0.4,
      "fiber_g": 0.5,
      "confidence": 0.86
    }
  ],
  "totals": {
    "calories": 520,
    "protein_g": 32,
    "carbs_g": 61,
    "fat_g": 17,
    "fiber_g": 7
  },
  "detalhe": "explicação breve em 1 frase"
}
Identifique cada alimento visível no prato (mínimo 1). Valores são ESTIMATIVAS.
confidence é de 0 a 1. Seja conservador nas porções. Sempre devolva números.
Se não identificar nada, retorne foods: [] e detalhe explicando.
`;

function normalizeCalorieVisionResponse(parsed) {
  if (parsed && Array.isArray(parsed.foods)) {
    const foods = parsed.foods.map((f) => ({
      name: (f && f.name) || 'Alimento',
      estimated_grams: Number(f && f.estimated_grams) || 100,
      calories: Number(f && (f.calories != null ? f.calories : f.kcal)) || 0,
      protein_g: Number(f && (f.protein_g != null ? f.protein_g : f.protein)) || 0,
      carbs_g: Number(f && (f.carbs_g != null ? f.carbs_g : f.carbs)) || 0,
      fat_g: Number(f && (f.fat_g != null ? f.fat_g : f.fat)) || 0,
      fiber_g: Number(f && (f.fiber_g != null ? f.fiber_g : f.fiber)) || 0,
      confidence: Math.min(
        1,
        Math.max(0, Number(f && f.confidence) || 0.5),
      ),
    }));
    const totalsFromFoods = foods.reduce(
      (acc, f) => ({
        calories: acc.calories + (f.calories || 0),
        protein_g: acc.protein_g + (f.protein_g || 0),
        carbs_g: acc.carbs_g + (f.carbs_g || 0),
        fat_g: acc.fat_g + (f.fat_g || 0),
        fiber_g: acc.fiber_g + (f.fiber_g || 0),
      }),
      { calories: 0, protein_g: 0, carbs_g: 0, fat_g: 0, fiber_g: 0 },
    );
    const t = (parsed && parsed.totals) || {};
    const totals = {
      calories: Number(t.calories) || totalsFromFoods.calories,
      protein_g: Number(t.protein_g) || totalsFromFoods.protein_g,
      carbs_g: Number(t.carbs_g) || totalsFromFoods.carbs_g,
      fat_g: Number(t.fat_g) || totalsFromFoods.fat_g,
      fiber_g: Number(t.fiber_g) || totalsFromFoods.fiber_g,
    };
    // Compat legado (tela antiga): agregados no topo.
    return {
      foods,
      totals,
      name: foods.map((f) => f.name).join(' + ') || 'Refeição',
      kcal: Math.round(totals.calories),
      protein: Math.round(totals.protein_g),
      carbs: Math.round(totals.carbs_g),
      fat: Math.round(totals.fat_g),
      confidence:
        foods.length === 0
          ? 'baixa'
          : foods.every((f) => f.confidence >= 0.75)
            ? 'alta'
            : foods.every((f) => f.confidence >= 0.45)
              ? 'media'
              : 'baixa',
      detalhe: (parsed && parsed.detalhe) || '',
    };
  }

  // Formato legado (prato único).
  return {
    foods: [
      {
        name: (parsed && parsed.name) || 'Refeição',
        estimated_grams: Number(parsed && parsed.estimated_grams) || 250,
        calories: Number(parsed && parsed.kcal) || 0,
        protein_g: Number(parsed && parsed.protein) || 0,
        carbs_g: Number(parsed && parsed.carbs) || 0,
        fat_g: Number(parsed && parsed.fat) || 0,
        fiber_g: Number(parsed && parsed.fiber) || 0,
        confidence:
          parsed && parsed.confidence === 'alta'
            ? 0.85
            : parsed && parsed.confidence === 'media'
              ? 0.6
              : 0.35,
      },
    ],
    totals: {
      calories: Number(parsed && parsed.kcal) || 0,
      protein_g: Number(parsed && parsed.protein) || 0,
      carbs_g: Number(parsed && parsed.carbs) || 0,
      fat_g: Number(parsed && parsed.fat) || 0,
      fiber_g: Number(parsed && parsed.fiber) || 0,
    },
    name: (parsed && parsed.name) || 'Refeição',
    kcal: Number(parsed && parsed.kcal) || 0,
    protein: Number(parsed && parsed.protein) || 0,
    carbs: Number(parsed && parsed.carbs) || 0,
    fat: Number(parsed && parsed.fat) || 0,
    confidence: (parsed && parsed.confidence) || 'baixa',
    detalhe: (parsed && parsed.detalhe) || '',
  };
}

exports.calorieVision = httpsAi(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;
  if (!requirePost(req, res)) return;

  const uid = await requireAuth(req, res);
  if (!uid) return;
  if (!(await verifyAppCheck(req, res))) return;

  try {
    const imageBase64 = stripDataUrl((req.body || {}).imageBase64);
    if (!imageBase64) {
      return res.status(400).json({ error: 'Imagem ausente.', code: 'image_missing' });
    }
    if (imageBase64.length > MAX_IMAGE_BASE64_CHARS) {
      return res.status(413).json({
        error: 'A foto está grande demais. Tire outra com menos zoom ou escolha uma imagem menor.',
        code: 'image_too_large',
      });
    }

    if (!(await consumeAiQuota(db, uid, 'calorieVision'))) {
      return res.status(429).json({
        error: 'Muitas análises neste momento. Aguarde alguns minutos e tente de novo.',
        code: 'rate_limited',
      });
    }

    const apiKey = getOpenAiKey();
    if (!apiKey) {
      console.warn('calorieVision: OPENAI_API_KEY ausente');
      return res.status(503).json({
        error: 'A análise de calorias por foto ainda não está configurada no servidor.',
        code: 'openai_not_configured',
      });
    }

    const { ok, status, data } = await openaiChat(apiKey, {
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: CALORIE_VISION_PROMPT },
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text:
                'Identifique os alimentos desta refeição e estime gramas, calorias e macros.',
            },
            {
              type: 'image_url',
              image_url: { url: `data:image/jpeg;base64,${imageBase64}` },
            },
          ],
        },
      ],
      max_tokens: 900,
      temperature: 0.3,
    }, 40000);

    if (!ok) {
      console.error('calorieVision openai', status, data && data.error);
      return res.status(502).json({
        error: 'A análise da imagem falhou. Tente outra foto em instantes.',
        code: 'openai_error',
      });
    }

    const raw =
      data.choices && data.choices[0] && data.choices[0].message
        ? data.choices[0].message.content
        : '';

    let parsed;
    try {
      const cleaned = String(raw || '').replace(/```json|```/g, '').trim();
      parsed = JSON.parse(cleaned);
    } catch (_) {
      console.error('calorieVision parse');
      return res.status(502).json({
        error: 'Não foi possível interpretar a análise. Tente outra foto.',
        code: 'parse_error',
      });
    }

    return res.status(200).json(normalizeCalorieVisionResponse(parsed));
  } catch (e) {
    console.error('calorieVision error', e && e.name, e && e.message);
    const timedOut = e && (e.name === 'TimeoutError' || e.name === 'AbortError');
    return res.status(timedOut ? 504 : 500).json({
      error: timedOut
        ? 'A análise demorou demais. Verifique a internet e tente novamente.'
        : 'Não conseguimos analisar essa imagem. Tente outra foto com os alimentos visíveis.',
      code: timedOut ? 'timeout' : 'internal',
    });
  }
});

// ---------------------------------------------------------------------------
// Resgate de cupons (Módulo 8) — a ÚNICA forma de creditar a recompensa de
// um cupom. Exige token de autenticação (o app manda no header Authorization)
// pra sabermos QUEM está resgatando, e usa transação pra não deixar
// ultrapassar o limite de uso mesmo com resgates simultâneos.
// ---------------------------------------------------------------------------
exports.redeemCoupon = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;

  try {
    const uid = await requireAuth(req, res);
    if (!uid) return;
    if (!(await verifyAppCheck(req, res))) return;

    const code = (req.body && req.body.code || '').toUpperCase().trim();
    if (!code) {
      return res.status(400).json({ success: false, message: 'Código ausente.' });
    }

    const couponRef = db.collection('coupons').doc(code);
    const redemptionRef = db.collection('coupon_redemptions').doc(`${uid}_${code}`);
    const userRef = db.collection('users').doc(uid);

    const result = await db.runTransaction(async (tx) => {
      const [couponSnap, redemptionSnap, userSnap] = await Promise.all([
        tx.get(couponRef),
        tx.get(redemptionRef),
        tx.get(userRef),
      ]);

      if (!couponSnap.exists) return { success: false, message: 'Cupom não encontrado.' };
      if (redemptionSnap.exists) return { success: false, message: 'Você já resgatou este cupom.' };

      const c = couponSnap.data();
      if (c.active === false) return { success: false, message: 'Cupom inativo.' };
      if (c.expiresAt && new Date(c.expiresAt) < new Date()) {
        return { success: false, message: 'Cupom expirado.' };
      }
      if ((c.usageCount || 0) >= (c.usageLimit || 1)) {
        return { success: false, message: 'Cupom esgotado.' };
      }

      const userUpdates = {
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (c.reward === 'xp') {
        userUpdates.xp = admin.firestore.FieldValue.increment(c.value || 0);
      } else if (c.reward === 'coins') {
        userUpdates.coins = admin.firestore.FieldValue.increment(c.value || 0);
      } else if (c.reward === 'premiumDays') {
        const days = Number(c.value) || 0;
        const now = new Date();
        let base = now;
        const existing = userSnap.exists ? userSnap.data().premiumExpiresAt : null;
        if (existing) {
          let exp;
          if (typeof existing.toDate === 'function') exp = existing.toDate();
          else if (existing instanceof Date) exp = existing;
          else if (typeof existing === 'string') exp = new Date(existing);
          else if (existing._seconds) exp = new Date(existing._seconds * 1000);
          if (exp && !isNaN(exp.getTime()) && exp > now) base = exp;
        }
        const newExpiry = new Date(base.getTime() + days * 24 * 60 * 60 * 1000);
        userUpdates.isPremium = true;
        userUpdates.premiumExpiresAt = newExpiry.toISOString();
      } else {
        userUpdates.coins = admin.firestore.FieldValue.increment(c.value || 0);
      }

      tx.update(couponRef, { usageCount: admin.firestore.FieldValue.increment(1) });
      tx.set(redemptionRef, { uid, code, redeemedAt: admin.firestore.FieldValue.serverTimestamp() });
      tx.set(userRef, userUpdates, { merge: true });

      return {
        success: true,
        message: `Cupom resgatado! +${c.value} ${c.reward === 'xp' ? 'XP' : c.reward === 'premiumDays' ? 'dias Premium' : 'moedas'} 🎉`,
      };
    });

    return res.status(200).json(result);
  } catch (e) {
    console.error('redeemCoupon error', e);
    return res.status(200).json({ success: false, message: 'Não foi possível resgatar agora.' });
  }
});

// ---------------------------------------------------------------------------
// Streaming de vídeo/áudio — resolve a URL real sob demanda.
//
// A URL de streaming NUNCA fica no documento público `videos/{id}` (que
// qualquer usuária logada pode ler). Ela mora em `videos/{id}/private/stream`,
// com `allow read: if false` — só esta function (Admin SDK) acessa. Isso é
// o que torna "Premium" uma proteção de verdade, não só um botão escondido.
// ---------------------------------------------------------------------------
exports.getVideoUrl = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;

  try {
    const uid = await requireAuth(req, res);
    if (!uid) return;
    if (!(await verifyAppCheck(req, res))) return;

    const videoId = req.body && req.body.videoId;
    if (!videoId) return res.status(400).json({ error: 'videoId ausente.' });

    const videoSnap = await db.collection('videos').doc(videoId).get();
    if (!videoSnap.exists || videoSnap.data().active === false) {
      return res.status(404).json({ error: 'Vídeo não encontrado.' });
    }
    const video = videoSnap.data();

    if (video.isPremium) {
      const userSnap = await db.collection('users').doc(uid).get();
      if (!(await hasPremiumAccess(uid, userSnap.exists ? userSnap.data() : null))) {
        console.warn('acesso Premium negado', { uid, collection: 'videos', docId: videoId });
        return res.status(403).json({ error: 'Conteúdo exclusivo para assinantes Premium.' });
      }
    }

    const streamSnap = await db
      .collection('videos').doc(videoId)
      .collection('private').doc('stream')
      .get();
    if (!streamSnap.exists || !streamSnap.data().videoUrl) {
      return res.status(404).json({ error: 'URL de streaming não configurada.' });
    }

    return res.status(200).json({ url: streamSnap.data().videoUrl });
  } catch (e) {
    console.error('getVideoUrl error', e);
    return res.status(500).json({ error: 'Erro ao resolver o vídeo.' });
  }
});

// ---------------------------------------------------------------------------
// Resolução genérica de conteúdo protegido — mesma lógica do getVideoUrl,
// generalizada pra qualquer coleção nova que precise do padrão "metadados
// públicos + arquivo privado" (e-books hoje; cursos/outros no futuro),
// sem duplicar a função pra cada tipo de conteúdo novo.
//
// Whitelist de coleções permitidas — nunca aceita um nome de coleção
// arbitrário vindo do cliente, por segurança.
// ---------------------------------------------------------------------------
const CONTENT_COLLECTIONS = {
  ebooks: { privateDoc: 'file', urlField: 'fileUrl' },
  courses: { privateDoc: 'lessons', urlField: null }, // retorna o mapa inteiro
  audio_courses: { privateDoc: 'chapters', urlField: null }, // idem — mapa chapterId->url
  pdf_recipes: { privateDoc: 'file', urlField: 'pdfUrl' }, // arquivo isolado em /private/file
  programs: { privateDoc: 'audios', urlField: null }, // Programa 7 Dias etc. — mapa audioId->url
};

exports.getContentUrl = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;

  try {
    const uid = await requireAuth(req, res);
    if (!uid) return;
    if (!(await verifyAppCheck(req, res))) return;

    const { collection, docId } = req.body || {};
    const config = CONTENT_COLLECTIONS[collection];
    if (!config || !docId) {
      return res.status(400).json({ error: 'Parâmetros inválidos.' });
    }

    const docSnap = await db.collection(collection).doc(docId).get();
    if (!docSnap.exists || docSnap.data().active === false) {
      return res.status(404).json({ error: 'Conteúdo não encontrado.' });
    }
    const content = docSnap.data();

    if (content.isPremium || content.premium === true) {
      const userSnap = await db.collection('users').doc(uid).get();
      if (!(await hasPremiumAccess(uid, userSnap.exists ? userSnap.data() : null))) {
        console.warn('acesso Premium negado', { uid, collection, docId });
        return res.status(403).json({ error: 'Conteúdo exclusivo para assinantes Premium.' });
      }
    }

    const privateSnap = await db
      .collection(collection).doc(docId)
      .collection('private').doc(config.privateDoc)
      .get();
    if (!privateSnap.exists) {
      return res.status(404).json({ error: 'Arquivo não configurado.' });
    }

    // Alguns tipos (ex.: cursos) têm várias URLs (uma por aula) em vez de uma só.
    if (config.urlField) {
      const url = privateSnap.data()[config.urlField];
      if (!url) return res.status(404).json({ error: 'Arquivo não configurado.' });
      return res.status(200).json({ url });
    }
    return res.status(200).json({ data: privateSnap.data() });
  } catch (e) {
    console.error('getContentUrl error', e);
    return res.status(500).json({ error: 'Erro ao resolver o conteúdo.' });
  }
});

// ---------------------------------------------------------------------------
// IA assistente da Personal — NÃO substitui a Amanda, NÃO diagnostica.
// ---------------------------------------------------------------------------
const ACCOMPANIMENT_AI_PROMPT = `
Você é um assistente da Personal Amanda no app Método 1 Dia de Cada Vez.
Regras obrigatórias:
- Nunca diagnostique doenças nem prescreva medicamentos.
- Nunca afirme que uma condição médica está confirmada.
- Nunca invente peso, medida, treino, lesão, medicamento ou frequência.
- Se faltar dado, diga: "Não há informação cadastrada."
- Use apenas os dados enviados no JSON.
- Frases de atenção: "Esse relato merece atenção antes da progressão do treino."
- Você organiza, resume e sugere. A decisão final é da Amanda.
- Não envie mensagem nem publique treino.
Responda em português do Brasil, objetiva e acolhedora.
`;

const PERSONAL_ONLY_AI_ACTIONS = new Set([
  'reply_suggestion',
  'summarize_chat',
]);
const ANY_AUTH_AI_ACTIONS = new Set([
  'student_assistant',
  'anamnesis_summary',
]);

async function callOpenAi(system, userContent, maxTokens = 700) {
  const apiKey = getOpenAiKey();
  if (!apiKey) return { configured: false, text: null };
  const { ok, status, data } = await openaiChat(apiKey, {
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: system },
      { role: 'user', content: userContent },
    ],
    max_tokens: maxTokens,
    temperature: 0.4,
  });
  if (!ok) {
    console.error('accompaniment openai', status, data && data.error);
    return { configured: true, text: null, status };
  }
  const text =
    data.choices && data.choices[0] && data.choices[0].message
      ? data.choices[0].message.content
      : null;
  return { configured: true, text };
}

exports.accompanimentAi = httpsAi(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;
  if (!requirePost(req, res)) return;
  const uid = await requireAuth(req, res);
  if (!uid) return;
  if (!(await verifyAppCheck(req, res))) return;

  try {
    const body = req.body || {};
    const action = String(body.action || '').trim();
    if (!action) {
      return res.status(400).json({ error: 'Ação ausente.', code: 'action_missing' });
    }
    if (PERSONAL_ONLY_AI_ACTIONS.has(action)) {
      if (!(await requirePersonalOrAdmin(uid, res))) return;
    } else if (!ANY_AUTH_AI_ACTIONS.has(action)) {
      return res.status(400).json({ error: 'Ação inválida.', code: 'invalid_action' });
    }

    const payload = { ...body };
    delete payload.action;
    if (action === 'student_assistant') {
      const message = typeof payload.message === 'string' ? payload.message.trim() : '';
      if (!message) {
        return res.status(400).json({ error: 'Mensagem vazia.', code: 'empty_message' });
      }
      if (message.length > MAX_ASSISTANT_MESSAGE_CHARS) {
        return res.status(400).json({
          error: 'Mensagem longa demais. Envie um texto mais curto.',
          code: 'message_too_long',
        });
      }
      payload.message = message;
    }

    if (!(await consumeAiQuota(db, uid, 'accompanimentAi'))) {
      return res.status(429).json({
        error: 'Muitas solicitações neste momento. Aguarde alguns minutos.',
        code: 'rate_limited',
      });
    }

    const result = await callOpenAi(
      ACCOMPANIMENT_AI_PROMPT,
      `Ação: ${action}\nDados (use só o que existir):\n${JSON.stringify(payload)}`,
    );

    if (!result.configured) {
      console.warn('accompanimentAi: OPENAI_API_KEY ausente');
      return res.status(503).json({
        error: 'A IA na nuvem ainda não está configurada no servidor.',
        code: 'openai_not_configured',
      });
    }
    if (!result.text || !String(result.text).trim()) {
      return res.status(502).json({
        error: 'A IA não conseguiu responder agora. Tente novamente em instantes.',
        code: 'openai_error',
      });
    }

    if (action !== 'student_assistant') {
      await db.collection('pt_ai_logs').add({
        trainerId: uid,
        type: action,
        prompt: action,
        result: String(result.text).slice(0, 4000),
        createdAt: new Date().toISOString(),
        approved: false,
      });
    }

    return res.status(200).json({ result: String(result.text).trim() });
  } catch (e) {
    console.error('accompanimentAi', e && e.name, e && e.message);
    const timedOut = e && (e.name === 'TimeoutError' || e.name === 'AbortError');
    return res.status(timedOut ? 504 : 500).json({
      error: timedOut
        ? 'A resposta demorou demais. Tente novamente.'
        : 'Não foi possível gerar a resposta agora. Tente novamente.',
      code: timedOut ? 'timeout' : 'internal',
    });
  }
});

// ---------------------------------------------------------------------------
// Google Calendar — OAuth + freebusy + eventos. Tokens só no servidor.
// ---------------------------------------------------------------------------
function googleCreds() {
  const cfg = functions.config().googlecalendar || {};
  return {
    clientId: cfg.client_id || process.env.GOOGLE_CALENDAR_CLIENT_ID || '',
    clientSecret:
      cfg.client_secret || process.env.GOOGLE_CALENDAR_CLIENT_SECRET || '',
    redirectUri:
      cfg.redirect_uri ||
      process.env.GOOGLE_CALENDAR_REDIRECT_URI ||
      '',
  };
}

async function refreshGoogleToken(trainerId, secrets) {
  const { clientId, clientSecret } = googleCreds();
  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      refresh_token: secrets.refreshToken,
      grant_type: 'refresh_token',
    }),
  });
  const json = await tokenRes.json();
  if (!json.access_token) throw new Error('refresh_failed');
  await db.collection('pt_calendar_secrets').doc(trainerId).set(
    {
      accessToken: json.access_token,
      expiry: Date.now() + (json.expires_in || 3500) * 1000,
    },
    { merge: true },
  );
  return json.access_token;
}

exports.googleCalendar = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;
  const uid = await requireAuth(req, res);
  if (!uid) return;
  if (!(await verifyAppCheck(req, res))) return;

  const action = (req.body && req.body.action) || '';
  const { clientId, clientSecret, redirectUri } = googleCreds();

  try {
    if (action === 'oauth_start') {
      if (!clientId || !redirectUri) {
        return res.status(200).json({
          ok: false,
          error:
            'Google Calendar não configurado. Defina GOOGLE_CALENDAR_CLIENT_ID e REDIRECT_URI nas Cloud Functions.',
        });
      }
      const scope = encodeURIComponent(
        'https://www.googleapis.com/auth/calendar.events https://www.googleapis.com/auth/calendar.freebusy https://www.googleapis.com/auth/calendar.readonly',
      );
      const authUrl =
        'https://accounts.google.com/o/oauth2/v2/auth' +
        `?client_id=${encodeURIComponent(clientId)}` +
        `&redirect_uri=${encodeURIComponent(redirectUri)}` +
        '&response_type=code&access_type=offline&prompt=consent' +
        `&scope=${scope}&state=${encodeURIComponent(uid)}`;
      return res.status(200).json({ ok: true, authUrl });
    }

    if (action === 'oauth_callback') {
      const code = req.body.code;
      if (!code) return res.status(400).json({ error: 'code ausente' });
      const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          code,
          client_id: clientId,
          client_secret: clientSecret,
          redirect_uri: redirectUri,
          grant_type: 'authorization_code',
        }),
      });
      const tokens = await tokenRes.json();
      if (!tokens.refresh_token && !tokens.access_token) {
        return res.status(400).json({ error: 'Falha no OAuth Google' });
      }
      await db.collection('pt_calendar_secrets').doc(uid).set({
        refreshToken: tokens.refresh_token || null,
        accessToken: tokens.access_token,
        expiry: Date.now() + (tokens.expires_in || 3500) * 1000,
      });
      await db.collection('pt_calendar_connections').doc(uid).set({
        connected: true,
        calendarId: 'primary',
        state: 'synced',
        lastSync: new Date().toISOString(),
        error: '',
      });
      return res.status(200).json({ ok: true });
    }

    if (action === 'disconnect') {
      await db.collection('pt_calendar_secrets').doc(uid).delete();
      await db.collection('pt_calendar_connections').doc(uid).set({
        connected: false,
        state: 'disconnected',
        error: '',
      });
      return res.status(200).json({ ok: true });
    }

    const secretSnap = await db.collection('pt_calendar_secrets').doc(uid).get();
    if (!secretSnap.exists) {
      return res.status(200).json({
        ok: false,
        pending: true,
        error: 'Google Calendar não conectado',
      });
    }
    let access = secretSnap.data().accessToken;
    if (!access || (secretSnap.data().expiry || 0) < Date.now()) {
      access = await refreshGoogleToken(uid, secretSnap.data());
    }

    const conn = await db.collection('pt_calendar_connections').doc(uid).get();
    const calendarId = (conn.data() && conn.data().calendarId) || 'primary';

    if (action === 'busy') {
      const timeMin = req.body.timeMin;
      const timeMax = req.body.timeMax;
      const busyRes = await fetch(
        'https://www.googleapis.com/calendar/v3/freeBusy',
        {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${access}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            timeMin,
            timeMax,
            timeZone: 'America/Sao_Paulo',
            items: [{ id: calendarId }],
          }),
        },
      );
      const busyJson = await busyRes.json();
      const busy =
        (busyJson.calendars &&
          busyJson.calendars[calendarId] &&
          busyJson.calendars[calendarId].busy) ||
        [];
      return res.status(200).json({ ok: true, busy });
    }

    if (action === 'sync_appointment' || action === 'sync_now') {
      await db.collection('pt_calendar_connections').doc(uid).set(
        {
          lastSync: new Date().toISOString(),
          state: 'synced',
          error: '',
        },
        { merge: true },
      );
      return res.status(200).json({ ok: true });
    }

    return res.status(400).json({ error: 'Ação desconhecida' });
  } catch (e) {
    console.error('googleCalendar', e);
    await db.collection('pt_calendar_connections').doc(uid).set(
      { state: 'error', error: String(e.message || e) },
      { merge: true },
    );
    return res.status(200).json({
      ok: false,
      pending: true,
      error: 'Sincronização pendente',
    });
  }
});

// ---------------------------------------------------------------------------
// Admin Técnico — criar conta e bloquear no Firebase Auth.
// O cliente NUNCA cria Admin/Personal no cadastro público.
// ---------------------------------------------------------------------------
function canonicalRole(raw) {
  const v = String(raw || 'student').trim().toLowerCase();
  if (v === 'technical_admin' || v === 'admin' || v === 'role_admin') {
    return 'technical_admin';
  }
  if (v === 'trainer' || v === 'personal' || v === 'role_personal') {
    return 'trainer';
  }
  return 'student';
}

exports.adminManageUser = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;

  const uid = await requireAuth(req, res);
  if (!uid) return;
  if (!(await verifyAppCheck(req, res))) return;
  if (!(await requireAdmin(uid, res))) return;

  const body = req.body || {};
  const action = body.action;

  try {
    if (action === 'setDisabled') {
      const targetUid = String(body.targetUid || '').trim();
      const disabled = body.disabled === true;
      if (!targetUid) {
        return res.status(400).json({ success: false, message: 'targetUid ausente.' });
      }
      if (targetUid === uid) {
        return res.status(400).json({
          success: false,
          message: 'Você não pode bloquear a própria conta.',
        });
      }
      await admin.auth().updateUser(targetUid, { disabled });
      if (disabled) {
        await admin.auth().revokeRefreshTokens(targetUid);
      }
      await db.collection('users').doc(targetUid).set(
        { disabled },
        { merge: true },
      );
      return res.status(200).json({
        success: true,
        message: disabled ? 'Conta bloqueada no Auth.' : 'Conta reativada no Auth.',
        uid: targetUid,
      });
    }

    if (action === 'createUser') {
      const name = String(body.name || '').trim();
      const email = String(body.email || '').trim().toLowerCase();
      const password = String(body.password || '');
      const role = canonicalRole(body.role);
      if (!name || !email || password.length < 6) {
        return res.status(400).json({
          success: false,
          message: 'Nome, e-mail e senha (mín. 6) são obrigatórios.',
        });
      }

      const created = await admin.auth().createUser({
        email,
        password,
        displayName: name,
        disabled: false,
      });

      const isAdminRole = role === 'technical_admin';
      const isPersonal = isAdminRole || role === 'trainer';
      await db.collection('users').doc(created.uid).set({
        name,
        email,
        role,
        isAdmin: isAdminRole,
        isPersonalTrainer: isPersonal,
        isPremium: false,
        disabled: false,
        memberSince: new Date().toISOString(),
        xp: 0,
        level: 1,
        streak: 0,
        totalWorkouts: 0,
        totalKm: 0,
        referralCount: 0,
        referralCode: created.uid.substring(0, 6).toUpperCase(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdBy: uid,
      }, { merge: true });

      if (isAdminRole) {
        await db.collection('admins').doc(created.uid).set({
          uid: created.uid,
          role,
          updatedAt: new Date().toISOString(),
          updatedBy: uid,
        }, { merge: true });
      }

      await db.collection('referral_codes').doc(
        created.uid.substring(0, 6).toUpperCase(),
      ).set({ ownerUid: created.uid }, { merge: true });

      return res.status(200).json({
        success: true,
        message: `Conta criada como ${role}.`,
        uid: created.uid,
      });
    }

    return res.status(400).json({ success: false, message: 'Ação desconhecida.' });
  } catch (e) {
    console.error('adminManageUser', e);
    const msg = e && e.message ? String(e.message) : 'Falha ao gerenciar usuário.';
    return res.status(200).json({ success: false, message: msg });
  }
});

// Teste grátis de 7 dias. Uma vez por conta. Admin pode resetar em homologação
// com auditoria — não altera assinatura paga.
exports.startFreeTrial = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;

  try {
    const uid = await requireAuth(req, res);
    if (!uid) return;
    if (!(await verifyAppCheck(req, res))) return;

    let target = uid;
    const requested = req.body && req.body.targetUid;
    if (requested && requested !== uid) {
      if (!(await requireAdmin(uid, res))) return;
      target = requested;
    }

    const ref = db.collection('subscriptions').doc(target);
    const existing = await ref.get();
    const reset = req.body && req.body.reset === true;
    if (reset) {
      if (!(await requireAdmin(uid, res))) return;
    } else if (existing.exists && existing.data().trialUsed === true) {
      return res.status(409).json({ error: 'Teste grátis já utilizado.' });
    }
    if (existing.exists) {
      const st = String((existing.data() || {}).status || '');
      if ((st === 'active' || st === 'cancelled') && !reset) {
        return res.status(409).json({ error: 'Conta já possui assinatura registrada.' });
      }
    }

    const now = new Date();
    const end = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const payload = {
      userId: target,
      plan: 'trial',
      status: 'trial',
      trialUsed: true,
      startedAt: now.toISOString(),
      trialStartedAt: now.toISOString(),
      trialEndsAt: end.toISOString(),
      platform: 'none',
      source: reset || (requested && requested !== uid) ? 'admin_test' : 'trial',
      productId: '',
    };
    await ref.set(payload);
    await db.collection('subscription_audit').add({
      actorUid: uid,
      targetUid: target,
      action: reset ? 'reset_free_trial' : 'start_free_trial',
      note: payload.source,
      at: now.toISOString(),
    });
    return res.status(200).json({ success: true, subscription: payload });
  } catch (e) {
    console.error('startFreeTrial', e);
    return res.status(500).json({ error: 'Falha ao iniciar o teste.' });
  }
});

