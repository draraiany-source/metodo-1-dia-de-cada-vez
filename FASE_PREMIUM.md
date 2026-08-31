# ✨ Fase Premium — Experiência

Nenhum módulo novo. Nenhuma funcionalidade alterada. Só polimento de experiência.

## 1. Microanimações (`core/widgets/animations.dart`)
| Widget | Uso |
|---|---|
| `PressableScale` | "Afunda" ao toque + háptico (banner, chip de moedas, card de saúde) |
| `AnimatedProgressBar` | Barra que anima até o novo valor (missões) — sem salto seco |
| `AnimatedCounter` | Números que "contam" (XP e moedas ao resgatar missão) |
| `Pulse` | Pulsação sutil no botão "Resgatar" quando há recompensa pronta |
| `FadeInUp` / `PopIn` / `Shimmer` / `SkeletonBox` | Já existentes, mantidos |

> `StaggeredList` foi removido: era redundante com `FadeInUp(delayMs:)`.

## 2. Mascote viva (`core/widgets/lili_animated.dart`)

**Sem Rive.** `AnimatedLiliMascot` anima as poses PNG existentes com princípios
clássicos de animação (squash & stretch, easing):

| `LiliMood` | Efeito | Onde |
|---|---|---|
| `respirando` | Peito sobe/desce (seno, 3,2 s) | Card motivacional da Home |
| `viva` | Respirando + piscada periódica | Avatar da Home, Splash |
| `comemorando` | Pulinho com squash & stretch | Missão concluída, treino, resgate |
| `correndo` | Balanço rítmico + inclinação | disponível |
| `calma` | Balanço lento (5 s) | Card "Momento Zen" |
| `estatica` | Sem animação (listas/avatares pequenos) | — |

**Sobre Rive**: arquivos `.riv` são binários do editor Rive — não é possível
gerá-los por código. A infraestrutura (`RiveHelper`, `assets/rive/`, dependência
comentada) segue pronta: ao exportar os `.riv`, o Rive assume e estas animações
viram fallback. Ver `release_config/health_permissions.md` e `assets/rive/README.md`.

## 3. Lottie (11 no total)
Novas: **`unlock.json`** (cadeado abrindo + brilho) e **`medal_unlock.json`**
(medalha descendo com fita e raios). Já existentes: confete, XP, level up,
troféu, chama de streak, check, coração, água, loading.
Ligadas: `unlock` no resgate da Loja · `confetti` na missão concluída.

## 4. Transições entre telas
`_fadeSlide` (fade + deslize de 3%, 260 ms `easeOutCubic`) em **21 rotas
full-screen**. As abas do `ShellRoute` mantêm troca instantânea — animar a
bottom nav deixa o app "borrachudo".

Bônus: `debugLogDiagnostics` agora só em `kDebugMode` (não logava navegação em release).

## 5. Feedback visual e tátil
- Botões: háptico no toque (`HapticFeedback.lightImpact`).
- Cards e atalhos: ripple (`InkWell`) ou `PressableScale`.
- Barras de progresso: animação com `easeOutCubic`.
- **Cuidado tomado**: não envolvemos `ElevatedButton` em `PressableScale` —
  dois detectores de gesto sobrepostos podem disparar a ação **duas vezes**.

## 6. Sons e vibração (`core/services/feedback_service.dart`)
**Ativo hoje, sem nenhum pacote extra**: háptico nativo + sons de sistema
(`SystemSound`), funcionando em Android e iOS.

| Evento | Háptico | Som |
|---|---|---|
| Conquista / Level up | médio + forte (rajada) | click |
| Recompensa | leve | click |
| Sucesso | médio | click |
| Erro | vibrar | alert |

Usuário controla em **Perfil → Som e vibração** (persistido).

**Sons customizados (opcional)**: `flutter pub add audioplayers`, coloque os
`.mp3` em `assets/sounds/` e descomente `_playCustom` no serviço.
Não foi possível gerar arquivos de áudio aqui.

## 7. Tipografia refinada (`core/theme/app_theme.dart`)
- Títulos com `letterSpacing` negativo (-0.8 a -0.1) — padrão de apps de topo.
- Corpo com `height: 1.45` para respiro e legibilidade.
- `bodyLarge/Medium/Small` agora definidos explicitamente com Inter.

## 8. Fluidez
- **0 vazamentos**: todos os `AnimationController` têm `dispose()`.
- Animações usam `AnimatedBuilder` com `child` cacheado (não reconstrói a imagem).
- Transições curtas (260/200 ms) — acima disso o app parece lento.
- `Pulse`/`AnimatedLiliMascot` param quando `mood == estatica`.

> Fluidez real (FPS/jank) só é mensurável com o **Flutter DevTools em device**.
> Não há SDK neste ambiente.
