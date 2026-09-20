import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_url.dart';
import 'package:metodo_1_dia/features/video_streaming/domain/video_models.dart';

void main() {
  test('seed mantém boas-vindas e inclui os 3 Shorts ativos', () {
    final raw =
        File('assets/content/videos_biblioteca.json').readAsStringSync();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['videos'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final ids = list.map((v) => '${v['id']}').toSet();
    expect(ids, contains('boas_vindas_metodo_1_dia'));
    expect(
      ids,
      containsAll(['yt_34PHGKECMTY', 'yt_3T0HDPX4jkk', 'yt_zRSTnW3EMF8']),
    );

    final welcome =
        list.firstWhere((v) => v['id'] == 'boas_vindas_metodo_1_dia');
    expect(welcome['name'], contains('Boas-vindas'));

    const expected = {
      'yt_34PHGKECMTY': '34PHGKECMTY',
      'yt_3T0HDPX4jkk': '3T0HDPX4jkk',
      'yt_zRSTnW3EMF8': 'zRSTnW3EMF8',
    };
    expected.forEach((docId, videoId) {
      final item = list.firstWhere((v) => v['id'] == docId);
      final parsed = VideoContent.fromMap(docId, item);
      expect(parsed.youtubeVideoId, videoId);
      expect(parsed.active, isTrue);
      expect(parsed.category, VideoCategory.metodo1Dia);
      expect(YoutubeUrl.extractVideoId('${item['youtubeUrl']}'), videoId);
      expect(item['videoId'], videoId);
      expect(item['thumbnailUrl'], contains(videoId));
    });
  });
}
