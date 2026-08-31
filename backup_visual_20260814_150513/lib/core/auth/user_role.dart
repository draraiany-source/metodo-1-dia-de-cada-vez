/// Papéis do app — fonte única para roteamento e permissões.
///
/// Segurança real deve espelhar estes roles nas regras do Firebase/Firestore.
/// No cliente, o papel só decide a UX inicial; nunca é a única barreira.
enum UserRole {
  aluno,
  personal,
  admin,
}

extension UserRoleX on UserRole {
  String get firestoreValue => switch (this) {
        UserRole.aluno => 'ROLE_ALUNO',
        UserRole.personal => 'ROLE_PERSONAL',
        UserRole.admin => 'ROLE_ADMIN',
      };

  bool get isStaff => this == UserRole.personal || this == UserRole.admin;
}

/// Resolve o papel a partir das flags do perfil (compatível com AppUser atual).
UserRole resolveUserRole({
  required bool isPersonalTrainer,
  required bool isAdmin,
}) {
  if (isAdmin) return UserRole.admin;
  if (isPersonalTrainer) return UserRole.personal;
  return UserRole.aluno;
}
