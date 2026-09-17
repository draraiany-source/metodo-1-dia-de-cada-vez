import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/services/feedback_service.dart';
import '../../../core/services/local_reminders_service.dart';
import '../domain/workout_timer_models.dart';

class WorkoutTimerController extends ChangeNotifier with WidgetsBindingObserver {
  WorkoutTimerController();

  WorkoutTimerState? _state;
  Ticker? _ticker;
  DateTime? _phaseEndsAt;
  DateTime? _lastTick;
  DateTime? _pausedAt;
  bool _bgNotified = false;
  bool _observing = false;

  WorkoutTimerState? get state => _state;
  bool get isActive => _state != null && !(_state!.finished);

  void bind(WorkoutTimerBlueprint blueprint) {
    _ticker ??= Ticker(_onTick);
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    _state = WorkoutTimerState(blueprint: blueprint);
    notifyListeners();
  }

  void clear() {
    _ticker?.stop();
    _setWake(false);
    _state = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _ticker?.dispose();
    _setWake(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final s = _state;
    if (s == null || !s.running) return;
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.hidden) {
      _syncFromWallClock();
      if (!_bgNotified) {
        _bgNotified = true;
        LocalRemindersService.showNow(
          id: 42001,
          title: 'Treino em andamento',
          body: _bgBody(),
        );
      }
    } else if (lifecycle == AppLifecycleState.resumed) {
      _bgNotified = false;
      _syncFromWallClock();
    }
  }

  String _bgBody() {
    final s = _state;
    if (s == null) return 'Seu treino continua';
    final clock = formatTimer(s.remaining);
    if (s.phase == TimerPhase.rest) return 'Descanso $clock';
    return '${s.current?.name ?? 'Treino'} · $clock';
  }

  Future<void> startWorkout() async {
    final s = _state;
    if (s == null) return;
    _setWake(true);
    _state = s.copyWith(
      startedAt: DateTime.now(),
      exerciseIndex: 0,
      setIndex: 0,
      roundIndex: 0,
      finished: false,
    );
    notifyListeners();
    final first = _state!.blueprint.exercises.firstOrNull;
    if (first == null) return;
    if (first.autoStart || s.blueprint.autoStartFirst) {
      await startCurrent();
    }
  }

  Future<void> startCurrent() async {
    final ex = _state?.current;
    if (ex == null) return;
    await FeedbackService.play(FeedbackEvent.toqueLeve);
    if (ex.protocol == TimerProtocol.hiit) {
      _enterWork(Duration(seconds: ex.workSeconds <= 0 ? 40 : ex.workSeconds));
    } else if (ex.protocol == TimerProtocol.emom) {
      _enterWork(const Duration(seconds: 60));
    } else if (ex.protocol == TimerProtocol.amrap) {
      final secs = ex.workSeconds <= 0 ? 12 * 60 : ex.workSeconds;
      _enterWork(Duration(seconds: secs));
    } else if (ex.isTimed) {
      _enterWork(Duration(seconds: ex.workSeconds <= 0 ? 40 : ex.workSeconds));
    } else {
      _enterWork(Duration.zero, free: true);
    }
  }

  void pause() {
    final s = _state;
    if (s == null || !s.running) return;
    _pausedAt = DateTime.now();
    _ticker?.stop();
    _state = s.copyWith(running: false);
    notifyListeners();
  }

  void resume() {
    final s = _state;
    if (s == null || s.running || s.phase == TimerPhase.idle) return;
    if (_pausedAt != null && _phaseEndsAt != null) {
      _phaseEndsAt = _phaseEndsAt!.add(DateTime.now().difference(_pausedAt!));
    }
    _pausedAt = null;
    _lastTick = DateTime.now();
    _ticker?.start();
    _state = s.copyWith(running: true);
    notifyListeners();
  }

  void restartPhase() => startCurrent();

  void skip() {
    if (_state?.phase == TimerPhase.rest) {
      _afterRest();
    } else {
      _completeSet();
    }
  }

  void addRestSeconds(int seconds) {
    if (_state?.phase != TimerPhase.rest || _phaseEndsAt == null) return;
    _phaseEndsAt = _phaseEndsAt!.add(Duration(seconds: seconds));
    _syncFromWallClock();
  }

  void finishWorkout() {
    final s = _state;
    if (s == null) return;
    _ticker?.stop();
    _setWake(false);
    _state = s.copyWith(
      running: false,
      phase: TimerPhase.done,
      finished: true,
      remaining: Duration.zero,
    );
    notifyListeners();
  }

  void _enterWork(Duration duration, {bool free = false}) {
    final s = _state;
    if (s == null) return;
    _lastTick = DateTime.now();
    if (free) {
      _phaseEndsAt = null;
      _state = s.copyWith(
        phase: TimerPhase.work,
        running: true,
        remaining: Duration.zero,
        phaseTotal: Duration.zero,
        lastBeepSecond: -1,
      );
    } else {
      _phaseEndsAt = DateTime.now().add(duration);
      _state = s.copyWith(
        phase: TimerPhase.work,
        running: true,
        remaining: duration,
        phaseTotal: duration,
        lastBeepSecond: -1,
      );
    }
    _ticker?.start();
    _setWake(true);
    notifyListeners();
  }

