import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/mascot/mascot_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_providers.dart';
import '../../nutrition/presentation/food_database_screen.dart';
import 'admin_treinos_catalog_tab.dart';

/// Painel Administrativo.
///
/// Estrutura base com dashboard + abas de CRUD. As operações de escrita
/// exigem que o UID esteja na coleção `admins` (ver firestore.rules).
/// Treinos: catálogo oficial local (117) com alertas de revisão.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null || !user.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Painel Admin')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Acesso restrito',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel Admin ⚙️'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Treinos'),
              Tab(text: 'Receitas'),
              Tab(text: 'Desafios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _dashboard(context),
            const AdminTreinosCatalogTab(),
            _crudList(context,
                const ['Salada mediterrânea', 'Smoothie verde', 'Frango grelhado'],
                'receita'),
            _crudList(
                context,
                const ['Desafio 7 dias', 'Hidratação total', '10k passos'],
                'desafio'),
          ],
        ),
      ),
    );
  }

  Widget _dashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Diagnóstico de configuração externa (chaves injetadas em build).
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Configuração de produção',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...AppConfig.status.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(e.value ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: e.value
                                ? AppColors.success
                                : AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Text(e.key,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const Spacer(),
                        Text(e.value ? 'OK' : 'pendente',
                            style: TextStyle(
                                fontSize: 12,
                                color: e.value
                                    ? AppColors.success
                                    : AppColors.textTertiary)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: const [
            _MetricCard('1.284', 'Usuárias', Icons.people, AppColors.primary),
            _MetricCard('342', 'Premium', Icons.workspace_premium,
                AppColors.warning),
            _MetricCard('8.920', 'Treinos feitos', Icons.fitness_center,
                AppColors.success),
            _MetricCard('4.7k', 'Check-ins', Icons.check_circle,
                AppColors.info),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Ações rápidas',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _actionTile(context, Icons.add, 'Novo treino'),
        _actionTile(context, Icons.restaurant, 'Nova receita'),
        _actionTile(context, Icons.emoji_events, 'Novo desafio'),
        _actionTile(context, Icons.campaign, 'Enviar notificação push'),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.face_retouching_natural,
                color: AppColors.secondary),
            title: Text('Assets da ${MascotConfig.shortName} (mascote)',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Poses, expressões e animações dinâmicas',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.liliAssetsAdmin),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.person_outline,
                color: AppColors.secondary),
            title: const Text('Editar perfil Quem Sou Eu',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Textos, especialidades, formação, redes e contato',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.amandaProfileEdit),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.photo_camera_outlined,
                color: AppColors.secondary),
            title: const Text('Fotos da Amanda (personal)',
                style: TextStyle(color: Colors.white)),
            subtitle: Text('Capa, perfil, galeria — independentes da ${MascotConfig.shortName}',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.amandaAssetsAdmin),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.menu_book_outlined,
                color: AppColors.secondary),
            title: const Text('E-books',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cadastro real, já conectado ao Firestore',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.ebooksAdmin),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.headphones,
                color: AppColors.secondary),
            title: const Text('Cursos em áudio / Meditações / Lili Fit',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cadastro real, já conectado ao Firestore',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.audioCoursesAdmin),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.self_improvement,
                color: AppColors.primary),
            title: const Text('Programa 7 Dias (áudio)',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Abre o programa; seed via tools/audio_seed (ver docs/AUDIO_PROGRAMS.md)',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(
                '/audio-programs/programa_7_dias_um_dia_de_cada_vez'),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.restaurant_menu,
                color: AppColors.secondary),
            title: const Text('Banco de alimentos',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cadastro real, já conectado ao Firestore',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const FoodDatabaseScreen(isAdmin: true))),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.video_library_outlined,
                color: AppColors.secondary),
            title: const Text('Vídeos (streaming)',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cadastro real, já conectado ao Firestore',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.videosAdmin),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.confirmation_number_outlined,
                color: AppColors.secondary),
            title: const Text('Cupons e promoções',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cadastro real, já conectado ao Firestore',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.couponsAdmin),
          ),
        ),
      ],
    );
  }

  Widget _crudList(BuildContext context, List<String> items, String tipo) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _notImplemented(context, 'Criar $tipo'),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        itemBuilder: (_, i) => Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(items[i],
                style: const TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit,
                        size: 18, color: AppColors.secondary),
                    onPressed: () => _notImplemented(context, 'Editar')),
                IconButton(
                    icon: const Icon(Icons.delete,
                        size: 18, color: AppColors.danger),
                    onPressed: () => _notImplemented(context, 'Excluir')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String label) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: () => _notImplemented(context, label),
      ),
    );
  }

  void _notImplemented(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action — conecte ao Firestore para ativar.')),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
