# Auditoria Final de Publicação
## Método 1 Dia de Cada Vez

| Campo | Valor |
|---|---|
| Data | 19 de setembro de 2026 |
| Versão / build | `1.0.0+1` (`pubspec.yaml`) |
| Package / Bundle | `com.metodo1dia.app` |
| Branch | `finalizacao-metodo-1-dia-de-cada-vez` (10 commits à frente do origin) |
| HEAD | `23b1c0a` |
| Backup | tag `backup-auditoria-publicacao-completa-20260919` |
| Firebase | `metodo1dia-app` (único — homolog = produção) |
| Cobrança real | **Desligada** (`PAYMENTS_ENABLED=false`) |
| Produção alterada? | **Não.** Sem deploy, sem exclusão de dados, sem publicação. |

**Pergunta principal:** este aplicativo pode ser publicado na Google Play e na App Store agora?

**Resposta:** **Não.**

---

## 1. Resumo executivo

O código do app está avançado: Flutter + Firebase + RBAC no cliente e nas rules, logout centralizado, cadastro sempre aluno, documentos legais locais limpos, exclusão de conta no app, catálogo de planos (7 dias / mensal / trimestral / anual em breve), três YouTube Shorts no seed, CMS da Personal no app.

**Não está pronto para as lojas.** Faltam tarefas operacionais e de nuvem — a maioria **não exige contratar programador**. Exigem acesso Firebase, contas de teste, material das lojas e um Mac para iOS.

Nenhum fluxo dos 3 perfis foi marcado PASSOU em aparelho: **não há e-mail/senha/UID de teste nesta sessão**. Inventar PASSOU seria mentira.

**Testes unitários reexecutados após as correções locais:** 30 passaram.

---

## 2. Classificação final

### STATUS DO APLICATIVO

- [ ] PRONTO PARA PUBLICAR
- [ ] PRONTO COM PEQUENOS AJUSTES
- [x] **NÃO PRONTO — EXISTEM BLOQUEADORES**

### ANDROID

- [ ] PRONTO
- [x] **NÃO PRONTO**

### iOS

- [ ] PRONTO
- [x] **NÃO PRONTO**

---

## 3. O que impede a publicação agora

Somente bloqueadores, em ordem de prioridade:

1. **Documentos legais no ar estão errados.** Hosting `https://metodo1dia-app.web.app/termos.html` (19/09/2026) ainda começa com dados pessoais de e-mail. `privacidade.html` no ar ainda tem HTML duplicado (2 `</html>`). Os arquivos locais (`public/termos.html`, `public/privacidade.html`) estão limpos (teste unitário). A Play e a App Store vão abrir essas URLs.  
   Ação: `firebase deploy --only hosting --project metodo1dia-app` (não é publicar o app). Depois conferir o HTML no navegador.

2. **Cloud Functions de IA na nuvem não são as do repositório.** `amandaChat` e `calorieVision` respondem HTTP **400** a POST sem token (código antigo, sem `requireAuth`). `accompanimentAi` retorna **404** (não implantada). Código local exige auth e não devolve resultado fictício.  
   Ação: deploy das Functions do repo + OpenAI **somente no servidor**. Sem isso, IA/foto na vitrine falham ou ficam inseguras.

3. **E2E dos 3 perfis não foi feito.** Sem contas Aluno / Personal / Admin (`admins/{uid}`). Login, cadastro, reset, logout, troca de conta, anamnese, treino, áudio, vídeo no aparelho = não evidenciados. Revisor da loja vai quebrar se o fluxo básico falhar.

4. **Ficha das lojas incompleta.** Sem screenshots, feature graphic, Data Safety (Play), App Privacy (Apple), conta de revisor, texto de listing. Ícone 1024 de loja (`assets/app_icon/app_icon.png`) **ausente**.

5. **iOS não gera build nesta máquina.** Windows. `lib/firebase_options.dart` iOS ainda tem `REPLACE_ME`. Pasta `ios/` em grande parte só local (não está no GitHub). Sem IPA / TestFlight / App Store.

6. **Assinatura digital nas lojas ainda não está ligada.** Estrutura RevenueCat + IDs existe. `PAYMENTS_ENABLED=false` (correto até autorização). Se o app vender acesso a conteúdo digital, **é obrigatório** Play Billing / Apple IAP — **não** usar Pix/Stripe/externo para isso. Sandbox não foi comprado de verdade.

