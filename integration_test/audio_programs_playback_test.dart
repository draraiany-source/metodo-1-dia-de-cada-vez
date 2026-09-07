import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:just_audio/just_audio.dart';

/// Validação no device: 7 faixas — load, play, pause, ±15s, reload.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const days = <(String id, String title)>[
    ('01_como_vencer_a_procrastinacao', 'Como Vencer a Procrastinação'),
    ('02_como_criar_disciplina', 'Como Criar Disciplina'),
    ('03_como_vencer_a_preguica', 'Como Vencer a Preguiça'),
    ('04_como_manter_a_constancia', 'Como Manter a Constância'),
    ('05_como_voltar_depois_de_errar', 'Como Voltar Depois de Errar'),
    ('06_como_criar_habitos_saudaveis', 'Como Criar Hábitos Saudáveis'),
    ('07_como_acreditar_em_voce', 'Como Acreditar em Você'),
  ];

  testWidgets('7 audios playback controls', (tester) async {
    final player = AudioPlayer();
    addTearDown(() async {
      try {
        await player.dispose();
      } catch (_) {}
    });

    for (final day in days) {
      final id = day.$1;
      final title = day.$2;
      final path = 'assets/audio_programs/$id.mp3';

      final duration = await player.setAsset(path).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('load $title'),
      );
      expect(duration, isNotNull, reason: 'load $title');
      expect(duration!.inSeconds, greaterThan(20), reason: '$title curto');

      await player.seek(const Duration(seconds: 2));
      await player.play();
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(player.playing, isTrue, reason: 'play $title');

      await player.pause();
      expect(player.playing, isFalse, reason: 'pause $title');

      final mid = player.position;
      await player.seek(mid + const Duration(seconds: 15));
      expect(player.position.inMilliseconds,
          greaterThan(mid.inMilliseconds + 5000));

      await player.seek(player.position - const Duration(seconds: 15));

      // Fechar/reabrir faixa
      await player.stop();
      final again = await player.setAsset(path);
      expect(again, isNotNull, reason: 'reopen $title');
      await player.seek(const Duration(seconds: 1));
      await player.play();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(player.playing, isTrue, reason: 'reopen play $title');
      await player.pause();

      // Término: seek perto do fim
      final endPos = duration - const Duration(milliseconds: 500);
      if (endPos > Duration.zero) {
        await player.seek(endPos);
        expect(player.position.inMilliseconds,
            greaterThan(duration.inMilliseconds - 2000));
      }
      await player.stop();
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
  @override
  String toString() => message;
}
