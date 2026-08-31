import 'package:flutter/material.dart';

import '../../../core/mascot/mascot_config.dart';
import '../domain/audio_course_models.dart';
import 'audio_courses_screen.dart';

/// Biblioteca da Lili Fit — bom dia/boa tarde/boa noite, antes/depois do
/// treino, com a voz e personalidade da mascote. Mesma infraestrutura da
/// biblioteca de áudio, só filtrando as categorias dela.
class LiliAudiosScreen extends StatelessWidget {
  const LiliAudiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AudioCoursesScreen(
      title: 'Biblioteca ${MascotConfig.name} 💜',
      subtitle: 'A ${MascotConfig.shortName} com você em cada momento do dia',
      onlyCategories: {
        AudioCourseCategory.bomDia,
        AudioCourseCategory.boaTarde,
        AudioCourseCategory.boaNoite,
        AudioCourseCategory.antesDoTreino,
        AudioCourseCategory.depoisDoTreino,
        AudioCourseCategory.motivacao,
      },
    );
  }
}
