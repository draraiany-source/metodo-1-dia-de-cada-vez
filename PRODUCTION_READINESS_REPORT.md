# 📋 Relatório de Prontidão para Produção — Método 1 Dia de Cada Vez / Lili Fit

Data desta revisão. Análise **estática** (li o código; não foi possível rodar
`flutter analyze`/`test`/build aqui — sem SDK e sem internet neste ambiente).

---

## 1. Análise geral do projeto

| Área | Estado | Observação |
|---|---|---|
| Estrutura de pastas | ✅ Ótima | Feature-first (`lib/features/<módulo>/{presentation,data,providers}`) + `core/` |
| Arquitetura | ✅ Sólida | Riverpod + GoRouter + repositórios; sem gambiarras |
| Dependências | ✅ Completas | Firebase, Riverpod, GoRouter, geolocator, fl_chart, lottie, svg… |
| Assets | ✅ Integrados | 101 assets vetoriais + catálogo `AppAssets` + design system |
| Firebase (código) | ✅ Pronto | Init com degradação graciosa + hooks de Crashlytics |
| Firebase (nuvem) | ⚠️ Suas chaves | `firebase_options.dart` está com `REPLACE_ME` |
| Cloud Functions | ✅ Código pronto | `functions/src/index.js` (XP + `amandaChat` OpenAI) |
| Firestore rules/indexes | ✅ Presentes | `firebase/firestore.rules`, `firestore.indexes.json` |
| Riverpod | ✅ Correto | Providers por feature, sem vazamento óbvio |
| GoRouter | ✅ Correto | ShellRoute (5 abas) + rotas full-screen |
| Performance | ✅ Boa | Listas com builders, sem rebuilds gritantes |
| Segurança | ✅ Boa | Regras por coleção; OpenAI atrás de Cloud Function (chave não exposta) |
| **Pastas nativas** | ❌ **Ausentes** | **Não há `android/`, `ios/`, `web/`** — bloqueador de build |
| Testes | ⚠️ Mínimo | Adicionei `test/smoke_test.dart` (era inexistente) |

**Conclusão da análise:** o código está bem construído e roda em **modo local**
(sem Firebase) para desenvolvimento. Para virar produção faltam: pastas nativas,
suas chaves, e configuração dos consoles.

---

## 2. Erros corrigidos / itens tratados nesta revisão

- ✅ **Billing real** — criei `PremiumService` (interface + `LocalPremiumService`
  persistente em SharedPreferences, **pronto para RevenueCat**) e liguei a tela
  Premium para **assinar / restaurar / detectar premium** com loading e feedback
  (antes era só um `SnackBar` mock).
- ✅ **AnalyticsService** — wrapper de Firebase Analytics com degradação graciosa
  (no-op quando Firebase off) + eventos de negócio prontos (`workout_completed`,
  `run_finished`, `subscribe`, `checkin`) e `observer` para o router.
- ✅ **Widgets de conteúdo nativos** (`LiliMedal`, `LiliBanner`, `LiliScene`) —
  corrigem o fato de `flutter_svg` não renderizar `<text>`/emoji.
- ✅ **Imports** — verificados em todos os 45 arquivos Dart: **0 quebrados**.
- ✅ **Referências de assets** — todas as `AppAssets.*` existem no catálogo.
- ✅ **Teste de fumaça** — `test/` criado (billing + montagem de app).
- ✅ Sem `print()` no código; nenhum `TODO`/`FIXME` em lógica.

> Não havia crashes/leaks óbvios para corrigir por leitura. Bugs que só aparecem
> em runtime precisam do build local (ver seção 5).

---

## 3. O que foi implementado / adicionado