7. **Um único projeto Firebase.** Homolog = produção. Não impede o botão “enviar à loja”, mas qualquer teste malfeito mexe em dados reais. Não criamos segundo projeto (seria alteração de conta/ambiente).

---

## 4. Precisa contratar programador?

**Não, não é obrigatório contratar programador para o estado atual do código.**

Não recomendo contratação “por precaução”. O que falta é operacional e de acesso, não um buraco de arquitetura que impeça a dona do projeto de avançar.

| O que já está pronto no projeto | Quem pode concluir |
|---|---|
| App Flutter, rotas, RBAC, rules com catch-all deny | Já no repositório |
| Login/cadastro/reset/logout no código | Dona do Firebase + 3 contas de teste |
| CMS da Personal (vídeos, fotos, textos, alunos, anamnese) | Amanda no app, após login Personal |
| Legais locais + exclusão de conta + e-mail `1diadecadavezsuporte@gmail.com` | Deploy Hosting (Firebase CLI) |
| Planos 7 dias / mensal / trimestral (anual “em breve”) | Ativar lojas só com autorização |
| Shorts no seed + parser YouTube (teste unitário) | QA no aparelho |

| O que ainda falta | Precisa de programador? |
|---|---|
| `firebase deploy --only hosting` | **Não** — quem tem o Firebase |
| Deploy das Functions + chave OpenAI no servidor | **Não** — Firebase + painel OpenAI. Se não souber CLI, 1 sessão guiada basta |
| 3 contas e teste no celular | **Não** |
| Listing Play / Data Safety | **Não** (Data Safety: alinhar com jurídico) |
| PNG 1024 da loja | **Não** — designer ou exportar do ícone existente |
| IPA / TestFlight | **Não necessariamente programador** — precisa **Mac + Xcode + conta Apple**. Pode ser o próprio Mac, um conhecido, ou um serviço de build (Codemagic). Sem Mac, iOS não sai deste Windows |
| Compra sandbox RevenueCat | **Não** — testers Play/Apple + chaves no build |
| Apertar rule `subscriptions` (Personal lê qualquer doc) | Opcional; muda Firebase. Só se quiser endurecer |

**Bloqueador que exige equipamento, não contratação:** gerar IPA no macOS.

**Quando faria sentido alguém técnico por poucas horas:** se não houver familiaridade com `firebase deploy` / OpenAI no servidor / `flutterfire configure` no iOS. Isso é apoio pontual, não um programador full-time.

---

## 5. Status geral por frente

| Frente | Status | Evidência |
|---|---|---|
| Código / RBAC | Aprovado no código e nas rules | `user_role.dart`, `firestore.rules`, testes |
| E2E 3 perfis | **FALHOU** (não executado) | Sem credenciais |
| Segurança nuvem | **Não aprovada** | Functions 400/404; App Check sem enforce |
| Legais locais | PASSOU (teste) | `test/etapa7_legal_test.dart` |
| Legais no ar | **FALHOU** | GET 19/09/2026 |
| Android loja | **Não pronto** | Listing + legais + E2E |
| iOS loja | **Não pronto** | Mac + Firebase iOS |
| Assinaturas sandbox | **Não validado** | Sem compra |
| IA / foto | **Não pronto** | Nuvem antiga / 404 |
| Conteúdo | Parcial | Seed + CMS no código; sem QA aparelho |

---

## 6. Android

| Item | Valor / achado |
|---|---|
| applicationId | `com.metodo1dia.app` |
| versionName / versionCode | `1.0.0` / `1` |
| minSdk | 23 |
| targetSdk / compileSdk | 36 |
| R8 / minify | Ligado no release |
| BILLING | Permissão no `AndroidManifest.xml` |
| Keystore | Existe **localmente** (`android/key.properties` + JKS), gitignored. Sem ele o Gradle assina debug e a Play recusa. |
| Ícone launcher | mipmap presente nesta máquina |
| Ícone 1024 loja | **Falta** `assets/app_icon/app_icon.png` |
| AAB de loja nesta auditoria | **Não gerado** (bloqueadores 1–4 continuam; não publicar) |

Comando técnico quando os bloqueadores 1–4 forem resolvidos (**não enviar à Play sem autorização**):

