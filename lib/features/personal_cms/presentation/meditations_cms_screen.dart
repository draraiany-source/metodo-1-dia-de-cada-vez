import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../audio_courses/domain/audio_course_models.dart';
import '../../audio_courses/providers/audio_course_providers.dart';
import '../../audio_programs/data/repositories/audio_program_repository_impl.dart';
import '../../audio_programs/domain/entities/audio_program.dart';
import 'cms_confirm.dart';

const _meditationCats = {
  AudioCourseCategory.meditacao,
  AudioCourseCategory.respiracao,
  AudioCourseCategory.ansiedade,
  AudioCourseCategory.sono,
};

/// Stub CMS de meditações — reusa `audio_courses` (categorias de calma) e
/// `programs` (toggle `active`). Não cria coleção nova.
class MeditationsCmsScreen extends ConsumerWidget {
  const MeditationsCmsScreen({super.key});

  Stream<List<AudioProgram>> _watchProgramsIncludingInactive() {
    return FirebaseFirestore.instance
        .collection(kProgramsCollection)
        .orderBy('orderIndex')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AudioProgram.fromMap(d.id, d.data())).toList());
  }

  Future<void> _toggleProgram(
      BuildContext context, AudioProgram program) async {
    if (program.active) {
      final ok = await confirmDeactivate(
        context,
        title: 'Desativar "${program.title}"?',
      );
      if (!ok) return;
    }
    await FirebaseFirestore.instance
        .collection(kProgramsCollection)
        .doc(program.id)
        .set({'active': !program.active}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(audioCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meditações')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(Routes.audioCoursesAdmin),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar áudio'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          const Text(
            'Cursos de meditação / respiração / sono',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Criação completa fica em Áudios (mesmo Firestore). Aqui você vê '
            'só as categorias de meditação.',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          coursesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Não deu pra carregar os áudios.',
                style: TextStyle(color: AppColors.textSecondary)),
            data: (all) {
              final items = all
                  .where((c) => _meditationCats.contains(c.category))
                  .toList();
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nenhuma meditação cadastrada ainda.\n'
                    'Use Adicionar áudio e escolha a categoria Meditação.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                );
              }
              return Column(
                children: items
                    .map((c) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(c.title,
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              '${c.category.label} · ${c.chapters.length} capítulos',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right,
                                color: AppColors.textTertiary),
                            onTap: () =>
                                context.push(Routes.audioCoursesAdmin),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Programas de áudio',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Desativar esconde o programa das alunas (soft delete).',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<AudioProgram>>(
            stream: _watchProgramsIncludingInactive(),
            builder: (context, snap) {
              if (snap.hasError) {
                return const Text(
                  'Programas indisponíveis (verifique Firebase).',
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final programs = snap.data!;
              if (programs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Nenhum programa encontrado.\n'
                    'Seed via tools/audio_seed (docs/AUDIO_PROGRAMS.md).',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                );
              }
              return Column(
                children: programs
                    .map((p) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            title: Text(p.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${p.totalDays} dias'
                              '${p.active ? '' : ' · Desativado'}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                            trailing: SizedBox(
                              height: 44,
                              child: TextButton(
                                onPressed: () => _toggleProgram(context, p),
                                child:
                                    Text(p.active ? 'Desativar' : 'Reativar'),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
