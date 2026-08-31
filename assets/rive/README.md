# Animações Rive (.riv)

Coloque aqui seus arquivos `.riv` exportados do editor Rive (https://rive.app).

Nomes sugeridos (usados pelo RiveHelper / AppAnimations):
- lili_idle.riv        → mascote parada/respirando
- lili_running.riv     → mascote correndo
- lili_celebrate.riv   → comemoração de conquista
- streak_fire.riv      → chama da sequência (streak)
- level_up.riv         → subir de nível

## Como ativar
1. Descomente `rive: ^0.13.20` no pubspec.yaml (dev já deixou pronto).
2. Rode `flutter pub get`.
3. Descomente o corpo de `RiveHelper` em lib/core/widgets/rive_helper.dart.
4. Use: `RiveHelper.asset(AppAnimations.riveLiliIdle)`.

Enquanto não houver .riv, o app usa as animações Lottie equivalentes
automaticamente (fallback) — nada quebra.
