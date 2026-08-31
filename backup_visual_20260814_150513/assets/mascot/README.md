# assets/mascot/ — Lily Fit

## Onde colocar os PNGs

Coloque as artes em:

```
assets/mascot/png/
  mascot_profile.png
  mascot_default.png
  mascot_welcome.png
  mascot_pointing.png
  mascot_thumbs_up.png
  mascot_hydration.png
  mascot_checklist.png
  mascot_dumbbell.png
  mascot_strong.png
  mascot_meditation.png
  mascot_heart.png
  mascot_sad.png
  mascot_trophy.png
  mascot_celebrating.png
  mascot_queen.png
```

`MascotConfig.useNewMascot` já está `true`. Arquivos ausentes caem no fallback SVG/legado.

## Crop (importante)

Antes de exportar:

1. Remova canvas transparente excessivo (a personagem deve preencher ~85–95% do frame).
2. Mantenha proporção sem deformar o rosto.
3. Não corte cabeça/pés.
4. Preferência: PNG 640×640+ com fundo transparente, personagem centralizada.

Depois de copiar os arquivos, rode um **hot restart** (`R` no `flutter run`).
