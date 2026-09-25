# Regressão AAB — 22/09/2026

**App:** Método 1 Dia de Cada Vez (`com.metodo1dia.app`)  
**Escopo:** investigar ~597,66 MB → travar otimização → regenerar AAB release  
**Veredito:** AAB final **148,43 MB** (otimizado mantido; risco de regressão mitigado)  
**Não feito:** commit / push / publish na Play

---

## 1. Medição do AAB no disco (antes do rebuild desta sessão)

| Campo | Valor |
|---|---|
| Path | `build/app/outputs/bundle/release/app-release.aab` |
| Bytes | 155.639.603 |
| MB | **148,43 MB** |
| mtime | 22/09/2026 17:10:39 |

Esse AAB já estava no patamar “bom” (pós-otimização posterior à auditoria de 236 MB).  
A regressão histórica documentada foi **597,66 MB → 236,26 MB (−361,40 MB)** em `docs/AUDITORIA_OTIMIZACAO_TAMANHO.md`.

---

## 2. Inventário `assets/*` (antes de mover bloat)

Fonte: `tools/_folder_sizes_before.txt` / `tools/_probe_aab_regression_out.txt`

| Pasta | MB | Notas |
|---|---:|---|
| amanda | 107,76 | **originals = 105,41 MB** (15 JPG) |
| images | 60,54 | **icons_3d 11,13 + icons_3d_pack2 38,02** |
| icons | 54,82 | neon extras ~16,8 MB + treinos |
| lily | 43,33 | arte Lily |
| lily_exercicios | 20,71 | inclui `_backup` 0,43 + `_incoming` 4,94 |
| `_lily_backup_before_frame_fix` | 15,29 | raiz assets (não declarada) |
| `_lily_backup_before_pack_*` | 2,53 | raiz assets |
| `_lily_trim_preview` | 0,21 | raiz assets |

### Smoking guns verificados

1. **`assets/lily_exercicios/_backup_before_cadeiras_20260922/`** — sob `assets/lily_exercicios/` declarado → **entraria no próximo AAB** (~0,43 MB).
2. **`assets/_lily_backup_*` / `_lily_trim_preview`** — na raiz de `assets/`; **não** estavam em path declarado; AAB atual tinha **0** paths `_backup`. Movidos por higiene.
3. **`assets/amanda/`** declarado na raiz do pubspec + `promo/` + `optimized/` — `originals/` (~105 MB) era o maior risco de reinclusão; código usa só `promo/` e `optimized/` (`lib/core/constants/app_assets.dart`, `amanda_photos.dart`).
4. **`assets/images/` (raiz) no pubspec** — reabria `icons_3d` + `icons_3d_pack2` (~49 MB), só showcase/`kDebugMode`.
5. **`assets/icons/` (raiz)** — com subpastas neon não usadas no disco, reincluiria ~16+ MB; AAB atual já tinha só `neon/treinos` + 1 arquivo de `corrida`.

### AAB atual (antes do rebuild) — zip

| Métrica | Valor |
|---|---|
| Entries | 1334 |
| flutter_assets (uncomp.) | **77,26 MB** |
| MP3 | 0 |
| PNG / JPG | 387 / 425 |
| Paths `_backup` / `_incoming` / `amanda/originals` / `icons_3d*` | **0** |
| Maiores dirs em flutter_assets | icons 36,32 · lily_exercicios 15,34 · images 11,39 · mascot 5,39 · lily 3,44 · amanda 2,35 |

Ou seja: o AAB de 148 MB **ainda não** continha os culpados; o risco era **rebuild com pubspec/disco regressivo**.

---

## 3. Culpados da regressão ~362 MB (histórico 597 → 236)

Alinhado à auditoria de 20/09 + estado do disco em 22/09:

| Culprit | ~MB | Mecanismo |
|---|---:|---|
| Imagens não recomprimidas (pré-otimização) | ~290 | JPEG/PNG grandes no bundle |
| `icons_3d` + `icons_3d_pack2` sob `assets/images/` | ~49 | declaração ampla / showcase |
| neon extras (`navegacao/saude/nutricao/conquistas/perfil` + extras corrida) | ~17–50* | sob `assets/icons/` |
| `amanda/originals` (risco atual) | ~105 | sob possível `assets/amanda/` |
| `_backup` / `_incoming` em `lily_exercicios` | ~5 | pasta pai declarada |

\*Valores históricos de neon variam conforme recompressão.

**Soma típica da redução documentada:** **~361 MB** (597,66 → 236,26).

---

## 4. Correção aplicada (sem apagar arte usada)

### Movido para `tools/_excluded_from_bundle/aab_regression_20260922_192425/`

| Origem | MB |
|---|---:|
| `assets/amanda/originals` | 105,41 |
| `assets/images/icons_3d_pack2` | 38,02 |
| `assets/_lily_backup_before_frame_fix` | 15,29 |
| `assets/images/icons_3d` | 11,13 |
| `assets/icons/neon/conquistas` | 5,56 |
| `assets/lily_exercicios/_incoming` | 4,94 |
| `assets/icons/neon/saude` | 4,45 |
| `assets/icons/neon/nutricao` | 4,01 |
| `assets/_lily_backup_before_pack_*` | 2,53 |
| `assets/icons/neon/navegacao` | 2,31 |
| `assets/icons/neon/perfil` | 0,50 |
| `assets/lily_exercicios/_backup_before_cadeiras_20260922` | 0,43 |
| extras `neon/corrida` (exceto JPG declarado) | ~1,7 |
| `_lily_trim_preview` | 0,21 |

**Total movido ≈ 196 MB** para fora das árvores empacotáveis.

### `pubspec.yaml`

