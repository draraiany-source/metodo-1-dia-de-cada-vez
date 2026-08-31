class WaterLogEntry {
  const WaterLogEntry({
    required this.date,
    required this.consumedMl,
    required this.goalMl,
    this.entries = const [],
  });

  final DateTime date;
  final int consumedMl;
  final int goalMl;
  final List<WaterIntakeEvent> entries;

  int get remainingMl => (goalMl - consumedMl).clamp(0, goalMl);

  double get progress => goalMl > 0 ? (consumedMl / goalMl).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toMap() => {
        'date': _dayKey(date),
        'consumedMl': consumedMl,
        'goalMl': goalMl,
        'entries': entries.map((e) => e.toMap()).toList(),
      };

  factory WaterLogEntry.fromMap(Map<String, dynamic> m) {
    final raw = m['entries'] as List<dynamic>? ?? [];
    final key = m['date'] as String? ?? '';
    return WaterLogEntry(
      date: _parseDayKey(key),
      consumedMl: ((m['consumedMl'] ?? 0) as num).round(),
      goalMl: ((m['goalMl'] ?? 2000) as num).round(),
      entries: raw
          .map((e) => WaterIntakeEvent.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static DateTime _parseDayKey(String key) {
    final parts = key.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }
    return DateTime.now();
  }
}

class WaterIntakeEvent {
  const WaterIntakeEvent({
    required this.ml,
    required this.at,
  });

  final int ml;
  final DateTime at;

  Map<String, dynamic> toMap() => {
        'ml': ml,
        'at': at.toIso8601String(),
      };

  factory WaterIntakeEvent.fromMap(Map<String, dynamic> m) => WaterIntakeEvent(
        ml: ((m['ml'] ?? 0) as num).round(),
        at: DateTime.parse(m['at'] as String),
      );
}
