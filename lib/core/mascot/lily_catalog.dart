import 'mascot_assets.dart';
import '../widgets/lili_widgets.dart' show MascotePose;

/// Situações de apoio da Lily (linguagem adulta, sem infantilizar).
enum LilySituation {
  welcome,
  celebrating,
  motivating,
  meditating,
  training,
  nutrition,
  water,
  achievement,
  attention,
  rest,
}

/// Catálogo profissional da Lily — nomes estáveis + melhor asset disponível.
///
/// Preferência: `assets/lily/lily_*.png` (cópias organizadas).
/// Fallback: artes oficiais já existentes em mascot/lily_fit.
class LilyCatalog {
  LilyCatalog._();

  static const String base = 'assets/lily';

  static String organizedPath(LilySituation s) => switch (s) {
        LilySituation.welcome => '$base/lily_welcome.png',
        LilySituation.celebrating => '$base/lily_success.png',
        LilySituation.motivating => '$base/lily_motivation.png',
        LilySituation.meditating => '$base/lily_meditation.png',
        LilySituation.training => '$base/lily_workout.png',
        LilySituation.nutrition => '$base/lily_nutrition.png',
        LilySituation.water => '$base/lily_water.png',
        LilySituation.achievement => '$base/lily_achievement.png',
        LilySituation.attention => '$base/lily_attention.png',
        LilySituation.rest => '$base/lily_rest.png',
      };

  /// Fallback quando o PNG organizado ainda não carregou / não existe.
  static String fallbackAssetFor(LilySituation s) => switch (s) {
        LilySituation.welcome => MascotAssets.lily02Paz,
        LilySituation.celebrating => MascotAssets.officialCelebratingRing,
        LilySituation.motivating => MascotAssets.lily01Joinha,
        LilySituation.meditating =>
          '${MascotAssets.newBasePath}mascot_meditation.png',
        LilySituation.training => MascotAssets.lily09Halter,
        LilySituation.nutrition => MascotAssets.healthyFood,
        LilySituation.water => MascotAssets.lily07Shaker,
        LilySituation.achievement => MascotAssets.officialCelebratingRing,
        LilySituation.attention => MascotAssets.lily04Apontando,
        LilySituation.rest => MascotAssets.lily08Notebook,
      };

  /// Asset preferencial (organizado → oficial conhecido).
  static String assetFor(LilySituation s) => organizedPath(s);

  static MascotePose poseFor(LilySituation s) => switch (s) {
        LilySituation.welcome => MascotePose.boasVindas,
        LilySituation.celebrating => MascotePose.celebrando,
        LilySituation.motivating => MascotePose.joinha,
        LilySituation.meditating => MascotePose.meditacao,
        LilySituation.training => MascotePose.halteres,
        LilySituation.nutrition => MascotePose.coracao,
        LilySituation.water => MascotePose.hidratacao,
        LilySituation.achievement => MascotePose.trofeu,
        LilySituation.attention => MascotePose.apontando,
        LilySituation.rest => MascotePose.padrao,
      };

  static String labelFor(LilySituation s) => switch (s) {
        LilySituation.welcome => 'Lily dando boas-vindas',
        LilySituation.celebrating => 'Lily comemorando',
        LilySituation.motivating => 'Lily motivando',
        LilySituation.meditating => 'Lily meditando',
        LilySituation.training => 'Lily treinando',
        LilySituation.nutrition => 'Lily na alimentação',
        LilySituation.water => 'Lily com água',
        LilySituation.achievement => 'Lily na conquista',
        LilySituation.attention => 'Lily pedindo atenção',
        LilySituation.rest => 'Lily em descanso',
      };

  /// Mensagens curtas e elegantes (sem excesso, sem infantilizar).
  static String messageFor(LilySituation s, {int seed = 0}) {
    final list = switch (s) {
      LilySituation.welcome => const [
          'Hoje você não precisa fazer tudo. Só precisa dar o próximo passo.',
          'Bem-vinda. Um dia de cada vez.',
        ],
      LilySituation.celebrating => const [
          'Mais um dia cumprido. Continue.',
          'Você investiu alguns minutos em você hoje.',
        ],
      LilySituation.motivating => const [
          'O importante não é nunca parar. É sempre voltar.',
          'Disciplina começa no próximo passo, não na perfeição.',
        ],
      LilySituation.meditating => const [
          'Respire. Este momento é seu.',
          'Alguns minutos de presença já mudam o dia.',
        ],
      LilySituation.training => const [
          'Mais um treino. Mais um compromisso consigo.',
          'Movimento com intenção. Vamos.',
        ],
      LilySituation.nutrition => const [
          'Alimentar-se também é cuidado.',
          'Escolhas simples, consistentes.',
        ],
      LilySituation.water => const [
          'Hora de se hidratar.',
          'Um gole agora. Seu corpo agradece.',
        ],
      LilySituation.achievement => const [
          'Você concluiu mais um passo da sua jornada.',
          'Registre isso: você se mostrou presente.',
        ],
      LilySituation.attention => const [
          'Pausa. O que importa agora?',
          'Volte ao essencial: o próximo passo.',
        ],
      LilySituation.rest => const [
          'Descansar também faz parte do método.',
          'Recarregue. Amanhã continua.',
        ],
    };
    return list[seed.abs() % list.length];
  }
}
