import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/core/utils/date_utils.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_record.dart';
import 'package:hercare/features/cycle_tracking/domain/services/cycle_calculation_engine.dart';

void main() {
  const engine = CycleCalculationEngine();

  group('CycleCalculationEngine - Data sufficiency thresholds', () {
    test('returns insufficientData when record list is empty', () {
      final estimate = engine.calculate(
        records: [],
        referenceDate: DateTime(2026, 10, 22),
      );

      expect(estimate.reliability, EstimateReliability.insufficient);
      expect(estimate.hasPrediction, false);
      expect(estimate.currentEstimatedPhase, CyclePhase.uncertain);
      expect(estimate.recordedCyclesCount, 0);
    });

    test('single period entry provides limitedInformation baseline estimate', () {
      final records = [
        CycleRecord(
          startDate: DateTime(2026, 10, 18),
          endDate: DateTime(2026, 10, 23),
        ),
      ];

      final estimate = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 10, 20),
      );

      expect(estimate.reliability, EstimateReliability.limitedInformation);
      expect(estimate.recordedCyclesCount, 1);
      expect(estimate.hasPrediction, true);
      expect(estimate.dayOfCycle, 3);
      expect(estimate.currentEstimatedPhase, CyclePhase.menstrual);
      expect(estimate.averageCycleLength, 28.0);
    });

    test('marks 2 records as preliminary estimate (1 interval)', () {
      final records = [
        CycleRecord(startDate: DateTime(2026, 8, 1)),
        CycleRecord(startDate: DateTime(2026, 8, 30)), // 29 days interval
      ];

      final estimate = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 9, 10),
      );

      expect(estimate.reliability, EstimateReliability.preliminary);
      expect(estimate.averageCycleLength, 29.0);
      expect(estimate.hasPrediction, true);
      expect(estimate.nextEstimatedPeriodStart, DateTime(2026, 9, 28));
    });

    test('marks 3+ records as cycleInformed estimate with rolling average', () {
      final records = [
        CycleRecord(startDate: DateTime(2026, 6, 1)),
        CycleRecord(startDate: DateTime(2026, 6, 30)), // 29 days
        CycleRecord(startDate: DateTime(2026, 7, 31)), // 31 days
        CycleRecord(startDate: DateTime(2026, 8, 30)), // 30 days
      ];

      final estimate = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 9, 10),
      );

      expect(estimate.reliability, EstimateReliability.cycleInformed);
      expect(estimate.averageCycleLength, 30.0);
      expect(estimate.recordedCyclesCount, 4);
      expect(estimate.nextEstimatedPeriodStart, DateTime(2026, 9, 29));
      expect(estimate.variabilityDays, greaterThanOrEqualTo(1));
    });
  });

  group('CycleCalculationEngine - Robustness & Edge Cases', () {
    test('handles out-of-order and duplicate records gracefully', () {
      final records = [
        CycleRecord(startDate: DateTime(2026, 8, 30)),
        CycleRecord(startDate: DateTime(2026, 6, 1)),
        CycleRecord(startDate: DateTime(2026, 6, 1)), // duplicate
        CycleRecord(startDate: DateTime(2026, 7, 1)),
        CycleRecord(startDate: DateTime(2026, 7, 31)),
      ];

      final estimate = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 9, 10),
      );

      expect(estimate.recordedCyclesCount, 4);
      expect(estimate.hasPrediction, true);
    });

    test('handles leap year transition seamlessly (e.g. Feb 29 leap day)', () {
      // 2028 is a leap year (Feb 29 exists)
      final records = [
        CycleRecord(startDate: DateTime(2028, 1, 31)),
        CycleRecord(startDate: DateTime(2028, 2, 29)), // 29 days interval in leap year
      ];

      final estimate = engine.calculate(
        records: records,
        referenceDate: DateTime(2028, 3, 5),
      );

      expect(estimate.averageCycleLength, 29.0);
      expect(estimate.nextEstimatedPeriodStart, DateTime(2028, 3, 29));
    });

    test('phase detection reflects menstrual, follicular, ovulatory and luteal stages', () {
      final records = [
        CycleRecord(
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 5),
        ),
        CycleRecord(
          startDate: DateTime(2026, 10, 31),
          endDate: DateTime(2026, 11, 4),
        ),
      ];

      // Day 3 of cycle (Nov 2) -> Menstrual
      final estMenstrual = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 11, 2),
      );
      expect(estMenstrual.currentEstimatedPhase, CyclePhase.menstrual);

      // Day 8 of cycle (Nov 7) -> Follicular
      final estFollicular = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 11, 7),
      );
      expect(estFollicular.currentEstimatedPhase, CyclePhase.follicular);

      // Day 15 of cycle (Nov 14, mid-cycle of 30-day cycle) -> Ovulatory
      final estOvulatory = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 11, 14),
      );
      expect(estOvulatory.currentEstimatedPhase, CyclePhase.ovulatory);

      // Day 24 of cycle (Nov 23) -> Luteal
      final estLuteal = engine.calculate(
        records: records,
        referenceDate: DateTime(2026, 11, 23),
      );
      expect(estLuteal.currentEstimatedPhase, CyclePhase.luteal);
    });
  });

  group('AppDateUtils Tests', () {
    test('leap year day counts', () {
      expect(AppDateUtils.getDaysInMonth(2028, 2), 29); // leap year
      expect(AppDateUtils.getDaysInMonth(2026, 2), 28); // non-leap year
      expect(AppDateUtils.getDaysInMonth(2026, 4), 30);
      expect(AppDateUtils.getDaysInMonth(2026, 12), 31);
    });

    test('dateOnly removes time components', () {
      final d = DateTime(2026, 10, 22, 18, 45, 12);
      final stripped = AppDateUtils.dateOnly(d);
      expect(stripped.hour, 0);
      expect(stripped.minute, 0);
      expect(stripped.second, 0);
      expect(stripped.year, 2026);
      expect(stripped.month, 10);
      expect(stripped.day, 22);
    });
  });
}
