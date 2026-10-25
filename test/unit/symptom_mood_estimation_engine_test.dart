import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/symptoms/domain/services/symptom_mood_estimation_engine.dart';

void main() {
  const engine = SymptomMoodEstimationEngine();

  group('SymptomMoodEstimationEngine - Phase-based estimation', () {
    test('menstrual phase estimates cramps, fatigue, and rest needs', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.cycleInformed,
        averageCycleLength: 29,
        variabilityDays: 2,
        currentEstimatedPhase: CyclePhase.menstrual,
        dayOfCycle: 2,
        recordedCyclesCount: 3,
        statusTitle: 'Cycle-Informed',
        explanationMessage: 'Valid',
      );

      final result = engine.estimate(cycleEstimate: estimate);

      expect(result.hasEstimates, true);
      expect(result.currentPhase, CyclePhase.menstrual);

      // Check physical possibilities
      final physicalLabels = result.physicalPossibilities.map((p) => p.label).toList();
      expect(physicalLabels, contains('Abdominal Cramps'));
      expect(physicalLabels, contains('Lower Energy or Fatigue'));

      // Check emotional possibilities
      final emotionalLabels = result.emotionalPossibilities.map((p) => p.label).toList();
      expect(emotionalLabels, contains('Wanting Extra Rest'));
      expect(result.confidenceBadge, 'Cycle-Informed');
    });

    test('follicular phase estimates rising vitality and balanced mood', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.preliminary,
        averageCycleLength: 28,
        variabilityDays: 2,
        currentEstimatedPhase: CyclePhase.follicular,
        dayOfCycle: 8,
        recordedCyclesCount: 2,
        statusTitle: 'Early Estimate',
        explanationMessage: 'Valid',
      );

      final result = engine.estimate(cycleEstimate: estimate);

      final physicalLabels = result.physicalPossibilities.map((p) => p.label).toList();
      expect(physicalLabels, contains('Rising Energy & Lightness'));

      final emotionalLabels = result.emotionalPossibilities.map((p) => p.label).toList();
      expect(emotionalLabels, contains('Emotionally Balanced'));
    });

    test('late luteal phase estimates bloating, tension, and stress sensitivity', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.cycleInformed,
        averageCycleLength: 28,
        variabilityDays: 2,
        daysUntilEstimatedPeriod: 3, // late luteal
        currentEstimatedPhase: CyclePhase.luteal,
        dayOfCycle: 25,
        recordedCyclesCount: 3,
        statusTitle: 'Cycle-Informed',
        explanationMessage: 'Valid',
      );

      final result = engine.estimate(cycleEstimate: estimate);

      final physicalLabels = result.physicalPossibilities.map((p) => p.label).toList();
      expect(physicalLabels, contains('Bloating or Fullness'));

      final emotionalLabels = result.emotionalPossibilities.map((p) => p.label).toList();
      expect(emotionalLabels, contains('Sensitive to Stress & Overwhelm'));
      expect(emotionalLabels, contains('Preferring Quiet & Space'));
    });

    test('insufficient data handles empty state gracefully', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.insufficient,
        currentEstimatedPhase: CyclePhase.uncertain,
        recordedCyclesCount: 0,
        statusTitle: 'No History',
        explanationMessage: 'None',
      );

      final result = engine.estimate(cycleEstimate: estimate);

      expect(result.hasEstimates, false);
      expect(result.physicalPossibilities, isEmpty);
      expect(result.emotionalPossibilities, isEmpty);
    });

    test('transparentNotice explicitly states that estimates are not confirmed facts', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.limitedInformation,
        averageCycleLength: 28,
        currentEstimatedPhase: CyclePhase.menstrual,
        dayOfCycle: 2,
        recordedCyclesCount: 1,
        statusTitle: 'Limited Information',
        explanationMessage: 'General baseline',
      );

      final result = engine.estimate(cycleEstimate: estimate);

      expect(result.transparentNotice, contains('not confirmed facts'));
      expect(result.transparentNotice, contains('Individual experiences vary'));
    });
  });
}

