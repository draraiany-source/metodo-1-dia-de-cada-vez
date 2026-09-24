import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/router/app_navigation.dart';
import 'package:metodo_1_dia/core/router/app_router.dart';

void main() {
  group('AppNavigation hubs / roots', () {
    test('hubForPath — admin técnico', () {
      expect(AppNavigation.hubForPath(Routes.admin), Routes.admin);
      expect(AppNavigation.hubForPath(Routes.adminUsers), Routes.admin);
      expect(AppNavigation.hubForPath(Routes.adminSubscriptions), Routes.admin);
      expect(AppNavigation.hubForPath('/admin/videos'), Routes.personalTrainer);
    });

    test('hubForPath — personal', () {
      expect(
        AppNavigation.hubForPath(Routes.personalTrainer),
        Routes.personalTrainer,
      );
      expect(
        AppNavigation.hubForPath('${Routes.personalTrainer}/agenda'),
        Routes.personalTrainer,
      );
      expect(
        AppNavigation.hubForPath(Routes.painelPersonal),
        Routes.personalTrainer,
      );
      expect(
        AppNavigation.hubForPath('/admin/ebooks'),
        Routes.personalTrainer,
      );
    });

    test('hubForPath — aluna', () {
      expect(AppNavigation.hubForPath(Routes.home), Routes.home);
      expect(AppNavigation.hubForPath(Routes.workouts), Routes.home);
    });

    test('isRoleRootPath', () {
      expect(AppNavigation.isRoleRootPath(Routes.admin), isTrue);
      expect(AppNavigation.isRoleRootPath(Routes.personalTrainer), isTrue);
      expect(AppNavigation.isRoleRootPath(Routes.home), isTrue);
      expect(AppNavigation.isRoleRootPath(Routes.adminUsers), isFalse);
      expect(
        AppNavigation.isRoleRootPath('${Routes.personalTrainer}/agenda'),
        isFalse,
      );
    });
  });
}
