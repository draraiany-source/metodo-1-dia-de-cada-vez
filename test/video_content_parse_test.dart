import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/video_streaming/domain/video_models.dart';

void main() {
  test('VideoContent.fromMap tolera tipos frouxos do Firestore', () {
    final v = VideoContent.fromMap('id1', {
      'category': 'hiit',
      'name': 'HIIT 20min',
      'durationSeconds': 1200.0, // double
      'order': '3', // string
      'isPremium': 1, // num
      'active': 'true', // string
      'publishedAt': '2026-01-01T10:00:00.000',
      'level': 'iniciante',
    });

    expect(v.name, 'HIIT 20min');
    expect(v.durationSeconds, 1200);
    expect(v.order, 3);
    expect(v.isPremium, isTrue);
    expect(v.active, isTrue);
    expect(v.category, VideoCategory.hiit);
  });

  test('VideoContent.fromMap assume active true se campo ausente', () {
    final v = VideoContent.fromMap('id2', {
      'name': 'Casa',
    });
    expect(v.active, isTrue);
  });
}
