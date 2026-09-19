import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/constants/app_constants.dart';
import 'package:metodo_1_dia/core/config/app_config.dart';
import 'package:metodo_1_dia/core/auth/user_role.dart';

void main() {
  test('produção não libera visitante nem premium de debug', () {
    expect(AppConstants.enableGuestMode, isFalse);
    expect(AppConstants.debugUnlockAllPremiumContent, isFalse);
    expect(AppConfig.paymentsEnabled, isFalse);
  });

  test('RBAC: aluno não é staff; admin exige flag admin', () {
    expect(
      resolveUserRole(isPersonalTrainer: false, isAdmin: false),
      UserRole.aluno,
    );
    expect(
      resolveUserRole(isPersonalTrainer: true, isAdmin: false),
      UserRole.personal,
    );
    expect(
      resolveUserRole(isPersonalTrainer: true, isAdmin: true),
      UserRole.admin,
    );
    expect(RolePermissions.of(UserRole.aluno).canOpenTechnicalPanel, isFalse);
    expect(RolePermissions.of(UserRole.personal).canManageUserRoles, isFalse);
    expect(RolePermissions.of(UserRole.admin).canOpenTechnicalPanel, isTrue);
    expect(isPersonalAllowedAdminPath('/admin'), isFalse);
    expect(isPersonalAllowedAdminPath('/admin/videos'), isTrue);
  });

  test('Firestore rules: catch-all deny e sem allow-true', () {
    final rules = File('firebase/firestore.rules').readAsStringSync();
    expect(rules.contains('allow read, write: if false;'), isTrue);
    expect(rules.contains('allow read, write: if true;'), isFalse);
    expect(rules.contains('noPrivilegedFields'), isTrue);
    expect(rules.contains('admins/{uid}'), isTrue);
  });

  test('Storage rules: catch-all deny; público só em /public', () {
    final rules = File('firebase/storage.rules').readAsStringSync();
    expect(rules.contains('allow read, write: if false;'), isTrue);
    expect(rules.contains('underSize'), isTrue);
    expect(rules.contains('isImage()'), isTrue);
  });
}
