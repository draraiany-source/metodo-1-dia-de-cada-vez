import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/trainer_engine.dart';

/// Contexto de gamificação que a IA usa para respostas contextuais.
class TrainerContext {
  const TrainerContext({
    this.streak = 0,
    this.missoesProntas = 0,
    this.moedas = 0,
    this.nivel = 1,
    this.treinosNaSemana = 0,
    this.historicoPeso = const [],
    this.userName = 'você',
    this.passosHoje = 0,
    this.caloriasHoje = 0,
    this.fonteSaude,
  });

  final int streak;
  final int missoesProntas;
  final int moedas;
  final int nivel;
  final int treinosNaSemana;
  final List<double> historicoPeso;
  final String userName;

  /// Dados vindos da sincronização de saúde (0 quando indisponíveis).
  final int passosHoje;
  final int caloriasHoje;
  final String? fonteSaude;
}

/// Intenções que a IA local sabe atender.
enum TrainerIntent {
  gerarTreino,
  alimentacao,
  agua,
  motivacao,
  plato,
  descanso,
  metas,
  duvidaExercicio,
  duvidaAlimentacao,
  progresso,
  gamificacao,
  saudacao,
  desconhecido,
}

/// Repositório da IA Personal Trainer.
///
/// **Produção**: chama a Cloud Function `amandaChat`, que guarda a chave da
/// OpenAI no servidor (a chave NUNCA fica no app). Basta configurar
/// `AppConstants.amandaFunctionUrl` e a function.
///
/// **Sem chave**: usa o [TrainerEngine] + regras de intenção — respostas reais
/// e personalizadas, não frases genéricas.
class AiTrainerRepository {
  /// True quando a IA remota (OpenAI) está disponível.
  bool get isRemoteAvailable => FirebaseService.isReady && AppConfig.aiConfigured;

  /// URL efetiva: prioriza a injetada por --dart-define.
  String get _functionUrl => AppConfig.amandaFunctionUrl.isNotEmpty
      ? AppConfig.amandaFunctionUrl
      : AppConstants.amandaFunctionUrl;

  Future<String> ask(
    String message, {
    required TrainerProfile profile,
    required TrainerContext context,
  }) async {
    if (isRemoteAvailable) {
      try {
        return await _callFunction(message, profile, context);
      } catch (_) {
        // cai para o modo local em caso de erro de rede
      }
    }
    return localReply(message, profile: profile, context: context);
  }

