import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';



import '../../../core/theme/app_colors.dart';

import '../../workouts/data/treino_catalog_repository.dart';

import '../../workouts/domain/treino_catalog_models.dart';

import '../../workouts/providers/treino_catalog_providers.dart';



/// Aba administrativa do catálogo oficial — alertas de revisão e pendências.

class AdminTreinosCatalogTab extends ConsumerWidget {

  const AdminTreinosCatalogTab({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final snapAsync = ref.watch(treinoCatalogSnapshotProvider);

    final validationAsync = ref.watch(treinoCatalogValidationProvider);



    return snapAsync.when(

      loading: () => const Center(child: CircularProgressIndicator()),

      error: (e, _) => Center(

        child: Text('Erro ao carregar catálogo: $e',

            style: const TextStyle(color: Colors.white)),

      ),

      data: (snap) {

        final review = snap.needsReview;

        final pendencias = snap.pendenciasNaoImportar;



        return ListView(

          padding: const EdgeInsets.all(20),

          children: [

            validationAsync.when(

              data: (v) => _ValidationBanner(validation: v),

              loading: () => const SizedBox.shrink(),

              error: (_, __) => const SizedBox.shrink(),

            ),

            const SizedBox(height: 12),

            Text(

              'Catálogo oficial: ${snap.treinos.length} treinos (v${snap.version})',

              style: const TextStyle(

                color: Colors.white,

                fontWeight: FontWeight.w700,

                fontSize: 16,

              ),

            ),

            const SizedBox(height: 8),

            const Text(

              'Backup recomendado antes de sync Firestore (coleção treinos). '

              'Upsert por id — não alterar links YouTube.',

              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),

            ),

            if (review.isNotEmpty) ...[

              const SizedBox(height: 20),

              Row(

                children: [

                  const Icon(Icons.warning_amber_rounded,

                      color: AppColors.warning, size: 22),

                  const SizedBox(width: 8),

                  Text(

                    '${review.length} registro(s) para revisar',

                    style: const TextStyle(

                      color: AppColors.warning,

                      fontWeight: FontWeight.w700,

                    ),

                  ),

                ],

              ),

              const SizedBox(height: 8),

              ...review.map((t) => _ReviewAlertCard(treino: t)),

            ],

            if (pendencias.isNotEmpty) ...[

              const SizedBox(height: 20),

              const Text(

                'Pendências (não importadas para alunas)',

                style: TextStyle(

                  color: AppColors.danger,

                  fontWeight: FontWeight.w700,

                ),

              ),

              const SizedBox(height: 8),

              ...pendencias.map(_PendenciaCard.new),

            ],

            const SizedBox(height: 20),

            const Text(

              'Todos os treinos',

              style: TextStyle(

                color: AppColors.textSecondary,

                fontWeight: FontWeight.w600,

              ),

            ),

            const SizedBox(height: 8),

            ...snap.treinos.map((t) => _TreinoAdminTile(treino: t)),

          ],

        );

      },

    );

  }

}



class _ValidationBanner extends StatelessWidget {

  const _ValidationBanner({required this.validation});



  final TreinoCatalogValidation validation;



  @override

  Widget build(BuildContext context) {

    final ok = validation.isValid;

    return Container(

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(

        color: ok

            ? AppColors.success.withOpacity(0.15)

            : AppColors.danger.withOpacity(0.15),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(

          color: ok ? AppColors.success : AppColors.danger,

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            ok ? 'Validação OK — 117 treinos' : 'Validação com pendências',

            style: TextStyle(

              color: ok ? AppColors.success : AppColors.danger,

              fontWeight: FontWeight.w700,

            ),

          ),

          const SizedBox(height: 6),

          Text(

            'IDs únicos: ${validation.uniqueIds} · '

            'Links YouTube: ${validation.invalidYoutubeIds.isEmpty ? 'OK' : validation.invalidYoutubeIds.length} inválido(s) · '

            'Revisar: ${validation.reviewCount}',

            style: const TextStyle(

              color: AppColors.textSecondary,

              fontSize: 12,

            ),

          ),

        ],

      ),

    );

  }

}



class _ReviewAlertCard extends StatelessWidget {

  const _ReviewAlertCard({required this.treino});



  final TreinoCatalogEntry treino;



  @override

  Widget build(BuildContext context) {

    return Card(

      color: AppColors.warning.withOpacity(0.12),

      margin: const EdgeInsets.only(bottom: 8),

      child: ListTile(

        leading: const Icon(Icons.flag_outlined, color: AppColors.warning),

        title: Text(treino.nome, style: const TextStyle(color: Colors.white)),

        subtitle: Text(

          '${treino.id} · ${treino.status}',

          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),

        ),

        isThreeLine: true,

      ),

    );

  }

}



class _PendenciaCard extends StatelessWidget {

  const _PendenciaCard(this.data);



  final Map<String, dynamic> data;



  @override

  Widget build(BuildContext context) {

    return Card(

      color: AppColors.danger.withOpacity(0.1),

      margin: const EdgeInsets.only(bottom: 8),

      child: ListTile(

        leading: const Icon(Icons.block, color: AppColors.danger),

        title: Text(

          'ID original ${data['id_original']}',

          style: const TextStyle(color: Colors.white),

        ),

        subtitle: Text(

          (data['motivo'] ?? '').toString(),

          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),

        ),

      ),

    );

  }

}



class _TreinoAdminTile extends StatelessWidget {

  const _TreinoAdminTile({required this.treino});



  final TreinoCatalogEntry treino;



  @override

  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.only(bottom: 6),

      child: ListTile(

        dense: true,

        title: Text(treino.nome, style: const TextStyle(color: Colors.white)),

        subtitle: Text(

          '${treino.id} · ${treino.categoria ?? '-'} · ${treino.status}',

          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),

        ),

        trailing: treino.needsAdminReview

            ? const Icon(Icons.warning_amber, color: AppColors.warning, size: 20)

            : const Icon(Icons.check_circle_outline,

                color: AppColors.success, size: 20),

      ),

    );

  }

}

