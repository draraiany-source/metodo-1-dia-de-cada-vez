import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_url.dart';
import 'package:metodo_1_dia/features/video_streaming/domain/video_models.dart';
import 'package:metodo_1_dia/features/video_streaming/domain/video_watch_state.dart';

void main() {
  group('VideoContent.fromMap', () {
    test('tolera tipos frouxos do Firestore', () {
      final v = VideoContent.fromMap('id1', {
        'category': 'motivacao',
        'name': 'Um dia de cada vez',
        'durationSeconds': 1200.0, // double
        'order': '3', // string
        'isPremium': 1, // num
        'active': 'true', // string
        'publishedAt': '2026-01-01T10:00:00.000',
        'level': 'iniciante',
      });

      expect(v.name, 'Um dia de cada vez');
      expect(v.durationSeconds, 1200);
      expect(v.order, 3);
      expect(v.isPremium, isTrue);
      expect(v.active, isTrue);
      expect(v.category, VideoCategory.motivacao);
    });

    test('assume active true se o campo estiver ausente', () {
      final v = VideoContent.fromMap('id2', {'name': 'Sem flag'});
      expect(v.active, isTrue);
    });

    // A biblioteca era categorizada por tipo de treino antes de virar biblioteca
    // de conteúdo. Documentos antigos precisam continuar carregando.
    test('migra categorias legadas de treino em vez de descartá-las', () {
      expect(
        VideoContent.fromMap('x', {'category': 'hiit'}).category,
        VideoCategory.treinamento,
      );
      expect(
        VideoContent.fromMap('x', {'category': 'casa'}).category,
        VideoCategory.treinamento,
      );
      expect(
        VideoContent.fromMap('x', {'category': 'yoga'}).category,
        VideoCategory.alongamentoMobilidade,
      );
      expect(
        VideoContent.fromMap('x', {'category': 'categoria_que_nao_existe'})
            .category,
        VideoCategory.especiais,
      );
    });

    test('preserva youtubeUrl no round-trip toMap/fromMap', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final original = VideoContent.fromMap('id3', {
        'name': 'Boas-vindas',
        'category': 'boasVindas',
        'youtubeUrl': url,
      });
      final voltou = VideoContent.fromMap('id3', original.toMap());
      expect(voltou.youtubeUrl, url);
      expect(voltou.youtubeVideoId, 'dQw4w9WgXcQ');
      expect(voltou.isYoutube, isTrue);
      expect(voltou.aguardandoUrl, isFalse);
    });
  });

  group('VideoContent — regras da biblioteca', () {
    VideoContent comUrl(String url, {int duracao = 0}) =>
        VideoContent.fromMap('v', {
          'name': 'Vídeo',
          'youtubeUrl': url,
          'durationSeconds': duracao,
        });

    test('vídeo sem link fica "aguardando URL" e não é tratado como YouTube', () {
      final v = comUrl('');
      expect(v.aguardandoUrl, isTrue);
      expect(v.isYoutube, isFalse);
    });

    test('link inválido não passa por YouTube', () {
      final v = comUrl('https://vimeo.com/12345');
      expect(v.isYoutube, isFalse);
      expect(v.aguardandoUrl, isTrue);
    });

    test('capa cai na automática do YouTube quando não há capa enviada', () {
      final v = comUrl('https://youtu.be/dQw4w9WgXcQ');
      expect(v.thumbnailUrl, isEmpty);
      expect(v.displayThumbnailUrl,
          'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg');
    });

    test('capa enviada tem prioridade sobre a automática', () {
      final v = VideoContent.fromMap('v', {
        'name': 'Vídeo',
        'youtubeUrl': 'https://youtu.be/dQw4w9WgXcQ',
        'thumbnailUrl': 'https://exemplo.com/capa.jpg',
      });
      expect(v.displayThumbnailUrl, 'https://exemplo.com/capa.jpg');
    });

    test('durationLabel formata segundos, minutos e horas', () {
      expect(comUrl('', duracao: 0).durationLabel, '');
      expect(comUrl('', duracao: 45).durationLabel, '45s');
      expect(comUrl('', duracao: 600).durationLabel, '10 min');
      expect(comUrl('', duracao: 3600).durationLabel, '1 h');
      expect(comUrl('', duracao: 3900).durationLabel, '1 h 05');
    });
  });

  group('YoutubeUrl', () {
    test('extrai id de todos os formatos que a Amanda pode colar', () {
      const id = 'dQw4w9WgXcQ';
      for (final url in [
        'https://www.youtube.com/watch?v=$id',
        'https://youtu.be/$id',
        'https://www.youtube.com/shorts/$id',
        'https://www.youtube.com/embed/$id',
        'https://www.youtube.com/live/$id',
        'youtube.com/watch?v=$id', // sem https
        'https://www.youtube.com/watch?v=$id&t=30s',
      ]) {
        expect(YoutubeUrl.extractVideoId(url), id, reason: url);
      }
    });

    test('devolve null para o que não é vídeo do YouTube', () {
      expect(YoutubeUrl.extractVideoId(''), isNull);
      expect(YoutubeUrl.extractVideoId('https://vimeo.com/12345'), isNull);
      expect(YoutubeUrl.extractVideoId('não é uma url'), isNull);
    });

    test('normaliza shorts e youtu.be para watch?v=', () {
      final uri = YoutubeUrl.normalize('https://youtu.be/dQw4w9WgXcQ');
      expect(uri?.host, 'www.youtube.com');
      expect(uri?.queryParameters['v'], 'dQw4w9WgXcQ');
    });
  });

  group('VideoWatchState', () {
    test('sem duração cadastrada não há progresso estimável', () {
      const e = VideoWatchState(secondsInPlayer: 120);
      expect(e.progresso(0), 0);
      expect(e.iniciado, isTrue);
    });

    test('progresso é a fração do tempo de tela, limitada a 1', () {
      const e = VideoWatchState(secondsInPlayer: 300);
      expect(e.progresso(600), closeTo(0.5, 0.001));
      expect(e.progresso(100), 1);
    });

    test('concluído sempre reporta 100%', () {
      const e = VideoWatchState(secondsInPlayer: 5, completed: true);
      expect(e.progresso(600), 1);
    });

    test('round-trip de serialização', () {
      const e = VideoWatchState(
          secondsInPlayer: 42, completed: true, lastOpenedAtMs: 1700000000000);
      final volta = VideoWatchState.fromMap(e.toMap());
      expect(volta.secondsInPlayer, 42);
      expect(volta.completed, isTrue);
      expect(volta.lastOpenedAtMs, 1700000000000);
    });
  });
}
