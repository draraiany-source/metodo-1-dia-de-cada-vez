# Auditoria de tamanho — Android (AAB / APK)

**App:** Método 1 Dia de Cada Vez (`com.metodo1dia.app`)  
**Data:** 19/09/2026  
**Escopo:** somente leitura. Nenhuma funcionalidade foi alterada.  
**Loja / pagamentos:** sem upload à Play; `PAYMENTS_ENABLED` permanece false.

Arquivo bruto da medição: `docs/_audit_tamanho_android.json`.

---

## Veredito

| Pacote | Caminho | Tamanho no disco |
|---|---|---|
| AAB | `build/app/outputs/bundle/release/app-release.aab` | **597,66 MB** (626.693.231 bytes) |
| APK universal | `build/app/outputs/flutter-apk/app-release.apk` | **603,28 MB** (632.583.442 bytes) |

O peso **não** vem de vídeo local, PDF local, builds antigos no zip, nem de `google_fonts` compilado.

Vem quase todo de **PNG fotográfico grande** declarado no `pubspec.yaml` e copiado para `flutter_assets` (**524 MB** descompactados; 807 arquivos).

A Play **não entrega** os 131 MB de `BUNDLE-METADATA` (mapas ProGuard + `.sym`) ao celular. Mesmo assim, o usuário ainda baixaria ~524 MB de imagens + uma ABI nativa (~24 MB). Isso **bloqueia publicação**: o limite típico de download install-time da Play é **200 MB**.

---

## 1. O que está dentro do APK (descompactado, maior → menor)

| Item | MB | Observação |
|---|---:|---|
| `assets/flutter_assets/` | **524,29** | 817 entradas; 807 são arte do app |
| `lib/` (3 ABIs) | **72,84** | `libapp.so` + `libflutter.so` dominam |
| `classes*.dex` | **12,97** | código Java/Kotlin |
| `res/` + `resources.arsc` | **0,93** | splash/ícone nativo |
| resto | < 0,5 | META, protobuf |

### 1.1 Pastas dentro de `flutter_assets/assets/` (o que o celular instala)

| Pasta | MB | Arquivos | No APK? |
|---|---:|---:|---|
| `icons/` | **215,70** | 283 | Sim |
| `images/` | **146,92** | 161 | Sim |
| `lily_treinos/` | **41,59** | 24 | Sim |
| `lily/` (só a raiz) | **39,06** | 33 | Sim |
| `amanda/` (promo + optimized + thumbs + raiz) | **37,90** | 53 | Sim |
| `lily_exercicios/` (sem `_incoming`) | **31,95** | 117 | Sim |
| `mascot/` | **7,17** | 31 | Sim |
| `audio_programs/` | **3,45** | 7 MP3 | Sim |
| `app_icon/`, `content/`, Lottie, SVG | **< 0,3** | — | Sim |

### 1.2 Extensões no AAB (descompactado)

| Tipo | MB | Papel |
|---|---:|---|
| `.png` | **471,48** | Causa principal |
| `.sym` | 93,17 | Símbolos no AAB; Play não instala |
| `.so` | 72,84 | Nativo (3 ABIs) |
| `.map` | 38,27 | ProGuard no AAB; Play não instala |
| `.jpg` / `.jpeg` | 48,05 | Lily exercícios + algumas fotos |
| `.dex` | 12,97 | |
| `.mp3` | **3,45** | 7 áudios locais |
| `.webp` | 1,37 | Pouquíssimo uso |

**Vídeo local:** 0. **PDF local:** 0. Vídeos vão para YouTube/remoto. PDFs de receita/certificado são remotos ou gerados.

---

## 2. Pastas no disco `assets/` (maior → menor)

Total no disco: **700,76 MB / 1.109 arquivos**.  
Diferença vs APK (~177 MB): backups, `amanda/originals` e `lily/treinos lily fit` — **não entram no binário**.

