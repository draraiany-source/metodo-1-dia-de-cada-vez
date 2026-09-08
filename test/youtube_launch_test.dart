import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/utils/youtube_launch.dart';

void main() {
  test('extractVideoId handles watch, short and embed URLs', () {
    expect(
      YoutubeLaunch.extractVideoId('https://www.youtube.com/watch?v=abc123XYZ01'),
      'abc123XYZ01',
    );
    expect(
      YoutubeLaunch.extractVideoId('https://youtu.be/abc123XYZ01'),
      'abc123XYZ01',
    );
    expect(
      YoutubeLaunch.extractVideoId('https://www.youtube.com/shorts/abc123XYZ01'),
      'abc123XYZ01',
    );
    expect(
      YoutubeLaunch.extractVideoId('https://www.youtube.com/embed/abc123XYZ01'),
      'abc123XYZ01',
    );
  });

  test('extractVideoId works for 3 catalog sample videos', () {
    const samples = [
      'https://youtube.com/shorts/yirpahOImBs?si=8YufptI_E0HdBvrs',
      'https://youtube.com/shorts/4mBJliQoI8g?si=ZssJk_664_6-hg9X',
      'https://youtube.com/shorts/leJO-flyPDY?si=_pggWV5Q4FjovTpN',
    ];
    expect(YoutubeLaunch.extractVideoId(samples[0]), 'yirpahOImBs');
    expect(YoutubeLaunch.extractVideoId(samples[1]), '4mBJliQoI8g');
    expect(YoutubeLaunch.extractVideoId(samples[2]), 'leJO-flyPDY');
  });
}
