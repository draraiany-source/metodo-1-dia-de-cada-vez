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
    expect(
      YoutubeLaunch.extractVideoId('https://www.youtube.com/live/abc123XYZ01'),
      'abc123XYZ01',
    );
    expect(
      YoutubeLaunch.extractVideoId('https://m.youtube.com/watch?v=abc123XYZ01&t=10'),
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

  test('extractVideoId works for the 3 Método 1 Dia Shorts', () {
    const samples = [
      'https://youtube.com/shorts/34PHGKECMTY?si=Hh9Z_l00kVvDS16n',
      'https://youtube.com/shorts/3T0HDPX4jkk?si=TWZdqXR6V7c9q1xL',
      'https://youtube.com/shorts/zRSTnW3EMF8?si=mf5LY0hnhld4M0rW',
    ];
    expect(YoutubeLaunch.extractVideoId(samples[0]), '34PHGKECMTY');
    expect(YoutubeLaunch.extractVideoId(samples[1]), '3T0HDPX4jkk');
    expect(YoutubeLaunch.extractVideoId(samples[2]), 'zRSTnW3EMF8');
    expect(
      YoutubeLaunch.normalize(samples[0])?.queryParameters['v'],
      '34PHGKECMTY',
    );
  });
}