| Pasta | MB | Arquivos | Entra no APK? |
|---|---:|---:|---|
| `assets/icons` | 215,70 | 283 | Sim |
| `assets/images` | 146,92 | 161 | Sim |
| `assets/amanda` | 143,31 | 68 | Parcial (37,90 MB). `originals/` **não** |
| `assets/icons/neon` | 127,89 | 97 | Sim (pasta inteira) |
| `assets/lily` | 78,95 | 179 | Parcial (39,06 MB). subpasta `treinos lily fit` **não** |
| `assets/images/recipes/neon` | 75,62 | 40 | Sim (~2 MB cada PNG) |
| `assets/lily_treinos` | 41,59 | 24 | Sim (~2 MB cada) |
| `assets/lily/treinos lily fit` | 39,89 | 146 | **Não** (subpasta não listada no pubspec) |
| `assets/images/icons_3d_pack2` | 39,43 | 41 | Sim, mas só usado no showcase |
| `assets/icons/app` | 38,98 | 28 | Sim (navegação oficial) |
| `assets/lily_exercicios` | 36,88 | 134 | Parcial (117). `_incoming/` **não** |
| `assets/amanda/promo` | 36,52 | 23 | Sim — **duplicata de poses Lily** |
| `assets/_lily_backup_before_frame_fix` | 15,29 | 59 | **Não** |
| `assets/icons/personal-ai` | 14,40 | 10 | Sim |
| `assets/images/icons_3d` | 11,13 | 15 | Sim; **nenhuma referência em `lib/`** |
| `assets/mascot` | 8,33 | 33 | Quase tudo |
| `assets/_validation` | 4,88 | 34 | **Não** |
| `assets/audio_programs` | 3,45 | 7 | Sim |
| `tools/audio_seed/assets_audio` | 3,45 | 7 | **Não** (cópia do seed) |
| `assets/_incoming_lily` | 2,64 | 14 | **Não** |
| `assets/_lily_backup_before_pack_…` | 2,53 | 10 | **Não** |
| `assets/images/lily_fit` | 2,49 | 10 | Sim (e é cópia de mascote/Lily) |
| `assets/amanda/optimized` | 1,19 | 15 | Sim |
| `assets/amanda/thumbs` | 0,18 | 15 | Sim |
| SVG / Lottie / content / app_icon | < 0,3 | — | Sim |

`pubspec.yaml` **não** declara pastas `_lily_backup*`, `_incoming`, `_validation`. Correto.

Declarar `assets/amanda/` **não** inclui `originals/` (Flutter só pega arquivos daquele nível). Por isso os JPG de 6–8 MB ficaram fora do APK.

---

## 3. Maiores arquivos individuais no APK

Quase todos são PNG ~2 MB (ícone ou pose, resolução de foto):

| Arquivo no APK | MB |
|---|---:|
| `lily_treinos/lily_corda_naval.png` | 2,07 |
| `lily_treinos/lily_agachamento.png` | 2,07 |
| `lily_treinos/lily_kettlebell.png` | 2,04 |
| `images/recipes/neon/38_icone_neon_de_suco_detox_verde.png` | 2,03 |
| `images/recipes/neon/40_icone_neon_de_torrada_com_abacate.png` | 2,01 |
| + dezenas de PNG neon/Lily na mesma faixa (1,9–2,0 MB) | |

No disco, os maiores são `amanda/originals/*.jpg` (5,9–8,3 MB cada) — **fora do APK**.

---

## 4. Duplicatas (mesmo MD5, arquivos ≥ 30 KB)

Top 40 grupos: **~66,5 MB** de cópia desperdiçada no disco. Parte disso **está no APK**.

Padrões:

1. **`assets/lily/*.png` = `assets/amanda/promo/amanda_*.png`**  
   Dezenas de pares ~1,5–1,7 MB. A mesma pose entra duas vezes no binário (~30 MB).
2. **Lily + mascote + lily_fit**  
   Ex.: `lily_motivation.png` = `01_lili_fit_joinha.png` = `avatar_joinha.png` = `mascot_thumbs_up.png` (7 cópias).
3. **Ícone de app = ícone 3D**  
   `icons/icon_recipes.png` = `images/icons_3d/icon_recipes_3d.png`.
4. **Neon receita = neon nutrição**  
   `icons/neon/nutricao/icone_neon_de_salada_saudavel.png` = `images/recipes/neon/33_…`.
5. **Alguns `lily_exercicios/treino_XXX.jpg` repetidos** entre si e vs `lily/treinos lily fit`.

Backups no disco repetem o mesmo conteúdo; isso **não** aumenta o APK.

---

## 5. Uso no código vs o que o `pubspec` empacota

