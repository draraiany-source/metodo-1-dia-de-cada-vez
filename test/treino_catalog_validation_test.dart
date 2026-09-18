import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/workouts/data/treino_catalog_repository.dart';
import 'package:metodo_1_dia/features/workouts/domain/treino_catalog_models.dart';
import 'package:metodo_1_dia/features/workouts/presentation/treino_catalog_detail_screen.dart';
import 'package:metodo_1_dia/features/workouts/presentation/treino_catalog_screen.dart';
import 'package:metodo_1_dia/features/workouts/presentation/treino_catalog_visual.dart';
import 'package:metodo_1_dia/features/workouts/providers/treino_catalog_providers.dart';

Future<List<TreinoCatalogEntry>> _loadAll() async {
  final raw =
      await File('assets/content/treinos_catalogo_oficial.json').readAsString();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return (decoded['treinos'] as List)
      .map((e) => TreinoCatalogEntry.fromMap(e as Map<String, dynamic>))
      .toList();
}

Future<Map<String, dynamic>> _loadRaw() async {
  final raw =
      await File('assets/content/treinos_catalogo_oficial.json').readAsString();
  return jsonDecode(raw) as Map<String, dynamic>;
}

bool _matchesQuery(TreinoCatalogEntry t, String q) {
  if (q.isEmpty) return true;
  final lower = q.toLowerCase();
  return t.nome.toLowerCase().contains(lower) ||
      (t.categoria ?? '').toLowerCase().contains(lower) ||
      (t.grupoMuscular ?? '').toLowerCase().contains(lower) ||
      (t.equipamento ?? '').toLowerCase().contains(lower);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Catálogo oficial 117 treinos — validação completa', () {
    late List<TreinoCatalogEntry> all;
    late Map<String, dynamic> raw;

    setUpAll(() async {
      raw = await _loadRaw();
      all = await _loadAll();
    });

    test('exatamente 117 treinos com IDs treino_001..treino_117 sem duplicidade',
        () {
      expect(all.length, 117);
      final ids = all.map((t) => t.id).toList();
      expect(ids.toSet().length, 117);
      for (var i = 1; i <= 117; i++) {
        expect(ids, contains('treino_${i.toString().padLeft(3, '0')}'));
      }
    });

    test('cada treino tem link YouTube válido associado ao seu ID', () {
      final linkById = <String, String>{};
      for (final t in all) {
        expect(t.linkYoutube, startsWith('http'));
        expect(t.linkYoutube.toLowerCase(), contains('youtube'));
        expect(t.nome.trim().isNotEmpty, isTrue);
        linkById[t.id] = t.linkYoutube;
      }
      expect(linkById.length, 117);
      for (final m in raw['treinos'] as List) {
        final map = m as Map<String, dynamic>;
        expect(linkById[map['id']], map['link_youtube']);
      }
    });

    test('repositório valida catálogo completo', () {
      final repo = TreinoCatalogRepository();
      final snap = TreinoCatalogSnapshot(
        version: '2.0',
        totalTreinos: 117,
        treinos: List.from(all),
        pendenciasNaoImportar: const [],
      );
      final v = repo.validate(snap);
      expect(v.isValid, isTrue);
      expect(v.reviewCount, 14);
    });

    test('filtros por categoria, nível, grupo muscular e equipamento', () {
      final cardio = all.where((t) => t.categoria == 'Cardio').toList();
      expect(cardio, isNotEmpty);
      expect(
        cardio.every(
          (t) => const TreinoCatalogFilters(categoria: 'Cardio').matches(t),
        ),
        isTrue,
      );

      final iniciante = all.where((t) => t.nivel.contains('Iniciante')).toList();
      expect(iniciante, isNotEmpty);
      expect(
        iniciante.every(
          (t) => const TreinoCatalogFilters(nivel: 'Iniciante').matches(t),
        ),
        isTrue,
      );

      final withGrupo =
          all.where((t) => (t.grupoMuscular ?? '').isNotEmpty).toList();
      expect(withGrupo, isNotEmpty);
      final grupo = withGrupo.first.grupoMuscular!;
      final byGrupo =
          all.where((t) => TreinoCatalogFilters(grupoMuscular: grupo).matches(t));
      expect(byGrupo, isNotEmpty);
      expect(byGrupo.every((t) => t.grupoMuscular == grupo), isTrue);

      final withEquip =
          all.where((t) => (t.equipamento ?? '').isNotEmpty).toList();
      expect(withEquip, isNotEmpty);
      final equip = withEquip.first.equipamento!;
      final byEquip = all
          .where((t) => TreinoCatalogFilters(equipamento: equip).matches(t));
      expect(byEquip, isNotEmpty);
      expect(byEquip.every((t) => t.equipamento == equip), isTrue);
    });

    test('busca por nome retorna resultados coerentes', () {
      final bike = all.where((t) => _matchesQuery(t, 'bike')).toList();
      expect(bike, isNotEmpty);
      expect(bike.every((t) => _matchesQuery(t, 'bike')), isTrue);
      final prancha = all.firstWhere((t) => t.id == 'treino_012');
      expect(_matchesQuery(prancha, 'prancha'), isTrue);
    });

    // Auditoria de imagens 2026-09-17: treino_053 foi ARQUIVADO (duplicata do
    // treino_113, mesmo vídeo-base). O registro continua no catálogo (117 ids),
    // mas com status 'incompleto_arquivado_*' ele sai da lista da aluna.
    test('aluno vê 116 treinos (053 arquivado); pendência 31 não importada', () {
      final pendencias = raw['pendencias_nao_importar'] as List;
      expect(pendencias, isNotEmpty);
      final student = all.where((t) => t.isReadyForStudent).toList();
      expect(student.length, 116);
      expect(student.any((t) => t.id == 'treino_053'), isFalse);
      expect(student.any((t) => t.id == 'treino_113'), isTrue);
      expect(all.any((t) => t.id == '31'), isFalse);
      expect(all.any((t) => t.id == 'treino_031'), isTrue);
    });

    test('14 registros marcados para revisão no admin', () {
      final review = all.where((t) => t.needsAdminReview).toList();
      expect(review.length, 14);
    });

    test('campos de UI nunca expõem null/undefined como texto', () {
      for (final t in all) {
        for (final text in [
          t.nome,
          treinoSubtitle(t),
          treinoMetaLine(t),
          t.categoria,
          t.grupoMuscular,
          t.equipamento,
          t.prescricao,
          t.intervalo,
          t.objetivo,
          t.observacao,
        ]) {
          if (text == null || text.isEmpty) continue;
          expect(text.toLowerCase(), isNot(contains('null')));
          expect(text.toLowerCase(), isNot(contains('undefined')));
        }
      }
    });

    testWidgets('tela de detalhe dos 117 treinos monta sem null e com voltar',
        (tester) async {
      for (final treino in all) {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            TreinoCatalogDetailScreen(treino: treino),
                      ),
                    ),
                    child: const Text('abrir'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('abrir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text(treino.nome), findsWidgets);
        expect(find.text('Assistir vídeo'), findsOneWidget);
        expect(find.textContaining('null'), findsNothing);
        expect(find.textContaining('undefined'), findsNothing);
        expect(find.byTooltip('Voltar'), findsOneWidget);

        await tester.tap(find.byTooltip('Voltar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('abrir'), findsOneWidget);
      }
    });

    test('repositório carrega 117 treinos via rootBundle', () async {
      final repo = TreinoCatalogRepository();
      repo.clearCache();
      final snap = await repo.load(forceReload: true);
      expect(snap.treinos.length, 117);
      // 116 e não 117: treino_053 arquivado na auditoria de imagens (2026-09-17).
      expect(snap.forStudent.length, 116);
    });

    testWidgets('lista abre detalhe e volta com provider mockado', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            treinoCatalogStudentProvider.overrideWith((ref) async => all),
            treinoCatalogFilterOptionsProvider.overrideWith(
              (ref) async => TreinoCatalogFilterOptions(
                categorias: all
                    .map((t) => t.categoria ?? '')
                    .where((c) => c.isNotEmpty)
                    .toSet()
                    .toList(),
                niveis: all.expand((t) => t.nivel).toSet().toList(),
                gruposMusculares: all
                    .map((t) => t.grupoMuscular ?? '')
                    .where((g) => g.isNotEmpty)
                    .toSet()
                    .toList(),
                equipamentos: all
                    .map((t) => t.equipamento ?? '')
                    .where((e) => e.isNotEmpty)
                    .toSet()
                    .toList(),
                objetivos: all
                    .map((t) => t.objetivo ?? '')
                    .where((o) => o.isNotEmpty)
                    .toSet()
                    .toList(),
              ),
            ),
          ],
          child: const MaterialApp(home: TreinoCatalogScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(all.first.nome), findsWidgets);

      await tester.tap(find.text(all.first.nome).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TreinoCatalogDetailScreen), findsOneWidget);
      expect(find.textContaining('null'), findsNothing);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(TreinoCatalogScreen), findsOneWidget);
    });
  });
}