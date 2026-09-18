/// Regras de conflito de horário (America/Sao_Paulo no app; UTC no banco).
library;

class TimeRange {
  const TimeRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  bool overlaps(TimeRange other) {
    return start.isBefore(other.end) && other.start.isBefore(end);
  }
}

class AppointmentOverlap {
  AppointmentOverlap._();

  /// Duas consultas ativas não podem ocupar o mesmo intervalo.
  static bool conflicts({
    required DateTime start,
    required int durationMinutes,
    required Iterable<TimeRange> occupied,
  }) {
    final candidate = TimeRange(
      start,
      start.add(Duration(minutes: durationMinutes)),
    );
    for (final o in occupied) {
      if (candidate.overlaps(o)) return true;
    }
    return false;
  }

  static const timezoneId = 'America/Sao_Paulo';
}
