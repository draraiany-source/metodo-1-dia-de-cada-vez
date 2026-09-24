# Relatório — Planos e Assinaturas

Backup anterior: commit `218e520`  
(`chore: backup antes de implementar planos e assinaturas`)

Cobrança real: **desligada** (`PAYMENTS_ENABLED=false`).  
Publicação em produção: **não realizada**.

---

## Arquivos criados

| Arquivo | Função |
|---|---|
| `lib/features/subscriptions/domain/subscription_models.dart` | Catálogo, status, regras de acesso |
| `lib/features/subscriptions/data/subscription_repository.dart` | Firestore + `startFreeTrial` |
| `lib/features/subscriptions/providers/subscription_providers.dart` | Riverpod + `isContentLocked` |
| `lib/features/subscriptions/presentation/plans_screen.dart` | Tela Planos e Assinaturas |
| `lib/features/subscriptions/presentation/my_subscription_screen.dart` | Minha Assinatura |
| `lib/features/subscriptions/presentation/admin_subscriptions_screen.dart` | Painel Admin |
| `lib/features/subscriptions/presentation/premium_gate_sheet.dart` | Modal Conteúdo Premium |
| `test/subscription_catalog_test.dart` | Testes de catálogo e status |
| `RELATORIO_PLANOS_ASSINATURAS.md` | Este relatório |

## Arquivos alterados

- `lib/core/config/app_config.dart` — `PAYMENTS_ENABLED`, produto trimestral
- `lib/core/constants/app_constants.dart` — IDs alinhados + preços de catálogo
- `lib/core/services/premium_service.dart` — gate de cobrança, trimestral, merge do trial
- `lib/core/router/app_router.dart` — `/minha-assinatura`, `/admin/assinaturas`
- `lib/features/premium/presentation/premium_screen.dart` — aponta para Planos
- `lib/features/profile/presentation/profile_screen.dart` — Minha Assinatura
- `lib/features/profile/presentation/settings_screen.dart` — Planos e Assinaturas
- `lib/features/home/presentation/home_screen.dart` — Conheça o Premium
- `lib/features/admin/presentation/admin_screen.dart` — tile Assinaturas
- `lib/features/personal_trainer/presentation/student_detail_screen.dart` — ativo / Premium / gratuito
- Gates de vídeo, e-book, curso, áudio e PDF
- `firebase/firestore.rules` — trial create único + auditoria; catch-all deny intacto
- `functions/src/auth_helpers.js` — `hasPremiumAccess`
- `functions/src/index.js` — `startFreeTrial` + validação Premium no backend
- `.env.example` — `PAYMENTS_ENABLED=false`

## Telas criadas

1. **Planos e Assinaturas** (`/premium`) — teste 7 dias, mensal R$ 199,00, trimestral R$ 399,00 (selo MAIS ESCOLHIDO), anual R$ 1.490,00
2. **Minha Assinatura** (`/minha-assinatura`) — status, valor, datas, plataforma, gerenciar, restaurar
3. **Admin → Assinaturas** (`/admin/assinaturas`) — totais e filtro por status (sem editar pago)

Navegação: Perfil, Configurações, Home (opcional), modal Premium, AppBar com voltar.

## Estrutura do banco

Coleção `subscriptions/{uid}`:

- `userId`, `plan` (`trial` \| `monthly` \| `quarterly` \| `yearly`)
- `status` (`free` \| `trial` \| `active` \| `cancelled` \| `expired` \| `pending` \| `billing_issue`)
- `amount`, `currency`, `startedAt`, `nextBillingAt`
- `trialStartedAt`, `trialEndsAt`, `trialUsed`
- `platform`, `productId`, `source`

Coleção `subscription_audit/{autoId}`: `actorUid`, `targetUid`, `action`, `note`, `at`.

`users.isPremium` / `premiumExpiresAt` / `premiumPlan` / trial **não** são graváveis pelo aluno.

## Regras de acesso

- Aluno: lê o próprio `subscriptions/{uid}`; cria **somente** o próprio trial, uma vez
- Personal: lê status para ver se o aluno é gratuito / teste / Premium; **não** altera preço nem financeiro; UI sem dados de loja
- Admin Técnico: lê todos os registros; **não** edita assinatura paga no app
- Plano pago: só webhook / Admin SDK
- Catch-all `allow read, write: if false` permanece
- Backend (`getVideoUrl` / `getContentUrl`) valida `users.isPremium` **ou** trial/pago ativo

## IDs dos produtos (padrão já existente)

| Plano | ID |
|---|---|
| Mensal | `metodo1dia_premium_mensal` |
| Trimestral | `metodo1dia_premium_trimestral` |
| Anual | `metodo1dia_premium_anual` |
| Entitlement | `premium` |

Não foram usados `metodo1dia_mensal` / `metodo1dia_trimestral` — o projeto já tinha o prefixo `metodo1dia_premium_*`.

Preços de catálogo (fallback até a loja responder): mensal **R$ 199,00**; trimestral **R$ 399,00** (≡ R$ 133,00/mês; economize R$ 198,00 vs 3 mensais); anual **R$ 1.490,00** (≡ R$ 124,17/mês com cobrança anual; economize R$ 898,00 vs 12 mensais).

## O que está funcionando

- UI de planos, minha assinatura e admin
- Teste de 7 dias (uma vez por conta)
- Modal Premium (VER PLANOS / AGORA NÃO) sem travar o app
- Acesso Premium efetivo = loja/cupom **ou** trial válido
- `PAYMENTS_ENABLED=false` bloqueia compra real
- Restaurar compras preparado (loja ainda inativa)
- Personal vê só acesso do aluno
- Voltar em todas as telas novas (`PremiumAppBar`)
- App não exige assinatura ao abrir

## Testes

`test/subscription_catalog_test.dart`: **14 passaram**

| Cenário | Resultado |
|---|---|
| Gratuito sem assinatura | PASSOU |
| Teste ativo | PASSOU |
| Teste expirado | PASSOU |
| Mensal ativo | PASSOU |
| Trimestral ativo | PASSOU |
| Cancelada no período | PASSOU |
| Expirada | PASSOU |
| Flag `isPremium` válida | PASSOU |
| `trialUsed` impede reinício | PASSOU |
| IDs / preços / PAYMENTS_ENABLED | PASSOU |

Manuais em dispositivo (login real + lojas): **pendentes**.

## O que ainda depende da App Store

- Produto `metodo1dia_premium_mensal` / `_trimestral` / `_anual` no App Store Connect
- StoreKit / assinatura em grupo
- Preço anual (não inventado)
- Review de compras e “Gerenciar assinatura”
- Chave `--dart-define=REVENUECAT_IOS_KEY`

## O que ainda depende da Google Play

- Mesmos IDs na Play Console (subscriptions)
- Play Billing
- Chave `--dart-define=REVENUECAT_ANDROID_KEY`
- Publicar a function `startFreeTrial`

## Riscos

1. Function `startFreeTrial` precisa de deploy; o app cai no create restrito das rules se ela ainda não existir.
2. Personal pode ler docs de `subscriptions` (só status na UI; sem dados bancários).
3. Preços de catálogo são fallback. Com `PAYMENTS_ENABLED=true`, a loja deve prevalecer.
4. `users.isPremium` antigo (cupom) continua válido e é mesclado ao trial.
5. Web não tem StoreKit/Play Billing.

## Pendências

- Deploy de `startFreeTrial` e `hasPremiumAccess`
- Cadastrar produtos nas lojas + RevenueCat
- Só então `PAYMENTS_ENABLED=true` no build de release
- Testar as 3 contas reais no dispositivo
