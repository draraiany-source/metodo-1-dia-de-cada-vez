import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_url.dart';
import 'package:metodo_1_dia/features/audio_programs/data/repositories/audio_program_repository_impl.dart';

/// Device: os 7 dias do Programa apontam para os Shorts já validados no Android.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const days = <(String id, String title, String videoId)>[
    ('01_como_vencer_a_procrastinacao', 'Como Vencer a Procrastinação', 'UH5zs7CtPvs'),
    ('02_como_criar_disciplina', 'Como Criar Disciplina', 'lLpZMeMNbcU'),
    ('03_como_vencer_a_preguica', 'Como Vencer a Preguiça', 'nZempKMRbe0'),
    ('04_como_manter_a_constancia', 'Como Manter a Constância', '36WIOOoo-3I'),
    ('05_como_voltar_depois_de_errar', 'Como Voltar Depois de Errar', 'JXnM5Kw5rtQ'),
    ('06_como_criar_habitos_saudaveis', 'Como Criar Hábitos Saudáveis', 'gTS3NisvXBg'),
    ('07_como_acreditar_em_voce', 'Como Acreditar em Você', 'p1fnlTzTLyE'),
  ];

  testWidgets('Programa 7 Dias resolve para os 7 Shorts do YouTube', (tester) async {
    for (final day in days) {
      final url = AudioProgramRepositoryImpl.youtubeUrlFor(day.$1);
      expect(url, 'https://www.youtube.com/shorts/${day.$3}', reason: day.$2);
      expect(YoutubeUrl.extractVideoId(url!), day.$3, reason: day.$2);
    }
  });
}
