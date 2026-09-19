# Etapa 8 — Segurança e infraestrutura (auditoria)

Não publicar. Não ligar cobrança. Não apagar dados. Rules não foram enfraquecidas.

Backup: tag `backup-etapa-seguranca-20260919`  
Remote: `https://github.com/draraiany-source/metodo-1-dia-de-cada-vez.git`  
Branch: `finalizacao-metodo-1-dia-de-cada-vez` (ahead do origin)

`.env` ausente no disco. `android/key.properties` e `google-services.json` existem **só local** (gitignore). Não versionar.

---

## Arquitetura atual

Um único projeto Firebase `metodo1dia-app` (Auth, Firestore, Storage, Functions us-central1, Analytics, Crashlytics, App Check, Hosting, FCM).  
RBAC: Admin = `admins/{uid}`; Personal = `users.isPersonalTrainer`; Aluno = restante.  
OpenAI só no servidor. RevenueCat no cliente com `PAYMENTS_ENABLED=false`.  
Corrida: `geolocator` + `flutter_map` (não é SDK Google Maps).

---

## Correções feitas nesta etapa

1. Login demo (“qualquer senha” / Ana Silva) **bloqueado** em release e quando o Firebase tem chave mas falhou ao iniciar.
2. Modo visitante residual no SharedPreferences **ignorado** (`enableGuestMode=false`).
3. `.gitignore` inclui `.gradle-homolog/` e `.firebase/`.

---

## Secrets

| Item | Onde | Ação |
|---|---|---|
| Firebase Android/Web apiKey | `lib/firebase_options.dart` | Chave **pública** de cliente. Restringir no Google Cloud (app/package/SHA). Rotacionar só se unrestricted e vazou com abuso. |
| Firebase iOS apiKey | `REPLACE_ME` | Configurar `flutterfire configure` — não é secret vazado. |
| OpenAI | servidor / config Functions (vazio na última leitura) | Nunca no cliente. Configurar e **não** commitar. |
| RevenueCat secret (dashboard) | não está no repo | OK. SDK keys só via dart-define no build. |
| key.properties / keystore | local, gitignored | Não commitar. Backup offline da dona. |
| Service account | não encontrado no git | Se existir em máquina, não commitar; rotacionar se já foi enviado. |

Nenhum `sk-` / service account commitado no código auditado (`lib/`, `functions/`).

---

## App Check — preparar, não enforce

Já ativo no app Android/iOS (Play Integrity / DeviceCheck em release; debug provider em debug). Web pulado. Functions verificam token só se `ENFORCE_APP_CHECK=true` (hoje off).

Antes de enforce: registrar debug tokens, testar Android release, iOS, Web; só então ligar no Console (Firestore/Storage/Functions) em modo monitor → enforce.

---

## Functions (produção vs código)

Código local exige Bearer. Produção antiga de `amandaChat`/`calorieVision` ainda responde sem token (evidência Etapa 6). `accompanimentAi` 404. Deploy das Functions novas continua pendente (não feito aqui).

---

## Dados Firestore — não apagar

Coleções reais: users, admins, pt_*, progress, running_sessions, workout_history, habits, subscriptions, videos, recipes, workouts, weekly_challenges, nutrition subcols, etc.

Propor (manual, depois):

- Revisar users de homolog misturados no mesmo projeto
- Vídeos seed vs CMS
- Órfãos: pt_messages após exclusão de conta; subscriptions que o cliente não apaga
- Flag `users.isAdmin` sem doc em `admins/{uid}` (o app já ignora)

Não há segundo projeto DEV/STAGING. Homolog = produção. **ALTO.**

---

## Google Maps

`MAPS_API_KEY` existe vazia. `google_maps_flutter` comentado. Mapa da corrida usa flutter_map. Sem restrição de chave Google Maps porque a chave não está em uso. Sem billing novo.

---

## Dependências

Não atualizei pacotes. `google_sign_in` no pubspec sem uso em `lib`. `health` nativo não integrado. Atualizar só com teste, em etapa própria.

---

## Ambientes

| | Projeto |
|---|---|
| DEV local | mesmo Firebase se o app inicializa |
| Homolog | `metodo1dia-app` |
| Produção | o mesmo |

Não há staging separado. Não inventar segundo projeto sem autorização (custo).