  Future<String> _callFunction(
    String message,
    TrainerProfile profile,
    TrainerContext context,
  ) async {
    final res = await http.post(
      Uri.parse(_functionUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'userName': context.userName,
        // Contexto rico para a IA personalizar (o system prompt fica na Function).
        'profile': profile.toMap(),
        'context': {
          'streak': context.streak,
          'nivel': context.nivel,
          'moedas': context.moedas,
          'missoesProntas': context.missoesProntas,
          'treinosNaSemana': context.treinosNaSemana,
          'historicoPeso': context.historicoPeso,
          'passosHoje': context.passosHoje,
          'caloriasHoje': context.caloriasHoje,
        },
      }),
    ).timeout(const Duration(seconds: 20));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final reply = data['reply'] as String?;
      if (reply != null && reply.trim().isNotEmpty) return reply;
    }
    throw Exception('AI trainer error: ${res.statusCode}');
  }

  // ---------------------------------------------------------------------------
  // MODO LOCAL INTELIGENTE
  // ---------------------------------------------------------------------------

  static TrainerIntent detectIntent(String message) {
    final m = message.toLowerCase();
    bool has(List<String> keys) => keys.any(m.contains);

    if (has(['monta', 'montar', 'gerar treino', 'criar treino', 'plano de treino', 'treino pra mim', 'treino para mim'])) {
      return TrainerIntent.gerarTreino;
    }
    if (has(['platô', 'plato', 'empacou', 'não perco', 'nao perco', 'estagnei', 'parou de emagrecer'])) {
      return TrainerIntent.plato;
    }
    if (has(['descanso', 'descansar', 'cansada', 'exausta', 'overtraining', 'dor muscular'])) {
      return TrainerIntent.descanso;
    }
    if (has(['água', 'agua', 'hidrat', 'quanto beber'])) {
      return TrainerIntent.agua;
    }
    if (has(['meta', 'metas', 'objetivo da semana', 'semana'])) {
      return TrainerIntent.metas;
    }
    if (has(['cardápio', 'cardapio', 'comer', 'dieta', 'alimenta', 'refeição', 'refeicao', 'caloria', 'proteína', 'proteina'])) {
      return has(['pode comer', 'posso comer', 'é bom', 'faz mal', 'engorda'])
          ? TrainerIntent.duvidaAlimentacao
          : TrainerIntent.alimentacao;
    }
    if (has(['como faz', 'como fazer', 'como executar', 'técnica', 'tecnica', 'postura', 'series', 'séries', 'repetiç'])) {
      return TrainerIntent.duvidaExercicio;
    }
    if (has(['evolução', 'evolucao', 'progresso', 'estou melhorando', 'resultado'])) {
      return TrainerIntent.progresso;
    }
    if (has(['streak', 'sequência', 'sequencia', 'missão', 'missao', 'missões', 'missoes', 'moeda', 'loja', 'conquista', 'medalha', 'xp', 'nível', 'nivel'])) {
      return TrainerIntent.gamificacao;
    }
    if (has(['triste', 'desanimada', 'desisti', 'sem vontade', 'motiva', 'difícil', 'dificil'])) {
      return TrainerIntent.motivacao;
    }
    if (has(['oi', 'olá', 'ola', 'bom dia', 'boa tarde', 'boa noite', 'e aí', 'eai'])) {
      return TrainerIntent.saudacao;
    }
    return TrainerIntent.desconhecido;
  }

  /// Resposta local — usa o motor de prescrição, não frases soltas.
  String localReply(
    String message, {
    required TrainerProfile profile,
    required TrainerContext context,
  }) {
    final intent = detectIntent(message);
    final nome = context.userName;

    switch (intent) {
      case TrainerIntent.gerarTreino:
        final plano = TrainerEngine.gerarPlano(profile);
        final b = StringBuffer()
          ..writeln('Montei seu plano, $nome! 💪')
          ..writeln('')
          ..writeln('📋 ${plano.resumo}')
          ..writeln('');
        for (final dia in plano.dias) {
          b.writeln('${dia.titulo} — ${dia.foco} (${dia.duracaoMin} min)');
          for (final ex in dia.exercicios) {
            final obs = ex.observacao != null ? ' _(${ex.observacao})_' : '';
            b.writeln('• ${ex.nome}: ${ex.series}x${ex.reps}, descanso ${ex.descanso}$obs');
          }
          b.writeln('');
        }
        for (final aviso in plano.avisos) {
          b.writeln('⚠️ $aviso');
        }
        b.write('\n${AppConstants.amandaDisclaimer}');
        return b.toString().trim();

      case TrainerIntent.plato:
        final plato = TrainerEngine.detectarPlato(context.historicoPeso);
        if (plato != null) return plato;
        return 'Ainda não vejo um platô nos seus dados. 📈 Continue registrando '
            'seu peso semanalmente que eu monitoro para você — se estabilizar por '
            '3 semanas, te aviso e ajusto o plano.';

      case TrainerIntent.descanso:
        final rec = TrainerEngine.recomendarDescanso(
          treinosNaSemana: context.treinosNaSemana,
          streak: context.streak,
        );
        return rec ??
            'Seu volume está equilibrado. 👍 Se sentir dor persistente (não a dor '
                'boa do músculo), tire um dia de descanso e observe. Sono e água '
                'aceleram a recuperação.';

      case TrainerIntent.agua:
        return 'Para ${profile.pesoKg.toStringAsFixed(0)} kg e nível '
            '${profile.nivel.label.toLowerCase()}, recomendo '
            '**${profile.aguaLitros} L por dia** (~${profile.aguaCopos} copos de 250ml). 💧\n\n'
            'Dica: deixe a garrafa à vista e beba 1 copo a cada hora. '
            'Registre na aba Nutrição para completar sua missão diária!';

      case TrainerIntent.metas:
        final metas = TrainerEngine.metasSemanais(profile);
        return 'Suas metas para esta semana, $nome: 🎯\n\n'
            '${metas.map((m) => '• $m').join('\n')}\n\n'
            'Cadastre-as na aba Metas para acompanhar o progresso!';

      case TrainerIntent.alimentacao:
        final sug = TrainerEngine.sugestoesAlimentacao(profile);
        return 'Sugestão alimentar para ${profile.objetivo.label.toLowerCase()}: 🥗\n\n'
            '${sug.map((s) => '• $s').join('\n')}\n\n'
            '${AppConstants.amandaDisclaimer}';

      case TrainerIntent.duvidaAlimentacao:
        return 'Nenhum alimento sozinho engorda ou emagrece — o que conta é o '
            'conjunto e a quantidade ao longo do dia. 🥗\n\n'
            'Regra prática: metade do prato de vegetais, um quarto de proteína, '
            'um quarto de carboidrato. Se for um alimento que você ama, cabe sim, '
            'com moderação.\n\n${AppConstants.amandaDisclaimer}';

      case TrainerIntent.duvidaExercicio:
        return 'Boa pergunta! Três princípios que valem para qualquer exercício:\n\n'
            '1. **Técnica antes de carga** — movimento controlado, sem balanço.\n'
            '2. **Respiração** — solte o ar no esforço, puxe na volta.\n'
            '3. **Amplitude** — melhor pouco peso com movimento completo.\n\n'
            'Para o seu nível (${profile.nivel.label.toLowerCase()}), trabalhe com '
            'séries de ${TrainerEngine.gerarPlano(profile).dias.first.exercicios.first.series} '
            'e pare 2 repetições antes da falha. Me diga qual exercício específico '
            'que eu detalho!';

      case TrainerIntent.progresso:
        final plato = TrainerEngine.detectarPlato(context.historicoPeso);
        final base = 'Você está no nível ${context.nivel} com '
            '${context.streak} dia(s) de sequência. 📈';
        final saude = context.passosHoje > 0
            ? '\n\nHoje você já deu ${context.passosHoje} passos'
                '${context.caloriasHoje > 0 ? ' e queimou ~${context.caloriasHoje} kcal' : ''}'
                '${context.fonteSaude != null ? ' (via ${context.fonteSaude})' : ''}. '
                '${context.passosHoje >= 8000 ? 'Meta batida! 🎉' : 'Faltam ${8000 - context.passosHoje} para a meta de 8.000.'}'
            : '';
        if (plato != null) return '$base$saude\n\n$plato';
        return '$base$saude\n\nContinue registrando peso e treinos — quanto mais dados, '
            'mais preciso eu fico nas recomendações. Constância vence intensidade!';

      case TrainerIntent.gamificacao:
        final partes = <String>[
          'Nível ${context.nivel} · 🔥 ${context.streak} dias de sequência',
          '🪙 ${context.moedas} moedas na carteira',
        ];
        if (context.missoesProntas > 0) {
          partes.add(
              '🎁 Você tem ${context.missoesProntas} missão(ões) pronta(s) para resgatar!');
        }
        partes.add('Use suas moedas na Loja de Recompensas para desbloquear itens.');
        return '${partes.join('\n')}\n\nOrgulho de você, $nome! 💜';

      case TrainerIntent.motivacao:
        if (context.streak > 0) {
          return 'Ei, $nome. 💜 Você já tem ${context.streak} dia(s) de sequência — '
              'isso é prova de que você consegue.\n\nNão precisa ser perfeita hoje. '
              'Só não quebre a corrente: faça 10 minutos. Só isso. '
              'Estou aqui com você.';
        }
        return 'Tudo bem não estar 100% hoje, $nome. 💜 Você não precisa ser '
            'perfeita, só precisa continuar.\n\nComeça pequeno: um copo de água, '
            'um alongamento. Um dia de cada vez. Estou aqui com você.';

      case TrainerIntent.saudacao:
        final extra = context.missoesProntas > 0
            ? ' Você tem ${context.missoesProntas} recompensa(s) esperando! 🎁'
            : '';
        return 'Oi, $nome! 💜 Que bom te ver por aqui.$extra\n\n'
            'Posso montar seu treino, sugerir alimentação, calcular sua água ou '
            'só te ouvir. O que você precisa hoje?';

      case TrainerIntent.desconhecido:
        return 'Estou aqui com você, $nome. 💜 Posso te ajudar com:\n\n'
            '• "Monta um treino pra mim"\n'
            '• "Quanto de água devo beber?"\n'
            '• "Sugestões de alimentação"\n'
            '• "Estou num platô"\n'
            '• "Preciso de descanso?"\n'
            '• "Quais minhas metas da semana?"\n\n'
            'Ou simplesmente me conte como está se sentindo.';
    }
  }
}
