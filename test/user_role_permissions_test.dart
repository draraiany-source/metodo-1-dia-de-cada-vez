import 'package:flutter_test/flutter_test.dart';

import 'package:metodo_1_dia/core/auth/user_role.dart';

void main() {
  group('resolveUserRole', () {
    test('admin técnico tem prioridade sobre personal', () {
      expect(
        resolveUserRole(isPersonalTrainer: true, isAdmin: true),
        UserRole.admin,
      );
    });

    test('personal sem admin', () {
      expect(
        resolveUserRole(isPersonalTrainer: true, isAdmin: false),
        UserRole.personal,
      );
    });

    test('aluno padrão', () {
      expect(
        resolveUserRole(isPersonalTrainer: false, isAdmin: false),
        UserRole.aluno,
      );
    });
  });

  group('firestoreValue', () {
    test('mapeia para technical_admin / trainer / student', () {
      expect(UserRole.admin.firestoreValue, 'technical_admin');
      expect(UserRole.personal.firestoreValue, 'trainer');
      expect(UserRole.aluno.firestoreValue, 'student');
    });
  });

  group('RolePermissions', () {
    test('somente admin técnico abre painel técnico', () {
      expect(RolePermissions.of(UserRole.admin).canOpenTechnicalPanel, isTrue);
      expect(
          RolePermissions.of(UserRole.personal).canOpenTechnicalPanel, isFalse);
      expect(RolePermissions.of(UserRole.aluno).canOpenTechnicalPanel, isFalse);
    });

    test('personal e admin abrem central', () {
      expect(RolePermissions.of(UserRole.admin).canOpenPersonalCentral, isTrue);
      expect(
          RolePermissions.of(UserRole.personal).canOpenPersonalCentral, isTrue);
      expect(
          RolePermissions.of(UserRole.aluno).canOpenPersonalCentral, isFalse);
    });
  });

  group('isPersonalAllowedAdminPath', () {
    test('whitelist profissional liberada', () {
      expect(isPersonalAllowedAdminPath('/admin/amanda-profile'), isTrue);
      expect(isPersonalAllowedAdminPath('/admin/amanda-assets'), isTrue);
      expect(isPersonalAllowedAdminPath('/admin/videos'), isTrue);
    });

    test('painel técnico raiz bloqueado para personal', () {
      expect(isPersonalAllowedAdminPath('/admin'), isFalse);
      expect(isPersonalAllowedAdminPath('/admin/users'), isFalse);
      expect(isPersonalAllowedAdminPath('/admin/coupons'), isFalse);
    });
  });

  group('homePathForRole', () {
    test('aluno vai para /home', () {
      expect(homePathForRole(UserRole.aluno), '/home');
      expect(
        homePathForUser(isPersonalTrainer: false, isAdmin: false),
        '/home',
      );
    });

    test('personal vai para Central da Personal', () {
      expect(homePathForRole(UserRole.personal), '/personal-trainer');
      expect(
        homePathForUser(isPersonalTrainer: true, isAdmin: false),
        '/personal-trainer',
      );
    });

    test('admin técnico vai para /admin e prevalece sobre personal', () {
      expect(homePathForRole(UserRole.admin), '/admin');
      expect(
        homePathForUser(isPersonalTrainer: true, isAdmin: true),
        '/admin',
      );
    });
  });
}
