const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {
  setCors,
  handleOptions,
  requireAuth,
  verifyAppCheck,
  isPremiumActive,
} = require('./auth_helpers');

admin.initializeApp();
const db = admin.firestore();

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


exports.amandaChat = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;

  const uid = await requireAuth(req, res);
  if (!uid) return;
  if (!(await verifyAppCheck(req, res))) return;

  try {
    const { message, userName, profile, context } = req.body || {};
    if (!message) return res.status(400).json({ error: 'message ausente' });

    const apiKey =
      (functions.config().openai && functions.config().openai.key) ||
      process.env.OPENAI_API_KEY;

    if (!apiKey) {
      // Sem chave configurada: devolve fallback para não quebrar o app.
      return res.status(200).json({
        reply:
          'Estou aqui com você 💜 (Amanda em modo básico — configure a chave da OpenAI na Cloud Function para respostas completas.)',
      });
    }

    const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: AMANDA_SYSTEM_PROMPT },
          {
            role: 'user',
            content: buildUserContent(message, userName, profile, context),
          },
        ],
        max_tokens: 300,
        temperature: 0.8,
      }),
    });

    const data = await openaiRes.json();
    const reply =
      data.choices && data.choices[0] && data.choices[0].message
        ? data.choices[0].message.content
        : 'Vamos com calma, um dia de cada vez. 💜';

    return res.status(200).json({ reply });
  } catch (e) {
    console.error('amandaChat error', e);
    return res.status(200).json({
      reply: 'Tive um probleminha agora, mas continuo com você. 💜',
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

exports.calorieVision = functions.https.onRequest(async (req, res) => {
  setCors(res);
  if (handleOptions(req, res)) return;

  const uid = await requireAuth(req, res);
  if (!uid) return;
  if (!(await verifyAppCheck(req, res))) return;

  try {
    const { imageBase64 } = req.body || {};
    if (!imageBase64) {
      return res.status(400).json({ error: 'imageBase64 ausente' });
    }

    const apiKey =
      (functions.config().openai && functions.config().openai.key) ||
      process.env.OPENAI_API_KEY;

    if (!apiKey) {
      return res.status(200).json(
        normalizeCalorieVisionResponse({
          name: 'Refeição',
          kcal: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          confidence: 'baixa',
          detalhe:
            'Chave da OpenAI não configurada na Cloud Function — registre manualmente.',
        }),
      );
    }

    const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
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
      }),
    });

    const data = await openaiRes.json();
    const raw =
      data.choices && data.choices[0] && data.choices[0].message
        ? data.choices[0].message.content
        : '{}';

    let parsed;
    try {
      const cleaned = raw.replace(/```json|```/g, '').trim();
      parsed = JSON.parse(cleaned);
    } catch (_) {
      parsed = { foods: [], detalhe: 'Resposta inválida da IA.' };
    }

    return res.status(200).json(normalizeCalorieVisionResponse(parsed));
  } catch (e) {
    console.error('calorieVision error', e);
    return res.status(200).json(
      normalizeCalorieVisionResponse({
        foods: [],
        detalhe:
          'Não conseguimos analisar essa imagem. Tente tirar outra foto com os alimentos mais visíveis.',
      }),
    );
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
      if (!isPremiumActive(userSnap.exists ? userSnap.data() : null)) {
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
      if (!isPremiumActive(userSnap.exists ? userSnap.data() : null)) {
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