```bat
flutter build appbundle --release --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

Não usar `PAYMENTS_ENABLED=true` sem autorização.

---

## 7. iOS

| Item | Achado |
|---|---|
| Bundle ID | `com.metodo1dia.app` |
| Firebase iOS | `apiKey` / `appId` = `REPLACE_ME` em `lib/firebase_options.dart` |
| GoogleService-Info.plist | Não no repositório |
| Entitlements IAP | Não encontrados |
| Microfone | Removido do `Info.plist` (sem gravação no código) |
| Ícone 1024 | Arquivo local em `ios/Runner/Assets.xcassets/...` (pasta `ios/` quase toda **fora do GitHub**) |
| IPA / TestFlight / App Store | **Impossível neste Windows** |

Falta no Mac: `flutterfire configure`, signing Apple, capabilities, TestFlight, App Privacy.

---

## 8. Firebase

| Superfície | Achado |
|---|---|
| Authentication | E-mail/senha, reset, conta desativada → sign-out (código) |
| Firestore rules | Catch-all `if false`. Sem `allow read, write: if true`. `noPrivilegedFields`. Admin = `admins/{uid}` |
| Storage | Auth + imagem + tamanho. `/public` leitura aberta (capas) |
| Functions no ar | `amandaChat`, `calorieVision`, `getContentUrl`, `getVideoUrl`, `redeemCoupon`, triggers de treino/corrida/usuário. **Sem** `accompanimentAi` |
| Functions locais a mais | `accompanimentAi`, `googleCalendar`, `adminManageUser`, `startFreeTrial` |
| App Check | Cliente ativa em release; `ENFORCE_APP_CHECK` **off** |
| Ambientes | Um projeto só |

---

## 9. Segurança

| Tema | Resultado |
|---|---|
| Secrets no GitHub | Nenhum `.env`, service account ou keystore versionado |
| OpenAI no app | Não. Só via Functions |
| Guest / debug premium | `false` (teste) |
| Login local falso em release | Bloqueado (etapa 8) |
| Splash vs guest residual | **Corrigido nesta auditoria** — ver seção 16 |
| Logs de token | Não encontrados |
| Rule `subscriptions` | Qualquer Personal lê qualquer doc (não alterada — seria Firebase) |
| Functions no ar sem Bearer | Bloqueador (deploy pendente) |

Nenhuma senha, token ou chave privada está neste relatório.

---

## 10. Aluno / Personal / Administrador

### O que o código garante (não substitui E2E)

**Aluno:** cadastro público sempre aluno. Não entra em `/admin` (vai para `/home`). Não entra em `/personal-trainer/*` de gestão. Não escreve `isAdmin` / `isPersonalTrainer` / `isPremium`.

**Personal:** home em `/personal-trainer`. Pode CMS: vídeos, áudios, receitas, Lily, fotos Amanda, desafios, alunos, anamnese. **Não** entra no painel técnico `/admin`. **Não** promove papéis. Apostilas (`ebooks`): Firestore só Admin escreve — a UI agora esconde publicar/apagar para Personal (consulta liberada).

**Admin Técnico:** só se existir `admins/{uid}`. Flag órfã `users.isAdmin` não eleva. Gerencia usuários/papéis, cupons, e-books, assinaturas (leitura). Métricas do dashboard (`1.284`, `342`…) são **placeholder**, não dados reais. Push admin = stub “não implementado”.

**Logout:** `lib/core/auth/session_sign_out.dart` — Perfil, Configurações, Admin, Painel Personal, CMS.

**Troca de perfil:** sem tela “virar Personal”. Troca = sair e entrar em outra conta. Não testado em aparelho.

### Área do aluno (código vs aparelho)

Telas existem: Home, treinos, cronômetro, desafio, calendário/agenda, hidratação, IMC/evolução, calorias/foto, vídeos, apostilas, áudios/meditações, receitas, perfil, notificações, favoritos.  
**Aparelho (branco, travar, loading infinito, back):** não revalidado agora. Correções de empty/error/loading e `PopScope` no cronômetro já estão no código de etapas anteriores.

### Área da Personal

Amanda **consegue no app** (após login Personal), sem desenvolvedor: adicionar/editar/remover vídeos, fotos, textos, Quem sou eu (atalho no hub nesta auditoria), receitas, áudios, desafios, alunos, consultar/editar anamnese vinculada.  
**Não consegue sozinha:** gravar apostilas no Firestore (regra Admin); implantar Functions; alterar preços das lojas; promover Admin.

### Administrador

Painel `/admin` + usuários/papéis. Sair da conta no AppBar. Relatórios de negócio ao vivo **não existem**. Preços **não** se editam no painel (loja / `PlanCatalog`).

---

## 11. Anamnese

| Item | Status |
|---|---|
| Coleção | `pt_anamnesis/{studentId}` |
| Criar / editar / ver | Código + rules (aluno vinculado, Personal dona, Admin) |
| Sem vínculo | Formulário bloqueia “Continuar” |
| Persistência | Firestore (não testada com conta real) |
| Pronto para loja? | Código sim; E2E **não**. Se a vitrine vender acompanhamento, E2E é bloqueador |

Não faltou tela estrutural. Faltou teste com dados reais. Rules não foram abertas.

---

## 12. Vídeos

Três Shorts no seed `assets/content/videos_biblioteca.json`:

- `https://youtube.com/shorts/34PHGKECMTY`
- `https://youtube.com/shorts/3T0HDPX4jkk`
- `https://youtube.com/shorts/zRSTnW3EMF8`

Parser YouTube (watch / shorts / embed) **PASSOU** em `test/youtube_launch_test.dart`. Player in-app: WebView embed + fallback navegador (`youtube_launch.dart`, `youtube_in_app_screen.dart`).  
**Reprodução no aparelho / iOS:** não revalidada. Play em iframe de ferramenta interna já falhou antes (erro YouTube 153) — isso **não** prova o player nativo.

---

## 13. Áudios

Resolver: asset local (Programa 7 Dias) → URL → Storage → Function `getContentUrl`. Erros viram mensagem amigável; timeout 12s; player com play/pause.  
**Nenhum áudio foi tocado nesta auditoria.** Não marcar “todos reproduzem”.

---

## 14. Assinaturas e regras das lojas

Estrutura desejada no código:

| Plano | Código |
|---|---|
| Teste 7 dias | `PlanCatalog.trialDays = 7`; Function `startFreeTrial` (local, deploy incerto) |
| Mensal | `metodo1dia_premium_mensal` |
| Trimestral | `metodo1dia_premium_trimestral` (destaque) |
| Anual | `metodo1dia_premium_anual` — `comingSoon: true` |

Preços de vitrine (fallback, **não definitivos**): `AppConstants.premiumMonthlyPrice` / `premiumQuarterlyPrice` (`lib/core/constants/app_constants.dart`). Quando a cobrança da loja estiver ligada, o preço da Play/Apple **manda**.

**Orientação de política:** conteúdo digital consumido no app → **obrigatório** Google Play Billing e Apple IAP/StoreKit. RevenueCat já é o adaptador. **Não** implementar checkout externo (Pix, Stripe, Mercado Pago) para desbloquear o app. Cobrança real **não foi ativada**.

---

## 15. LGPD / privacidade

| Item | Status |
|---|---|
| Política e Termos locais | PASSOU (teste) |
| No ar | **FALHOU** (ver bloqueador 1) |
| Suporte | `1diadecadavezsuporte@gmail.com` em `AppLegal` |
| Consentimento cadastro | Checkbox no registro |
| Exclusão de conta | Configurações + digitar `EXCLUIR` |
| Exclusão total | Não apaga `pt_messages` (documentado; honesto) |
| Data Safety / App Privacy | **Não preenchidos nas consoles** |

---

## 16. Erros corrigidos nesta auditoria

Backup **antes** das correções: tag `backup-auditoria-publicacao-completa-20260919`.  
**Produção não foi alterada.**

| Correção | Arquivo | Motivo |
|---|---|---|
| Splash ignorava `enableGuestMode` | `lib/features/splash/presentation/splash_screen.dart` | Pref residual de visitante mandava para Home e o router devolvia ao login |
| Personal via FAB publicava apostila e tomava erro de rule | `lib/features/ebooks/presentation/ebooks_admin_screen.dart` | Write de `ebooks` é só Admin; UI agora só consulta |
| “Quem sou eu” fora do hub CMS | `lib/features/personal_cms/presentation/personal_cms_hub_screen.dart` | Atalho para a tela que já existia (`/admin/amanda-profile`) |

Testes repetidos depois: **30 passaram**.

Não corrigido de propósito (produção / escopo): deploy Hosting, deploy Functions, rules de `subscriptions`, Firebase iOS, AAB/IPA, pagamentos.

---

## 17. Erros encontrados (não corrigidos ou só no ar)

- Termos publicados com cabeçalho pessoal; privacidade duplicada no ar.
- Functions sem auth efetiva; `accompanimentAi` 404.
- Admin dashboard com números fictícios.
- Push / abas Receitas-Desafios do Admin: stub.
- Anual “em breve”; sandbox sem compra.
- `google_sign_in` no `pubspec` sem fluxo usado.
- 79 pacotes com versão mais nova — **não atualizados** (risco alto sem necessidade).
- Working tree sujo (homolog, logs, `ios/` local).

---

## 18. Ícones, navegação, responsividade, performance, erros, logs, dependências

| Tema | Achado |
|---|---|
| Ícones | Launcher Android OK local; PNG 1024 Play **falta**. Lily/exercícios: não houve passe visual de aparelho agora |
| Voltar | Login `canPop: false` (intencional). Cronômetro/treino pedem confirmação. Sem E2E de “preso” |
| Responsividade | Sem iPhone / 3 tamanhos Android nesta sessão |
| Performance | Sem profiling. Otimizações agressivas não feitas |
| Erros ao usuário | `FirebaseErrorMapper` + empty/error widgets no código; Functions antigas ainda podem falhar feio |
| Logs | Sem print de token. `debugPrint` de erro genérico em debug |
| Dependências | Firebase 3.x/5.x; `purchases_flutter` 8.11.0. Sem upgrade em massa |

Não executei `flutter clean` + `flutter build appbundle --release` nesta rodada: o AAB não ficaria aprovado para envio enquanto os bloqueadores 1–4 existirem, e o clean apagaria cache sem mudar o veredito.

---

## 19. Testes executados

| Teste | Resultado | Ambiente |
|---|---|---|
| etapa6 IA/foto | 5 passaram | Windows / Flutter |
| etapa7 legal | 3 passaram | Windows / Flutter |
| etapa8 segurança | 4 passaram | Windows / Flutter |
| seed 3 Shorts | passou | Windows / Flutter |
| YouTube IDs/URLs | 3 passaram | Windows / Flutter |
| catálogo assinaturas | 15 passaram | Windows / Flutter |
| **Total desta rodada** | **30 passaram** | 19/09/2026 |
| GET legais no ar | Termos sujos; privacidade duplicada | Hosting produção |
| POST Functions sem token | 400 / 400 / 404 | us-central1 |
| Login 3 perfis / aparelho | **Não executado** | Sem contas |
| iPhone / TestFlight / AAB | **Não executado** | Windows / bloqueadores |

---

## 20. Fluxos pedidos (cadastro → … → logout)

| Fluxo | Resultado |
|---|---|
| Aluno completo | **Não executado** |
| Personal completo | **Não executado** |
| Admin completo | **Não executado** |

O código prevê cada etapa. Sem contas, o fluxo não foi repetido depois das correções.

---

## 21. Pendências e recomendações

**Obrigatório (bloqueadores):** lista da seção 3.

**Recomendado:** App Check em monitor → enforce; restringir API keys no Cloud; aceitar por escrito um Firebase só ou criar staging depois; testers sandbox se for vender; commitar só o release (sem keystore/`.env`/lixo de homolog).

**Pós-lançamento:** exportação LGPD; limpar `pt_messages` órfãos; lock-screen de áudio; remover `google_sign_in` se não for usado; números reais no Admin.

---

## 22. Arquivos gerados / alterados nesta auditoria

**Relatórios**

- `docs/AUDITORIA_FINAL_PUBLICACAO_METODO_1_DIA.md`
- `docs/AUDITORIA_FINAL_PUBLICACAO_METODO_1_DIA.pdf`

**Código (local, não publicado)**

- `lib/features/splash/presentation/splash_screen.dart`
- `lib/features/ebooks/presentation/ebooks_admin_screen.dart`
- `lib/features/personal_cms/presentation/personal_cms_hub_screen.dart`

**Backup:** `backup-auditoria-publicacao-completa-20260919`

---

## 23. Veredito em uma linha

**Não publique agora na Google Play nem na App Store.**  
Feche os 7 itens da seção 3 — a maior parte sem contratar programador — e só então gere AAB/IPA e envie para revisão.
