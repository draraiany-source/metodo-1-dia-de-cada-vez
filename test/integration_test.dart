import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:metodo_1_dia/features/gamification/providers/gamification_providers.dart';
import 'package:metodo_1_dia/features/missions/providers/missions_providers.dart';
import 'package:metodo_1_dia/features/rewards/providers/rewards_providers.dart';
import 'package:metodo_1_dia/features/ai_trainer/data/ai_trainer_repository.dart';
import 'package:metodo_1_dia/features/ai_trainer/domain/trainer_engine.dart';
import 'package:metodo_1_dia/features/health_sync/data/health_service.dart';
import 'package:metodo_1_dia/features/health_sync/domain/health_models.dart';

import 'test_helpers.dart';

/// Testes de INTEGRAÇÃO: validam que os módulos compartilham os mesmos dados.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Gamificação — fonte única de verdade', () {
    test('XP persiste e o nível é derivado dele', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final notifier = c.read(gamificationProvider.notifier);
      final xpInicial = c.read(gamificationProvider).xp;

      notifier.addXp(1000);
      expect(c.read(gamificationProvider).xp, xpInicial + 1000);
      expect(c.read(gamificationProvider).level, ((xpInicial + 1000) ~/ 1000) + 1);
      await flushAsyncWork();
    });

    test('addXp ignora valores não positivos', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);
      final antes = c.read(gamificationProvider).xp;
      c.read(gamificationProvider.notifier).addXp(0);
      c.read(gamificationProvider.notifier).addXp(-50);
      expect(c.read(gamificationProvider).xp, antes);
      await flushAsyncWork();
    });

    test('check-in incrementa o streak apenas 1x por dia', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final n = c.read(gamificationProvider.notifier);
      final primeiro = n.registerCheckin();
      final streakApos = c.read(gamificationProvider).streak;

      final segundo = n.registerCheckin(); // mesmo dia
      expect(primeiro, isTrue, reason: 'primeiro check-in do dia deve contar');
      expect(segundo, isFalse, reason: 'segundo check-in do dia não conta');
      expect(c.read(gamificationProvider).streak, streakApos);
      await flushAsyncWork();
    });
  });

  group('Loja de Recompensas', () {
    test('earn credita e redeem debita moedas', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final n = c.read(rewardsProvider.notifier);
      n.earn(1000);
      final saldo = c.read(rewardsProvider).coins;

      final item = RewardsCatalog.all.firstWhere((i) => i.price <= saldo);
      final erro = n.redeem(item);

      expect(erro, isNull);
      expect(c.read(rewardsProvider).coins, saldo - item.price);
      expect(c.read(rewardsProvider).owned, contains(item.id));
      expect(c.read(rewardsProvider).history.first.itemId, item.id);
      await flushAsyncWork();
    });

    test('não resgata sem saldo suficiente', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final caro = RewardsCatalog.all
          .reduce((a, b) => a.price > b.price ? a : b);
      final erro = c.read(rewardsProvider.notifier).redeem(caro);
      expect(erro, isNotNull);
      expect(c.read(rewardsProvider).owned, isNot(contains(caro.id)));
      await flushAsyncWork();
    });

    test('não resgata o mesmo item duas vezes', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final n = c.read(rewardsProvider.notifier);
      n.earn(5000);
      final item = RewardsCatalog.all.first;
      expect(n.redeem(item), isNull);
      expect(n.redeem(item), isNotNull, reason: 'segunda vez deve falhar');
      await flushAsyncWork();
    });
  });

  group('Missões', () {
    test('report avança e claim credita XP + moedas', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final missions = c.read(missionsProvider.notifier);
      final def = MissionsCatalog.byId('d_treino'); // target 1

      missions.report(MissionEvent.treinoConcluido);
      expect(missions.isComplete(def), isTrue);
      expect(missions.claimableCount, greaterThan(0));

      final r = missions.claim(def);
      expect(r.ok, isTrue);
      expect(r.xp, def.xp);
      expect(r.coins, def.coins);
      expect(missions.isClaimed(def), isTrue);

      // Segunda tentativa falha.
      expect(missions.claim(def).ok, isFalse);
      await flushAsyncWork();
    });

    test('setProgress usa valor absoluto (água) e respeita o alvo', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final missions = c.read(missionsProvider.notifier);
      final agua = MissionsCatalog.byId('d_agua'); // target 8

      missions.setProgress(MissionEvent.copoDeAgua, 5);
      expect(c.read(missionsProvider).progressOf('d_agua').current, 5);

      missions.setProgress(MissionEvent.copoDeAgua, 99); // acima do alvo
      expect(c.read(missionsProvider).progressOf('d_agua').current, agua.target);
      await flushAsyncWork();
    });

    test('não conclui missão sem atingir o alvo', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);
      final missions = c.read(missionsProvider.notifier);
      final semanal = MissionsCatalog.byId('s_treinos'); // target 4
      missions.report(MissionEvent.treinoConcluido); // só 1
      expect(missions.isComplete(semanal), isFalse);
      expect(missions.claim(semanal).ok, isFalse);
      await flushAsyncWork();
    });
  });

  group('IA Personal Trainer — motor local', () {
    test('adapta exercícios conforme limitação de joelho', () {
      const perfil = TrainerProfile(limitacoes: {Limitacao.joelho});
      final plano = TrainerEngine.gerarPlano(perfil);
      final nomes = plano.dias
          .expand((d) => d.exercicios)
          .map((e) => e.nome.toLowerCase())
          .toList();
      expect(nomes.any((n) => n.contains('agachamento')), isFalse,
          reason: 'agachamento deve ser substituído para joelho');
      expect(plano.avisos, isNotEmpty);
    });

    test('volume aumenta com o nível', () {
      const inic = TrainerProfile(nivel: NivelFisico.iniciante);
      const avan = TrainerProfile(nivel: NivelFisico.avancado);
      final sInic = TrainerEngine.gerarPlano(inic).dias.first.exercicios.first.series;
      final sAvan = TrainerEngine.gerarPlano(avan).dias.first.exercicios.first.series;
      expect(sAvan, greaterThan(sInic));
    });

    test('detecta platô com variação < 0,5 kg em 3 semanas', () {
      expect(TrainerEngine.detectarPlato([74.2, 74.1, 74.0]), isNotNull);
      expect(TrainerEngine.detectarPlato([78.0, 76.0, 74.0]), isNull);
      expect(TrainerEngine.detectarPlato([74.0]), isNull, reason: 'dados insuficientes');
    });

    test('recomenda descanso com volume alto', () {
      expect(TrainerEngine.recomendarDescanso(treinosNaSemana: 6, streak: 3), isNotNull);
      expect(TrainerEngine.recomendarDescanso(treinosNaSemana: 2, streak: 3), isNull);
    });

    test('água escala com peso', () {
      const leve = TrainerProfile(pesoKg: 50);
      const pesada = TrainerProfile(pesoKg: 90);
      expect(pesada.aguaLitros, greaterThan(leve.aguaLitros));
    });

    test('classifica intenções corretamente', () {
      expect(AiTrainerRepository.detectIntent('monta um treino pra mim'),
          TrainerIntent.gerarTreino);
      expect(AiTrainerRepository.detectIntent('quanto de água devo beber?'),
          TrainerIntent.agua);
      expect(AiTrainerRepository.detectIntent('estou num platô'),
          TrainerIntent.plato);
    });

    test('resposta local nunca vem vazia', () {
      final repo = AiTrainerRepository();
      const perfil = TrainerProfile();
      const ctx = TrainerContext();
      for (final msg in ['oi', 'monta um treino', 'blablabla', 'estou triste']) {
        final r = repo.localReply(msg, profile: perfil, context: ctx);
        expect(r.trim(), isNotEmpty);
      }
    });
  });

  group('Health Sync — fallback sem permissão', () {
    test('LocalHealthService funciona e marca métricas indisponíveis', () async {
      final svc = LocalHealthService(coposDeAgua: 6, pesoKg: 70, treinosHoje: 1);
      final r = await svc.read(DateTime.now());

      expect(r.ok, isTrue);
      expect(r.snapshot!.get(HealthMetric.hidratacaoMl), 1500);
      expect(r.snapshot!.get(HealthMetric.pesoKg), 70);
      expect(r.snapshot!.has(HealthMetric.passos), isFalse,
          reason: 'passos só vêm da plataforma de saúde');
      expect(r.metricasIndisponiveis, contains(HealthMetric.passos));
    });

    test('permissão indisponível não quebra o app', () async {
      final svc = LocalHealthService();
      expect(await svc.permissionStatus(), HealthPermission.indisponivel);
      expect(await svc.isAvailable(), isTrue);
      expect((await svc.read(DateTime.now())).ok, isTrue);
    });

    test('snapshot serializa e desserializa', () {
      final snap = HealthSnapshot(
        date: DateTime(2026, 1, 15),
        source: HealthSource.manual,
        valores: const {HealthMetric.passos: 8500},
      );
      final back = HealthSnapshot.fromMap(snap.toMap());
      expect(back.get(HealthMetric.passos), 8500);
      expect(back.source, HealthSource.manual);
    });
  });

  group('Integração cruzada', () {
    test('missão concluída → XP e moedas sobem juntos', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final xpAntes = c.read(gamificationProvider).xp;
      final moedasAntes = c.read(rewardsProvider).coins;

      final missions = c.read(missionsProvider.notifier);
      final def = MissionsCatalog.byId('d_checkin');
      missions.report(MissionEvent.checkinFeito);
      final r = missions.claim(def);

      // A UI credita — simulamos o mesmo fluxo.
      c.read(gamificationProvider.notifier).addXp(r.xp);
      c.read(rewardsProvider.notifier).earn(r.coins);

      expect(c.read(gamificationProvider).xp, xpAntes + def.xp);
      expect(c.read(rewardsProvider).coins, moedasAntes + def.coins);
      await flushAsyncWork();
    });

    test('XP ganho eleva o nível usado pelo Ranking', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await settleProviders(c);

      final nivelAntes = c.read(gamificationProvider).level;
      c.read(gamificationProvider.notifier).addXp(2000);
      expect(c.read(gamificationProvider).level, greaterThan(nivelAntes));
      await flushAsyncWork();
    });
  });
}
