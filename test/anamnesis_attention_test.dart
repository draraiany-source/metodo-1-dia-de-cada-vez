import 'package:flutter_test/flutter_test.dart';
import 'package:metodo_1_dia/features/accompaniment/domain/anamnesis_attention.dart';
import 'package:metodo_1_dia/features/accompaniment/domain/appointment_overlap.dart';

void main() {
  group('AnamnesisAttention', () {
    test('sem relatos fica sem pendência', () {
      final r = AnamnesisAttention.evaluate(const AnamnesisAttentionInput());
      expect(r.level, AttentionLevel.none);
      expect(r.flags, isEmpty);
    });

    test('dor no peito gera avaliação antes de progressão e mostra a resposta',
        () {
      final r = AnamnesisAttention.evaluate(
        const AnamnesisAttentionInput(chestPainOnEffort: true),
      );
      expect(r.level, AttentionLevel.reviewBeforeProgression);
      expect(
        r.flags.first.reason,
        contains('dor no peito durante esforço'),
      );
    });

    test('dor articular gera esclarecimento, não diagnóstico', () {
      final r = AnamnesisAttention.evaluate(
        const AnamnesisAttentionInput(painRegions: ['Joelho'], maxPainScale: 4),
      );
      expect(r.level, AttentionLevel.clarify);
      expect(r.flags.any((f) => f.reason.contains('Joelho')), isTrue);
    });
  });

  group('AppointmentOverlap', () {
    test('bloqueia o mesmo horário', () {
      final start = DateTime(2026, 9, 20, 14);
      expect(
        AppointmentOverlap.conflicts(
          start: start,
          durationMinutes: 60,
          occupied: [TimeRange(start, start.add(const Duration(hours: 1)))],
        ),
        isTrue,
      );
    });

    test('libera horário seguinte sem sobreposição', () {
      final occupiedStart = DateTime(2026, 9, 20, 14);
      expect(
        AppointmentOverlap.conflicts(
          start: DateTime(2026, 9, 20, 15),
          durationMinutes: 60,
          occupied: [
            TimeRange(
              occupiedStart,
              occupiedStart.add(const Duration(hours: 1)),
            ),
          ],
        ),
        isFalse,
      );
    });
  });
}
