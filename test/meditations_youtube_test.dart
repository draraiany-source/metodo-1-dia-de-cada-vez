import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_url.dart';
import 'package:metodo_1_dia/features/video_streaming/domain/video_models.dart';

void main() {
  const expected = <String, String>{
    'meditation_yt_UH5zs7CtPvs': 'UH5zs7CtPvs',
    'meditation_yt_lLpZMeMNbcU': 'lLpZMeMNbcU',
    'meditation_yt_nZempKMRbe0': 'nZempKMRbe0',
    'meditation_yt_36WIOOoo-3I': '36WIOOoo-3I',
    'meditation_yt_JXnM5Kw5rtQ': 'JXnM5Kw5rtQ',
    'meditation_yt_gTS3NisvXBg': 'gTS3NisvXBg',
    'meditation_yt_p1fnlTzTLyE': 'p1fnlTzTLyE',
  };

  test('seed traz as 7 meditações do YouTube com id e capa', () {
    final raw =
        File('assets/content/videos_biblioteca.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['videos'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    expect(expected.keys.every((id) => list.any((v) => v['id'] == id)), isTrue);

    expected.forEach((docId, videoId) {
      final item = list.firstWhere((v) => v['id'] == docId);
      final parsed = VideoContent.fromMap(docId, item);
      expect(parsed.category, VideoCategory.meditacao);
      expect(parsed.isMeditation, isTrue);
      expect(parsed.category.isVideoLibrary, isFalse);
      expect(parsed.active, isTrue);
      expect(parsed.youtubeVideoId, videoId);
      expect(YoutubeUrl.extractVideoId('${item['youtubeUrl']}'), videoId);
      expect(parsed.displayThumbnailUrl, contains(videoId));
    });
  });

  test('Shorts viram watch?v= e o player usa só o id', () {
    const raw =
        'https://youtube.com/shorts/UH5zs7CtPvs?si=mw0c1lvNJBTF4iBw';
    expect(YoutubeUrl.extractVideoId(raw), 'UH5zs7CtPvs');
    expect(
      YoutubeUrl.normalize(raw).toString(),
      'https://www.youtube.com/watch?v=UH5zs7CtPvs',
    );
  });

  test('categoria meditacao não cai em especiais', () {
    final v = VideoContent.fromMap('m', {
      'name': 'Meditação',
      'category': 'meditacao',
      'youtubeUrl': 'https://www.youtube.com/shorts/gTS3NisvXBg',
    });
    expect(v.category, VideoCategory.meditacao);
    expect(v.isYoutube, isTrue);
  });
}
