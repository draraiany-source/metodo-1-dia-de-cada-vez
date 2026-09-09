import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:metodo_1_dia/core/assets/app_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pacote Cursor: principais assets existem no bundle', () async {
    final sample = [
      AppIcons.home,
      AppIcons.workout,
      AppIcons.recipes,
      AppIcons.evolution,
      AppIcons.profile,
      AppIcons.checkin,
      AppIcons.water,
      AppIcons.calories,
      AppIcons.moodHappy,
      AppIcons.trophy,
      AppIcons.premium,
      AppIcons.edit,
      AppIcons.play,
      AppIcons.achStreak7,
    ];

    for (final path in sample) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(100), reason: path);
    }
  });

  test('moodCheckin tem 5 estados', () {
    expect(AppIcons.moodCheckin.length, 5);
  });
}
