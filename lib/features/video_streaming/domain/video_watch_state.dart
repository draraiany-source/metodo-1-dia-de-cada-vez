/// Estado de acompanhamento de um vídeo da biblioteca, por aluna (local).
///
/// **Por que não é posição de reprodução:** os vídeos da biblioteca tocam no
/// YouTube, dentro de um WebView (mobile) ou iframe (web). Esse player não
/// devolve a posição atual para o app, então não existe como saber "parou em
/// 4:12". O que conseguimos medir com honestidade é quanto tempo a aluna ficou
/// na tela do player ([secondsInPlayer]) e se ela concluiu ([completed]).
///
/// Consequências para a UI:
/// - "Continuar assistindo" = já abriu e ainda não concluiu.
/// - A barra de progresso é uma **estimativa** baseada em tempo de tela.
/// - A aluna sempre pode marcar/desmarcar como assistido na mão.
class VideoWatchState {
  const VideoWatchState({
    this.secondsInPlayer = 0,
    this.completed = false,
    this.lastOpenedAtMs = 0,
  });

  /// Tempo acumulado na tela do player, em segundos.
  final int secondsInPlayer;

  /// Concluído — automático (ver [kCompletionRatio]) ou marcado pela aluna.
  final bool completed;

  /// Epoch em ms da última abertura, para ordenar "continuar assistindo".
  final int lastOpenedAtMs;

  /// Fração do vídeo que precisa ser assistida para marcar como concluído
  /// automaticamente. Abaixo de 100% porque quase ninguém assiste os créditos,
  /// e porque o tempo de tela é uma estimativa.
  static const double kCompletionRatio = 0.6;

  bool get iniciado => secondsInPlayer > 0 || lastOpenedAtMs > 0;

  /// Progresso estimado de 0 a 1. Sem duração cadastrada não há como estimar,
  /// então devolve 0 (a UI mostra só "Continuar assistindo", sem barra).
  double progresso(int durationSeconds) {
    if (completed) return 1;
    if (durationSeconds <= 0 || secondsInPlayer <= 0) return 0;
    final bruto = secondsInPlayer / durationSeconds;
    // `num.clamp` devolve num, não double — daí o toDouble().
    return bruto.clamp(0.0, 1.0).toDouble();
  }

  VideoWatchState copyWith({
    int? secondsInPlayer,
    bool? completed,
    int? lastOpenedAtMs,
  }) {
    return VideoWatchState(
      secondsInPlayer: secondsInPlayer ?? this.secondsInPlayer,
      completed: completed ?? this.completed,
      lastOpenedAtMs: lastOpenedAtMs ?? this.lastOpenedAtMs,
    );
  }

  Map<String, dynamic> toMap() => {
        's': secondsInPlayer,
        'c': completed,
        't': lastOpenedAtMs,
      };

  factory VideoWatchState.fromMap(Map<String, dynamic> m) {
    return VideoWatchState(
      secondsInPlayer: _int(m['s']),
      completed: m['c'] == true,
      lastOpenedAtMs: _int(m['t']),
    );
  }

  static int _int(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }
}
