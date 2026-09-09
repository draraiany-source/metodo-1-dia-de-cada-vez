# Relatório — Analisar refeição com IA

## Resumo

Funcionalidade completa de análise de refeição por foto no módulo Nutrição, reaproveitando o scanner e a Cloud Function `calorieVision` existentes (sem chave de API no app Flutter).

Fluxo: **Nutrição → Analisar refeição com IA → Tirar/escolher foto → Analisar → Corrigir alimentos → Tipo da refeição → Adicionar ao meu dia → Totais do dia atualizados**.

---

## Arquivos criados

| Arquivo | Função |
|---------|--------|
| `lib/features/nutrition/domain/food_analysis_models.dart` | `FoodAnalysisItem`, `NutritionAnalysisResult`, `NutritionDiaryEntry` |
| `lib/features/nutrition/data/meal_photo_storage_service.dart` | Upload comprimido para Firebase Storage |
| `lib/features/nutrition/data/repositories/nutrition_diary_repository.dart` | Persistência em `users/{uid}/nutritionDiary` |
| `test/nutrition_analysis_result_test.dart` | Testes de parse JSON multi-alimento / legado |
| `RELATORIO_ANALISAR_REFEICAO_IA.md` | Este relatório |

## Arquivos alterados

| Arquivo | Mudança |
|---------|---------|
| `functions/src/index.js` | Prompt + resposta multi-alimento (`foods[]` + `totals`), compat legado |
| `lib/features/nutrition/data/calorie_vision_repository.dart` | `analyzeMeal()` estruturado |
| `lib/features/nutrition/services/meal_ai_service.dart` | Usa análise multi-item |
| `lib/features/nutrition/domain/meal.dart` | Campos `imageUrl` e `source` |
| `lib/features/nutrition/domain/nutrition_firestore_paths.dart` | Paths de foto e `nutritionDiary` |
| `lib/features/nutrition/providers/nutrition_ia_providers.dart` | Providers diary + storage |
| `lib/features/nutrition/presentation/calorie_scanner_screen.dart` | Fluxo completo UI |
| `lib/features/nutrition/presentation/nutrition_screen.dart` | Card destaque, barras de macros, histórico |
| `lib/features/nutrition/presentation/nutrition_dashboard_screen.dart` | CTA atualizado |

---

## Serviço de IA utilizado

- **OpenAI Vision** via modelo `gpt-4o-mini`
- Proxy: Firebase Cloud Function HTTPS **`calorieVision`**
- O app envia apenas `imageBase64` autenticado (sem chave no cliente)

## Onde configurar a chave da IA

**Nunca no Flutter.** Somente no backend:

```bash
# Opção recomendada (Firebase Functions config)
firebase functions:config:set openai.key="SUA_CHAVE_OPENAI"

# Ou variável de ambiente no runtime da function
OPENAI_API_KEY=sk-...
```

Depois:

```bash
firebase deploy --only functions:calorieVision
```

URL no app: `AppConfig.calorieVisionFunctionUrl` / `AppConstants.calorieVisionFunctionUrl` (já existente).

---

## Estrutura Firestore

### Primária (já usada pelo módulo Nutrição IA)

`users/{userId}/dailyLogs/{dateKey}` — refeições embutidas (`Meal` com `source: ai_food_scan`).

### Espelho solicitado (nova)

`users/{userId}/nutritionDiary/{entryId}`:

```json
{
  "userId": "...",
  "mealType": "lunch",
  "date": "2026-09-09",
  "createdAt": "<serverTimestamp>",
  "createdAtClient": "ISO-8601",
  "imageUrl": "...",
  "source": "ai_food_scan",
  "foods": [ { "name", "estimated_grams", "calories", "protein_g", ... } ],
  "totalCalories": 520,
  "proteinG": 32,
  "carbsG": 61,
  "fatG": 17,
  "fiberG": 7
}
```

Regras: subcoleções de `users/{userId}` já são owner-only (`firestore.rules`).

Também sincroniza o diário local `foodLogProvider` (SharedPreferences) para o card “Calorias de hoje” na tela Nutrição.

---

## Estrutura Firebase Storage

```
users/{userId}/nutrition/{year}/{month}/{imageId}.jpg
```

Imagem redimensionada no client (`maxWidth/Height: 1024`, `imageQuality: 70`) antes do upload.

Regras: `users/{userId}/{allPaths=**}` — leitura/escrita só do dono (+ admin), imagens ≤ 8 MB.

---

## Permissões

### Android (`AndroidManifest.xml` — já existiam)

- `CAMERA`
- `READ_MEDIA_IMAGES`
- `READ_EXTERNAL_STORAGE` (maxSdk 32)

### iOS

Não há pasta `ios/` neste workspace. Ao gerar o target iOS, adicionar em `Info.plist`:

- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`

---

## Como testar

1. Login no app (auth obrigatória para a Cloud Function).
2. Nutrição → card **Analisar refeição com IA**.
3. Aceitar aviso de privacidade (primeira vez).
4. Tirar foto / galeria → **Analisar refeição**.
5. Editar / adicionar / excluir alimentos; totais recalculam.
6. Escolher tipo da refeição → **Adicionar ao meu dia**.
7. Conferir totais e “Refeições de hoje”; reabrir o app.
8. Excluir refeição pelo detalhe no histórico.

Cenários de erro cobertos na UI: sem internet, timeout, IA vazia, permissão negada, não autenticado, falha Firebase.

### Comandos

```bash
flutter analyze lib/features/nutrition test/nutrition_analysis_result_test.dart
flutter test test/nutrition_analysis_result_test.dart
# Deploy da function atualizada:
firebase deploy --only functions:calorieVision
```

---

## O que ainda depende de configuração externa

1. Deploy da Cloud Function atualizada (`calorieVision`).
2. Chave OpenAI configurada no servidor.
3. URL da function correta no build (`--dart-define` / `AppConstants`).
4. App Check (se habilitado no projeto) válido no device.
5. Target iOS + strings de permissão (se for publicar iOS).

---

## Possíveis custos da API

- Modelo: **gpt-4o-mini** (visão).
- Custo típico: frações de centavo de dólar por imagem (depende do tamanho do base64 e tokens de saída).
- Limites: timeout ~45s no client; `max_tokens: 900` na function.
- Recomendação: monitorar uso no painel OpenAI e Firebase.

---

## Validação executada

| Item | Status |
|------|--------|
| `flutter analyze` (módulo nutrição) | OK — No issues found |
| `flutter test test/nutrition_analysis_result_test.dart` | Passou (3 testes) |
| `flutter build apk --debug` | Falhou por cache Gradle externo do ambiente (não por erro de código); analyze limpo |
| Android (permissões no Manifest) | Preparado |
| iOS | Pasta `ios/` ausente neste repo — não validado em device |
| Screenshots | Não gerados neste ambiente (sem device/emulador anexado) |

---

## Segurança

- Chave OpenAI **somente** na Cloud Function.
- Auth obrigatória na function (`requireAuth`).
- Firestore/Storage: usuário só acessa os próprios dados.
- Aviso de privacidade antes da primeira análise.
- Estimativas sempre apresentadas como aproximadas (disclaimer na tela de resultado).
