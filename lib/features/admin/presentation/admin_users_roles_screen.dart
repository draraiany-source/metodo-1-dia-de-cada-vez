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
class AdminUsersRolesScreen extends ConsumerWidget {
  const AdminUsersRolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          data: (users) => AppPage(
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
                    'Aluno = sem flags privilegiadas. '
                    'Nunca use e-mail fixo no código.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                        fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                Text('${users.length} usuários',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                for (final u in users)
                  _UserRoleTile(
                    user: u,
                    isSelf: u.id == me.id,
                    onChangeRole: (role) async {
                      try {
                        await ref.read(rolesAdminRepositoryProvider).setUserRole(
                              actorUid: me.id,
                              targetUid: u.id,
                              role: role,
                            );
                        ref.invalidate(adminUsersListProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${u.name}: ${role.labelPt}')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      }
                    },
                  ),
                const SizedBox(height: 28),
              ],
            ),
          ),
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
  });

  final AppUser user;
  final bool isSelf;
  final ValueChanged<UserRole> onChangeRole;

  @override
  Widget build(BuildContext context) {
    final role = resolveUserRole(
      isPersonalTrainer: user.isPersonalTrainer,
      isAdmin: user.isAdmin,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.surface,
      child: ListTile(
        title: Text(
          '${user.name}${isSelf ? ' (você)' : ''}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${user.email}\n${role.labelPt} · ${role.firestoreValue}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
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
                style: const TextStyle(color: Colors.white, fontSize: 11)),
            backgroundColor: AppColors.surface2,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
