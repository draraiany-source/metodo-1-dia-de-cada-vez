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
      'yt_3T0HDPX4jkk': (videoId: '3T0HDPX4jkk', order: 10, shortLabel: 'Short 1'),
      'yt_zRSTnW3EMF8': (videoId: 'zRSTnW3EMF8', order: 11, shortLabel: 'Short 2'),
      'yt_34PHGKECMTY': (videoId: '34PHGKECMTY', order: 12, shortLabel: 'Short 3'),
    };
    expected.forEach((docId, expectData) {
      final item = list.firstWhere((v) => v['id'] == docId);
      final parsed = VideoContent.fromMap(docId, item);
      expect(parsed.youtubeVideoId, expectData.videoId);
      expect(parsed.active, isTrue);
      expect(parsed.category, VideoCategory.metodo1Dia);
      expect(parsed.order, expectData.order);
      expect('${item['name']}', contains(expectData.shortLabel));
      expect(YoutubeUrl.extractVideoId('${item['youtubeUrl']}'), expectData.videoId);
      expect(item['videoId'], expectData.videoId);
      expect(item['thumbnailUrl'], contains(expectData.videoId));
    });

    final shortsOrdered = list
        .where((v) => '${v['id']}'.startsWith('yt_'))
        .toList()
      ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
    expect(
      shortsOrdered.map((v) => '${v['id']}').toList(),
      ['yt_3T0HDPX4jkk', 'yt_zRSTnW3EMF8', 'yt_34PHGKECMTY'],
    );
  });
}
