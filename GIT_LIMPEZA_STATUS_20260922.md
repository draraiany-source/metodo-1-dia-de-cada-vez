# GIT limpeza — 2026-09-22

## Causa dos “10.000+ arquivos”

Não eram 10k mudanças reais do projeto. Em disco:

| Pasta | Arquivos (aprox.) | Situação |
|-------|-------------------|----------|
| `build/` | **~24.034** | Já ignorada; artefato de `flutter build` / Gradle |
| `.dart_tool/` | ~73 | Já ignorada |
| `tools/_excluded_from_bundle/` | ~216 | Já ignorada |
| `assets/_incoming*`, `_validation`, backups | centenas | Staging / backup / validação visual |

Quando o Git indexava ou o status expandia essas pastas (ou `.gitignore` incompleto), o working tree parecia ter milhares de alterações. **O volume vinha de build/cache/exclusões**, não de 10k edições em `lib/` ou assets de produto.

Após reforçar `.gitignore` + `git rm --cached` só em artefatos: **status curto ~944 linhas** (ainda inclui staged deletions de backups e muitas trocas reais PNG→JPG / otimizações).

## O que foi uncached (`git rm -r --cached`, arquivos **permanecem no disco**)

- `assets/_validation/` (34)
- `assets/_incoming_lily/` (14)
- `assets/lily_exercicios/_incoming/` (17) — pasta já ausente no disco; só saiu do index
- `backup_assets_fast_20260815_095605/`
- `backup_assets_pre_alpha_20260814_193732/`
- `backup_assets_pre_alpha_20260814_193858/`

**Confirmado:** `git ls-files backup_assets*` → **0**  
**Confirmado:** `build/` e `.dart_tool/` **não** aparecem no `git status --short`.

**Não tocado:** assets validados em uso (lily cadeiras, amanda promo/optimized, ícones de produto). Sem commit / push / deploy.

## `.gitignore` (reforçado)

Já cobria / passou a cobrir de forma explícita: `build/`, `**/build/`, `.dart_tool/`, `**/.gradle/`, `caches/`, `.firebase/`, `tools/_excluded_from_bundle/`, `assets/_lily_backup*/`, `_lily_trim_preview/`, `_incoming*/`, `_validation/`, `_offbundle_backups/`, `assets/**/_backup*/`, `assets/**/_incoming/`, `backup_assets*/`, `analyze_*.txt`, logs locais de build/homolog/audit, etc.

## AAB

`build\app\outputs\bundle\release\app-release.aab`

- **155 639 605 bytes**
- **148,43 MB**

## Homologação web (sem deploy)

- URL documentada: https://metodo1dia-app--homologacao-cw9j2u83.web.app  
- HTTP GET: **200** (live)  
- Produção hosting: https://metodo1dia-app.web.app também **200**

## Smoke (sem alterar assets)

| Check | Resultado |
|-------|-----------|
| `assets/images/logo.svg` | OK |
| `lily_fit_cadeira_abdutora.jpeg` / `extensora.jpeg` | OK |
| `assets/amanda/promo/amanda_acenando.jpg` | OK |
| `assets/icons/app/inicio.jpg` | OK |
| `assets/audio_programs/*.mp3` | Ausentes **de propósito** (YouTube / hub de meditações) |
| PDFs de receitas | Remotos (Firestore + URL assinada); sem PDF local obrigatório |
| `dart analyze lib/core` | **Pulado** (travou) |

Full short status salvo em: `tools/_git_status_after_cleanup.txt`

## Status após limpeza (medida)

- **Total `git status --short`:** 944 linhas  
- Prefixos: ~428 modificados (` M` / similar), **358** untracked (`??`), **158** deleted staged (`D`, em grande parte uncache de artefatos + trocas de formato de assets)

### Por pasta (topo)

| Count | Top-level |
|------:|-----------|
| 661 | assets |
| 79 | tools |
| ~93 | backup_assets_* (**só staged D** após uncache — sumirão do status após commit futuro) |
| 21 | lib |
| 10 | ios |
| + | docs, test, pubspec, android, .gitignore, relatórios MD/PDF, logs residuais |

### Mudanças “reais” de produto (agrupado; exclui junk logs e uncache puro)

**~699** linhas ainda relevantes (maioria assets de formato/otimização já feitas no working tree):

| Count | Grupo |
|------:|-------|
| 234 | `assets/icons` (PNG→JPG / otimização) |
| 164 | `assets/images` |
| 76 | `assets/amanda` (optimized `M`; originals/promo PNG removidos; JPG novos) |
| 50 | `assets/lily` |
| 48 | `assets/lily_treinos` |
| 11 | `assets/mascot` |
| 7 | `assets/audio_programs` (MP3 locais `D` — YouTube) |
| 4 | `assets/lily_exercicios` (cadeiras OK no disco) |
| 21 | `lib/` (ícones, lily assets, áudio/YouTube, vídeos, CMS, `firebase_options`) |
| 79 | `tools/` (scripts auxiliares, muitos `??`) |
| + | `ios/`, `android/gradle.properties`, `pubspec.yaml`, `.gitignore` |

Lista completa: `tools/_git_status_after_cleanup.txt`.

## Pronto para teste Aluna / Personal / Admin?

**SIM — pronto para teste de perfis (Aluna / Personal / Admin)** com o AAB atual (~148,43 MB) e homolog web ao vivo.

Canal homolog:

**https://metodo1dia-app--homologacao-cw9j2u83.web.app**

Observações operacionais (não bloqueiam smoke de perfil):

- Working tree ainda sujo (centenas de mudanças de assets + scripts); **não** foi feito commit.
- `dart analyze` não foi revalidado nesta rodada (pulado).
- Teste E2E nos três perfis deve ser feito no app / homolog; esta limpeza só removeu ruído Git.