| Recurso | Empacotado | Uso em `lib/` |
|---|---|---|
| `assets/icons/app/` (39 MB) | Sim | Catálogo oficial `AppIcons` |
| `assets/icons/neon/treinos/` + 1 arquivo em `neon/corrida/` | Sim | Exercícios em `AppIcons` |
| Restante de `icons/neon/` (navegação, saúde, nutrição, conquistas, perfil) | **Sim, pasta inteira 127,89 MB** | **Não referenciado** (exceto o 1 arquivo de corrida) |
| `images/recipes/neon/` (75,62 MB) | Sim | Catálogo de receitas (`recipe_neon_icons.dart`) — conteúdo necessário, arquivos inchados |
| `images/icons_3d_pack2/` (39,43 MB) | Sim | Só `AssetShowcaseScreen` |
| `images/icons_3d/` (11,13 MB) | Sim | **Zero imports** |
| `lily_treinos/` (41,59 MB) | Sim | Capas de treino — necessário, PNG inchado |
| `lily_exercicios/` 117 capas | Sim | Catálogo oficial 117 — necessário, poderia ser remoto |
| `amanda/promo` | Sim | CMS/promo; conteúdo **idêntico** a Lily |
| 7 MP3 | Sim | Player de áudio (asset://) |
| `google_fonts` Poppins/Inter | Não | Download em runtime (não entra no AAB) |
| Vídeo / PDF | Não | YouTube / Storage / gerado |

`AssetShowcaseScreen` está no `go_router`. Tirar o pack2 do `pubspec` exige **não quebrar** essa rota (ou apontá-la para o pacote oficial).

---

## 6. Bibliotecas nativas (`.so`)

O APK universal inclui **três ABIs**:

| ABI | MB | Principais |
|---|---:|---|
| x86_64 | 25,82 | emulador |
| arm64-v8a | 24,36 | celulares atuais |
| armeabi-v7a | 22,66 | aparelhos antigos |

Arquivos: `libapp.so` (~13–15 MB), `libflutter.so` (~8–13 MB), `libdartjni.so` e um `.so` minúsculo do DataStore.

Dependências (`purchases_flutter`, `video_player`, `pdfx`, `flutter_map`, `chewie`) **não** são o vilão. No celular via AAB a Play manda **uma** ABI (~24 MB). No APK de teste as três somam 73 MB.

---

## 7. O que **não** está no problema

- Builds antigos (`build/`, APKs de homolog) **não** vão para dentro do AAB.
- Pastas `_lily_backup*`, `_incoming`, `_validation`, `amanda/originals` **não** estão no APK.
- Sem vídeo/PDF embutido.
- `google_fonts` não empacota TTF.
- Sem secrets no pacote desta auditoria.

---

## 8. Estratégia segura (aguardar autorização)

Nada abaixo apaga arte do repositório. Ordem: menor risco → maior ganho. Cada fase tem rollback (git + originais fora do `pubspec`).

### Fase A — Recomprimir o que já é necessário (sem mudar telas)

Converter PNG/JPG de vitrine para **WebP ou JPEG** em tamanho de tela (ex. lado maior 512–1024 px, qualidade ~75–80). Manter originais em pasta **não** listada no `pubspec` (ou no Storage).

Alvos, do maior para o menor:

1. `icons/neon` (~128 MB)  
2. `images/recipes/neon` (~76 MB, 40 ícones de ~2 MB)  
3. `lily_treinos` (~42 MB)  
4. `icons/app` (~39 MB; `receitas.png` sozinho tem 1,94 MB)  
5. `lily/` raiz + `amanda/promo` (~39 + 37 MB)  
6. `lily_exercicios` 117 capas (~32 MB)  
7. `personal-ai` (~14 MB)

**Ganho esperado:** 350–450 MB no AAB/APK, sem remover funcionalidade, se a compressão for feita com preview visual.

### Fase B — Parar de empacotar o que o app não usa (arquivos ficam no disco)

Só depois de um grep + teste das telas:

1. Tirar do `pubspec` as subpastas `icons/neon/{navegacao,saude,nutricao,conquistas,perfil}` se o grep continuar zerado.  
2. Tirar `images/icons_3d/` (0 usos).  
3. Decidir o showcase: ou usa `AppIcons` oficial, ou o pack2 sai do bundle.

**Ganho esperado:** dezenas de MB (pack2 sozinho = 39 MB) **sem** recomprimir.

### Fase C — Uma cópia canônica (sem apagar)

Lily e `amanda/promo` são o **mesmo binário**. Manter um caminho (`assets/lily/…`) e fazer o CMS da Amanda apontar para ele (ou um único arquivo compartilhado). Não apagar `promo/` no disco até validar a UI.

**Ganho esperado:** ~25–35 MB no APK.

### Fase D — Remoto, sem apagar conteúdo

Mover para Firebase Storage / CDN, com cache e placeholder local:

- 117 fotos `lily_exercicios` (já existe catálogo JSON)  
- 7 MP3 (o player já tem caminho `asset://`; dá para preferir URL remota com fallback local)

**Ganho esperado:** ~35 MB. Exige upload + regras de Storage + teste offline.

### Fase E — APK de teste menor (não muda o AAB)

`flutter build apk --release --split-per-abi` gera um APK **arm64** (~24 MB a menos de `.so`). Não reduz as imagens.

### O que **não** fazer agora

- Não apagar pastas Lily / Amanda / 117 exercícios.  
- Não ligar `PAYMENTS_ENABLED`.  
- Não enviar este AAB à Play.  
- Não commitar originais de 8 MB em pasta declarada.  
- Não “otimizar” no escuro sem abrir Home, Treinos, Receitas, Hidratação e CMS.

---

## 9. Estimativa de meta (depois da autorização)

| Cenário | AAB / APK aproximado | Risco |
|---|---|---|
| Hoje | ~598 / ~603 MB | — |
| Só Fase A (recomprimir) | ~120–200 MB | Baixo, se houver preview |
| A + B + C | ~80–150 MB | Médio (grep + QA) |
| A+B+C+D | ~50–100 MB | Médio (rede) |

Meta realista para Play: **< 150 MB** no AAB, com install-time < 200 MB.

---

## 10. Próximo passo

Aguardo autorização explícita para a **Fase A** (e se deseja incluir B no mesmo lote).  
Nenhuma alteração irreversível foi feita.
