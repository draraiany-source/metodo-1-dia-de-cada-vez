import '../../../core/services/local_reminders_service.dart';
import '../domain/weekly_challenge_models.dart';

/// Agenda lembretes locais do Desafio da Semana.
class WeeklyChallengeNotifications {
  WeeklyChallengeNotifications._();

  static int _base(String challengeId) =>
      41000 + (challengeId.hashCode.abs() % 800);

  static Future<void> scheduleFor(WeeklyChallenge challenge) async {
    await cancelFor(challenge.id);
    if (!challenge.isPublished) return;

    final base = _base(challenge.id);
    final start = DateTime(
      challenge.startDate.year,
      challenge.startDate.month,
      challenge.startDate.day,
      8,
    );
    await LocalRemindersService.scheduleOnce(
      id: base,
      title: 'Seu Desafio da Semana começou 💜',
      body: challenge.title,
      when: start,
    );

    final mid = challenge.startDate.add(const Duration(days: 3));
    await LocalRemindersService.scheduleOnce(
      id: base + 1,
      title: 'Você já concluiu alguns dias. Continue!',
      body: 'Um dia de cada vez — ${challenge.title}',
      when: DateTime(mid.year, mid.month, mid.day, 18),
    );

    final last = DateTime(
      challenge.endDate.year,
      challenge.endDate.month,
      challenge.endDate.day,
      9,
    );
    await LocalRemindersService.scheduleOnce(
      id: base + 2,
      title: 'Último dia do desafio!',
      body: 'Falta pouco para completar ${challenge.title} 🔥',
      when: last,
    );
  }

  static Future<void> notifyProgress({
    required WeeklyChallenge challenge,
    required int completed,
  }) async {
    final remaining = challenge.requiredDays - completed;
    if (remaining == 1) {
      await LocalRemindersService.showNow(
        id: _base(challenge.id) + 5,
        title: 'Falta apenas 1 dia para completar seu desafio 🔥',
        body: challenge.title,
      );
    } else if (completed == 3) {
      await LocalRemindersService.showNow(
        id: _base(challenge.id) + 6,
        title: 'Você já concluiu 3 dias. Continue!',
        body: 'Um dia de cada vez 💜',
      );
    }
  }

  static Future<void> cancelFor(String challengeId) async {
    final base = _base(challengeId);
    for (var i = 0; i < 8; i++) {
      await LocalRemindersService.cancel(base + i);
    }
  }
}
