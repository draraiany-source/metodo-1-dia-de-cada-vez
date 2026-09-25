# RELATÓRIO FINAL — Método 1 Dia de Cada Vez (Amanda Lopes)

| Campo | Valor |
|---|---|
| Data da auditoria | 22/09/2026 |
| App | Método 1 Dia de Cada Vez |
| Package / Bundle | `com.metodo1dia.app` |
| Versão | `1.0.0+1` (`pubspec.yaml`) |
| Branch | `finalizacao-metodo-1-dia-de-cada-vez` |
| HEAD (último commit) | `293ffa9` (working tree com otimizações de tamanho **não commitadas**) |
| Backup | tag `backup-pre-homologacao-final-20260922` |
| Firebase | `metodo1dia-app` (único projeto — homolog = produção) |
| Cobrança real | **Desligada** (`PAYMENTS_ENABLED=false`) |
| Publicação nesta etapa | **Não realizada** (conforme pedido) |

---

## STATUS GERAL

# 🟡 PENDÊNCIAS ANTES DA PUBLICAÇÃO

Não declarar “pronto para publicar” apenas porque existe APK/AAB técnico.  
Fluxos críticos **não** foram revalidados E2E com contas reais Aluno/Personal/Admin nesta sessão.  
Há bloqueadores operacionais (lojas, legais no ar, Functions, iOS) e conteúdo possivelmente só no Firestore.

---

## 1. Resumo executivo

O aplicativo Flutter está **avançado e funcionalmente rico**: Auth Firebase, RBAC (Aluno/Personal/Admin), home, treinos, hidratação, receitas, vídeos YouTube separados das lições, meditações/Programa 7 Dias via Shorts, PDFs remotos, área Amanda/Personal, planos/RevenueCat estruturado, exclusão de conta, minify/R8, guest mode **off**.

Redução de tamanho recente (não commitada no HEAD): APK fat **149,47 MB** / arm64 **104,61 MB** (antes ~235 MB pós-remoção de MP3).

**Não está pronto para as lojas** enquanto: (1) E2E dos 3 perfis não for executado e documentado; (2) listing/Data Safety/screenshots não existirem; (3) Hosting legal / Functions não forem confirmados em produção; (4) iOS não tiver `flutterfire configure` + Mac; (5) AAB de loja assinado não for regenerado e arquivado após commit das otimizações.

---

## 2. Situação atual por frente

| Frente | Classificação | Evidência |
|---|---|---|
| Código / arquitetura Flutter | ✅ CONCLUÍDO | Features em `lib/features/*`, Riverpod, go_router |
| RBAC no código + rules | ✅ CONCLUÍDO (código) / ⚠️ PRECISA CONFERIR (E2E) | Rules com deny catch-all; sem E2E UID |
| Guest / login falso | ✅ CONCLUÍDO | `enableGuestMode = false` |
| Meditações YouTube (7 Shorts) | ✅ CONCLUÍDO (código + teste Android prévio) | Seed + player; usuário já validou 7 vídeos |
| Programa 7 Dias → YouTube | ✅ CONCLUÍDO | MP3 locais removidos |
| Biblioteca de vídeos (separada) | ✅ CONCLUÍDO (código) / ⚠️ PRECISA CONFERIR | Seed + CMS Personal; Firestore é fonte de verdade |
| Troca Shorts `lLfcuiW32iI` → `akKcU1UVUYw` | ⚠️ PRECISA CONFERIR | **ID antigo não existe no repositório local** — provável só Firestore/CMS |
| Otimização tamanho Android | ✅ CONCLUÍDO (artefatos) / 👨‍💻 DEPENDE DO PROGRAMADOR (commit) | APK 149,47 MB; working tree suja |
| APK release local | ✅ CONCLUÍDO | `build/.../app-release.apk` e split ABI |
| AAB atual pós-otimização | ❌ PRECISA CORRIGIR | AAB do build atual **ausente** no disk (só APKs) |
| Assinatura Android (keystore) | ✅ CONCLUÍDO (local) / 👩‍💼 DEPENDE DA PROPRIETÁRIA (cópia segura) | `key.properties` gitignored; keystore local |
| Pagamentos produção | ✅ CONCLUÍDO (desligado) | `PAYMENTS_ENABLED=false` — correto até autorização |
| Sandbox IAP | ⚠️ PRECISA CONFERIR | Não revalidado nesta sessão |
| Firebase Functions IA | 🚨 BLOQUEIA PUBLICAÇÃO (se IA for vitrine) / ⚠️ | Relatórios anteriores: nuvem desatualizada |
| Legais locais (`public/`) | ✅ CONCLUÍDO | `privacidade.html` / `termos.html` com e-mail suporte |
| Legais no Hosting | ⚠️ PRECISA CONFERIR | Revalidar GET após último deploy |
| E2E Aluno/Personal/Admin | 🚨 BLOQUEIA PUBLICAÇÃO | Sem PASSOU documentado com contas reais |
| Google Play listing | 🚨 BLOQUEIA PUBLICAÇÃO | Screenshots, Data Safety, textos |
| App Store / iOS | 🚨 BLOQUEIA PUBLICAÇÃO | `REPLACE_ME` no iOS Firebase; Windows sem IPA |
| Ícone 1024 | ✅ CONCLUÍDO | `assets/app_icon/app_icon.png` presente |

