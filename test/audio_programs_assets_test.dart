import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const slugs = [
    '01_como_vencer_a_procrastinacao',
    '02_como_criar_disciplina',
    '03_como_vencer_a_preguica',
    '04_como_manter_a_constancia',
    '05_como_voltar_depois_de_errar',
    '06_como_criar_habitos_saudaveis',
    '07_como_acreditar_em_voce',
  ];

  test('Programa 7 Dias: 7 MP3 assets existem e nao estao vazios', () async {
    for (final slug in slugs) {
      final key = 'assets/audio_programs/$slug.mp3';
      final data = await rootBundle.load(key);
      expect(data.lengthInBytes, greaterThan(10 * 1024),
          reason: '$key muito pequeno ou ausente');
      final bytes = data.buffer.asUint8List(0, 3);
      final isId3 = bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33;
      final isFrame = bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
      expect(isId3 || isFrame, isTrue, reason: '$key header MP3 invalido');
    }
  });
}
