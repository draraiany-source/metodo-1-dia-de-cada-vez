# Relatório — RevenueCat, assinaturas e sandbox

Backup: `6c9275d` — chore: backup antes de preparar RevenueCat sandbox  
`PAYMENTS_ENABLED` permanece **false**. Nenhum produto foi publicado em produção.

## 1. O que já estava configurado

- SDK `purchases_flutter` **8.11.0** (`pubspec` ^8.1.0)
- Entitlement no código: `premium`
- IDs: `metodo1dia_premium_mensal`, `metodo1dia_premium_trimestral`, `metodo1dia_premium_anual`
- Chaves só via `--dart-define` (públicas `goog_` / `appl_`, sem secret no git)
- `Purchases.configure` no `main` se houver chave
- Restore, paywall, Minha Assinatura, trial Firestore e rules
- ProGuard RevenueCat no Android
- `debugUnlockAllPremiumContent = false`

## 2. O que foi implementado agora

- `BILLING_SANDBOX` (default false): abre o sheet da loja só em teste, sem ligar produção
- Offering `default` mapeada para `monthly`, `three_month` (trimestral) e `annual`, com fallback pelo product ID
- Paywall usa **preço da loja** quando o RevenueCat devolve offering; catálogo só como fallback
- Anual: preço de vitrine R$ 1.490,00 (≡ R$ 124,17/mês); na loja só após cadastro Play/Apple + RevenueCat. Cobrança real continua off até autorização.
- Teste de 7 dias: com RevenueCat configurado, a elegibilidade fica na loja (introductory offer), não só no Firestore
- `Purchases.logIn(uid)` na troca de sessão (restore em outro aparelho)
- Status real do RevenueCat: entitlement, renovação, expiração, `periodType`, loja, `managementURL`
- Gerenciar assinatura abre URL da loja (não cancela no app)
- Mensagens amigáveis (cancelou, sem rede, produto indisponível, RC fora, restore vazio)
- Permissão `com.android.vending.BILLING` no manifest

## 3. O que foi testado

Automatizado: catálogo, flags, entitlement, restore/erros.  
Sandbox real (compra, renovação acelerada, TestFlight): **não executado** — faltam chaves no build, produtos nas lojas e testadores.

## 4. Checklist

| Item | Resultado |
|---|---|
| SDK RevenueCat | **PASSOU** (8.11.0 instalado) |
| API key | **FALHOU** (não injetada neste build) |
| Offering | **FALHOU** (estrutura no app; offering no painel RC não validada) |
| Mensal | **PARCIAL** (ID pronto; produto Play/ASC não cadastrado aqui) |
| Trimestral | **PARCIAL** (`three_month` + ID custom) |
| Anual | **PARCIAL** (sem preço inventado; espera offering) |
| Entitlement `premium` | **PASSOU** no código |
| Paywall | **PASSOU** (UI + restore + termos + voltar) |
| Compra sandbox | **FALHOU** (sem testador/loja neste ambiente) |
| Restore purchases | **PASSOU** no código / **FALHOU** E2E |
| Status da assinatura | **PASSOU** no código (só preenche com CustomerInfo real) |
| Cancelamento/gerenciamento | **PASSOU** (link Play / App Store) |
| Teste grátis | **PARCIAL** (loja quando RC existe; senão trial Firestore único) |
| Android sandbox | **FALHOU** E2E (Play Console + license testers pendentes) |
| iOS sandbox | **FALHOU** (sem `.entitlements` IAP, sem ASC/TestFlight aqui) |
| Segurança | **PASSOU** (sem secret key, sem debug unlock, `PAYMENTS_ENABLED=false`) |

## 5. Depende da Google Play Console

- Assinatura com os 3 product IDs (rascunho/teste, **não** produção)
- Base plan + offer de 7 dias se quiser trial da loja
- License testers
- Build com `--dart-define=REVENUECAT_ANDROID_KEY=goog_... --dart-define=BILLING_SANDBOX=true`
- Vincular app no RevenueCat (Play)

## 6. Depende da App Store Connect

- Conta Apple / IAP / paid apps agreement
- Mesmos product IDs + subscription group
- Introductory offer 7 dias
- Sandbox Tester / TestFlight
- Capability In-App Purchase no Xcode (ainda sem `Runner.entitlements`)
- `--dart-define=REVENUECAT_IOS_KEY=appl_...`

## 7. O que ainda bloqueia produção

1. `PAYMENTS_ENABLED=false` de propósito
2. Sem produtos publicados e sem review das lojas
3. Sem chaves RevenueCat no build de release
4. Offering/entitlement no dashboard RC não conferidos daqui
5. iOS sem IAP capability e sem Firebase iOS completo (já pendente)
6. Function `startFreeTrial` ainda precisa de deploy se for usar trial fora da loja

**Não ativar `PAYMENTS_ENABLED=true` sem sua autorização.**  
Sandbox: `BILLING_SANDBOX=true` + testador da loja. Usuário comum nesse build ainda pode ser cobrado pela Play se não for license tester.
