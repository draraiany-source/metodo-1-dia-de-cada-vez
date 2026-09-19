# Auditoria final — Método 1 Dia de Cada Vez

Data: 19/09/2026  
Branch: `finalizacao-metodo-1-dia-de-cada-vez` (`ccd3a51`, ahead do GitHub)  
Backup: tag `backup-etapa-auditoria-final-20260919`  
Testes reexecutados nesta auditoria: 12 passaram (etapas 6–8).  
**Nenhum E2E com login real dos 3 perfis. Não inventei PASSOU.**  
Não publiquei. `PAYMENTS_ENABLED=false`. Rules não abertas.

---

## Veredito

### ANDROID
- Pronto para gerar AAB: **NÃO** (keystore local existe, mas o release de loja ainda tem bloqueadores)
- Pronto para Google Play: **NÃO**
- Bloqueadores: Hosting legal antigo (e-mail pessoal nos Termos); Functions IA sem auth na nuvem; sem contas de revisão; sem screenshots/feature graphic/Data Safety; ícone 1024 de loja ausente; working tree com muita alteração não commitada; um Firebase só (homolog=prod)

### iOS
- Pronto para gerar build: **NÃO**
- Pronto para TestFlight: **NÃO**
- Pronto para App Store: **NÃO**
- Bloqueadores: Windows não gera IPA; Firebase iOS `REPLACE_ME`; pasta `ios/` em grande parte só local; sem signing Apple; sem IAP entitlements; mesmos legais/ícone/screenshots

### SISTEMA
- Segurança aprovada: **NÃO** (Functions públicas + legal no ar + App Check sem enforce)
- RBAC aprovado: **SIM no código/rules** — **NÃO no E2E** (sem UIDs de teste)
- Pagamentos aprovados em sandbox: **NÃO**
- Conteúdo aprovado: **PARCIAL** (Shorts no seed; sem QA de aparelho)

Quando quiser **só** gerar AAB técnico local (não enviar à Play):

```bat
flutter build appbundle --release --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

Não coloque `PAYMENTS_ENABLED=true`. Sem `key.properties` o Gradle assina debug e a Play recusa. Keystore local: `android/keystore/upload-keystore.jks` (existe nesta máquina; não versionar).

---

## 1. Etapas anteriores (consolidado)

| Etapa | Conclusão honesta |
|---|---|
| Login/logout/RBAC | Código + unitário PASSOU. E2E 3 perfis FALHOU (sem contas) |
| Área aluno / visual | Correções no código + testes. Sem aparelho |
| Vídeos Shorts | Seed/CMS no código. Play no app real não revalidado aqui |
| RevenueCat | SDK/IDs prontos. Sandbox E2E FALHOU |
| IA / foto / Functions | Código novo sem fake 200. **Nuvem antiga** sem Bearer; accompaniment 404 |
| Legal | HTML local limpo. **Hosting ainda sujo** |
| Segurança | Demo login e guest residual bloqueados. Enforce App Check off |

Guest `false`. Debug premium `false`. Cobrança `false`.

---

## 2–5. E2E Aluno / Personal / Admin / troca

**FALHOU / não executado.** Não há e-mail/senha/UID de teste nesta sessão. Sem isso, marcar PASSOU seria inventar.

O que o código prevê (não substitui teste):

- Logout único `signOutAndGoToLogin` (Auth + sessão local + guest + `context.go(login)`)
- Login `PopScope(canPop: false)`
- Conta `disabled` → sign-out
- Admin só com `admins/{uid}`
- Aluno não entra em `/admin` nem `/personal-trainer/*` de gestão
- Personal não gerencia papéis

Saudação: `homeGreeting` evita “Olá, !”.

---

## 6. Firebase (hoje)

| Superfície | Evidência |
|---|---|
| Auth | E-mail/senha, reset, too-many-requests no código |
| Firestore rules | Catch-all deny; sem allow-true (teste) |
| Storage rules | Auth + tipo + tamanho; `/public` leitura aberta |
| Functions | `amandaChat`/`calorieVision` POST sem token → **400** (não 401). `accompanimentAi` **404** |
| App Check | Activate Android/iOS; Web off; enforce off |
| iOS Firebase | `REPLACE_ME` |

---

## 7. RevenueCat

Sandbox: **não pronto**. Produção: **proibida** (`PAYMENTS_ENABLED=false`).  
Falta: chaves no build, produtos Play/ASC, testers, offering validada, IAP iOS.

---

## 8. IA / foto

Não considerar pronto. Fallback local existe e é declarado. Function nova não implantada. Sem OpenAI confirmada. Sem foto real analisada nesta auditoria.

---

## 9. UI

Polimento no código (SafeArea, loading, vazios). Sem passe em iPhone. Android homolog antigo não refeito agora. Ícone mipmap existe; PNG 1024 de loja **não**.

---

## 10. Legal

Local: OK (teste).  
**No ar (19/09/2026):** Termos ainda começam com `dra.raiany@gmail.com`. Privacidade tem **2** `</html>`.  
Ação: `firebase deploy --only hosting --project metodo1dia-app` (não é publicar o app).

---

## 11–14. Lojas

Play: package `com.metodo1dia.app`, version `1.0.0+1`, target 36, minify sim, BILLING no manifest, exclusão no app. Falta listing, Data Safety, revisor, IAP se for vender.

TestFlight: **NÃO**. Precisa macOS + Apple + Firebase iOS + IPA.

---

## 15–16. Performance / crash

Sem profiling de aparelho. Crashlytics no Android se Firebase sobe. Sem revisão de crash do Console aqui.

---

## 17. Dados de teste

Não apaguei nada.

| Destino | O quê |
|---|---|
| MANTER TEMPORARIAMENTE | Contas de homolog quando forem criadas; seed de Shorts |
| REMOVER ANTES DA PRODUÇÃO | Usuários Ana Silva/demo se existirem no Auth; dados de web homolog misturados; HTML legal antigo no Hosting |
| PODE PERMANECER | Conteúdo institucional Amanda/Lily; catálogo de treinos/receitas publicado |

UIDs de teste: **não provisionados**.

---

## 18. Segurança

- Sem senha/OpenAI/service account no git auditado  
- Client API keys Firebase públicas (restringir no Cloud)  
- `key.properties` só local  
- Sem guest/debug auth em release  
- Functions na nuvem **ainda inseguras**  
- Legal no ar **ainda vaza e-mail pessoal**
