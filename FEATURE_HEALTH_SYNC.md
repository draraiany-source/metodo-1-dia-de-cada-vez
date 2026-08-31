# 🩺 Módulo: Health Connect / Apple Health / Google Fit

Módulo novo (`lib/features/health_sync/`). Nada existente foi alterado — só adições.

## Arquitetura honesta

O pacote `health` **não pôde ser adicionado e validado** no ambiente onde o código
foi montado (sem SDK/rede). Se eu importasse `package:health` direto, o projeto
**não compilaria** para você.

Por isso usei o mesmo padrão já adotado no RevenueCat deste projeto:

```
HealthService (interface)   <-- a UI fala só com isto
├── LocalHealthService      ATIVO HOJE — usa os registros manuais do app
└── PlatformHealthService   PRONTA, comentada — Health Connect + HealthKit
```

Trocar de motor = **1 linha** em `health_providers.dart`. Nenhuma tela muda.

## Tela `/health-sync`
- **Status** da conexão + última sincronização ("há 5 min")
- **Permissões**: botão de conceder, com mensagens claras para concedida/negada/indisponível
- **Grade de 9 métricas**: passos, distância, calorias, freq. cardíaca, peso, IMC,
  treinos, tempo ativo, hidratação (`—` quando indisponível)
- **Sincronização manual** (botão, com recompensa) e **automática** (switch, ao abrir o app)
- Nota de privacidade

## Fallback (requisito central)
Se o usuário **negar a permissão** — ou se a plataforma não existir — o app segue
normal: o `LocalHealthService` monta o snapshot a partir de água, peso e treinos
já registrados manualmente. A tela mostra "Usando registros manuais".

## Integrações
| Módulo | Como |
|---|---|
| **Missões** | Hidratação → progresso absoluto da missão de água; peso → missão semanal |
| **Loja de Recompensas** | +5 🪙 por sync manual; +20 🪙 de bônus ao bater 8.000 passos (1x/dia) |
| **Conquistas / XP / Ranking** | +20 XP por sync; +50 XP de bônus por meta de passos → sobe nível e ranking |
| **IA Personal Trainer** | `TrainerContext` ganhou `passosHoje`, `caloriasHoje`, `fonteSaude`. A IA responde: *"Hoje você já deu 9.412 passos e queimou ~420 kcal. Meta batida! 🎉"* |
| **Dashboard (Home)** | Card "Saúde de hoje" com passos, calorias e tempo ativo (só aparece se houver dados) |
| **Cloud Function** | O prompt da OpenAI agora recebe passos e calorias |

Anti-farm: a sincronização automática (`silent`) **não** concede recompensas —
só a manual. O bônus de passos é limitado a 1x por dia.

## Ativar os dados reais
Passo a passo completo em **`release_config/health_permissions.md`**:
1. `health: ^11.1.0` no pubspec + `flutter pub get`
2. Permissões do Health Connect no `AndroidManifest.xml` (minSdk 26)
3. Capability HealthKit + chaves no `Info.plist` (iOS)
4. Descomentar `PlatformHealthService` e trocar 1 linha no provider

> **Google Fit**: o Google recomenda migrar do Fit API para o Health Connect.
> O pacote `health` já lê o que o Google Fit grava lá — não é preciso a API antiga.