  void _enterRest(Duration duration) {
    final s = _state;
    if (s == null) return;
    _lastTick = DateTime.now();
    _phaseEndsAt = DateTime.now().add(duration);
    _state = s.copyWith(
      phase: TimerPhase.rest,
      running: true,
      remaining: duration,
      phaseTotal: duration,
      lastBeepSecond: -1,
    );
    _ticker?.start();
    notifyListeners();
  }

  void _onTick(Duration _) {
    if (_state == null || !(_state!.running)) return;
    _syncFromWallClock();
  }

  void _syncFromWallClock() {
    final s = _state;
    if (s == null || !s.running) return;
    final now = DateTime.now();
    final last = _lastTick ?? now;
    var delta = now.difference(last);
    if (delta.isNegative) delta = Duration.zero;
    _lastTick = now;

    var total = s.totalElapsed + delta;
    var active = s.activeElapsed;
    var rest = s.restElapsed;
    if (s.phase == TimerPhase.work) {
      active += delta;
    } else if (s.phase == TimerPhase.rest) {
      rest += delta;
    }

    if (_phaseEndsAt == null) {
      _state = s.copyWith(
        remaining: active,
        totalElapsed: total,
        activeElapsed: active,
        restElapsed: rest,
      );
      notifyListeners();
      return;
    }

    var remaining = _phaseEndsAt!.difference(now);
    if (remaining.isNegative) remaining = Duration.zero;
    final secs = remaining.inSeconds;
    if (secs <= 5 && secs > 0 && secs != s.lastBeepSecond) {
      _beepLastSeconds(secs);
    }

    _state = s.copyWith(
      remaining: remaining,
      totalElapsed: total,
      activeElapsed: active,
      restElapsed: rest,
      lastBeepSecond: secs <= 5 ? secs : -1,
    );
    notifyListeners();

    if (remaining == Duration.zero) {
      _onPhaseComplete();
    }
  }

  void _onPhaseComplete() {
    _finishCue();
    if (_state?.phase == TimerPhase.work) {
      _completeSet();
    } else if (_state?.phase == TimerPhase.rest) {
      _afterRest();
    }
  }

  void _completeSet() {
    final s = _state;
    final ex = s?.current;
    if (s == null || ex == null) return;
    final seriesDone = s.seriesDone + 1;
    if (ex.protocol == TimerProtocol.hiit ||
        ex.protocol == TimerProtocol.emom) {
      final nextRound = s.roundIndex + 1;
      if (nextRound >= ex.effectiveRounds) {
        _nextExercise(seriesDone);
        return;
      }
      _state = s.copyWith(roundIndex: nextRound, seriesDone: seriesDone);
      if (ex.protocol == TimerProtocol.hiit && ex.restSeconds > 0) {
        _enterRest(Duration(seconds: ex.restSeconds));
        return;
      }
      startCurrent();
      return;
    }

    final nextSet = s.setIndex + 1;
    if (nextSet >= ex.effectiveRounds) {
      _nextExercise(seriesDone);
      return;
    }
    _state = s.copyWith(setIndex: nextSet, seriesDone: seriesDone);
    notifyListeners();
    if (ex.restSeconds > 0) {
      _enterRest(Duration(seconds: ex.restSeconds));
    } else if (ex.autoAdvance) {
      startCurrent();
    } else {
      _ticker?.stop();
      _state = _state!.copyWith(running: false, phase: TimerPhase.idle);
      notifyListeners();
    }
  }

  void _afterRest() {
    final ex = _state?.current;
    if (ex == null) return;
    if (ex.autoAdvance) {
      startCurrent();
    } else {
      _ticker?.stop();
      _state = _state!.copyWith(running: false, phase: TimerPhase.idle);
      notifyListeners();
    }
  }

  void _nextExercise(int seriesDone) {
    final s = _state;
    if (s == null) return;
    final next = s.exerciseIndex + 1;
    final doneEx = s.exercisesDone + 1;
    if (next >= s.blueprint.exercises.length) {
      _state = s.copyWith(seriesDone: seriesDone, exercisesDone: doneEx);
      finishWorkout();
      return;
    }
    final upcoming = s.blueprint.exercises[next];
    _state = s.copyWith(
      exerciseIndex: next,
      setIndex: 0,
      roundIndex: 0,
      seriesDone: seriesDone,
      exercisesDone: doneEx,
    );
    notifyListeners();
    if (upcoming.autoAdvance || upcoming.autoStart) {
      startCurrent();
    } else {
      _ticker?.stop();
      _state = _state!.copyWith(running: false, phase: TimerPhase.idle);
      notifyListeners();
    }
  }

  Future<void> _finishCue() async {
    await FeedbackService.play(FeedbackEvent.sucesso);
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> _beepLastSeconds(int sec) async {
    try {
      if (FeedbackService.hapticsEnabled) {
        await HapticFeedback.heavyImpact();
      }
      if (FeedbackService.soundEnabled) {
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {}
  }

  void _setWake(bool on) {
    try {
      if (on) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
    } catch (_) {}
  }
}

String formatTimer(Duration d) {
  final abs = d.abs();
  final m = abs.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = abs.inSeconds.remainder(60).toString().padLeft(2, '0');
  final body = abs.inHours > 0 ? '${abs.inHours}:$m:$s' : '$m:$s';
  return d.isNegative ? '-$body' : body;
}

final workoutTimerControllerProvider =
    ChangeNotifierProvider<WorkoutTimerController>((ref) {
  final c = WorkoutTimerController();
  ref.onDispose(c.dispose);
  return c;
});
