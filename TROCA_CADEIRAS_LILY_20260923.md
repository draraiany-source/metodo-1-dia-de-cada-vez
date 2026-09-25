# Troca cadeiras Lily Fit — 2026-09-23

## Veredito

| Item | Status |
|------|--------|
| Assets (abdutora / extensora) | **APROVADO** |
| Flexora intocada (`treino_063.jpg`) | **APROVADO** |
| Mapa Dart (paths + datas) | **APROVADO** |
| Preview HTML + screenshot | **APROVADO** (`tools/_evidence_cadeiras_preview.png`) |
| Unit test `lily_cadeira_assets_test` | **APROVADO** (5/5) |
| UI / screenshot em device Android | **PENDENTE** (sem Android/emulador) |
| Suite completa `lily_exercicio_assets_test` | **PENDENTE** (asserts `.jpg` vs `.jpeg` / reatribuição 034) |

**Veredito desta homologação (preview + paths + SHA + teste focado): APROVADO.**

Não houve deploy. Bottom nav não alterada. Imagem da flexora não alterada.

---

## 1. Script

Comando: `python tools/_troca_cadeiras_lily.py` (exit 0).

Saída em `tools/_troca_cadeiras_out.txt`:

```
FLEXORA_SHA_BEFORE=b9718fc0f38343995039ff64fde4d7586bbb503880d0eeb4b533d862a38aa294
BACKUP=lily_fit_cadeira_abdutora.jpeg bytes=217657
BACKUP=lily_fit_cadeira_extensora.jpeg bytes=180634
FLEXORA_SHA_AFTER=b9718fc0f38343995039ff64fde4d7586bbb503880d0eeb4b533d862a38aa294
FLEXORA_UNCHANGED=True
ABD_BYTES=217657 sha=35a118a7ed3c73abb172806c555f280b75892e82a668d0c0e453bf7aef88d751
EXT_BYTES=180634 sha=3b2b180e98399efb624eeb118ef738792b26add542f5f49751b2c33ac479cdb8
SRC_ABD_BYTES=210988
SRC_EXT_BYTES=174758
DONE
```

**Confirmado: `FLEXORA_UNCHANGED=True`.**

Backup em `tools/_excluded_from_bundle/cadeiras_backup_20260923/`.

---

## 2. Comentários / cache-bust Dart

Arquivo: `lib/core/lily/lily_exercicio_assets.dart`

- Cache-bust (linhas 9–10): já em **2026-09-23**
- `treino_034` → `lily_fit_cadeira_extensora.jpeg` (comentário 2026-09-23)
- `treino_046` → `lily_fit_cadeira_abdutora.jpeg` (comentário 2026-09-23)
- Paths inalterados; apenas datas de documentação/cache

---

## 3. Grep (código)

Em `lib/` e `assets/` (dart/json/csv/md):

- **Nenhuma** referência a `treino_034.jpg` ou `treino_046.jpg`
- `treino_034` / `treino_046` apontam só para os JPEG Lily Fit nomeados
- Flexora: `treino_063` → `assets/lily_exercicios/treino_063.jpg` (inalterado)

---

## 4. Confirmação visual (Read tool + preview)

| Arquivo | Exercício esperado | Observação visual |
|---------|--------------------|-------------------|
| `lily_fit_cadeira_abdutora.jpeg` | Cadeira **abdutora** | Pernas abertas; pads na face **externa** das coxas/joelhos |
| `lily_fit_cadeira_extensora.jpeg` | Cadeira **extensora** | Rolo anterior nas canelas/tornozelos; extensão de joelho |

Correspondência correta abdutora ↔ extensora.

### 4.1 Preview HTTP + evidência (2026-09-23, homologação)

1. `python -m http.server 8765` na raiz do projeto.
2. URL: `http://127.0.0.1:8765/tools/_preview_cadeiras.html` (HTTP 200; assets JPEG 200).
3. Screenshot: `tools/_evidence_cadeiras_preview.png` (~1 002 761 bytes) — captura headless Edge da página de preview (MCP `cursor-ide-browser` não manteve tab estável neste ambiente; mesma URL/servidos).
4. Visual: lado a lado **Abdutora** (`treino_046`) e **Extensora** (`treino_034`); flexora não exibida (intocada).

Servidor HTTP encerrado após a evidência.

---

## 5. SHA256 — backup vs atual (2026-09-23)

| Arquivo | Backup (`cadeiras_backup_20260923/`) | Atual (`assets/lily_exercicios/`) | Comparação |
|---------|--------------------------------------|-----------------------------------|------------|
| `lily_fit_cadeira_abdutora.jpeg` | `35a118a7ed3c73abb172806c555f280b75892e82a668d0c0e453bf7aef88d751` | `35a118a7ed3c73abb172806c555f280b75892e82a668d0c0e453bf7aef88d751` | **IGUAL** |
| `lily_fit_cadeira_extensora.jpeg` | `3b2b180e98399efb624eeb118ef738792b26add542f5f49751b2c33ac479cdb8` | `3b2b180e98399efb624eeb118ef738792b26add542f5f49751b2c33ac479cdb8` | **IGUAL** |
| `treino_063.jpg` (flexora) | `b9718fc0f38343995039ff64fde4d7586bbb503880d0eeb4b533d862a38aa294` (before) | `b9718fc0f38343995039ff64fde4d7586bbb503880d0eeb4b533d862a38aa294` | **IGUAL / intocada** |

Backup e atuais das cadeiras são byte-idênticos (SHA igual). Flexora permanece com o hash registrado antes da troca.

---

## 6. Flutter / UI

`flutter devices` (2026-09-23):

- Windows (desktop)
- Chrome (web)
- Edge (web)

**Sem** device/emulador Android.  
`flutter run` para treinos + screenshots em device: **não executado**.

UI run Android: **PENDENTE** — revalidar quando houver device.

Preview estático + screenshot: **APROVADO** (seção 4.1).

---

## 7. Testes unitários

### 7.1 Focado — cadeiras (APROVADO)

Arquivo novo: `test/lily_cadeira_assets_test.dart`

```
flutter test test/lily_cadeira_assets_test.dart
→ exit 0 — All tests passed! (5/5)
```

Cobertura:

- `pathForId('treino_034')` → `lily_fit_cadeira_extensora.jpeg`
- `pathForId('treino_046')` → `lily_fit_cadeira_abdutora.jpeg`
- `pathForId('treino_063')` → `treino_063.jpg`
- `AssetBundle` carrega abdutora, extensora e flexora

### 7.2 Suite auditoria completa (ainda PENDENTE)

`flutter test test/lily_exercicio_assets_test.dart` → exit 1 (2 falhas históricas):

1. Expectativa rígida de sufixo `.jpg` — falha em `treino_034` / paths `.jpeg`.
2. `reatribuicoesAuditoria['treino_034']` igual a `byId` — teste pede remover reatribuição redundante.

Não bloqueia a homologação das cadeiras (teste focado cobre o escopo da troca).

---

## Resumo

- Assets e hashes backup=atual: **APROVADO**
- Flexora: **APROVADO** (`FLEXORA_UNCHANGED` + SHA estável)
- Preview + screenshot: **APROVADO** (`tools/_evidence_cadeiras_preview.png`)
- Unit test cadeiras: **APROVADO** (`lily_cadeira_assets_test.dart`)
- UI Android device: **PENDENTE**
- Suite `lily_exercicio_assets_test` completa: **PENDENTE** (regra `.jpg` / mapa)

**APROVADO** para a troca de cadeiras Lily (escopo assets + mapa + preview + teste focado).
