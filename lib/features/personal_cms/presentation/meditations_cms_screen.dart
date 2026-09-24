import 'package:flutter/material.dart';

import '../../video_streaming/domain/video_models.dart';
import '../../video_streaming/presentation/videos_admin_screen.dart';

/// CMS de meditações — reusa a coleção `videos` (categoria [VideoCategory.meditacao])
/// e o mesmo editor de YouTube da biblioteca.
class MeditationsCmsScreen extends StatelessWidget {
  const MeditationsCmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideosAdminScreen(
      onlyCategory: VideoCategory.meditacao,
      title: 'Meditações',
      fabLabel: 'Nova meditação',
    );
  }
}
