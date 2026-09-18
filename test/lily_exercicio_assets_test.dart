import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/core/lily/lily_exercicio_assets.dart';
import 'package:metodo_1_dia/features/workouts/domain/treino_catalog_models.dart';

/// Guarda de regressão criada pela auditoria de imagens de 2026-09-17
/// (ver AUDITORIA_IMAGENS_LILI_FIT.md na raiz do projeto).
///
/// O objetivo é impedir que o vínculo exercício → arte volte a quebrar sem que
/// alguém perceba: se um arquivo for renomeado, apagado, ou se uma reatribuição
/// nova criar compartilhamento de arte, algum teste aqui falha.

const String _kAssetsDir = 'assets/lily_exercicios';
const String _kCatalogPath = 'assets/content/treinos_catalogo_oficial.json';

/// Artes que hoje atendem MAIS DE UM exercício visível para a aluna.
///
/// Isso não é um bug de código: o pacote de arte original só tem 101 imagens
/// distintas para 117 exercícios (há arquivos byte-idênticos). Cada grupo aqui
/// corresponde a um item da seção "IMAGENS QUE PRECISAM SER GERADAS" do
/// relatório. Quando a arte própria for entregue, remova o grupo desta lista.
const Map<String, List<String>> kArtesCompartilhadasConhecidas = {
  // 116 é o dono correto (búlgaro sem peso); 020 (salto) espera arte nova.
  'treino_020.jpg': ['treino_020', 'treino_116'],
  // 052 é o dono correto (búlgaro com halteres); 022 (salto no step) espera arte.
  'treino_022.jpg': ['treino_022', 'treino_052'],
  // 033 é o dono correto (goblet); 027 (TRX) espera arte nova.
  'treino_027.jpg': ['treino_027', 'treino_033'],
  // 040 é o dono correto (afundo no Smith); 032 (halteres no step) espera arte.
  'treino_032.jpg': ['treino_032', 'treino_040'],
  'treino_037.jpg': ['treino_037', 'treino_069'],
  // 031 (afundo com halteres) e 054 (afundo com recuo) compartilham a 040.
  'treino_040.jpg': ['treino_031', 'treino_054'],
  'treino_055.jpg': ['treino_048', 'treino_049'],
  'treino_095.jpg': ['treino_095', 'treino_096'],
  'treino_100.jpg': ['treino_099', 'treino_100'],
  // 014 é o dono correto (infra na paralela); 101 espera arte do combinado.
  'treino_101.jpg': ['treino_014', 'treino_101'],
  'treino_102.jpg': ['treino_102', 'treino_106'],
  'treino_106.jpg': ['treino_087', 'treino_088', 'treino_090'],
};

Future<List<TreinoCatalogEntry>> _loadCatalog() async {
  final raw = await File(_kCatalogPath).readAsString();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return (decoded['treinos'] as List)
      .map((e) => TreinoCatalogEntry.fromMap(e as Map<String, dynamic>))
      .toList(growable: false);
}

List<String> get _todosOsIds => List<String>.generate(
      117,
      (i) => 'treino_${(i + 1).toString().padLeft(3, '0')}',
      growable: false,
    );

