/// Papéis do app — fonte única para roteamento e permissões de UX.
///
/// Mapeamento canônico (produto ↔ código):
/// - [UserRole.admin]     ≈ `technical_admin` — Admin Técnico
/// - [UserRole.personal]  ≈ `trainer` — Personal / Admin profissional
/// - [UserRole.aluno]     ≈ `student` — Aluno
///
/// Segurança real: coleção Firestore `admins/{uid}` (Admin Técnico) +
/// `users.isPersonalTrainer` (Personal). Flags em `users` NÃO são a única
/// barreira — as regras do Firebase validam no servidor.
library;

enum UserRole {
  /// Aluno — `student`
  aluno,

  /// Personal / Admin profissional — `trainer`
  personal,

  /// Admin Técnico — `technical_admin`
  admin,
}

extension UserRoleX on UserRole {
  /// Valor persistido opcional em `users.role` (além das flags).
  String get firestoreValue => switch (this) {
        UserRole.aluno => 'student',
        UserRole.personal => 'trainer',
        UserRole.admin => 'technical_admin',
      };

  String get labelPt => switch (this) {
        UserRole.aluno => 'Aluno',
        UserRole.personal => 'Personal',
        UserRole.admin => 'Admin Técnico',
      };

  String get descriptionPt => switch (this) {
        UserRole.aluno =>
          'Acessa só os próprios dados, treinos e conteúdos liberados.',
        UserRole.personal =>
          'Gerencia alunos, treinos, exercícios, Quem Sou Eu e conteúdos.',
        UserRole.admin =>
          'Acesso técnico total: usuários, papéis, Firebase e manutenção.',
      };

  bool get isStaff => this == UserRole.personal || this == UserRole.admin;

  bool get isTechnicalAdmin => this == UserRole.admin;
}

/// Resolve o papel a partir das flags do perfil (compatível com AppUser).
UserRole resolveUserRole({
  required bool isPersonalTrainer,
  required bool isAdmin,
}) {
  if (isAdmin) return UserRole.admin;
  if (isPersonalTrainer) return UserRole.personal;
  return UserRole.aluno;
}

UserRole? roleFromFirestoreValue(String? raw) {
  final v = (raw ?? '').trim().toLowerCase();
  return switch (v) {
    'technical_admin' || 'role_admin' || 'admin' => UserRole.admin,
    'trainer' || 'role_personal' || 'personal' => UserRole.personal,
    'student' || 'role_aluno' || 'aluno' => UserRole.aluno,
    _ => null,
  };
}

/// Permissões de produto (UX). Sempre espelhar nas rules do Firebase.
class RolePermissions {
  const RolePermissions._(this.role);
  final UserRole role;

  factory RolePermissions.of(UserRole role) => RolePermissions._(role);

  bool get canOpenTechnicalPanel => role == UserRole.admin;
  bool get canManageUserRoles => role == UserRole.admin;
  bool get canAccessCriticalConfig => role == UserRole.admin;
  bool get canManageCoupons => role == UserRole.admin;

  bool get canOpenPersonalCentral =>
      role == UserRole.personal || role == UserRole.admin;
  bool get canManageStudents => canOpenPersonalCentral;
  bool get canManageWorkouts => canOpenPersonalCentral;
  bool get canManageExercises => canOpenPersonalCentral;
  bool get canEditAmandaProfile => canOpenPersonalCentral;
  bool get canManageContent => canOpenPersonalCentral;
  bool get canSendStudentNotifications => canOpenPersonalCentral;

  bool get canUseStudentApp => true; // todos autenticados
  bool get canEditOthersStudents => false; // só via vínculo trainer/aluno nas rules
}

/// Rotas `/admin/*` liberadas também para Personal (ferramentas profissionais).
/// O painel técnico raiz `/admin` continua exclusivo do Admin Técnico.
const kPersonalAllowedAdminPaths = <String>{
  '/admin/amanda-assets',
  '/admin/amanda-profile',
  '/admin/ebooks',
  '/admin/audio-courses',
  '/admin/videos',
  '/admin/lili-assets',
};

bool isPersonalAllowedAdminPath(String path) {
  if (kPersonalAllowedAdminPaths.contains(path)) return true;
  // Sub-rotas futuras sob esses prefixos.
  for (final p in kPersonalAllowedAdminPaths) {
    if (path.startsWith('$p/')) return true;
  }
  return false;
}
