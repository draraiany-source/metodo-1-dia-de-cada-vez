import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_page.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/roles_admin_repository.dart';

final rolesAdminRepositoryProvider =
    Provider((ref) => RolesAdminRepository());

final adminUsersListProvider = FutureProvider((ref) {
  return ref.read(rolesAdminRepositoryProvider).listUsers();
});

/// Painel Técnico — usuários e papéis (somente Admin Técnico).
class AdminUsersRolesScreen extends ConsumerStatefulWidget {
  const AdminUsersRolesScreen({super.key});

  @override
  ConsumerState<AdminUsersRolesScreen> createState() =>
      _AdminUsersRolesScreenState();
}

class _AdminUsersRolesScreenState extends ConsumerState<AdminUsersRolesScreen> {
  String _query = '';
  String _filter = 'todos';

  UserRole _roleOf(AppUser u) => resolveUserRole(
        isPersonalTrainer: u.isPersonalTrainer,
        isAdmin: u.isAdmin,
      );

  List<AppUser> _apply(List<AppUser> users) {
    final q = _query.trim().toLowerCase();
    return users.where((u) {
      if (q.isNotEmpty &&
          !u.name.toLowerCase().contains(q) &&
          !u.email.toLowerCase().contains(q)) {
        return false;
      }
      final role = _roleOf(u);
      switch (_filter) {
        case 'admin':
          return role == UserRole.admin;
        case 'personal':
          return role == UserRole.personal;
        case 'aluno':
          return role == UserRole.aluno;
        case 'bloqueados':
          return u.disabled;
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _snack(String msg) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _criarUsuario() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    var role = UserRole.aluno;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cadastrar usuário',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Cadastro público do app sempre cria Aluno. '
                  'Personal e Admin só nascem por aqui.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Nome')),
                TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'E-mail')),
                TextField(
                    controller: password,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Senha (mín. 6)')),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: [
                    for (final r in UserRole.values)
                      DropdownMenuItem(value: r, child: Text(r.labelPt)),
                  ],
                  onChanged: (v) => setSheet(() => role = v ?? role),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Criar conta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok != true) return;
    final result = await ref.read(rolesAdminRepositoryProvider).createUser(
          name: name.text,
          email: email.text,
          password: password.text,
          role: role,
        );
    name.dispose();
    email.dispose();
    password.dispose();
    await _snack(result.message);
    if (result.ok) ref.invalidate(adminUsersListProvider);
  }

  Future<void> _vincularPersonal(AppUser student, List<AppUser> all) async {
    final personals = ref
        .read(rolesAdminRepositoryProvider)
        .listPersonals(all)
        .where((p) => p.id != student.id)
        .toList();
    if (personals.isEmpty) {
      await _snack('Cadastre uma Personal antes de vincular.');
      return;
    }
    var selectedId = personals.first.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Vincular à Personal'),
        content: StatefulBuilder(
          builder: (ctx, setDlg) => DropdownButton<String>(
            isExpanded: true,
            value: selectedId,
            dropdownColor: AppColors.surface,
            items: [
              for (final p in personals)
                DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.name} (${p.email})',
                      overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) {
              if (v != null) setDlg(() => selectedId = v);
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Vincular')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final selected = personals.firstWhere((p) => p.id == selectedId);
      await ref.read(rolesAdminRepositoryProvider).assignStudentToPersonal(
            student: student,
            trainerId: selected.id,
          );
      await _snack('${student.name} vinculada a ${selected.name}.');
    } catch (e) {
      await _snack('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserProvider);
    final async = ref.watch(adminUsersListProvider);

    if (me == null || !me.isAdmin) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: PremiumAppBar(title: 'Usuários e papéis'),
        body: Center(
          child: Text('Acesso restrito ao Admin Técnico.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PremiumAppBar(
        title: 'Usuários e papéis',
        actions: [
          IconButton(
            tooltip: 'Cadastrar usuário',
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: _criarUsuario,
          ),
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminUsersListProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não foi possível listar usuários.\n$e\n\n'
                'Confirme que seu UID está em admins/{uid}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (users) {
            final filtered = _apply(users);
            return AppPage(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'Admin Técnico = coleção admins/{uid}. '
                      'Personal = users.isPersonalTrainer. '
                      'Aluno = cadastro público (role student). '
                      'Bloqueio grava users.disabled e, com a function publicada, o Auth.',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar nome ou e-mail',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final f in [
                          ('todos', 'Todos'),
                          ('admin', 'Admin'),
                          ('personal', 'Personal'),
                          ('aluno', 'Aluno'),
                          ('bloqueados', 'Bloqueados'),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f.$2),
                              selected: _filter == f.$1,
                              onSelected: (_) =>
                                  setState(() => _filter = f.$1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('${filtered.length} de ${users.length} usuários',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  for (final u in filtered)
                    _UserRoleTile(
                      user: u,
                      isSelf: u.id == me.id,
                      onChangeRole: (role) async {
                        try {
                          await ref
                              .read(rolesAdminRepositoryProvider)
                              .setUserRole(
                                actorUid: me.id,
                                targetUid: u.id,
                                role: role,
                              );
                          ref.invalidate(adminUsersListProvider);
                          await _snack('${u.name}: ${role.labelPt}');
                        } catch (e) {
                          await _snack('$e');
                        }
                      },
                      onToggleBlock: u.id == me.id
                          ? null
                          : () async {
                              final next = !u.disabled;
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: Text(next
                                      ? 'Bloquear conta?'
                                      : 'Reativar conta?'),
                                  content: Text(
                                    next
                                        ? '${u.name} não conseguirá entrar no app.'
                                        : '${u.name} voltará a acessar o app.',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancelar')),
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: Text(next
                                            ? 'Bloquear'
                                            : 'Reativar')),
                                  ],
                                ),
                              );
                              if (confirm != true) return;
                              final result = await ref
                                  .read(rolesAdminRepositoryProvider)
                                  .setDisabled(
                                    actorUid: me.id,
                                    targetUid: u.id,
                                    disabled: next,
                                  );
                              ref.invalidate(adminUsersListProvider);
                              await _snack(result.message);
                            },
                      onLinkPersonal: _roleOf(u) == UserRole.aluno
                          ? () => _vincularPersonal(u, users)
                          : null,
                    ),
                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserRoleTile extends StatelessWidget {
  const _UserRoleTile({
    required this.user,
    required this.isSelf,
    required this.onChangeRole,
    this.onToggleBlock,
    this.onLinkPersonal,
  });

  final AppUser user;
  final bool isSelf;
  final ValueChanged<UserRole> onChangeRole;
  final VoidCallback? onToggleBlock;
  final VoidCallback? onLinkPersonal;

  @override
  Widget build(BuildContext context) {
    final role = resolveUserRole(
      isPersonalTrainer: user.isPersonalTrainer,
      isAdmin: user.isAdmin,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            ListTile(
              title: Text(
                '${user.name}${isSelf ? ' (você)' : ''}${user.disabled ? ' · bloqueada' : ''}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${user.email}\n${role.labelPt} · ${role.firestoreValue}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5),
              ),
              isThreeLine: true,
              trailing: PopupMenuButton<UserRole>(
                tooltip: 'Alterar papel',
                onSelected: onChangeRole,
                itemBuilder: (_) => [
                  for (final r in UserRole.values)
                    PopupMenuItem(
                      value: r,
                      enabled: !(isSelf && r != UserRole.admin),
                      child: Text(r.labelPt),
                    ),
                ],
                child: Chip(
                  label: Text(role.labelPt,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: AppColors.surface2,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 6,
                  children: [
                    if (onLinkPersonal != null)
                      TextButton.icon(
                        onPressed: onLinkPersonal,
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('Vincular Personal'),
                      ),
                    if (onToggleBlock != null)
                      TextButton.icon(
                        onPressed: onToggleBlock,
                        icon: Icon(
                          user.disabled
                              ? Icons.lock_open_outlined
                              : Icons.block,
                          size: 16,
                        ),
                        label: Text(user.disabled ? 'Reativar' : 'Bloquear'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
