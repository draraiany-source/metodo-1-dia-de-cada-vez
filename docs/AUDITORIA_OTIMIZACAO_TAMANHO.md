# Relatório final — otimização de tamanho Android

**App:** Método 1 Dia de Cada Vez (`com.metodo1dia.app`)  
**Data:** 20/09/2026  
**Branch:** `finalizacao-metodo-1-dia-de-cada-vez`  
**Cobrança:** `PAYMENTS_ENABLED` **não** foi passado no build (default **false**).  
**Google Play:** nenhum upload.

---

## Status pedido

| Item | Valor |
|---|---|
| **APK OTIMIZADO** | **SIM** |
| **AAB OTIMIZADO** | **SIM** |
| **TAMANHO FINAL DO APK** | **238,75 MB** (250.351.574 bytes) |
| **TAMANHO FINAL DO AAB** | **236,26 MB** (247.738.532 bytes) |
| **REDUÇÃO TOTAL** | APK **−364,53 MB (−60,4%)** · AAB **−361,40 MB (−60,5%)** |
| **TESTE ALUNO** | **PENDENTE** (E2E no celular) |
| **TESTE PERSONAL** | **PENDENTE** (E2E no celular) |
| **TESTE ADMIN** | **PENDENTE** (E2E no celular) |
| **PRONTO PARA ENVIAR À GOOGLE PLAY** | **NÃO** |

---

## ANTES → DEPOIS

| Pacote | Antes | Depois | Redução |
|---|---:|---:|---:|
| APK | 603,28 MB (632.583.442 B) | 238,75 MB (250.351.574 B) | 364,53 MB / 60,4% |
| AAB | 597,66 MB (626.693.231 B) | 236,26 MB (247.738.532 B) | 361,40 MB / 60,5% |

**Caminhos gerados (não enviados à loja):**

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 1. Segurança (feita antes de alterar assets)

| Item | Valor |
|---|---|
| Commit snapshot | `d45a67e` — `chore: snapshot antes de otimizar tamanho do Android` |
| Tag | `backup-pre-otimizacao-tamanho-20260920` |
| Branch de segurança | `backup/pre-otimizacao-tamanho-20260920` |
| Arquivos apagados do disco | **Nenhum** |
| Credenciais / Firebase prod / pagamentos / Play | **não alterados** |

Restaurar imagens ao estado pré-otimização:

```text
git checkout backup-pre-otimizacao-tamanho-20260920 -- assets/
```

---

## 2. Principais responsáveis pela redução

1. **Recompressão in-place das imagens empacotadas** (mesmo nome/extensão `.png` / `.jpg`): 495 arquivos reescritos, **290,6 MB** a menos no disco. Ícones de UI limitados a **768 px**; fotos Lily/Amanda a **1080 px**; proporção preservada; sem corte; PNG com transparência real mantida.
2. **`pubspec.yaml` — pastas comprovadamente fora das telas Aluno/Personal/Admin deixaram de ser empacotadas** (arquivos **permanecem no disco**):
   - `assets/images/icons_3d/` (~11,1 MB) — zero referências em `lib/`
   - `assets/images/icons_3d_pack2/` (~39,4 MB) — só `AssetShowcaseScreen` em `kDebugMode`
   - `assets/icons/neon/{navegacao,saude,nutricao,conquistas,perfil}` (~49,2 MB) — zero referências
   - pasta `neon/corrida/` inteira (~15,5 MB) → **só o arquivo usado** (`icone_neon_de_corrida_e_saude_cardiaca.png`)
3. **Release Flutter:** `--split-debug-info=build/app/debug-info` (símbolos **não** vão para o dispositivo). R8 minify + resource shrinking **já estavam** ligados.

Estimativa do que ainda entra no bundle (só o nível de pasta declarado no pubspec): **~165 MB** de arte (antes: **~524 MB** em `flutter_assets`).

---

## 3. Imagens

| Ação | Detalhe |
|---|---|
| Script | `tools/otimizar_imagens_empacotadas.py` |
| Log | `docs/_otimizacao_imagens_log.json` |
| Vistos / reescritos / sem ganho | 674 / 495 / restante < 12 KB ou sem ganho ≥ 3% |
| Conversão PNG→WebP com troca de extensão | **Não** (quebraria caminhos Dart) |
| Qualidade perceptível | Resize LANCZOS; JPEG q82; paleta 256 **somente em ícones de UI** ainda > 220 KB |
| Lily Fit / identidade | Mesmos arquivos, mesmos caminhos; sem troca de arte |

Maiores ganhos individuais (exemplos): receitas neon ~2,0 MB → ~180–220 KB aos 768 px.

---

## 4. Áudios / vídeos / PDFs

| Tipo | Resultado |
|---|---|
| MP3 locais | 7 arquivos em `assets/audio_programs/` (**3,45 MB**) — **mantidos** (player `asset://`) |
| WAV / M4A no APK | nenhum |
| MP4 local | nenhum — vídeos continuam YouTube/remoto |
| PDF local no bundle | nenhum — visualização já é remota/gerada |

**Firebase Storage nesta passagem:** nenhum arquivo movido. Offline dos 7 áudios e das capas Lily permanece.

---

## 5. `pubspec.yaml`

**Removido do empacotamento (não do disco):**

- `assets/images/icons_3d/`
- `assets/images/icons_3d_pack2/`
- `assets/icons/neon/` (raiz sem arquivos — quebraria o build)
- `assets/icons/neon/navegacao/`
- `assets/icons/neon/saude/`
- `assets/icons/neon/nutricao/`
- `assets/icons/neon/conquistas/`
- `assets/icons/neon/perfil/`
- pasta inteira `assets/icons/neon/corrida/` (substituída pelo PNG usado)

