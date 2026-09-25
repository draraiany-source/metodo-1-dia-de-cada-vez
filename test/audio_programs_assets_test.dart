import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_url.dart';
import 'package:metodo_1_dia/features/audio_programs/data/repositories/audio_program_repository_impl.dart';

void main() {
  test('Programa 7 Dias aponta para os 7 Shorts do YouTube, sem MP3 local', () {
    const expected = {
      '01_como_vencer_a_procrastinacao': 'UH5zs7CtPvs',
      '02_como_criar_disciplina': 'lLpZMeMNbcU',
      '03_como_vencer_a_preguica': 'nZempKMRbe0',
      '04_como_manter_a_constancia': '36WIOOoo-3I',
      '05_como_voltar_depois_de_errar': 'JXnM5Kw5rtQ',
      '06_como_criar_habitos_saudaveis': 'gTS3NisvXBg',
      '07_como_acreditar_em_voce': 'p1fnlTzTLyE',
    };

    expect(AudioProgramRepositoryImpl.kPrograma7YoutubeIds, expected);
    expected.forEach((slug, videoId) {
      final url = AudioProgramRepositoryImpl.youtubeUrlFor(slug);
      expect(url, 'https://www.youtube.com/shorts/$videoId');
      expect(YoutubeUrl.extractVideoId(url!), videoId);
    });
  });
}
