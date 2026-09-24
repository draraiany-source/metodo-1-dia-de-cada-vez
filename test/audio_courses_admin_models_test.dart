import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/audio_courses/domain/audio_course_models.dart';

void main() {
  test('AudioCourse.active defaults true for legacy maps', () {
    final c = AudioCourse.fromMap('id1', {
      'title': 'T',
      'teacher': 'A',
      'category': 'motivacao',
      'coverUrl': '',
      'isPremium': false,
      'order': 0,
    }, const []);
    expect(c.active, isTrue);
  });

  test('AudioCourse.active false when marked draft', () {
    final c = AudioCourse.fromMap('id1', {
      'title': 'TESTE',
      'teacher': 'A',
      'category': 'motivacao',
      'coverUrl': '',
      'active': false,
    }, const []);
    expect(c.active, isFalse);
  });

  test('AudioChapter keeps storagePath for replace/delete', () {
    final ch = AudioChapter.fromMap('ch1', {
      'title': 'Faixa',
      'durationSeconds': 12,
      'order': 2,
      'storagePath': 'audio_courses/c1/ch1.mp3',
    });
    expect(ch.storagePath, 'audio_courses/c1/ch1.mp3');
    expect(ch.order, 2);
    final moved = ch.copyWith(order: 0);
    expect(moved.order, 0);
    expect(moved.storagePath, 'audio_courses/c1/ch1.mp3');
  });
}