**Mantido:** `neon/treinos/`, receitas neon, Lily, Amanda, mascote, áudios, catálogo JSON.

**Dependências:** nenhuma removida (todas as ativas têm uso ou são estrutura de billing/PDF/vídeo remoto). `geocoding` / `rive` já estavam comentados.

**Fontes:** nenhuma fonte custom no pubspec; `google_fonts` continua em runtime. Tree-shake de Material/Cupertino no release (97–99%).

---

## 6. Android / Flutter release

| Recurso | Estado |
|---|---|
| `isMinifyEnabled` / `isShrinkResources` / R8 | já true em `android/app/build.gradle.kts` |
| `--split-debug-info` | **aplicado** |
| `--obfuscate` | **não** (stack traces internos continuam legíveis; símbolos DWARF extraídos) |
| ABI filter no AAB | **não** — a Play entrega uma ABI (~24 MB de `.so`, não as três) |
| Símbolos Dart | `build/app/debug-info/` (gitignored via `build/`): `app.android-arm.symbols` (4,8 MB), `app.android-arm64.symbols` (5,6 MB), `app.android-x64.symbols` (5,6 MB) |
| Keystore | `android/key.properties` presente — AAB/APK **assinados** de release |
| dart-defines oficiais | `SUPPORT_EMAIL`, `PRIVACY_POLICY_URL`, `TERMS_URL` |
| `PAYMENTS_ENABLED` | **ausente** no comando → false |

Guardar `build/app/debug-info/` fora do git se for preciso desofuscar crashes depois de limpar `build/`.

---

## 7. Testes

### Automáticos

| Teste | Resultado |
|---|---|
| `flutter analyze` | **0 errors** (57 info/warning pré-existentes) |
| Assets Cursor / Personal-IA / receitas neon / 7 MP3 / 117 capas Lily | **PASSOU** |
| `flutter test` | **200 passaram**, **5 falharam** (textos/UI de dashboard de nutrição, validação extra do catálogo 117, placeholder visual `vidro_3d` vs Lily genérica) — **não** são quebra de caminho de asset desta otimização |

### E2E nos três perfis (celular)

Não executado nesta máquina (sem dispositivo na sessão). Marcar **PASSOU** só depois do roteiro em `release_config/ROTEIRO_E2E_TRES_PERFIS.md` e `release_config/CHECKLIST_TESTE_ANDROID_AAB.md`.

Checklist mínimo no APK 238,75 MB:

- **Aluno:** login/logout, início, treinos, cronômetro, desafio semanal, vídeos YouTube, áudios, PDF remoto, hidratação, metas, fotos, navegação, voltar, notificações se disponíveis.
- **Personal:** login, alunos, anamnese, agenda, edição permitida, logout, permissões.
- **Admin:** login, usuários, vídeos, fotos, conteúdos, PDFs, CRUD, RBAC.

---

## 8. O que ainda pesa (e não foi mexido de propósito)

| Pasta (estimativa pós-otimização) | Por quê ficou |
|---|---|
| `assets/lily_treinos/` ~28,6 MB | usado nas telas de treino |
| `assets/lily/` ~24,1 MB | Lily Fit nas telas |
| `assets/amanda/promo/` ~21,9 MB | **duplicata MD5 de Lily** — alias de path seria o próximo ganho seguro (~22 MB), não feito sem autorização de troca de caminho |
| `assets/lily_exercicios/` ~14,0 MB | 117 capas do catálogo |
| `assets/icons/neon/treinos/` ~7,7 MB | ícones de exercício referenciados |
| `assets/images/recipes/neon/` ~7,0 MB | catálogo de receitas |
| 7 MP3 | offline do Programa 7 Dias |

O AAB **236 MB** ainda pode **ultrapassar o limite típico de ~200 MB** de download install-time da Play. Publicar agora arriscaria rejeição por tamanho.

---

## 9. Pendências / riscos / recomendações

**Falta para Play (além do tamanho):**

1. E2E Aluno / Personal / Admin no APK novo.
2. Data safety / ficha da loja / política de privacidade conferidas.
3. Conteúdo YouTube estável (não listado).
4. Autorização explícita para **ligar pagamentos** (hoje desligados).
5. Reduzir mais ~40–80 MB se a Play recusar o AAB de 236 MB:
   - alias `amanda/promo` → `lily` (sem arte nova);
   - ou Play Asset Delivery / Firebase Storage para capas e áudios, com cache e fallback.

**Riscos desta passagem:**

- Showcase debug (`/showcase`) deixa de carregar `icons_3d_pack2` até o pubspec ser reativado.
- Ícones de UI em paleta 256: conferir visual no celular (neon 3D).
- Qualidade JPEG 82 nas capas 1080 px: conferir nas telas de treino.

**Não feito (de propósito):** mover conteúdo para Firebase; apagar duplicatas; trocar Lily; alterar textos/preços; ativar IAP; enviar à Play.

---

## 10. Comando de rebuild (referência)

```text
flutter build appbundle --release --split-debug-info=build/app/debug-info --dart-define=SUPPORT_EMAIL=1diadecadavezsuporte@gmail.com --dart-define=PRIVACY_POLICY_URL=https://metodo1dia-app.web.app/privacidade.html --dart-define=TERMS_URL=https://metodo1dia-app.web.app/termos.html
```

Não adicionar `PAYMENTS_ENABLED=true`.
