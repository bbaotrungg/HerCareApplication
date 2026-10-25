import 'dart:math';
import '../../../../core/utils/date_utils.dart';
import '../models/cycle_estimate.dart';
import '../models/cycle_phase.dart';
import '../models/cycle_record.dart';

/// Pure, deterministic cycle calculation engine.
///
/// Implements transparent, rule-based cycle calculations isolated from UI code.
/// Never assumes an arbitrary 28-day cycle as medical fact, but provides a
/// documented general fallback when only one period is recorded.
/// Clearly communicates uncertainty and data sufficiency.
class CycleCalculationEngine {
  /// General reference baseline used ONLY as a documented fallback when exactly
  /// one period start date has been recorded.
  static const double generalBaselineCycleLength = 28.0;
  static const int generalBaselineVariability = 3;

  const CycleCalculationEngine();

  /// Calculates cycle estimates given a history of recorded period dates.
  /// [referenceDate] defaults to today if omitted.
  CycleEstimate calculate({
    required List<CycleRecord> records,
    DateTime? referenceDate,
  }) {
    final today = AppDateUtils.dateOnly(referenceDate ?? DateTime.now());

    // 1. Sanitize and sort records chronologically
    final cleanRecords = _sanitizeAndSort(records);

    if (cleanRecords.isEmpty) {
      return const CycleEstimate(
        reliability: EstimateReliability.insufficient,
        recordedCyclesCount: 0,
        currentEstimatedPhase: CyclePhase.uncertain,
        statusTitle: 'No Period History Yet',
        explanationMessage:
            'Start by recording the first day of her most recent period. '
            'HerCare will then automatically estimate her cycle phase and possible experiences.',
      );
    }

    final latestRecord = cleanRecords.last;
    final daysSinceLatest = AppDateUtils.daysBetween(latestRecord.startDate, today);
    final dayOfCycle = daysSinceLatest >= 0 ? daysSinceLatest + 1 : null;

    // Calculate average period duration if user provided end dates
    final durations = cleanRecords
        .where((r) => r.durationInDays != null && r.durationInDays! > 0 && r.durationInDays! <= 14)
        .map((r) => r.durationInDays!.toDouble())
        .toList();
    final avgPeriodDuration = durations.isNotEmpty
        ? durations.reduce((a, b) => a + b) / durations.length
        : 5.0;

    // 2. If only 1 record exists: use documented general baseline fallback
    if (cleanRecords.length < 2) {
      final nextStartDate = latestRecord.startDate.add(
        const Duration(days: 28),
      );
      final windowStart = nextStartDate.subtract(
        const Duration(days: generalBaselineVariability),
      );
      final windowEnd = nextStartDate.add(
        const Duration(days: generalBaselineVariability),
      );
      final daysUntil = AppDateUtils.daysBetween(today, nextStartDate);

      final phase = _determinePhase(
        today: today,
        latestRecord: latestRecord,
        avgPeriodDuration: avgPeriodDuration,
        avgCycleLength: generalBaselineCycleLength,
        dayOfCycle: dayOfCycle,
      );

      return CycleEstimate(
        reliability: EstimateReliability.limitedInformation,
        recordedCyclesCount: 1,
        averageCycleLength: generalBaselineCycleLength,
        variabilityDays: generalBaselineVariability,
        averagePeriodDuration: avgPeriodDuration,
        nextEstimatedPeriodStart: nextStartDate,
        estimatedPeriodWindowStart: windowStart,
        estimatedPeriodWindowEnd: windowEnd,
        daysUntilEstimatedPeriod: daysUntil,
        currentEstimatedPhase: phase,
        dayOfCycle: dayOfCycle,
        statusTitle: 'Limited Information (General Baseline)',
        explanationMessage:
            'Based on 1 recorded period start date and a general 28-day baseline. '
            'As you record future cycle start dates, HerCare will calibrate to her personal cycle rhythm.',
      );
    }

    // 3. Compute cycle intervals between consecutive start dates
    final intervals = <int>[];
    for (int i = 0; i < cleanRecords.length - 1; i++) {
      final diff = AppDateUtils.daysBetween(
        cleanRecords[i].startDate,
        cleanRecords[i + 1].startDate,
      );
      // Accept plausible cycle intervals (18 to 60 days) to prevent distorted averages
      if (diff >= 18 && diff <= 60) {
        intervals.add(diff);
      }
    }

    if (intervals.isEmpty) {
      return CycleEstimate(
        reliability: EstimateReliability.limitedInformation,
        recordedCyclesCount: cleanRecords.length,
        averagePeriodDuration: avgPeriodDuration,
        dayOfCycle: dayOfCycle,
        currentEstimatedPhase: CyclePhase.uncertain,
        statusTitle: 'Need More Consistent Records',
        explanationMessage:
            'The dates recorded have large gaps or overlap. '
            'Please verify that period start dates reflect consecutive cycles.',
      );
    }

    // 4. Calculate average length and variability
    final avgLength = intervals.reduce((a, b) => a + b) / intervals.length;
    final variability = _calculateVariability(intervals);

    final isSingleInterval = intervals.length == 1;
    final isVariable = variability >= 4;

    final EstimateReliability reliability;
    final String statusTitle;
    final String explanation;

    if (isSingleInterval) {
      reliability = EstimateReliability.preliminary;
      statusTitle = 'General Estimate (1 Recorded Cycle)';
      explanation = 'Based on a single recorded interval of ${avgLength.round()} days. '
          'At least 3 recorded periods are recommended for a personalized baseline.';
    } else if (isVariable) {
      reliability = EstimateReliability.variableCycle;
      statusTitle = 'Variable Cycle (${cleanRecords.length} Cycles)';
      explanation = 'Observed average cycle of ${avgLength.toStringAsFixed(1)} days with '
          'noticeable variation (±$variability days). Natural factors like stress and sleep shift cycle lengths.';
    } else {
      reliability = EstimateReliability.cycleInformed;
      statusTitle = 'Cycle-Informed (${cleanRecords.length} Cycles)';
      explanation = 'Based on an observed average cycle of ${avgLength.toStringAsFixed(1)} days '
          '(±$variability days variability).';
    }

    // 5. Estimate next period start date
    final nextStartDate = latestRecord.startDate.add(
      Duration(days: avgLength.round()),
    );
    final windowStart = nextStartDate.subtract(Duration(days: variability));
    final windowEnd = nextStartDate.add(Duration(days: variability));
    final daysUntil = AppDateUtils.daysBetween(today, nextStartDate);

    // 6. Determine estimated current phase
    final estimatedPhase = _determinePhase(
      today: today,
      latestRecord: latestRecord,
      avgPeriodDuration: avgPeriodDuration,
      avgCycleLength: avgLength,
      dayOfCycle: dayOfCycle,
    );

    return CycleEstimate(
      reliability: reliability,
      averageCycleLength: avgLength,
      variabilityDays: variability,
      averagePeriodDuration: avgPeriodDuration,
      nextEstimatedPeriodStart: nextStartDate,
      estimatedPeriodWindowStart: windowStart,
      estimatedPeriodWindowEnd: windowEnd,
      daysUntilEstimatedPeriod: daysUntil,
      currentEstimatedPhase: estimatedPhase,
      dayOfCycle: dayOfCycle,
      recordedCyclesCount: cleanRecords.length,
      statusTitle: statusTitle,
      explanationMessage: explanation,
    );
  }

