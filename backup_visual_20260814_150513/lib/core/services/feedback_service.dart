import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tipos de evento que merecem feedback.
enum FeedbackEvent {
  toqueLeve,
  conquista,
  recompensa,
  levelUp,
  erro,
  sucesso,
}

/// Feedback sensorial (háptico + som) para conquistas e recompensas.
///
/// **O que está ativo hoje**: háptico nativo e sons de sistema — funcionam em
/// Android e iOS **sem nenhum pacote extra** e sem arquivos de áudio.
///
/// **Para sons customizados** (opcional):
/// 1. `flutter pub add audioplayers`
/// 2. Coloque os `.mp3` em `assets/sounds/` e registre no `pubspec.yaml`:
///    `achievement.mp3`, `coin.mp3`, `level_up.mp3`, `error.mp3`
/// 3. Descomente o bloco `_playCustom` abaixo.
///
/// O usuário controla tudo em Perfil → Som e vibração.
class FeedbackService {
  FeedbackService._();

  static bool _hapticsOn = true;
  static bool _soundOn = true;

  static bool get hapticsEnabled => _hapticsOn;
  static bool get soundEnabled => _soundOn;

  static const _kHaptics = 'feedback_haptics';
  static const _kSound = 'feedback_sound';

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _hapticsOn = p.getBool(_kHaptics) ?? true;
    _soundOn = p.getBool(_kSound) ?? true;
  }

  static Future<void> setHaptics(bool v) async {
    _hapticsOn = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kHaptics, v);
    if (v) HapticFeedback.selectionClick();
  }

  static Future<void> setSound(bool v) async {
    _soundOn = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSound, v);
  }

  /// Dispara o feedback do evento. Nunca lança exceção.
  static Future<void> play(FeedbackEvent event) async {
    try {
      if (_hapticsOn) await _haptic(event);
      if (_soundOn) await _sound(event);
    } catch (_) {
      // feedback nunca pode quebrar um fluxo de negócio
    }
  }

  static Future<void> _haptic(FeedbackEvent e) async {
    switch (e) {
      case FeedbackEvent.toqueLeve:
        await HapticFeedback.selectionClick();
      case FeedbackEvent.recompensa:
        await HapticFeedback.lightImpact();
      case FeedbackEvent.sucesso:
        await HapticFeedback.mediumImpact();
      case FeedbackEvent.conquista:
      case FeedbackEvent.levelUp:
        // "Rajada" curta: dá a sensação de celebração.
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 90));
        await HapticFeedback.heavyImpact();
      case FeedbackEvent.erro:
        await HapticFeedback.vibrate();
    }
  }

  static Future<void> _sound(FeedbackEvent e) async {
    // Sons nativos do sistema — sem dependências nem assets.
    switch (e) {
      case FeedbackEvent.toqueLeve:
      case FeedbackEvent.recompensa:
      case FeedbackEvent.sucesso:
      case FeedbackEvent.conquista:
      case FeedbackEvent.levelUp:
        await SystemSound.play(SystemSoundType.click);
      case FeedbackEvent.erro:
        await SystemSound.play(SystemSoundType.alert);
    }
    // await _playCustom(e);
  }

  // ---------------------------------------------------------------------------
  // SONS CUSTOMIZADOS (descomente após adicionar `audioplayers` e os .mp3)
  // ---------------------------------------------------------------------------
  //
  // static final _player = AudioPlayer();
  //
  // static Future<void> _playCustom(FeedbackEvent e) async {
  //   final asset = switch (e) {
  //     FeedbackEvent.conquista => 'sounds/achievement.mp3',
  //     FeedbackEvent.recompensa => 'sounds/coin.mp3',
  //     FeedbackEvent.levelUp => 'sounds/level_up.mp3',
  //     FeedbackEvent.erro => 'sounds/error.mp3',
  //     _ => null,
  //   };
  //   if (asset == null) return;
  //   await _player.play(AssetSource(asset));
  // }
}

/// Estado observável das preferências (para a UI de configurações).
class FeedbackPrefs {
  const FeedbackPrefs({this.haptics = true, this.sound = true});
  final bool haptics;
  final bool sound;

  FeedbackPrefs copyWith({bool? haptics, bool? sound}) =>
      FeedbackPrefs(haptics: haptics ?? this.haptics, sound: sound ?? this.sound);
}

class FeedbackPrefsNotifier extends StateNotifier<FeedbackPrefs> {
  FeedbackPrefsNotifier() : super(const FeedbackPrefs()) {
    _load();
  }

  Future<void> _load() async {
    await FeedbackService.load();
    state = FeedbackPrefs(
        haptics: FeedbackService.hapticsEnabled,
        sound: FeedbackService.soundEnabled);
  }

  Future<void> setHaptics(bool v) async {
    await FeedbackService.setHaptics(v);
    state = state.copyWith(haptics: v);
  }

  Future<void> setSound(bool v) async {
    await FeedbackService.setSound(v);
    state = state.copyWith(sound: v);
  }
}

final feedbackPrefsProvider =
    StateNotifierProvider<FeedbackPrefsNotifier, FeedbackPrefs>(
        (ref) => FeedbackPrefsNotifier());
