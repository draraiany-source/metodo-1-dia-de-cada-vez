# Pacote 2 — Ícones 3D premium (Lily Fit)

40 PNGs 1:1, paleta rosa neon / lilás / roxo, estilo glossy 3D.
**Fundo transparente (RGBA)** — fundos claros removidos com Pillow (sem rembg).

## Uso no Flutter

```dart
import 'package:metodo_1_dia/core/assets/app_icons.dart';
// ou
import 'package:metodo_1_dia/core/assets/app_icons_pack2.dart';

Image.asset(AppIcons.premium)      // via catálogo unificado
Image.asset(AppIconsPack2.home)    // via catálogo pack 2
```

Pasta registrada em `pubspec.yaml` como `assets/images/icons_3d_pack2/`.

Backup RGB original (antes da transparência): `tools/icons_pack2_backup_rgb/`.

## Arquivos (40)

| Arquivo | Uso |
|---------|-----|
| `icon_home.png` | Início |
| `icon_gps.png` | Corrida GPS |
| `icon_water.png` | Água |
| `icon_checkin.png` | Check-in |
| `icon_habits.png` | Hábitos |
| `icon_streak.png` | Sequência |
| `icon_recipes.png` | Receitas |
| `icon_videos.png` | Vídeos |
| `icon_audio.png` | Áudios |
| `icon_diary.png` | Diário |
| `icon_progress.png` | Progresso |
| `icon_evolution.png` | Evolução |
| `icon_before_after.png` | Fotos antes/depois |
| `icon_community.png` | Comunidade |
| `icon_profile.png` | Perfil |
| `icon_personal.png` | Personal / Amanda |
| `icon_premium.png` | Premium |
| `icon_calendar.png` | Calendário |
| `icon_notifications.png` | Notificações |
| `icon_favorites.png` | Favoritos |
| `icon_goal.png` | Meta |
| `icon_calories.png` | Calorias |
| `icon_weight.png` | Peso |
| `icon_bmi.png` | IMC |
| `icon_play.png` | Play |
| `icon_pause.png` | Pausar |
| `icon_complete.png` | Concluir treino |
| `icon_back.png` | Voltar |
| `icon_next.png` | Próximo |
| `icon_settings.png` | Configurações |
| `icon_security.png` | Segurança |
| `icon_support.png` | Suporte |
| `icon_search.png` | Busca |
| `icon_filter.png` | Filtro |
| `icon_upload_photo.png` | Upload de foto |
| `icon_camera.png` | Câmera |
| `icon_gallery.png` | Galeria |
| `icon_hydration_goal.png` | Meta de hidratação |
| `icon_workout_goal.png` | Meta de treino |
| `icon_achievement.png` | Conquista |

## Integração

Ícones do **pacote 1** (`icons_3d/*_3d.png`) continuam nas áreas de treino/nav já aprovadas.
O pacote 2 cobre atalhos de sistema e itens que antes usavam PNGs flat em `assets/icons/`.
