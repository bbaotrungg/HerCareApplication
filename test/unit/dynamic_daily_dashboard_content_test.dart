import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/core/localization/app_language.dart';
import 'package:hercare/features/care/domain/services/recommendation_engine.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/symptoms/domain/services/symptom_mood_estimation_engine.dart';

void main() {
  const symptomEngine = SymptomMoodEstimationEngine();
  const recommendationEngine = RecommendationEngine();

  CycleEstimate buildEstimate({
    required int dayOfCycle,
    required CyclePhase phase,
    int? daysUntilPeriod,
    EstimateReliability reliability = EstimateReliability.cycleInformed,
  }) {
    return CycleEstimate(
      reliability: reliability,
      averageCycleLength: 28,
      variabilityDays: 2,
      currentEstimatedPhase: phase,
      dayOfCycle: dayOfCycle,
      daysUntilEstimatedPeriod: daysUntilPeriod,
      recordedCyclesCount: 3,
      statusTitle: 'Cycle-Informed',
      explanationMessage: 'Calculated with cycle history',
    );
  }

  group('Dynamic Daily Dashboard Content - Day-to-Day Variation', () {
    test('Menstrual phase (Days 1, 2, 3, 5) shows distinct daily symptoms & moods', () {
      final day1 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 1, phase: CyclePhase.menstrual),
      );
      final day2 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 2, phase: CyclePhase.menstrual),
      );
      final day3 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 3, phase: CyclePhase.menstrual),
      );
      final day5 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 5, phase: CyclePhase.menstrual),
      );

      // Verify all days have estimates
      expect(day1.hasEstimates, isTrue);
      expect(day2.hasEstimates, isTrue);
      expect(day3.hasEstimates, isTrue);
      expect(day5.hasEstimates, isTrue);

      // Day 1 vs Day 2: Day 1 focuses on onset/cramps, Day 2 on heavy flow/fatigue
      final d1Physical = day1.physicalPossibilities.map((p) => p.label).toList();
      final d2Physical = day2.physicalPossibilities.map((p) => p.label).toList();
      final d3Physical = day3.physicalPossibilities.map((p) => p.label).toList();
      final d5Physical = day5.physicalPossibilities.map((p) => p.label).toList();

      expect(d1Physical, contains('Abdominal Cramps'));
      expect(d1Physical, contains('Lower Back Discomfort'));
      expect(d2Physical, contains('Abdominal Cramps'));
      expect(d2Physical, contains('Lower Energy or Fatigue'));
      expect(d3Physical, contains('Cramping Easing to Mild Ache'));
      expect(d5Physical, contains('Renewed Physical Stamina'));

      // Day 1 emotional vs Day 5 emotional
      final d1Emotional = day1.emotionalPossibilities.map((p) => p.label).toList();
      final d5Emotional = day5.emotionalPossibilities.map((p) => p.label).toList();
      expect(d1Emotional, contains('Wanting Extra Rest'));
      expect(d5Emotional, contains('Optimistic & Ready for the Week'));

      // Ensure no two consecutive days in menstrual phase produce identical physical label sets
      expect(d1Physical, isNot(equals(d2Physical)));
      expect(d2Physical, isNot(equals(d3Physical)));
      expect(d3Physical, isNot(equals(d5Physical)));
    });

    test('Follicular phase (Days 6, 8, 11) demonstrates energy progression', () {
      final day6 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 6, phase: CyclePhase.follicular),
      );
      final day8 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 8, phase: CyclePhase.follicular),
      );
      final day11 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 11, phase: CyclePhase.follicular),
      );

      final d6Physical = day6.physicalPossibilities.map((p) => p.label).toList();
      final d8Physical = day8.physicalPossibilities.map((p) => p.label).toList();
      final d11Physical = day11.physicalPossibilities.map((p) => p.label).toList();

      expect(d6Physical, contains('Post-Period Vitality Lift'));
      expect(d8Physical, contains('Rising Energy & Lightness'));
      expect(d11Physical, contains('Pre-Ovulation Glow & Agility'));

      expect(d6Physical, isNot(equals(d8Physical)));
      expect(d8Physical, isNot(equals(d11Physical)));
    });

    test('Ovulation phase (Days 13, 14, 15) reflects mid-cycle peak & transition', () {
      final day13 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 13, phase: CyclePhase.ovulatory),
      );
      final day14 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 14, phase: CyclePhase.ovulatory),
      );
      final day15 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 15, phase: CyclePhase.ovulatory),
      );

      final d13Physical = day13.physicalPossibilities.map((p) => p.label).toList();
      final d14Physical = day14.physicalPossibilities.map((p) => p.label).toList();
      final d15Physical = day15.physicalPossibilities.map((p) => p.label).toList();

      expect(d13Physical, contains('Peak Vitality & Energy'));
      expect(d14Physical, contains('Mild Mid-Cycle Sensation'));
      expect(d15Physical, contains('Post-Ovulatory Transition'));

      expect(d14Physical, isNot(equals(d15Physical)));
    });

    test('Luteal phase (Days 17, 21, 24, 27) progresses from calm to premenstrual awareness', () {
      final day17 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 17, phase: CyclePhase.luteal),
      );
      final day21 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 21, phase: CyclePhase.luteal),
      );
      final day24 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 24, phase: CyclePhase.luteal),
      );
      final day27 = symptomEngine.estimate(
        cycleEstimate: buildEstimate(dayOfCycle: 27, phase: CyclePhase.luteal),
      );

      final d17Physical = day17.physicalPossibilities.map((p) => p.label).toList();
      final d21Physical = day21.physicalPossibilities.map((p) => p.label).toList();
      final d24Physical = day24.physicalPossibilities.map((p) => p.label).toList();
      final d27Physical = day27.physicalPossibilities.map((p) => p.label).toList();

      expect(d17Physical, contains('Steady Energy & Comfort'));
      expect(d21Physical, contains('Subtle Fluid Shift & Early Sensitivity'));
      expect(d24Physical, contains('Bloating or Fullness'));
      expect(d27Physical, contains('Pre-Menstrual Twinges & Dull Pelvic Ache'));

      // Check emotional variation
      final d17Emotional = day17.emotionalPossibilities.map((p) => p.label).toList();
      final d24Emotional = day24.emotionalPossibilities.map((p) => p.label).toList();
      expect(d17Emotional, contains('Grounded & Reflective'));
      expect(d24Emotional, contains('Sensitive to Stress & Overwhelm'));
    });
  });

  group('Dynamic Daily Care Suggestions - Human Tone & Non-Repetition', () {
    test('Consecutive days receive distinct, non-repetitive care suggestions', () {
      final estDay1 = buildEstimate(dayOfCycle: 1, phase: CyclePhase.menstrual);
      final symDay1 = symptomEngine.estimate(cycleEstimate: estDay1);

      final estDay2 = buildEstimate(dayOfCycle: 2, phase: CyclePhase.menstrual);
      final symDay2 = symptomEngine.estimate(cycleEstimate: estDay2);

      final estDay3 = buildEstimate(dayOfCycle: 3, phase: CyclePhase.menstrual);
      final symDay3 = symptomEngine.estimate(cycleEstimate: estDay3);

      final recsDay1 = recommendationEngine.generateRecommendations(
        cycleEstimate: estDay1,
        symptomMoodEstimate: symDay1,
      );
      final recsDay2 = recommendationEngine.generateRecommendations(
        cycleEstimate: estDay2,
        symptomMoodEstimate: symDay2,
      );
      final recsDay3 = recommendationEngine.generateRecommendations(
        cycleEstimate: estDay3,
        symptomMoodEstimate: symDay3,
      );

      expect(recsDay1, isNotEmpty);
      expect(recsDay2, isNotEmpty);
      expect(recsDay3, isNotEmpty);

      // Verify IDs vary across days
      final idsDay1 = recsDay1.map((r) => r.id).toList();
      final idsDay2 = recsDay2.map((r) => r.id).toList();
      final idsDay3 = recsDay3.map((r) => r.id).toList();

      expect(idsDay1, isNot(equals(idsDay2)));
      expect(idsDay2, isNot(equals(idsDay3)));

      // Day 1 has Day 1 tea
      expect(idsDay1, contains('care_day1_tea'));
      // Day 2 has cramps tea
      expect(idsDay2, contains('care_cramps_tea'));
      // Day 3 has chamomile tea & cozy evening
      expect(idsDay3, contains('care_day3_chamomile'));
    });

    test('Care suggestions have empathetic, respectful, and human-centered wording', () {
      final est = buildEstimate(dayOfCycle: 25, phase: CyclePhase.luteal);
      final sym = symptomEngine.estimate(cycleEstimate: est);
      final recs = recommendationEngine.generateRecommendations(
        cycleEstimate: est,
        symptomMoodEstimate: sym,
      );

      expect(recs, isNotEmpty);
      for (final rec in recs) {
        expect(rec.naturalThought, isNotEmpty);
        expect(rec.contextBasis, isNotEmpty);
        // Ensure no clinical or robotic jargon
        expect(rec.naturalThought.toLowerCase(), isNot(contains('diagnostic')));
        expect(rec.naturalThought.toLowerCase(), isNot(contains('prescribe')));
        expect(rec.naturalThought.toLowerCase(), isNot(contains('patient')));
      }
    });

    test('Transparent labels are always included on daily estimates', () {
      final est = buildEstimate(dayOfCycle: 14, phase: CyclePhase.ovulatory);
      final symEstimate = symptomEngine.estimate(cycleEstimate: est);

      expect(symEstimate.transparentNotice, contains('possibilities'));
      expect(symEstimate.transparentNotice, contains('not confirmed facts'));
      expect(symEstimate.confidenceBadge, isNotEmpty);
    });
  });

  group('Bilingual Daily Content (English & Vietnamese)', () {
    test('Symptoms and moods are fully localized in Vietnamese', () {
      const daysToSample = [1, 2, 7, 14, 21, 25];
      for (final day in daysToSample) {
        final phase = day <= 5
            ? CyclePhase.menstrual
            : day <= 12
                ? CyclePhase.follicular
                : day <= 15
                    ? CyclePhase.ovulatory
                    : CyclePhase.luteal;

        final est = buildEstimate(dayOfCycle: day, phase: phase);
        final viResult = symptomEngine.estimate(
          cycleEstimate: est,
          language: AppLanguage.vi,
        );

        expect(viResult.hasEstimates, isTrue);
        expect(viResult.physicalPossibilities, isNotEmpty);
        expect(viResult.emotionalPossibilities, isNotEmpty);

        // Check Vietnamese notice
        expect(viResult.transparentNotice, contains('khả năng thường gặp'));
        expect(viResult.transparentNotice, contains('không khẳng định chính xác'));

        // Check each possibility has non-empty label and natural explanation in Vietnamese
        for (final p in viResult.physicalPossibilities) {
          expect(p.label, isNotEmpty);
          expect(p.naturalExplanation, isNotEmpty);
          expect(p.likelihoodContext, isNotEmpty);
        }
        for (final p in viResult.emotionalPossibilities) {
          expect(p.label, isNotEmpty);
          expect(p.naturalExplanation, isNotEmpty);
          expect(p.likelihoodContext, isNotEmpty);
        }
      }
    });

    test('Care suggestions are fully localized in Vietnamese across cycle days', () {
      const daysToSample = [1, 2, 8, 14, 19, 25];
      for (final day in daysToSample) {
        final phase = day <= 5
            ? CyclePhase.menstrual
            : day <= 12
                ? CyclePhase.follicular
                : day <= 15
                    ? CyclePhase.ovulatory
                    : CyclePhase.luteal;

        final est = buildEstimate(dayOfCycle: day, phase: phase);
        final sym = symptomEngine.estimate(cycleEstimate: est, language: AppLanguage.vi);
        final viRecs = recommendationEngine.generateRecommendations(
          cycleEstimate: est,
          symptomMoodEstimate: sym,
          language: AppLanguage.vi,
        );

        expect(viRecs, isNotEmpty);
        for (final rec in viRecs) {
          expect(rec.contextBasis, isNotEmpty);
          expect(rec.naturalThought, isNotEmpty);
          if (rec.gentleContext != null) {
            expect(rec.gentleContext, isNotEmpty);
          }
        }
      }
    });
  });
}
