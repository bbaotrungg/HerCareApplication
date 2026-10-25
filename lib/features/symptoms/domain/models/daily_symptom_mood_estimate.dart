import 'package:hercare/features/cycle_tracking/domain/models/cycle_estimate.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_phase.dart';
import 'package:hercare/features/symptoms/domain/models/symptom_possibility.dart';

class DailySymptomMoodEstimate {
  final CyclePhase currentPhase;
  final int? dayOfCycle;
  final List<SymptomPossibility> physicalPossibilities;
  final List<SymptomPossibility> emotionalPossibilities;
  final EstimateReliability reliability;
  final String confidenceBadge;
  final String transparentNotice;

  const DailySymptomMoodEstimate({
    required this.currentPhase,
    this.dayOfCycle,
    required this.physicalPossibilities,
    required this.emotionalPossibilities,
    required this.reliability,
    required this.confidenceBadge,
    required this.transparentNotice,
  });

  bool get hasEstimates =>
      physicalPossibilities.isNotEmpty || emotionalPossibilities.isNotEmpty;
}
