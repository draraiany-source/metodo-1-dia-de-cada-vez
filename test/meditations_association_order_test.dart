import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_url.dart';
import 'package:metodo_1_dia/features/video_streaming/domain/video_models.dart';

/// Garante que cada meditação do seed aponta para o Short certo
/// (título canônico no app ↔ videoId ↔ título real no YouTube oEmbed).
void main() {
  /// Ordem canônica = Programa 7 Dias / cadastro Áudio 1…7.
  const expected = <({
    String id,
    String appName,
    String videoId,
    String youtubeTitle,
    int order,
  })>[
    (
      id: 'meditation_yt_UH5zs7CtPvs',
      appName: '1. Como Vencer a Procrastinação',
      videoId: 'UH5zs7CtPvs',
      youtubeTitle: 'Áudio 1 como vencer a procrastinação.',
      order: 1,
    ),
    (
      id: 'meditation_yt_lLpZMeMNbcU',
      appName: '2. Como Criar Disciplina',
      videoId: 'lLpZMeMNbcU',
      youtubeTitle: 'Áudio 2 como criar disciplina.',
      order: 2,
    ),
    (
      id: 'meditation_yt_nZempKMRbe0',
      appName: '3. Como Vencer a Preguiça',
      videoId: 'nZempKMRbe0',
      youtubeTitle: 'Áudio 3 como.vencer a preguiça.',
      order: 3,
    ),
    (
      id: 'meditation_yt_36WIOOoo-3I',
      appName: '4. Como Manter a Constância',
      videoId: '36WIOOoo-3I',
      youtubeTitle: 'Áudio 4 como manter a constância.',
      order: 4,
    ),
    (
      id: 'meditation_yt_JXnM5Kw5rtQ',
      appName: '5. Como Voltar Depois de Errar',
      videoId: 'JXnM5Kw5rtQ',
      youtubeTitle: 'Áudio 5 como voltar depois de errar',
      order: 5,
    ),
    (
      id: 'meditation_yt_gTS3NisvXBg',
      appName: '6. Como Criar Hábitos Saudáveis',
      videoId: 'gTS3NisvXBg',
      youtubeTitle: 'Áudio 6 Como criar hábitos saudável',
      order: 6,
    ),
    (
      id: 'meditation_yt_p1fnlTzTLyE',
      appName: '7. Como Acreditar em Você',
      videoId: 'p1fnlTzTLyE',
      youtubeTitle: 'Áudio 7 como acreditar em você.',
      order: 7,
    ),
  ];

  test('seed: 7 meditações na ordem 1–7 com videoId correto', () {
    final raw =
        File('assets/content/videos_biblioteca.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['videos'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((v) => v['category'] == 'meditacao')
        .toList()
      ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

    expect(list.length, 7);
    for (var i = 0; i < expected.length; i++) {
      final e = expected[i];
      final item = list[i];
      final parsed = VideoContent.fromMap('${item['id']}', item);
      expect(item['id'], e.id);
      expect(parsed.name, e.appName);
      expect(parsed.order, e.order);
      expect(parsed.youtubeVideoId, e.videoId);
      expect(YoutubeUrl.extractVideoId('${item['youtubeUrl']}'), e.videoId);
      expect(parsed.isMeditation, isTrue);
      // Nome do app e título do YouTube falam do mesmo tema (mesma numeração).
      final n = RegExp(r'Áudio\s*(\d)').firstMatch(e.youtubeTitle)?.group(1);
      expect(n, '${e.order}', reason: e.youtubeTitle);
    }
  });
}
