# Design System — Lili Fit 💜

Fonte única de verdade visual do app. Os tokens abaixo têm equivalente em código
em `lib/core/design_system/` (Dart) e em `design_system/tokens.json` (JSON).

---

## 🎨 Paleta oficial

| Token | Hex | Uso |
|---|---|---|
| primary | `#9B5DE5` | Cor principal (lilás) — botões, destaques, ícones |
| primaryDark | `#5A189A` | Roxo profundo — gradientes, headers |
| secondary | `#F15BB5` | Rosa — acentos, "vibe", elementos femininos |
| accent | `#C4A7F0` | Lilás claro — detalhes sutis |
| success | `#00C896` | Verde progresso — metas, confirmações |
| warning | `#F59E0B` | Âmbar — premium, alertas leves |
| danger | `#EF4444` | Vermelho — erros, sair |
| background | `#111111` | Fundo (dark-first) |
| surface | `#1C1B24` | Cards e superfícies |
| surface2 | `#241F35` | Superfícies elevadas / disabled |
| textPrimary | `#FFFFFF` | Texto principal |
| textSecondary | `#A1A1AA` | Texto de apoio |
| textTertiary | `#52525B` | Legendas / desabilitado |

**Em código:** `AppColors.primary`, `AppColors.surface`, ...

---

## 🌈 Gradientes

| Nome | Cores | Uso |
|---|---|---|
| brand | `#5A189A → #9B5DE5` | Logo, botões primários |
| vibe | `#9B5DE5 → #F15BB5` | Cards de destaque, Amanda, CTAs |
| premium | `#F59E0B → #5A189A` | Tudo relacionado a assinatura |
| success | `#00C896 → #0A8F6E` | Conclusões, metas |

**Em código:** `AppGradients.vibe`, `AppGradients.premium`, ...

---

## 🔤 Tipografia

- **Títulos:** Poppins (700–800)
- **Corpo:** Inter (400–600)

| Estilo | Tamanho | Peso |
|---|---|---|
| display | 32 | 800 |
| h1 | 24 | 700 |
| h2 | 20 | 600 |
| title | 16 | 600 |
| body | 15 | 400 |
| caption | 12 | 400 |

**Em código:** `AppTypography.h1`, `AppTypography.body`, ...

---

## 📏 Espaçamento & Raios

Escala base 4: `xxs 2 · xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · xxxl 32 · huge 48`
→ `AppSpacing.lg`

Raios: `sm 8 · md 12 · lg 16 · xl 20 · pill 999` → `AppRadii.xl`

---

## 🌑 Sombras

| Nome | Valor | Uso |
|---|---|---|
| card | `0 8px 18px rgba(0,0,0,.35)` | Cards |
| glowPurple | `0 0 30px rgba(155,93,229,.45)` | Botões primários, foco |
| glowPink | `0 0 26px rgba(241,91,181,.40)` | Destaques femininos |

**Em código:** `AppShadows.card`, `AppShadows.glowPurple`.

---

## 🧩 Componentes

Todos disponíveis em `lib/core/widgets/lili_widgets.dart`:

| Widget | Descrição |
|---|---|
| `LiliButton` | Botão gradiente com glow + estado desabilitado |
| `LiliCard` | Card padrão (surface + raio xl + sombra) |
| `LiliIcon` | Ícone SVG tintável da biblioteca |
| `BadgeView` | Medalha/conquista SVG (com estado bloqueado) |
| `LiliAnimation` | Wrapper de Lottie |
| `AppLogo` / `AppLogoMark` | Logo e símbolo da marca |
| `LiliMascot` | Mascote (PNG 3D quando disponível, senão vetor) |
| `GradientBackground` | Fundo com gradiente premium |

### Botões — estados
- **Normal:** gradiente `vibe` + `glowPurple`.
- **Pressed:** `scale 0.97` (aplique `AnimatedScale` no onTapDown se desejar).
- **Disabled:** `onPressed: null` → fundo `surface2`, sem glow, opacidade 0.4.

### Campos de texto
Definidos no `InputDecorationTheme` de `app_theme.dart`: fundo `surface`,
borda `focus` lilás 1.5px, raio `md`.

### Cards
`LiliCard` ou `Card` (tema global): `surface`, raio `xl`, sombra `card`.

---

## 🎛 Estados

| Estado | Efeito |
|---|---|
| hover (web/desktop) | overlay branco 6% |
| pressed | overlay preto 12% + scale 0.97 |
| disabled | opacidade 0.4 + fundo surface2 |
| focus | borda lilás 1.5px |

---

## 🖼 Biblioteca de assets

Catálogo em código: `lib/core/constants/app_assets.dart` (101 assets).
Categorias: `icons` (25), `badges` (9 tiers + 14 conquistas), `backgrounds` (8),
`banners` (7), `animations` Lottie (6), `onboarding` (12), `empty` (7),
`error` (3), marca (logo, splash, ícones de app).

Tela de catálogo visível no app: rota `/showcase` (botão na Home).
