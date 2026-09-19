import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/lili_guide.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../personal_amanda/domain/amanda_asset_models.dart';
import '../../personal_amanda/presentation/amanda_image.dart';
import '../providers/ai_trainer_providers.dart';

class AiTrainerScreen extends ConsumerStatefulWidget {
  const AiTrainerScreen({super.key});

  @override
  ConsumerState<AiTrainerScreen> createState() => _AiTrainerScreenState();
}

class _AiTrainerScreenState extends ConsumerState<AiTrainerScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  static const _quickActions = [
    ('💪', 'Monta um treino pra mim'),
    ('💧', 'Quanto de água devo beber?'),
    ('🥗', 'Sugestões de alimentação'),
    ('📉', 'Estou num platô'),
    ('😴', 'Preciso de descanso?'),
    ('🎯', 'Quais minhas metas da semana?'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    FeedbackService.play(FeedbackEvent.toqueLeve);
    await ref.read(trainerChatProvider.notifier).send(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(trainerChatProvider);
    final remote = ref.watch(aiTrainerRepositoryProvider).isRemoteAvailable;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(Routes.home),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: GestureDetector(
          onTap: () => context.push(Routes.amandaProfile),
          child: Row(
            children: [
              const ClipOval(
                child: AmandaImage(size: 36),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Amanda IA', style: TextStyle(fontSize: 16)),
                  Text(remote ? 'IA online' : 'Modo inteligente local',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Meu perfil físico',
            onPressed: () => context.push(Routes.aiProfile),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpar conversa',
            onPressed: () => ref.read(trainerChatProvider.notifier).clear(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (chat.lastReplyOffline)
              Material(
                color: AppColors.warning.withValues(alpha: 0.16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'A IA na nuvem não respondeu. Esta mensagem veio do modo local — não é uma resposta da Amanda IA online.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: chat.loading
                  ? const Center(child: CircularProgressIndicator())
                  : chat.messages.isEmpty
                      ? _EmptyState(onTap: _send)
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              chat.messages.length + (chat.thinking ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i >= chat.messages.length) {
                              return const _TypingIndicator();
                            }
                            final m = chat.messages[i];
                            return _Bubble(
                                text: m.text, fromUser: m.fromUser);
                          },
                        ),
            ),

            // Ações rápidas
            if (chat.messages.isNotEmpty)
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final (emoji, label) in _quickActions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.surface2),
                          label: Text('$emoji ${label.split(' ').take(2).join(' ')}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          onPressed: () => _send(label),
                        ),
                      ),
                  ],
                ),
              ),

            // Campo de entrada
            Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: const InputDecoration(
                        hintText: 'Pergunte à Amanda...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.vibeGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed:
                          chat.thinking ? null : () => _send(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final Future<void> Function(String) onTap;

  static const _suggestions = [
    'Monta um treino pra mim',
    'Quanto de água devo beber?',
    'Sugestões de alimentação',
    'Estou num platô',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
            child: AmandaImage(
                category: AmandaAssetCategory.principal, size: 160)),
        const SizedBox(height: 12),
        // A Lili já chega falando do contexto atual da usuária.
        const LiliGuide(mascotHeight: 70, showCta: false),
        const SizedBox(height: 16),
        Text('Sou a Amanda, sua personal 💜',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'Monto seu treino, ajusto sua alimentação, acompanho sua evolução '
          'e te lembro que você não precisa ser perfeita — só continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        for (final s in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: () => onTap(s),
              child: Text(s),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      decoration: BoxDecoration(
        gradient: fromUser ? AppColors.vibeGradient : null,
        color: fromUser ? null : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(fromUser ? 16 : 4),
          bottomRight: Radius.circular(fromUser ? 4 : 16),
        ),
      ),
      child: Text(text,
          style: const TextStyle(color: Colors.white, height: 1.45)),
    );

    if (fromUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const ClipOval(
            child: AmandaImage(size: 32),
          ),
          const SizedBox(width: 8),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
            SizedBox(width: 10),
            Text('Preparando resposta...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
