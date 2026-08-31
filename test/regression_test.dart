import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metodo_1_dia/core/utils/date_format.dart';
import 'package:metodo_1_dia/features/goals/presentation/goals_screen.dart';
import 'package:metodo_1_dia/features/missions/providers/missions_providers.dart';
import 'package:metodo_1_dia/features/rewards/providers/rewards_providers.dart';

import 'test_helpers.dart';

/// Testes de REGRESSÃO — travam as correções feitas na auditoria RC1.
/// Se alguém reintroduzir um dos bugs, estes testes quebram.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RC1 · Parse defensivo (dados corrompidos não derrubam o app)', () {
    test('Loja: histórico corrompido é descartado, app carrega', () async {
      SharedPreferences.setMockInitialValues({
        'rewards_coins': 300,
        'rewards_history': [
          '{"lixo": "não é um RedeemRecord"}',
          'isso nem é JSON',
          jsonEncode({
            'itemId': 'av_atleta',
            'title': 'Avatar Atleta',
            'price': 300,
            'date': DateTime(2026, 1, 1).toIso8601String(),
          }),
        ],
      });

      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final state = c.read(rewardsProvider);
      expect(state.loading, isFalse, reason: 'deve carregar mesmo com lixo');
      expect(state.coins, 300);
      expect(state.history.length, 1, reason: 'só o registro válido sobrevive');
      expect(state.history.first.itemId, 'av_atleta');
      await flushAsyncWork();
    });

    test('Missões: progresso corrompido é ignorado', () async {
      SharedPreferences.setMockInitialValues({
        'missions_progress': [
          '}{ json quebrado',
          jsonEncode({'id': 'd_treino', 'current': 1, 'claimed': false}),
        ],
        'missions_day_key': MissionsNotifier.dayKey(),
        'missions_week_key': MissionsNotifier.weekKey(),
        'missions_month_key': MissionsNotifier.monthKey(),
      });

      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final state = c.read(missionsProvider);
      expect(state.loading, isFalse);
      expect(state.progressOf('d_treino').current, 1);
      await flushAsyncWork();
    });

    test('Metas: entrada inválida não quebra o parse', () {
      const bom = '{"id":"g1","title":"Peso","target":5,"current":2,"unit":"kg"}';
      final g = Goal.fromMap(jsonDecode(bom) as Map<String, dynamic>);
      expect(g.progress, closeTo(0.4, 0.001));
      expect(g.done, isFalse);

      expect(() => Goal.fromMap(jsonDecode('{"id":"x"}') as Map<String, dynamic>),
          throwsA(anything),
          reason: 'fromMap lança; quem chama deve capturar (é o que o app faz)');
    });
  });

  group('RC1 · Renovação de período das missões', () {
    test('chave de dia muda a cada dia', () {
      final hoje = MissionsNotifier.dayKey(DateTime(2026, 3, 10));
      final amanha = MissionsNotifier.dayKey(DateTime(2026, 3, 11));
      expect(hoje, isNot(amanha));
    });

    test('chave de semana é a segunda-feira (mesma semana = mesma chave)', () {
      // 2026-03-10 é uma terça; 2026-03-12 é quinta — mesma semana.
      final terca = MissionsNotifier.weekKey(DateTime(2026, 3, 10));
      final quinta = MissionsNotifier.weekKey(DateTime(2026, 3, 12));
      final proximaSeg = MissionsNotifier.weekKey(DateTime(2026, 3, 16));
      expect(terca, quinta);
      expect(terca, isNot(proximaSeg));
    });

    test('chave de mês muda na virada', () {
      expect(MissionsNotifier.monthKey(DateTime(2026, 3, 31)),
          isNot(MissionsNotifier.monthKey(DateTime(2026, 4, 1))));
    });
  });

  group('RC1 · Utilitário de data (deduplicado)', () {
    test('dataHora formata com zero à esquerda', () {
      expect(DateFormatBr.dataHora(DateTime(2026, 1, 5, 9, 7)),
          '5 jan 2026 · 09:07');
    });

    test('data curta', () {
      expect(DateFormatBr.data(DateTime(2026, 12, 25)), '25 dez 2026');
    });

    test('tempoRelativo', () {
      expect(DateFormatBr.tempoRelativo(DateTime.now()), 'agora mesmo');
      expect(
          DateFormatBr.tempoRelativo(
              DateTime.now().subtract(const Duration(hours: 3))),
          'há 3 h');
      expect(
          DateFormatBr.tempoRelativo(
              DateTime.now().subtract(const Duration(days: 2))),
          'há 2 dia(s)');
    });
  });

  group('RC1 · Economia não permite estado inválido', () {
    test('saldo nunca fica negativo após resgate', () async {
      SharedPreferences.setMockInitialValues({'rewards_coins': 10});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final caro = RewardsCatalog.all.reduce((a, b) => a.price > b.price ? a : b);
      c.read(rewardsProvider.notifier).redeem(caro);
      expect(c.read(rewardsProvider).coins, greaterThanOrEqualTo(0));
      await flushAsyncWork();
    });
  });
}
