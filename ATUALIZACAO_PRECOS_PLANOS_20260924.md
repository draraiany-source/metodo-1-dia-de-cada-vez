# Atualização de preços — Planos (24/09/2026)

## Novos valores (vitrine do app)
| Plano | Preço | Equivalência | Economia vs mensal no período |
|---|---|---|---|
| Mensal | **R$ 199,00** / mês | — | — |
| Trimestral | **R$ 399,00** a cada 3 meses | **R$ 133,00**/mês | **R$ 198,00** (3×199 − 399) |
| Anual | **R$ 1.490,00** / ano | **R$ 124,17**/mês | **R$ 898,00** (12×199 − 1490) |

Teste grátis de **7 dias**: preservado (regras inalteradas).  
**PAYMENTS_ENABLED=false** — nenhuma cobrança real ativada.

## Fontes localizadas e tratadas
| Fonte | Ação |
|---|---|
| `lib/core/constants/app_constants.dart` | Preços + equivalentes + economias |
| `lib/features/subscriptions/domain/subscription_models.dart` | `PlanCatalog` mensal/trimestral/anual |
| `lib/features/subscriptions/presentation/plans_screen.dart` | UI anual ativo; textos de equivalência/economia/cobrança |
| `lib/features/profile/presentation/settings_screen.dart` | Subtítulo inclui anual |
| `test/subscription_catalog_test.dart` | Expectativas atualizadas |
| `RELATORIO_PLANOS_ASSINATURAS.md` | Valores antigos corrigidos |
| Firestore / produtos loja | **Sem alteração** (não há preços persistidos no app DB) |
| RevenueCat / Play / App Store | **Pendência** — cadastrar preços nas lojas quando autorizado |

Valores antigos removidos do código: R$ 79,90 / R$ 199,90 / “anual em breve”.

## Testes
`flutter test test/subscription_catalog_test.dart` → **+15 PASS**  
Inclui: preços, R$ 124,17 / R$ 133,00, economias 198 e 898, `PAYMENTS_ENABLED` false.

## Evidências visuais
Pasta: `homologacao_evidencias_planos_20260924/`
- `plans_web_viewport.png`
- `plans_android_viewport_same_ui.png` (mesma UI Flutter; **sem device Android** nesta sessão)
- `plans_vitrine.html` (referência)

## Confirmação de cobrança
- `AppConfig.paymentsEnabled` default **false**
- Disclaimer na tela: `PAYMENTS_ENABLED=false`
- **Não** foram criados produtos/assinaturas nas lojas nesta etapa

## Pendências para quando a cobrança for autorizada
1. Google Play Console — preços dos IDs `metodo1dia_premium_mensal|trimestral|anual`
2. App Store Connect — mesmos product IDs + introductory offer 7 dias
3. RevenueCat — offerings alinhadas aos novos preços da loja
4. Só então avaliar `PAYMENTS_ENABLED=true` (com autorização explícita)

**Não publicado nas lojas.**
