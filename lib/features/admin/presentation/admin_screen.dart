import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/staff_sign_out_button.dart';
import '../../../core/config/app_config.dart';
import '../../../core/mascot/mascot_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
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
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: PremiumAppBar(
            title: 'Painel Técnico',
            isRoleRoot: true,
            showBack: false,
            actions: [
              StaffSignOutButton(),
            ],
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Acesso restrito ao Admin Técnico.\n'
                'Personal e alunos não acessam esta área.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      // Raiz do Admin: gesto Voltar do Android NÃO abre Aluna/Personal.
      canPop: false,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
            title: const Text('Painel Técnico'),
            actions: [
              IconButton(
                tooltip: 'Configurações',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(Routes.settings),
              ),
              const StaffSignOutButton(),
            ],
            bottom: const TabBar(
              isScrollable: true,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Dashboard'),
                Tab(text: 'Treinos'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _dashboard(context),
              const AdminTreinosCatalogTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.workspace_premium_outlined,
                color: AppColors.secondary),
            title: const Text('Assinaturas',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Testes, planos e status — sem editar cobrança paga',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.adminSubscriptions),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.manage_accounts_outlined,
                color: AppColors.secondary),
            title: const Text('Usuários e papéis',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Admin Técnico · Personal · Aluno — via admins/{uid}',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.adminUsers),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.fitness_center_outlined,
                color: AppColors.secondary),
            title: const Text('Central da Personal',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Alunos, treinos e evolução',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.personalTrainer),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.dashboard_customize_outlined,
                color: AppColors.primary),
            title: const Text('Painel da Personal (conteúdos)',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Treinos, vídeos, receitas, áudios, meditações e Lily',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textTertiary),
            onTap: () => context.push(Routes.painelPersonal),
          ),
        ),
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
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Métricas agregadas reais ainda não estão ligadas a este painel. '
            'Use Assinaturas e Usuários para dados ao vivo. '
            'Receitas e desafios: edite no Painel da Personal (conteúdos).',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.35),
          ),
        ),
        const Text('Conteúdos (rotas reais)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.restaurant_menu, color: AppColors.secondary),
            title: const Text('Receitas (CMS)', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cadastro real no Painel da Personal',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => context.push(Routes.personalCmsRecipes),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.emoji_events_outlined, color: AppColors.secondary),
            title: const Text('Desafios (CMS)', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cadastro real no Painel da Personal',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            onTap: () => context.push(Routes.personalCmsChallenges),
          ),
        ),
        const SizedBox(height: 8),
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
                'Conheça a Amanda: textos, CTAs, formação, redes e contato',
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
}