  /// Calculates sample standard deviation or returns a default baseline variability
  int _calculateVariability(List<int> intervals) {
    if (intervals.length < 2) return 2;
    final mean = intervals.reduce((a, b) => a + b) / intervals.length;
    final sumSquares = intervals.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b);
    final variance = sumSquares / (intervals.length - 1);
    final stdDev = sqrt(variance).round();
    // Clamp variability reasonably between 1 and 6 days
    return max(1, min(stdDev, 6));
  }

  bool _isDuringPeriod(
    DateTime today,
    CycleRecord latest,
    double avgDuration,
  ) {
    if (today.isBefore(latest.startDate)) return false;
    if (latest.endDate != null) {
      return !today.isAfter(latest.endDate!);
    }
    final daysSince = AppDateUtils.daysBetween(latest.startDate, today);
    return daysSince >= 0 && daysSince < avgDuration.round();
  }

  CyclePhase _determinePhase({
    required DateTime today,
    required CycleRecord latestRecord,
    required double avgPeriodDuration,
    required double avgCycleLength,
    required int? dayOfCycle,
  }) {
    if (dayOfCycle == null || dayOfCycle <= 0) {
      return CyclePhase.uncertain;
    }

    // 1. Menstrual phase check
    if (_isDuringPeriod(today, latestRecord, avgPeriodDuration)) {
      return CyclePhase.menstrual;
    }

    final cycleLen = avgCycleLength.round();
    final periodDuration = avgPeriodDuration.round();
    final midCycleDay = (avgCycleLength / 2).round();

    // 2. Post-menstrual check
    if (dayOfCycle <= periodDuration) {
      return CyclePhase.menstrual;
    }

    // 3. Ovulatory window estimate: approx midCycleDay - 2 to midCycleDay + 1
    final ovulatoryStart = max(periodDuration + 1, midCycleDay - 2);
    final ovulatoryEnd = min(cycleLen - 7, midCycleDay + 1);

    if (dayOfCycle < ovulatoryStart) {
      return CyclePhase.follicular;
    } else if (dayOfCycle >= ovulatoryStart && dayOfCycle <= ovulatoryEnd) {
      return CyclePhase.ovulatory;
    } else if (dayOfCycle > ovulatoryEnd && dayOfCycle <= cycleLen + 2) {
      return CyclePhase.luteal;
    } else {
      // Past expected cycle length - uncertainty or awaiting period start
      return CyclePhase.uncertain;
    }
  }

  List<CycleRecord> _sanitizeAndSort(List<CycleRecord> records) {
    final valid = records.where((r) {
      if (r.endDate != null && r.endDate!.isBefore(r.startDate)) {
        return false;
      }
      return true;
    }).toList();

    // Sort chronologically by start date
    valid.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Remove duplicates on exact same start date
    final unique = <CycleRecord>[];
    for (final r in valid) {
      if (unique.isEmpty || !AppDateUtils.isSameDay(unique.last.startDate, r.startDate)) {
        unique.add(r);
      }
    }
    return unique;
  }
}
