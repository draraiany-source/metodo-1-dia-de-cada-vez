import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/assets/personal_ai_icons.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/premium_ui.dart';
import '../../../models/app_user.dart';
import '../../auth/providers/auth_providers.dart';
import '../domain/accompaniment_models.dart';
import '../providers/accompaniment_providers.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.conversation,
    this.isTrainer = false,
  });

  final AccompanimentConversation conversation;
  final bool isTrainer;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _text = TextEditingController();
  ChatMessage? _replyTo;
  String? _aiDraft;
  bool _sending = false;

  AccompanimentConversation get conv => widget.conversation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accompanimentRepositoryProvider).markRead(
            conversationId: conv.id,
            asTrainer: widget.isTrainer,
          );
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send({
    String? text,
    MessageKind kind = MessageKind.text,
    String mediaUrl = '',
    String mediaName = '',
  }) async {
    final user = ref.read(currentUserProvider) ?? AppUser.uiFallback();
    final body = text ?? _text.text.trim();
    if (body.isEmpty && mediaUrl.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(accompanimentRepositoryProvider).sendMessage(
            conv: conv,
            senderId: user.id,
            senderRole: widget.isTrainer ? 'trainer' : 'student',
            text: body,
            kind: kind,
            mediaUrl: mediaUrl,
            mediaName: mediaName,
            replyToId: _replyTo?.id ?? '',
          );
      _text.clear();
      _replyTo = null;
      _aiDraft = null;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;
    final url = await ref.read(accompanimentRepositoryProvider).uploadChatFile(
          conversationId: conv.id,
          studentId: conv.studentId,
          file: file,
          folder: 'images',
        );
    await _send(
      text: 'Foto',
      kind: MessageKind.image,
      mediaUrl: url,
      mediaName: file.name,
    );
  }

  Future<void> _suggest() async {
    final suggestion = await ref.read(accompanimentAiProvider).run(
      action: 'reply_suggestion',
      payload: {'lastMessage': conv.lastMessage},
    );
    if (!mounted) return;
    setState(() {
      _aiDraft = suggestion;
      _text.text = suggestion;
    });
  }

  Future<void> _summarize() async {
    final summary = await ref.read(accompanimentAiProvider).run(
      action: 'summarize_chat',
      payload: {'conversationId': conv.id, 'studentName': conv.studentName},
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Resumo da conversa'),
        content: SingleChildScrollView(child: Text(summary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider) ?? AppUser.uiFallback();
    final msgs = ref.watch(conversationMessagesProvider(conv.id));
    final fmt = DateFormat('HH:mm');

    return Scaffold(
      appBar: PremiumAppBar(
        title: widget.isTrainer ? conv.studentName : 'Amanda Lopes',
        actions: [
          if (widget.isTrainer)
            IconButton(
              tooltip: 'Resumir conversa',
              onPressed: _summarize,
              icon: AppIconImage(
                PersonalAiIcons.resumoConversa,
                size: 28,
                fallbackIcon: Icons.summarize_outlined,
                semanticLabel: 'Resumir conversa',
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                AppIconImage(
                  PersonalAiIcons.chatAmanda,
                  size: 40,
                  fallbackIcon: Icons.chat_bubble_outline,
                  semanticLabel: 'Chat com Amanda',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.isTrainer
                        ? 'Mensagens com ${conv.studentName}'
                        : 'Fale com Amanda',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: msgs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Chat indisponível')),
              data: (list) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final m = list[i];
                  final mine = m.senderId == user.id;
                  if (m.deleted) {
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Mensagem excluída',
                            style: TextStyle(
                                color: AppColors.textTertiary, fontSize: 12)),
                      ),
                    );
                  }
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                      ),
                      child: GestureDetector(
                        onLongPress: () async {
                          final repo = ref.read(accompanimentRepositoryProvider);
                          await showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: AppColors.surface,
                            builder: (sheet) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: const Text('Responder'),
                                    onTap: () {
                                      Navigator.pop(sheet);
                                      setState(() => _replyTo = m);
                                    },
                                  ),
                                  ListTile(
                                    title: Text(m.starred
                                        ? 'Desmarcar importante'
                                        : 'Marcar importante'),
                                    onTap: () {
                                      Navigator.pop(sheet);
                                      repo.toggleStar(m.id, !m.starred);
                                    },
                                  ),
                                  if (mine)
                                    ListTile(
                                      title: const Text('Excluir'),
                                      onTap: () {
                                        Navigator.pop(sheet);
                                        repo.deleteOwnMessage(
                                          messageId: m.id,
                                          senderId: user.id,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          decoration: BoxDecoration(
                            color: mine
                                ? AppColors.primary.withOpacity(0.28)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: m.starred
                                  ? AppColors.warning
                                  : (mine
                                      ? AppColors.secondary.withOpacity(0.35)
                                      : AppColors.border),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mine
                                    ? (widget.isTrainer ? 'Amanda' : 'Você')
                                    : (widget.isTrainer
                                        ? conv.studentName
                                        : 'Amanda'),
                                style: TextStyle(
                                  color: mine
                                      ? AppColors.secondary
                                      : AppColors.hotPink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (m.replyToId.isNotEmpty)
                                const Text('↳ resposta',
                                    style: TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 11)),
                              if (m.kind == MessageKind.image &&
                                  m.mediaUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(m.mediaUrl, height: 160),
                                  ),
                                ),
                              if (m.text.isNotEmpty)
                                Text(m.text,
                                    style: const TextStyle(
                                        color: Colors.white, height: 1.35)),
                              const SizedBox(height: 4),
                              Text(
                                '${fmt.format(m.createdAt.toLocal())} · ${m.status.name}',
                                style: const TextStyle(
                                    color: AppColors.textTertiary, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_replyTo != null)
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Respondendo: ${_replyTo!.text}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _replyTo = null),
                  ),
                ],
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: [
                  if (widget.isTrainer)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 4,
                        children: [
                          TextButton.icon(
                            onPressed: _suggest,
                            icon: AppIconImage(
                              PersonalAiIcons.sugestaoResposta,
                              size: 28,
                              fallbackIcon: Icons.auto_awesome,
                              semanticLabel: 'Sugestão de resposta com IA',
                            ),
                            label: const Text('Sugestão de resposta com IA'),
                          ),
                          TextButton.icon(
                            onPressed: _summarize,
                            icon: AppIconImage(
                              PersonalAiIcons.resumoConversa,
                              size: 28,
                              fallbackIcon: Icons.summarize_outlined,
                              semanticLabel: 'Resumir conversa',
                            ),
                            label: const Text('Resumir conversa'),
                          ),
                        ],
                      ),
                    ),
                  if (_aiDraft != null && widget.isTrainer)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _send(text: _aiDraft),
                        child: const Text('Usar resposta'),
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _sending ? null : _pickImage,
                        icon: const Icon(Icons.photo_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _text,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Mensagem',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _sending ? null : () => _send(),
                        icon: const Icon(Icons.send_rounded),
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extra do GoRouter quando a conversa já veio da tela anterior.
class ChatThreadRouteArgs {
  const ChatThreadRouteArgs({required this.conversation, this.isTrainer = false});
  final AccompanimentConversation conversation;
  final bool isTrainer;
}
