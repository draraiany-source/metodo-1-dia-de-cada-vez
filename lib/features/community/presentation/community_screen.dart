import 'package:flutter/material.dart';

import '../../../core/services/feedback_service.dart';
import '../../../core/widgets/animations.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/router/premium_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<_Post> _posts = [
    _Post('Camila', '🎉 Bati minha meta de 5km hoje! Quem diria...', 24, 6, true),
    _Post('Júlia', 'Primeira semana completa de treinos. Bora! 💪', 18, 3, false),
    _Post('Beatriz', 'Alguém mais ama o treino de glúteos? 🍑', 31, 12, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PremiumAppBar(title: 'Comunidade'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _newPost,
        child: const Icon(Icons.edit),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Conecte-se com outras mulheres na mesma jornada 💜',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ..._posts.indexed.map((entry) {
            final post = entry.$2;
            return FadeInUp(
              delayMs: entry.$1 * 50,
              child: _PostCard(
                post: post,
                onLike: () {
                  FeedbackService.play(FeedbackEvent.toqueLeve);
                  setState(() {
                    post.liked = !post.liked;
                    post.likes += post.liked ? 1 : -1;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _newPost() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nova publicação',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'Compartilhe sua conquista...'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() => _posts.insert(
                      0, _Post('Você', ctrl.text.trim(), 0, 0, false)));
                }
                Navigator.pop(context);
              },
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    ).whenComplete(ctrl.dispose);
  }
}

class _Post {
  final String author;
  final String text;
  int likes;
  final int comments;
  bool liked;
  _Post(this.author, this.text, this.likes, this.comments, this.liked);
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onLike});
  final _Post post;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(post.author[0])),
              const SizedBox(width: 10),
              Text(post.author,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.text,
              style: const TextStyle(color: Colors.white, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: onLike,
                child: Row(
                  children: [
                    FavoriteAssetIcon(active: post.liked, size: 18),
                    const SizedBox(width: 4),
                    Text('${post.likes}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline,
                  size: 17, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${post.comments}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
