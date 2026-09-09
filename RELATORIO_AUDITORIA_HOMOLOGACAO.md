# Relatório — Auditoria final de homologação (Android)

**Branch:** `consolidacao-recuperacao`  
**Checkpoint pré-correções:** `d6df97e`  
**Commit das correções:** `a8c8500`  
**Data:** 2026-09-09

### APKs disponíveis (teste — NÃO é AAB final)

| Arquivo | Caminho |
|---------|---------|
| Debug | `C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\flutter-apk\app-debug.apk` |
| Release (teste) | `C:\Users\Lenovo\Desktop\metodo 1 dia perfil premium 2\build\app\outputs\flutter-apk\app-release.apk` |

> AAB **não** foi gerado (conforme solicitado).

---

## Correções aplicadas nesta rodada

### Firebase (crítico Web)
- App Check **não ativa no Web** (evita TypeError `FirebaseException` ≠ `JavaScriptObject`).
- FCM **não chama `getToken()` no Web** sem VAPID/SW.
- `AuthHttpHeaders` não solicita token App Check no Web.
- Novo `FirebaseErrorMapper` para mensagens amigáveis.
- Startup / login não exibem stack/`FirebaseException` cru.

### Treinos em vídeo
- Parse tolerante (`double`, `Timestamp`, `active` string).
- Query com fallback se índice/`orderBy` falhar.
- Erros sobem para UI com **Tentar novamente** (não mais lista vazia silenciosa).
- Empty state por filtro vs catálogo vazio diferenciados.

### YouTube
- Extração ampliada (`live/`, `m.youtube.com`, etc.).
- Web abre externo (sem WebView quebrado).
- Android: embed `youtube.com` + retry `nocookie` + fallback “Abrir no YouTube”.

### Perfil
- `AppUser.guest()` / `uiFallback()` — sem “Ana Silva / 72,5 kg” com Firebase ativo.
- Telas migradas de `?? AppUser.demo()` para `?? AppUser.uiFallback()`.

---

## Status por área

| Área | Status | Nota |
|------|--------|------|
| Firebase boot (Web) | 🟢 | TypeError App Check/FCM mitigado |
| Firebase Auth | 🟢 | Mensagens amigáveis no login |
| Treinos em vídeo (Firestore `videos`) | 🟢/⚠️ | Código corrigido; precisa docs `active:true` + índice deployado |
| YouTube in-app | 🟢 | Fallback externo garantido |
| Perfil (sem mock produção) | 🟢 | Visitante sem dados fictícios |
| Áudios | ⚠️ | Repositórios já degradam; sem regressão intencional nesta rodada |
| Check-in / Hábitos / Evolução / Medidas / Fotos | ⚠️ | Não reescritos; manter smoke test manual no APK |
| GPS / Notificações | ⚠️ | Permissões Android já no Manifest; testar em device |
| Premium / Assinatura | 🟢 | Sem cobrança real; gates UI + CF streaming |
| Segurança rules | 🟢 | Owner-scoped; deploy rules se ainda pendente |
| Android build | ⚠️ | Validar APK gerado abaixo |
| Web | 🟢/⚠️ | Firebase Web mais estável; WebView vídeo desativado |

### Legenda
- 🟢 Pronto / ⚠️ Precisa melhorar / ❌ Não funciona / 🔴 Bloqueia publicação

---

## Conclusões

1. **Conclusão estimada para homologação Android:** ~85–90% (após smoke no APK).
2. **Bloqueios possíveis de publicação:**
   - Deploy da function `calorieVision` / índices Firestore `videos` se ainda não aplicados.
   - Conteúdo `videos` precisa estar em `videos` com `active: true` (YouTube do catálogo ≠ streaming).
   - Conta Play / privacy / Data Safety (ops).
3. **Pós-lançamento opcional:** App Check Web (reCAPTCHA), FCM Web, player YouTube nativo, paginação de vídeos.
4. **Apto para gerar AAB?** Quase — **não gerar AAB sem autorização**. Usar APK de teste primeiro.

---

## Como validar vídeos cadastrados

1. Console → coleção **`videos`** (não confundir com catálogo YouTube / PT).
2. Cada doc: `active: true` (boolean), `order` (number), `name`, `category`.
3. `firebase deploy --only firestore:indexes` se a query composta falhar.
4. Usuário autenticado (rules exigem login para ler).