void main() {
  group('LilyExercicioAssets — vínculo exercício → arte', () {
    test('os 117 ids do catálogo resolvem para um asset', () {
      for (final id in _todosOsIds) {
        expect(
          LilyExercicioAssets.pathForId(id),
          isNotNull,
          reason: '$id ficou sem asset em LilyExercicioAssets',
        );
      }
    });

    test('inspeção visual: donos confirmados e 101 sem o sumô do 052', () {
      const confirmados = <String, String>{
        'treino_029': 'assets/lily_exercicios/treino_031.jpg',
        'treino_030': 'assets/lily_exercicios/treino_033.jpg',
        'treino_031': 'assets/lily_exercicios/treino_040.jpg',
        'treino_033': 'assets/lily_exercicios/treino_027.jpg',
        'treino_040': 'assets/lily_exercicios/treino_032.jpg',
        'treino_042': 'assets/lily_exercicios/treino_030.jpg',
        'treino_052': 'assets/lily_exercicios/treino_022.jpg',
        'treino_054': 'assets/lily_exercicios/treino_040.jpg',
        'treino_096': 'assets/lily_exercicios/treino_095.jpg',
        'treino_114': 'assets/lily_exercicios/treino_042.jpg',
        'treino_116': 'assets/lily_exercicios/treino_020.jpg',
      };
      confirmados.forEach((id, path) {
        expect(LilyExercicioAssets.pathForId(id), path, reason: id);
      });
      expect(
        LilyExercicioAssets.pathForId('treino_101'),
        isNot('assets/lily_exercicios/treino_052.jpg'),
      );
      expect(
        LilyExercicioAssets.pathForId('treino_101'),
        'assets/lily_exercicios/treino_101.jpg',
      );
    });

    test('pathForId é tolerante a id nulo ou vazio', () {
      expect(LilyExercicioAssets.pathForId(null), isNull);
      expect(LilyExercicioAssets.pathForId(''), isNull);
      expect(LilyExercicioAssets.pathForId('id_que_nao_existe'), isNull);
    });

    test('todo asset resolvido existe fisicamente no disco', () {
      final quebrados = <String>[];
      for (final id in _todosOsIds) {
        final path = LilyExercicioAssets.pathForId(id)!;
        if (!File(path).existsSync()) quebrados.add('$id -> $path');
      }
      expect(quebrados, isEmpty, reason: 'Caminhos quebrados: $quebrados');
    });

    test('todo asset resolvido mora em $_kAssetsDir e é .jpg', () {
      for (final id in _todosOsIds) {
        final path = LilyExercicioAssets.pathForId(id)!;
        expect(path, startsWith('$_kAssetsDir/'), reason: 'id $id');
        expect(path, endsWith('.jpg'), reason: 'id $id');
        // _incoming/ são candidatas não aprovadas e não entram no bundle.
        expect(path.contains('_incoming'), isFalse, reason: 'id $id');
      }
    });

    test('$_kAssetsDir está declarado no pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec.contains('- $_kAssetsDir/'),
        isTrue,
        reason: 'Sem essa linha as 117 capas não entram no build.',
      );
    });

    test('reatribuicoesAuditoria não tem entrada redundante nem alvo ausente',
        () {
      LilyExercicioAssets.reatribuicoesAuditoria.forEach((id, path) {
        expect(
          LilyExercicioAssets.byId.containsKey(id),
          isTrue,
          reason: 'Reatribuição para id fora do catálogo: $id',
        );
        expect(
          path,
          isNot(LilyExercicioAssets.byId[id]),
          reason: 'Reatribuição de $id é igual ao mapa gerado; remova-a.',
        );
      });
    });

    test('nenhuma arte nova ficou compartilhada sem estar documentada',
        () async {
      final catalogo = await _loadCatalog();
      final visiveis = catalogo.where((t) => t.isReadyForStudent);

      final porArquivo = <String, List<String>>{};
      for (final treino in visiveis) {
        final path = LilyExercicioAssets.pathForId(treino.id);
        if (path == null) continue;
        porArquivo.putIfAbsent(path.split('/').last, () => <String>[]).add(
              treino.id,
            );
      }

      final compartilhadas = <String, List<String>>{};
      porArquivo.forEach((arquivo, ids) {
        if (ids.length > 1) compartilhadas[arquivo] = (ids..sort());
      });

      final esperado = Map<String, List<String>>.fromEntries(
        kArtesCompartilhadasConhecidas.entries.map(
          (e) => MapEntry(e.key, [...e.value]..sort()),
        ),
      );

      expect(
        compartilhadas,
        esperado,
        reason: 'Mudou o conjunto de artes compartilhadas. Se a mudança for '
            'intencional, atualize kArtesCompartilhadasConhecidas e a seção '
            '"IMAGENS QUE PRECISAM SER GERADAS" de '
            'AUDITORIA_IMAGENS_LILI_FIT.md.',
      );
    });

    test('exercício arquivado não aparece para a aluna, mas mantém histórico',
        () async {
      final catalogo = await _loadCatalog();
      final arquivado = catalogo.firstWhere((t) => t.id == 'treino_053');

      // Registro preservado (nada foi apagado)...
      expect(arquivado.nome, isNotEmpty);
      expect(arquivado.linkYoutube, isNotEmpty);
      // ...mas fora da lista da aluna.
      expect(arquivado.isReadyForStudent, isFalse);
      // E o principal continua ativo.
      final principal = catalogo.firstWhere((t) => t.id == 'treino_113');
      expect(principal.isReadyForStudent, isTrue);
    });
  });
}
