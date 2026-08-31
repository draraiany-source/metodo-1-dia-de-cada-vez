import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências globais de áudio (cursos/biblioteca de áudio da Lily).
///
/// Complementa `feedbackPrefsProvider` (que controla apenas som/vibração de
/// feedback de UI): aqui ficam as preferências de reprodução de conteúdo em
/// áudio pedidas na tela de Configurações. Mesmo padrão local-first
/// (SharedPreferences + Riverpod) já usado em todo o app — nenhuma
/// dependência nova.
class AudioPreferences {
  const AudioPreferences({
    this.volume = 0.8,
    this.autoplay = true,
    this.backgroundPlayback = true,
    this.speed = 1.0,
    this.downloadOverWifiOnly = true,
  });

  /// 0.0 a 1.0.
  final double volume;

  /// Toca a próxima aula automaticamente ao terminar a atual.
  final bool autoplay;

  /// Continua tocando com o app em segundo plano.
  final bool backgroundPlayback;

  /// Velocidade padrão sugerida ao abrir um player (0.75x a 2x).
  final double speed;

  /// Só baixa áudios para uso offline quando conectada ao Wi-Fi.
  final bool downloadOverWifiOnly;

  static const speedOptions = [0.75, 1.0, 1.25, 1.5, 2.0];

  AudioPreferences copyWith({
    double? volume,
    bool? autoplay,
    bool? backgroundPlayback,
    double? speed,
    bool? downloadOverWifiOnly,
  }) =>
      AudioPreferences(
        volume: volume ?? this.volume,
        autoplay: autoplay ?? this.autoplay,
        backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
        speed: speed ?? this.speed,
        downloadOverWifiOnly:
            downloadOverWifiOnly ?? this.downloadOverWifiOnly,
      );

  Map<String, dynamic> toMap() => {
        'volume': volume,
        'autoplay': autoplay,
        'backgroundPlayback': backgroundPlayback,
        'speed': speed,
        'downloadOverWifiOnly': downloadOverWifiOnly,
      };

  static AudioPreferences fromMap(Map<String, dynamic> m) => AudioPreferences(
        volume: (m['volume'] as num?)?.toDouble() ?? 0.8,
        autoplay: (m['autoplay'] as bool?) ?? true,
        backgroundPlayback: (m['backgroundPlayback'] as bool?) ?? true,
        speed: (m['speed'] as num?)?.toDouble() ?? 1.0,
        downloadOverWifiOnly: (m['downloadOverWifiOnly'] as bool?) ?? true,
      );
}

class AudioPreferencesNotifier extends StateNotifier<AudioPreferences> {
  AudioPreferencesNotifier() : super(const AudioPreferences()) {
    _load();
  }

  static const _key = 'audio_preferences';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      state = AudioPreferences.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {/* mantém default */}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toMap()));
  }

  Future<void> update(
      AudioPreferences Function(AudioPreferences) updater) async {
    state = updater(state);
    await _persist();
  }
}

final audioPreferencesProvider =
    StateNotifierProvider<AudioPreferencesNotifier, AudioPreferences>((ref) {
  return AudioPreferencesNotifier();
});
