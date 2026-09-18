import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/lili_animated.dart';
import '../../../core/widgets/lili_widgets.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../../personal_amanda/domain/amanda_asset_models.dart';
import '../../personal_amanda/presentation/amanda_image.dart';
import '../../personal_trainer/providers/pt_providers.dart';
import '../providers/accompaniment_providers.dart';

class FaleComAmandaScreen extends ConsumerWidget {
  const FaleComAmandaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final studentAsync = ref.watch(
      ptMyStudentProfileProvider((userId: user.id, email: user.email)),
    );

    return Scaffold(
      appBar: const PremiumAppBar(title: 'Fale com a Amanda'),
      body: AppPage(
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Não foi possível abrir o chat.'),
          data: (student) {
            if (student == null) {
              return const Text(
                'Você ainda não está vinculada à Personal. '
                'Peça para a Amanda cadastrar o mesmo e-mail da sua conta.',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }
            final convAsync = ref.watch(conversationForStudentProvider(student));
            return convAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Não foi possível abrir a conversa.'),
              data: (conv) {
                final status = conv.trainerOnline
                    ? 'Online'
                    : (conv.trainerLastSeen == null
                        ? 'Offline'
                        : 'Visto recentemente');
                return Column(
                  children: [
                    AppCard(
                      glow: true,
                      child: Row(
                        children: [
                          const AmandaImage(
                            category: AmandaAssetCategory.principal,
                            height: 72,
                            width: 72,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Amanda Lopes',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18)),
                                const Text('Personal Trainer',
                                    style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(status,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          AppIconImage(
                            PersonalAiIcons.chatAmanda,
                            size: 48,
                            fallbackIcon: Icons.chat_bubble_outline,
                            semanticLabel: 'Fale com Amanda',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Este é o seu espaço para tirar dúvidas, falar sobre seus treinos e acompanhar sua evolução junto com a Amanda.',
                      style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Iniciar conversa',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => context.push(
                        '${Routes.faleComAmanda}/chat/${conv.id}',
                        extra: conv,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AnimatedLiliMascot(
                      pose: MascotePose.checklist,
                      mood: LiliMood.viva,
                      height: 90,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
