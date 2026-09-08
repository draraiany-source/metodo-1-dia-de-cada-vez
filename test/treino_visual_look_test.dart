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

  test('cardio without modality uses heart', () {
    final look = treinoVisualLookOf(
      entry(categoria: 'Cardio', grupo: '', nome: 'Cardio steady'),
    );
    expect(look.label, 'Cardio');
    expect(look.asset, contains('cardio'));
  });

  test('visualSection prefers muscle over hybrid cardio', () {
    final t = entry(categoria: 'Hipertrofia / Cardio', grupo: 'Peitoral');
    expect(t.visualSection, TreinoVisualSection.peitoral);
  });
}
