import 'package:flutter_test/flutter_test.dart';
import 'package:hercare/features/care/domain/models/care_recommendation.dart';
import 'package:hercare/features/care/domain/services/recommendation_engine.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/notes/domain/models/care_preference.dart';
import 'package:hercare/features/symptoms/domain/models/daily_symptom_mood_estimate.dart';
import 'package:hercare/features/symptoms/domain/services/symptom_mood_estimation_engine.dart';

void main() {
  const estimationEngine = SymptomMoodEstimationEngine();
  const recEngine = RecommendationEngine();

  group('RecommendationEngine - Contextual Natural Language Suggestions', () {
    test('possible cramps trigger warm compress and soothing tea thoughts', () {
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

      final symptomMood = estimationEngine.estimate(cycleEstimate: estimate);
      final List<CareRecommendation> recs = recEngine.generateRecommendations(
        symptomMoodEstimate: symptomMood,
        cycleEstimate: estimate,
      );

      final ids = recs.map((CareRecommendation r) => r.id).toList();
      expect(ids, contains('care_cramps_heat'));
      expect(ids, contains('care_cramps_tea'));

      final heatRec = recs.firstWhere((CareRecommendation r) => r.id == 'care_cramps_heat');
      expect(heatRec.naturalThought, contains('warm up a heating pad or prepare a hot water bottle'));
      expect(heatRec.category, RecommendationCategory.comfort);
    });

    test('possible fatigue triggers chore and dinner relief suggestion', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.cycleInformed,
        averageCycleLength: 29,
        variabilityDays: 2,
        currentEstimatedPhase: CyclePhase.menstrual,
        dayOfCycle: 1,
        recordedCyclesCount: 3,
        statusTitle: 'Cycle-Informed',
        explanationMessage: 'Valid',
      );

      final symptomMood = estimationEngine.estimate(cycleEstimate: estimate);
      final List<CareRecommendation> recs = recEngine.generateRecommendations(
        symptomMoodEstimate: symptomMood,
        cycleEstimate: estimate,
      );

      expect(recs.any((CareRecommendation r) => r.id == 'care_fatigue_chores'), true);
      final choreRec = recs.firstWhere((CareRecommendation r) => r.id == 'care_fatigue_chores');
      expect(choreRec.naturalThought, contains('take care of dinner'));
    });

    test('possible stress sensitivity triggers patient listening without fixing', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.cycleInformed,
        averageCycleLength: 28,
        variabilityDays: 2,
        daysUntilEstimatedPeriod: 3,
        currentEstimatedPhase: CyclePhase.luteal,
        dayOfCycle: 25,
        recordedCyclesCount: 3,
        statusTitle: 'Cycle-Informed',
        explanationMessage: 'Valid',
      );

      final symptomMood = estimationEngine.estimate(cycleEstimate: estimate);
      final List<CareRecommendation> recs = recEngine.generateRecommendations(
        symptomMoodEstimate: symptomMood,
        cycleEstimate: estimate,
      );

      expect(recs.any((CareRecommendation r) => r.id == 'care_listen_patiently'), true);
      final listenRec = recs.firstWhere((CareRecommendation r) => r.id == 'care_listen_patiently');
      expect(listenRec.naturalThought, contains('just listening without immediately trying to solve'));
      expect(listenRec.category, RecommendationCategory.emotionalSupport);
    });

    test('period approaching window triggers discreet supply check', () {
      final approachingEstimate = CycleEstimate(
        reliability: EstimateReliability.cycleInformed,
        averageCycleLength: 28,
        variabilityDays: 2,
        nextEstimatedPeriodStart: DateTime.now().add(const Duration(days: 2)),
        daysUntilEstimatedPeriod: 2,
        currentEstimatedPhase: CyclePhase.luteal,
        recordedCyclesCount: 3,
        statusTitle: 'Cycle-Informed',
        explanationMessage: 'Valid',
      );

      final symptomMood = estimationEngine.estimate(cycleEstimate: approachingEstimate);
      final List<CareRecommendation> recs = recEngine.generateRecommendations(
        symptomMoodEstimate: symptomMood,
        cycleEstimate: approachingEstimate,
      );

      expect(recs.any((CareRecommendation r) => r.id == 'prep_supplies'), true);
      final prepRec = recs.firstWhere((CareRecommendation r) => r.id == 'prep_supplies');
      expect(prepRec.naturalThought, contains('bathroom cabinet'));
      expect(prepRec.category, RecommendationCategory.preparation);
    });

    test('includes saved comfort preferences naturally', () {
      const estimate = CycleEstimate(
        reliability: EstimateReliability.limitedInformation,
        averageCycleLength: 28,
        currentEstimatedPhase: CyclePhase.follicular,
        dayOfCycle: 9,
        recordedCyclesCount: 1,
        statusTitle: 'Limited Information',
        explanationMessage: 'Valid',
      );

      final pref = CarePreference(
        title: 'Dark Chocolate & Chamomile Tea',
        category: 'Favorite Comfort Foods',
        description: 'Her preferred comfort treat',
      );

      final symptomMood = estimationEngine.estimate(cycleEstimate: estimate);
      final List<CareRecommendation> recs = recEngine.generateRecommendations(
        symptomMoodEstimate: symptomMood,
        cycleEstimate: estimate,
        preferences: [pref],
      );

      expect(recs.any((CareRecommendation r) => r.id.contains('pref_')), true);
    });

    test('provides thoughtful general check-in when data is minimal', () {
      const emptyEstimate = CycleEstimate(
        reliability: EstimateReliability.insufficient,
        recordedCyclesCount: 0,
        currentEstimatedPhase: CyclePhase.uncertain,
        statusTitle: 'No History',
        explanationMessage: 'None',
      );

      const emptySymptomMood = DailySymptomMoodEstimate(
        currentPhase: CyclePhase.uncertain,
        physicalPossibilities: [],
        emotionalPossibilities: [],
        reliability: EstimateReliability.insufficient,
        confidenceBadge: 'Awaiting Period Date',
        transparentNotice: 'Awaiting first period date',
      );

      final List<CareRecommendation> recs = recEngine.generateRecommendations(
        symptomMoodEstimate: emptySymptomMood,
        cycleEstimate: emptyEstimate,
      );

      expect(recs.isNotEmpty, true);
      expect(recs.any((CareRecommendation r) => r.id == 'general_gentle_checkin'), true);
      expect(recs.any((CareRecommendation r) => r.id == 'general_water_drink'), true);
    });
  });
}
