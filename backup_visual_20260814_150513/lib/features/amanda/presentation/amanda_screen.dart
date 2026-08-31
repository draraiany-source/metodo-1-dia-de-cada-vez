import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../personal_amanda/presentation/amanda_image.dart';
import '../../../models/app_user.dart';
import '../../../models/domain_models.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/amanda_repository.dart';

class AmandaScreen extends ConsumerStatefulWidget {
  const AmandaScreen({super.key});

  @override
  ConsumerState<AmandaScreen> createState() => _AmandaScreenState();
}

class _AmandaScreenState extends ConsumerState<AmandaScreen> {
  final _repo = AmandaRepository();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text:
          'Oi! Eu sou a Amanda, sua personal virtual. 💜 Estou aqui para te motivar, um dia de cada vez. Como você está hoje?',
      fromUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider) ?? AppUser.demo();

    setState(() {
      _messages.add(ChatMessage(text: text, fromUser: true));
      _typing = true;
      _controller.clear();
    });
    _scrollDown();

    final reply = await _repo.send(text, userName: user.name.split(' ').first);
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(ChatMessage(text: reply, fromUser: false));
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.push(Routes.amandaProfile),
          child: Row(
            children: [
              const ClipOval(
                child: AmandaImage(size: 36),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amanda', style: TextStyle(fontSize: 16)),
                  Text('sua personal virtual',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (_typing && i == _messages.length) {
                  return const _Bubble(
                      text: 'Amanda está digitando...',
                      fromUser: false,
                      italic: true);
                }
                final m = _messages[i];
                return _Bubble(text: m.text, fromUser: m.fromUser);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: AppColors.surface,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Escreva para a Amanda...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _send,
                    ),
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

class _Bubble extends StatelessWidget {
  const _Bubble(
      {required this.text, required this.fromUser, this.italic = false});
  final String text;
  final bool fromUser;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
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
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          height: 1.4,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );

    if (fromUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    // Mensagens da Amanda vêm com a mascote contextual ao lado.
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const ClipOval(
              child: AmandaImage(size: 36),
            ),
            const SizedBox(width: 8),
            Flexible(child: bubble),
          ],
        ),
      ),
    );
  }
}