| Item | Arquivo |
|---|---|
| Serviço de assinatura (RevenueCat-ready) | `lib/core/services/premium_service.dart` |
| Analytics com degradação graciosa | `lib/core/services/analytics_service.dart` |
| Tela Premium funcional (assinar/restaurar) | `lib/features/premium/presentation/premium_screen.dart` |
| Design System (tokens Dart + docs) | `lib/core/design_system/`, `design_system/` |
| Biblioteca de assets + catálogo | `assets/`, `lib/core/constants/app_assets.dart` |
| Config de release nativo (drop-in) | `release_config/` |
| Teste de fumaça | `test/smoke_test.dart` |

---

## 4. O que foi otimizado

- Paywall com estado real de premium (bloqueio/desbloqueio consistente via provider).
- Camada de billing desacoplada da UI (troca para RevenueCat sem mexer em tela).
- Analytics centralizado e seguro (nunca quebra o app).
- Renderização de badges/banners nativa → visual correto e mais leve que SVG com texto.

---

## 5. O que depende SÓ das suas chaves / máquina

Estes itens **não** dá para eu concluir aqui — precisam de você:

1. **Gerar as pastas nativas** (obrigatório para qualquer build):
   ```bash
   cd metodo_1_dia
   flutter create .            # cria android/ ios/ web/ sem apagar seu lib/
   flutter pub get
   ```

2. **Firebase**: `flutterfire configure` (gera `firebase_options.dart` real e os
   `google-services.json` / `GoogleService-Info.plist`). Depois:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,functions,storage
   ```

3. **OpenAI** (Amanda): definir a chave na Function e o URL no app:
   ```bash
   firebase functions:config:set openai.key="SUA_CHAVE"
   ```
   e trocar `SEU-PROJETO` em `lib/core/constants/app_constants.dart`
   (`amandaFunctionUrl`). *A chave fica na Function, nunca no app — correto.*
   > Streaming: a HTTP Function atual retorna resposta completa. Streaming de
   > tokens exige Function com SSE/stream + cliente lendo chunks — deixei o
   > `amandaChat` pronto para resposta única; posso evoluir para streaming se quiser.

4. **Google Maps**: habilitar as APIs no Google Cloud, pôr a chave no
   `AndroidManifest.xml` (Android) e `AppDelegate`/`Info.plist` (iOS), descomentar
   `google_maps_flutter` no `pubspec.yaml` e trocar o placeholder do mapa na
   `running_screen.dart` pelo `GoogleMap`. (GPS/geolocator já funcionam.)

5. **RevenueCat / lojas**: criar produtos e o entitlement `premium`, adicionar
   `purchases_flutter` ao pubspec e trocar o `premiumServiceProvider` para
   `RevenueCatPremiumService` (stub já documentado no arquivo).

6. **Assinatura & publicação**: keystore Android (`key.properties` + `.jks`),
   certificados iOS, ícones/splash (`flutter_launcher_icons` + `flutter_native_splash`),
   e envio via Play Console / App Store Connect. Use `release_config/`.

---

## 6. Está pronto para publicar na Play Store / App Store?

**Ainda não — e nenhum ajuste de código sozinho resolve.** O código-fonte está
**production-grade e organizado**, mas a publicação depende de passos externos:

- ❌ **Bloqueador:** pastas nativas não existem → rode `flutter create .`
- ❌ **Bloqueador:** chaves reais (Firebase, OpenAI, Maps) e consoles configurados
- ❌ **Bloqueador:** assinatura de app (keystore/certificados) e `flutter analyze`/build
  verde na sua máquina
- ⚠️ RevenueCat + produtos nas lojas para cobrar de verdade

**Caminho mínimo até a loja (ordem):**
1. `flutter create .` → `flutter pub get` → `flutter analyze` (corrija o que aparecer)
2. `flutterfire configure` + `firebase deploy`
3. Ícones/splash + permissões (`release_config/`)
4. `flutter build appbundle --release` (Android) / `flutter build ipa` (iOS)
5. Configurar billing (RevenueCat) e testar compra sandbox
6. Enviar para revisão

Quando você rodar `flutter analyze` e me colar a saída, eu corrijo qualquer
erro específico que o compilador apontar — é o único passo que não consigo
executar por aqui.
