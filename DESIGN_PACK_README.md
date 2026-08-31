# 🎨 Lili Fit — Design Pack & Biblioteca de Assets

Este pacote adiciona ao app **Método 1 Dia de Cada Vez / Lili Fit** uma biblioteca
visual completa, integrada ao Flutter e pronta para uso imediato.

## ✅ O que já está pronto (101 assets vetoriais reais)

| Categoria | Qtd | Pasta |
|---|---|---|
| Ícones customizados SVG | 25 | `assets/icons/` |
| Medalhas (tier) | 9 | `assets/badges/badge_*` |
| Conquistas | 14 | `assets/badges/ach_*` |
| Backgrounds premium | 8 | `assets/backgrounds/` |
| Banners | 7 | `assets/illustrations/banners/` |
| Animações Lottie funcionais | 6 | `assets/animations/` |
| Onboarding | 12 | `assets/onboarding/` |
| Telas vazias | 7 | `assets/empty/` |
| Erros | 3 | `assets/error/` |
| Logo, splash, ícones de app | 9 | `assets/images/`, `assets/app_icon/` |

Tudo catalogado em `lib/core/constants/app_assets.dart` e visível na tela
**Design System** (rota `/showcase`, botão na Home).

## 🔌 Integração Flutter (feita automaticamente)

- **pubspec.yaml** — todas as pastas registradas; `flutter_svg` e `lottie` já presentes.
- **AppAssets** — catálogo com 101 constantes tipadas.
- **Design System** — `lib/core/design_system/`: cores, gradientes, tipografia,
  espaçamentos, raios, sombras.
- **Widgets** — `lib/core/widgets/lili_widgets.dart`: `LiliIcon`, `LiliButton`,
  `LiliCard`, `BadgeView`, `LiliAnimation`, `AppLogo`, `LiliMascot`, `GradientBackground`.
- **Theme** — mantém a paleta oficial (lilás/roxo/rosa/verde).

Exemplo de uso:
```dart
LiliIcon(AppAssets.icTreinos, color: AppColors.secondary);
BadgeView(AppAssets.badgeOuro, size: 120);
LiliAnimation(AppAssets.animSuccessCheck, repeat: false);
SvgPicture.asset(AppAssets.bannerPremium);
```

## 🖼 Ícones do aplicativo (gerar PNGs finais)

Os SVGs de ícone estão em `assets/app_icon/`. Para gerar os PNGs nas resoluções
das lojas, recomendo o pacote `flutter_launcher_icons`:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  image_path: "assets/app_icon/app_icon.png"          # exporte o SVG p/ PNG 1024
  android: true
  adaptive_icon_background: "#5A189A"
  adaptive_icon_foreground: "assets/app_icon/android_adaptive_foreground.png"
  ios: true
  web: { generate: true }
```
(Converta os `.svg` para `.png` com Inkscape/`rsvg-convert` ou no Figma.)

## 🎭 Arte de personagem (Lili Fit em 3D)

Não incluída como render final — exige um gerador de imagem/artista 3D para manter
a semelhança exata da mascote. **Todos os prompts prontos** estão em
`PROMPTS_LILI_FIT.md`, organizados por categoria (28 poses, 20 expressões,
20 stickers, 12 onboarding, cenas, 200 avatares). Gere os PNGs, solte em
`assets/avatars/lili_<pose>.png` e o widget `LiliMascot` passa a usá-los
automaticamente (com fallback vetorial enquanto não existirem).

Veja `assets_manifest.json` para o inventário completo (pronto vs a gerar).

## 📁 Estrutura

```
assets/
├── icons/  badges/  backgrounds/  animations/
├── illustrations/banners/
├── onboarding/  empty/  error/  success/  loading/
├── avatars/  stickers/  premium/
├── exercises/  recipes/  habits/  challenges/
├── images/ (logo, splash)   app_icon/ (store, adaptive, ios, favicon, notif)
design_system/  (tokens.json + DESIGN_SYSTEM.md)
PROMPTS_LILI_FIT.md
assets_manifest.json
```