---

## 3. Funcionalidades concluídas (código presente)

- Cadastro / login / logout / recuperação de senha (código)
- Perfil, home, treinos + catálogo oficial + Lily
- Cronômetro de treino, hidratação + meta/histórico
- Receitas (ícones neon), apostilas/PDFs remotos
- Vídeos (área própria) + meditações YouTube
- Áudios Programa 7 Dias via Shorts
- Calendário, metas, conquistas, notificações locais
- IMC/calorias (módulo), fotos Amanda, “Quem sou eu”
- Área Personal / Admin (CMS vídeos, roles)
- Exclusão de conta (`AuthRepository.deleteAccount`)
- Política/Termos URLs via dart-define

**Regra:** tela existente ≠ fluxo validado. Itens acima em **código** = ✅; E2E = ⚠️/🚨.

---

## 4. Pendências, bugs e riscos

### Conteúdo — Shorts `lLfcuiW32iI`

Busca completa em `assets/`, `lib/`, `test/`, tools: **zero ocorrências** de `lLfcuiW32iI`.  
O seed local (`videos_biblioteca.json`) tem apenas 3 Shorts de método + 7 meditações (outros IDs).  
**Conclusão:** o vídeo a substituir provavelmente está só no **Firestore** (publicado pelo CMS da Personal).  
**Ação:** Amanda/Personal edita o card no app **ou** programador atualiza o documento no Console. Não há arquivo local a alterar.

### Riscos

| Risco | Severidade |
|---|---|
| Um Firebase só (teste = prod) | Alta operacional |
| Working tree enorme não commitada (PNG→JPG) | Médio (perda/reprodutibilidade de build) |
| `key.properties` na máquina (senhas) — **não versionado** | Médio se backup da Amanda não existir |
| Functions/IA sem revalidação | Médio/Alto se feature for prometida na loja |
| iOS incompleto | Bloqueia App Store |

---

## 5. Bloqueadores de publicação (P0)

1. E2E dos 3 perfis no aparelho com evidência (login, conteúdos, logout, troca).
2. Material das lojas (screenshots, feature graphic, Data Safety / App Privacy, textos).
3. Confirmar Hosting de privacidade/termos no ar.
4. Regenerar **AAB assinado** após consolidar otimizações de assets.
5. iOS: `flutterfire configure` + Mac + signing (se publicar iOS agora).
6. Contas de revisor Play/Apple + e-mail suporte acessível.

---

## 6. Android

| Item | Status |
|---|---|
| applicationId `com.metodo1dia.app` | ✅ |
| versionName / versionCode `1.0.0` / `1` | ✅ |
| minSdk 23 / targetSdk 36 | ✅ |
| minify + shrinkResources | ✅ |
| Ícone / splash | ✅ |
| APK fat 149,47 MB / arm64 104,61 MB | ✅ |
| AAB pós-otimização | ❌ regenerar |
| Keystore local | ✅ (gitignored) |
| PAYMENTS_ENABLED | ✅ false |

---

## 7. iOS

| Item | Status |
|---|---|
| Pasta `ios/` | ⚠️ presente localmente / versionamento a conferir |
| `firebase_options` iOS | ❌ `REPLACE_ME` |
| IPA / TestFlight nesta máquina | ❌ Windows |
| Signing Apple | 👩‍💼 + 👨‍💻 |

---

## 8. Privacidade e conta

| Item | Status |
|---|---|
| Política / Termos locais | ✅ |
| E-mail suporte `1diadecadavezsuporte@gmail.com` | ✅ |
| Exclusão de conta no app | ✅ código |
| Revisão jurídica dos textos | 👩‍💼 + jurídico |
| Data Safety / App Privacy forms | 👩‍💼 + 👨‍💻 |

**Não inventar conformidade legal.** Textos locais existem; validação jurídica = proprietária.

---

## 9. Infraestrutura

- Firebase Auth / Firestore / Storage / Messaging / Analytics / Crashlytics / App Check (activate)
- Hosting `metodo1dia-app.web.app`
- Cloud Functions (código no repo; estado da nuvem a revalidar)
- RevenueCat estruturado, cobrança off
- OpenAI **somente servidor** (correto no desenho)

---

## 10. Publicação

**NÃO publicar nesta etapa.**  
Ordem: CORRIGIR → TESTAR (checklist) → HOMOLOGAR com Amanda → APROVAR → só então enviar AAB/IPA.

Entregáveis irmãos:

1. `CHECKLIST_HOMOLOGACAO_FINAL.md`
2. `PENDENCIAS_PROGRAMADOR.md`
3. `PENDENCIAS_AMANDA.md`
4. `INVENTARIO_ENTREGA_TECNICA.md`
5. `CHECKLIST_PUBLICACAO_ANDROID_IOS.md`
