import 'package:flutter/material.dart';

import '../domain/audio_course_models.dart';
import 'audio_courses_screen.dart';

/// Biblioteca de Meditações — mesma infraestrutura da biblioteca de áudio
/// (Firestore, favoritos, histórico, Premium), só filtrando as categorias
/// relevantes. Não duplica model/repositório/provider.
class MeditationsScreen extends StatelessWidget {
  const MeditationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AudioCoursesScreen(
      title: 'Meditações',
      subtitle: 'Um espaço calmo para respirar, soltar a mente e voltar a si.',
      onlyCategories: {
        AudioCourseCategory.meditacao,
        AudioCourseCategory.respiracao,
        AudioCourseCategory.ansiedade,
        AudioCourseCategory.sono,
      },
    );
  }
}
