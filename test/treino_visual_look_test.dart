import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/workouts/domain/treino_catalog_models.dart';
import 'package:metodo_1_dia/features/workouts/presentation/treino_catalog_visual.dart';

void main() {
  TreinoCatalogEntry entry({
    String id = 'treino_001',
    String nome = 'Teste',
    String categoria = '',
    String grupo = '',
  }) {
    return TreinoCatalogEntry(
      id: id,
      idOriginal: id,
      nome: nome,
      categoria: categoria,
      grupoMuscular: grupo,
      equipamento: '',
      nivel: const ['Iniciante'],
      prescricao: '',
      intervalo: '',
      objetivo: '',
      observacao: '',
      linkYoutube: 'https://youtube.com/watch?v=abc',
      status: 'ok',
    );
  }

  test('peitoral does not use cardio heart look', () {
    final look = treinoVisualLookOf(
      entry(categoria: 'Hipertrofia — Peitoral', grupo: 'Peitoral'),
    );
    expect(look.label, 'Peito');
    expect(look.asset, isNot(contains('cardio')));
  });

  test('hipertrofia/cardio hybrid is not heart', () {
    final look = treinoVisualLookOf(
      entry(categoria: 'Hipertrofia / Cardio', grupo: ''),
    );
    expect(look.label, isNot('Cardio'));
  });

  test('pure cardio keeps heart asset', () {
    final look = treinoVisualLookOf(
      entry(categoria: 'Cardio', grupo: '', nome: 'HIIT leve'),
    );
    // Nome com HIIT vence cardio genérico.
    expect(look.label, 'HIIT');
  });

  test('cardio without modality uses cardio neon icon', () {
    final look = treinoVisualLookOf(
      entry(categoria: 'Cardio', grupo: '', nome: 'Cardio steady'),
    );
    expect(look.label, 'Cardio');
    expect(look.asset, isNotNull);
    expect(look.asset!.contains('corrida') || look.asset!.contains('cardio'),
        isTrue);
    expect(look.asset, isNot(contains('halter')));
  });

  test('agachamento uses specific squat icon', () {
    final look = treinoVisualLookOf(
      entry(nome: 'Agachamento livre', categoria: 'Hipertrofia', grupo: 'Quadríceps'),
    );
    expect(look.source, TreinoVisualSource.exercise);
    expect(look.asset, contains('agachamento'));
  });

  test('placeholder never uses heart path', () {
    final look = treinoVisualLookOf(
      entry(nome: 'Treino misterioso XYZ', categoria: 'Outros', grupo: ''),
    );
    expect(look.source, TreinoVisualSource.placeholder);
    expect(look.asset, contains('vidro_3d'));
  });

  test('visualSection prefers muscle over hybrid cardio', () {
    final t = entry(categoria: 'Hipertrofia / Cardio', grupo: 'Peitoral');
    expect(t.visualSection, TreinoVisualSection.peitoral);
  });
}
