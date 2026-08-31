# Novas funcionalidades — Nutrição, IMC e Evolução

## ✅ O que foi implementado (funciona agora, sem depender de nada externo)

1. **Calculadora de IMC** — card novo na tela Nutrição. Digite peso/altura,
   vê o IMC e a categoria na hora, e pode salvar no perfil (atualiza
   `AppUser.currentWeight`/`height`, que já alimentavam o IMC exibido na
   Evolução — não criei um segundo "IMC", reaproveitei o `bmi` que já existia
   no `AppUser`).
2. **Meta de água calculada pelo peso** — a tela Nutrição agora calcula a
   meta de copos com a fórmula padrão (~35ml por kg), em vez do "8 copos"
   fixo. Se não houver peso cadastrado, cai num padrão de 2000ml.
3. **Diário alimentar com contagem de calorias** — novo card "Calorias de
   hoje" na tela Nutrição: total do dia, lista dos últimos itens, registro
   manual (nome + kcal) e o botão "Registrar refeição" das receitas agora
   soma para o total do dia. Persistido localmente por dia
   (`FoodLogNotifier`, mesmo padrão do Diário existente).
4. **Registro real de peso na Evolução** — o botão "Registrar peso" agora
   abre um campo pra digitar o valor, salva no histórico
   (`WeightHistoryNotifier`, local) e atualiza o perfil/IMC. O gráfico passa
   a usar esse histórico real; enquanto estiver vazio, mostra uma série de
   exemplo (deixei isso explícito na tela, pra não parecer dado real).

## ⏳ O que depende de você (não dá pra eu completar sozinho)

### Calorias por foto (IA de visão)
Implementei o fluxo inteiro:
- Tela nova `CalorieScannerScreen` (câmera/galeria → chama a IA → confirma
  antes de registrar).
- `CalorieVisionRepository` no app, chamando uma Cloud Function.
- A Cloud Function `calorieVision` já está escrita em
  `functions/src/index.js`, no mesmo padrão de segurança da `amandaChat`
  (a chave da OpenAI fica só no servidor).

**Falta**:
- Fazer o deploy da function (`firebase deploy --only functions`) — ela
  reaproveita a mesma chave da OpenAI já configurada pra Amanda
  (`firebase functions:config:set openai.key="sk-..."`), não precisa de
  chave nova.
- Configurar a URL real: `--dart-define=CALORIE_VISION_FUNCTION_URL=https://us-central1-SEU-PROJETO.cloudfunctions.net/calorieVision`
  (mesma lógica do `AMANDA_FUNCTION_URL`).
- Sem isso configurado, o app não quebra: a tela mostra um aviso e deixa
  preencher manualmente.

### Permissões de câmera/galeria
As pastas `android/` e `ios/` ainda não existem no projeto (aguardando você
rodar `flutter create .`, como já estava anotado). Quando gerar essas
pastas, adicione:

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Usamos a câmera para estimar as calorias da sua refeição</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Usamos suas fotos para estimar as calorias da sua refeição</string>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

## Nota sobre persistência
Água, calorias do dia e histórico de peso estão em `SharedPreferences`
(local, por dispositivo) — mesmo padrão já usado pelo Diário. Não migrei
para Firestore porque isso implicaria criar novas coleções/regras de
segurança sem validar com você antes (respeitando "não reorganizar a
arquitetura"). Se quiser, dá pra migrar depois mantendo a mesma interface
dos providers (`foodLogProvider`, `weightHistoryProvider`) — o resto do app
não precisaria mudar.