- Removido `assets/images/` (raiz); mantidas subpastas usadas + `logo.svg` / `logo_mark.svg` / `splash.svg`.
- Removido `assets/amanda/` (raiz); mantidos `promo/`, `optimized/`, `thumbs/`.
- Mantido `assets/icons/` (PNGs na raiz) após remover neon morto do disco.
- Comentários atualizados sobre `_backup` / `_incoming`.

### Preservado (obrigatório)

- `assets/lily_exercicios/lily_fit_cadeira_abdutora.jpeg` — **EXISTS**
- `assets/lily_exercicios/lily_fit_cadeira_extensora.jpeg` — **EXISTS**
- Refs em `lib/core/lily/lily_exercicio_assets.dart` (`treino_034`, `treino_046`) — intactas

---

## 5. Rebuild (concluído)

Comando efetivo (via `tools/_rebuild_aab_lowmem.cmd`):

```bat
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
set GRADLE_USER_HOME=C:\Users\Lenovo\.gradle
C:\Users\Lenovo\Desktop\flutter\flutter\bin\flutter.bat build appbundle --release --split-debug-info=build/app/debug-info --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

| Campo | Valor |
|---|---|
| Resultado | **SUCCESS** (`√ Built … app-release.aab (148.4MB)`) |
| Path | `build\app\outputs\bundle\release\app-release.aab` |
| Bytes | **155.639.605** |
| MB | **148,43 MB** |
| mtime | 22/09/2026 **21:50:05** |
| Gradle | ~934 s (após fix de heap) |
| `flutter_assets` | **77,26 MB** |
| MP3 / PNG / JPG | **0** / 387 / 425 |
| Paths `_backup` / `_incoming` / `originals` / `icons_3d*` | **0** |
| Cadeiras no AAB | **2** (`lily_fit_cadeira_abdutora.jpeg`, `lily_fit_cadeira_extensora.jpeg`) |

### Problemas de build encontrados (e correção)

1. **Gradle cache no Cursor sandbox** (`…\Temp\cursor-sandbox-cache\…\gradle\caches`) → `immutable workspace … have been modified`. Fix: `GRADLE_USER_HOME=C:\Users\Lenovo\.gradle`.
2. **OOM nativo** com `-Xmx5120m` em host ~7 GB RAM (`hs_err_pid*.log`). Fix: `android/gradle.properties` → `-Xmx2048m`, workers.max=2.

---

## 6. Inventário `assets/*` (depois)

| Pasta | MB | Files | Delta vs antes |
|---|---:|---:|---|
| **TOTAL assets** | **125,09** | 891 | **−196,47 MB** (321,56 → 125,09) |
| lily | 43,33 | 179 | = (subpasta `treinos lily fit` ~40 MB **não** empacotada) |
| icons | 36,32 | 231 | −18,5 (neon extras movidos) |
| lily_exercicios | 15,34 | 119 | −5,37 (`_backup`+`_incoming` fora) |
| images | 11,39 | 105 | −49,15 (`icons_3d*` fora) |
| mascot | 6,09 | 33 | = |
| amanda | 2,35 | 53 | −105,41 (`originals` fora) |
| lily_treinos | 2,54 | 24 | = (já JPG otimizado) |

### Estimativa do que o pubspec empacota (só nível declarado)

**~76,98 MB** de arte. Maiores itens empacotados:

| Dir declarado | MB |
|---|---:|
| `assets/icons/` (raiz PNGs UI) | 32,08 |
| `assets/lily_exercicios/` | 15,34 |
| `assets/lily/` (raiz) | 3,44 |
| `assets/mascot/png` + `extras` | 5,40 |
| `assets/images/recipes/neon` | 2,15 |
| `assets/lily_treinos/` | 2,54 |
| `assets/amanda/promo`+`optimized`+`thumbs` | 2,35 |
| `assets/icons/neon/treinos` | 1,40 |

**PNGs:** raiz de `icons/` ainda ~32 MB (42 PNG ~0,7–1,3 MB) — já no estado pós-1ª otimização (não restaurados aos ~2 MB fotográficos). Receitas/lily_treinos/promo permanecem JPG leves. **Não** foi necessário re-rodar `tools/otimizar_imagens_empacotadas.py`.

**Áudio:** `assets/audio_programs` **ausente**; não declarado no pubspec; 0 MP3 no AAB (meditações migradas).

---

## 7. Antes → Depois (resumo)

| Métrica | Antes (sessão) | Depois |
|---|---:|---:|
| AAB | 148,43 MB (17:10) | **148,43 MB (21:50)** |
| Disco `assets/` | 321,56 MB | **125,09 MB** |
| Excluído p/ `tools/_excluded_from_bundle/…` | 0 | **196,47 MB** |
| Arte empacotável (estim.) | ~77 MB | ~77 MB |
| Risco de reinclusão (originals/icons_3d/neon morto/backups) | alto no próximo rebuild | **mitigado** |

A “regressão ~362 MB” é a **histórica** 597,66 → 236,26 (−361,40). O AAB de 148 MB **já estava otimizado**; o trabalho desta sessão trava o estado e impede regressão no próximo build.

---

## 8. Arquivos alterados nesta sessão

- `pubspec.yaml` — sem raiz `images/` / `amanda/`; SVGs de logo explícitos
- `android/gradle.properties` — heap Gradle reduzido (OOM em host 7 GB)
- `tools/_exclude_aab_bloat.ps1` + log; pastas em `tools/_excluded_from_bundle/aab_regression_20260922_192425/`
- `tools/_probe_aab_regression*.ps1/txt`, `_aab_final_verify.*`, `_rebuild_aab_*.cmd`
- `REGRESSAO_AAB_20260922.md`

**Não feito:** commit / push / publish.
