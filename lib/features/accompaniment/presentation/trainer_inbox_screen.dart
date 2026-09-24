import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../personal_trainer/domain/pt_models.dart';
import '../../personal_trainer/presentation/student_detail_screen.dart';
import '../../personal_trainer/providers/pt_providers.dart';
import '../providers/accompaniment_providers.dart';
import 'chat_thread_screen.dart';

class TrainerInboxScreen extends ConsumerStatefulWidget {
  const TrainerInboxScreen({super.key});

  @override
  ConsumerState<TrainerInboxScreen> createState() => _TrainerInboxScreenState();
}

class _TrainerInboxScreenState extends ConsumerState<TrainerInboxScreen> {
  String _query = '';
  String _filter = 'todas';

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final inbox = ref.watch(trainerInboxProvider(trainer.id));
    final students = ref.watch(ptStudentsProvider(trainer.id)).valueOrNull ?? [];

    return Scaffold(
      appBar: const PremiumAppBar(
        title: 'Mensagens',
        showStaffSignOut: true,
      ),
      body: inbox.when(
        loading: () => const AppLoading(message: 'Carregando mensagens…'),
        error: (_, __) => AppErrorState(
          title: 'Mensagens indisponíveis',
          message: 'Não foi possível carregar as conversas agora.',
          onRetry: () => ref.invalidate(trainerInboxProvider(trainer.id)),
        ),
        data: (convs) {
          var list = convs.where((c) {
            if (_query.isNotEmpty &&
                !c.studentName.toLowerCase().contains(_query.toLowerCase())) {
              return false;
            }
            switch (_filter) {
              case 'nao_lidas':
                return c.unreadForTrainer > 0;
              case 'respondidas':
                return c.unreadForTrainer == 0 && c.lastMessage.isNotEmpty;
              case 'acompanhamento':
                return true;
              default:
                return true;
            }
          }).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    AppIconImage(
                      PersonalAiIcons.chatAmanda,
                      size: 40,
                      fallbackIcon: Icons.chat_bubble_outline,
                      semanticLabel: 'Mensagens',
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Conversas com as alunas',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nome',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    for (final f in [
                      ('todas', 'Todas'),
                      ('nao_lidas', 'Não lidas'),
                      ('respondidas', 'Respondidas'),
                      ('acompanhamento', 'Acompanhamento'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f.$2),
                          selected: _filter == f.$1,
                          onSelected: (_) => setState(() => _filter = f.$1),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? const AppEmptyState(
                        title: 'Nenhuma conversa ainda',
                        message:
                            'Quando uma aluna escrever, a conversa aparece aqui.',
                        mascotHeight: 120,
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final c = list[i];
                          Student? student;
                          for (final s in students) {
                            if (s.id == c.studentId) student = s;
                          }
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: c.studentPhoto.isNotEmpty
                                  ? NetworkImage(c.studentPhoto)
                                  : null,
                              child: c.studentPhoto.isEmpty
                                  ? Text(c.studentName.isEmpty
                                      ? '?'
                                      : c.studentName[0])
                                  : null,
                            ),
                            title: Text(c.studentName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              c.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  c.lastAt == null
                                      ? ''
                                      : DateFormat('HH:mm').format(c.lastAt!.toLocal()),
                                  style: const TextStyle(
                                      color: AppColors.textTertiary, fontSize: 11),
                                ),
                                if (c.unreadForTrainer > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('${c.unreadForTrainer}',
                                        style: const TextStyle(fontSize: 11)),
                                  ),
                              ],
                            ),
                            onTap: () => context.push(
                              '${Routes.trainerInbox}/chat/${c.id}',
                              extra: ChatThreadRouteArgs(
                                conversation: c,
                                isTrainer: true,
                              ),
                            ),
                            onLongPress: student == null
                                ? null
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => StudentDetailScreen(
                                            student: student!),
                                      ),
                                    ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
