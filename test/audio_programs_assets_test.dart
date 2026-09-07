import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Valida vínculo título ↔ arquivo (sem plugin nativo).
void main() {
  const expected = <(String id, String title)>[
    ('01_como_vencer_a_procrastinacao', 'Como Vencer a Procrastinação'),
    ('02_como_criar_disciplina', 'Como Criar Disciplina'),
    ('03_como_vencer_a_preguica', 'Como Vencer a Preguiça'),
    ('04_como_manter_a_constancia', 'Como Manter a Constância'),
    ('05_como_voltar_depois_de_errar', 'Como Voltar Depois de Errar'),
    ('06_como_criar_habitos_saudaveis', 'Como Criar Hábitos Saudáveis'),
    ('07_como_acreditar_em_voce', 'Como Acreditar em Você'),
  ];

  test('7 MP3 existem e batem com seed/títulos', () {
    final root = Directory.current;
    final assetsDir = Directory('${root.path}/assets/audio_programs');
    expect(assetsDir.existsSync(), isTrue);

    final seed = File('${root.path}/tools/audio_seed/seed_data.json');
    expect(seed.existsSync(), isTrue);
    final seedText = seed.readAsStringSync();

    for (final item in expected) {
      final id = item.$1;
      final title = item.$2;
      final file = File('${assetsDir.path}/$id.mp3');
      expect(file.existsSync(), isTrue, reason: 'faltando $id.mp3');
      expect(file.lengthSync(), greaterThan(100000), reason: '$id muito pequeno');
      expect(seedText.contains(id), isTrue, reason: 'seed sem $id');
      expect(seedText.contains(title), isTrue, reason: 'seed sem título $title');
    }

    final mp3s = assetsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.mp3'))
        .length;
    expect(mp3s, 7);
  });
}
