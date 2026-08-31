import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metodo_1_dia/core/providers/lili_guide_provider.dart';
import 'package:metodo_1_dia/core/widgets/lili_widgets.dart';
import 'package:metodo_1_dia/features/gamification/providers/gamification_providers.dart';
import 'package:metodo_1_dia/features/missions/providers/missions_providers.dart';
import 'package:metodo_1_dia/features/rewards/providers/rewards_providers.dart';

import 'test_helpers.dart';

/// A Lili é a guia do app: sua reação precisa ser previsível e acolhedora.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String ontem() =>
      GamificationNotifier.dayKey(DateTime.now().subtract(const Duration(days: 1)));

  String semanaPassada() => GamificationNotifier.dayKey(
      DateTime.now().subtract(const Duration(days: 7)));

  test('sequência perdida tem a MAIOR prioridade e acolhe (não pune)', () async {
    SharedPreferences.setMockInitialValues({
      'gam_streak': 12,
      'gam_last_checkin': semanaPassada(), // faz mais de 1 dia → quebra
      'rewards_coins': 99999, // mesmo com moedas, a perda fala mais alto
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);

    final gam = c.read(gamificationProvider);
    expect(gam.streak, 0);
    expect(gam.streakJustBroken, isTrue);
    expect(gam.previousStreak, 12);

    final guide = c.read(liliGuideProvider);
    expect(guide.situation, LiliSituation.sequenciaPerdida);
    expect(guide.pose, MascotePose.triste);
    expect(guide.fala, contains('12 dias'));
    expect(guide.fala.toLowerCase(), contains('tudo bem'),
        reason: 'a fala deve acolher, não culpar');
    expect(guide.cta, 'Recomeçar hoje');
    await flushAsyncWork();
  });

  test('streak mantido no dia anterior NÃO quebra', () async {
    SharedPreferences.setMockInitialValues({
      'gam_streak': 5,
      'gam_last_checkin': ontem(),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);

    expect(c.read(gamificationProvider).streak, 5);
    expect(c.read(gamificationProvider).streakJustBroken, isFalse);
    await flushAsyncWork();
  });

  test('recompensa pendente vence "em chamas"', () async {
    SharedPreferences.setMockInitialValues({
      'gam_streak': 20,
      'gam_last_checkin': ontem(),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);

    // Conclui uma missão diária → fica resgatável.
    c.read(missionsProvider.notifier).report(MissionEvent.treinoConcluido);

    final guide = c.read(liliGuideProvider);
    expect(guide.situation, LiliSituation.recompensaEsperando);
    expect(guide.pose, MascotePose.celebrando);
    expect(guide.rota, '/missions');
    await flushAsyncWork();
  });

  test('streak >= 7 sem missão pendente → em chamas', () async {
    SharedPreferences.setMockInitialValues({
      'gam_streak': 9,
      'gam_last_checkin': ontem(),
      'rewards_coins': 0,
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);

    final guide = c.read(liliGuideProvider);
    expect(guide.situation, LiliSituation.emChamas);
    expect(guide.fala, contains('9 dias'));
    await flushAsyncWork();
  });

  test('sem streak → modo "começando", com convite ao check-in', () async {
    SharedPreferences.setMockInitialValues({
      'gam_streak': 0,
      'rewards_coins': 0,
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);

    final guide = c.read(liliGuideProvider);
    expect(guide.situation, LiliSituation.comecando);
    expect(guide.rota, '/habits');
    await flushAsyncWork();
  });

  test('moedas suficientes → sugere a Loja', () async {
    final maisBarato =
        RewardsCatalog.all.map((i) => i.price).reduce((a, b) => a < b ? a : b);
    SharedPreferences.setMockInitialValues({
      'gam_streak': 3, // não é "em chamas" nem zero
      'gam_last_checkin': ontem(),
      'rewards_coins': maisBarato + 10,
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);

    final guide = c.read(liliGuideProvider);
    expect(guide.situation, LiliSituation.podeComprar);
    expect(guide.rota, '/rewards');
    await flushAsyncWork();
  });

  test('acknowledgeStreakBreak limpa o sinal (Lili não repete a má notícia)',
      () async {
    SharedPreferences.setMockInitialValues({
      'gam_streak': 4,
      'gam_last_checkin': semanaPassada(),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);

    expect(c.read(gamificationProvider).streakJustBroken, isTrue);
    c.read(gamificationProvider.notifier).acknowledgeStreakBreak();
    expect(c.read(gamificationProvider).streakJustBroken, isFalse);
    expect(c.read(liliGuideProvider).situation,
        isNot(LiliSituation.sequenciaPerdida));
    await flushAsyncWork();
  });

  test('toda situação produz fala não vazia', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await settleLiliGuide(c);
    expect(c.read(liliGuideProvider).fala.trim(), isNotEmpty);
    await flushAsyncWork();
  });
}
