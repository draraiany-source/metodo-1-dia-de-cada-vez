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
Você é um assistente que estima calorias e macros a partir de uma foto de comida.
Responda SOMENTE com um JSON válido, sem texto antes ou depois, no formato:
{"name": "nome curto do prato", "kcal": numero_inteiro, "protein": numero_inteiro, "carbs": numero_inteiro, "fat": numero_inteiro, "confidence": "alta" | "media" | "baixa", "detalhe": "explicação breve em 1 frase"}
protein, carbs e fat são em gramas. Seja conservador: se não der pra
identificar bem os alimentos ou as porções, use "confidence": "baixa" e
ainda assim dê a melhor estimativa possível para todos os campos.
Nunca invente que é impossível estimar — sempre devolva números.
`;

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
      return res.status(200).json({
        name: 'Refeição',
        kcal: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        confidence: 'baixa',
        detalhe:
          'Chave da OpenAI não configurada na Cloud Function — registre manualmente.',
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
          { role: 'system', content: CALORIE_VISION_PROMPT },
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Estime as calorias desta refeição.' },
              {
                type: 'image_url',
                image_url: { url: `data:image/jpeg;base64,${imageBase64}` },
              },
            ],
          },
        ],
        max_tokens: 200,
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
      // Remove eventuais cercas de código (```json ... ```) antes de parsear.
      const cleaned = raw.replace(/```json|```/g, '').trim();
      parsed = JSON.parse(cleaned);
    } catch (_) {
      parsed = { name: 'Refeição', kcal: 0, confidence: 'baixa' };
    }

    return res.status(200).json({
      name: parsed.name || 'Refeição',
      kcal: Number(parsed.kcal) || 0,
      protein: Number(parsed.protein) || 0,
      carbs: Number(parsed.carbs) || 0,
      fat: Number(parsed.fat) || 0,
      confidence: parsed.confidence || 'baixa',
      detalhe: parsed.detalhe || '',
    });
  } catch (e) {
    console.error('calorieVision error', e);
    return res.status(200).json({
      name: 'Refeição',
      kcal: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      confidence: 'baixa',
      detalhe: 'Não consegui analisar a foto agora — registre manualmente.',
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

    if (content.isPremium) {
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
