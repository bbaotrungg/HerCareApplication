import 'package:flutter/material.dart';

enum PossibilityType {
  physical,
  emotional,
}

class SymptomPossibility {
  final String label;
  final String naturalExplanation;
  final IconData icon;
  final PossibilityType type;
  final String likelihoodContext; // e.g. "Typical during menstruation", "Possible during luteal phase"

  const SymptomPossibility({
    required this.label,
    required this.naturalExplanation,
    required this.icon,
    this.type = PossibilityType.physical,
    required this.likelihoodContext,
  });

  bool get isPhysical => type == PossibilityType.physical;
  bool get isEmotional => type == PossibilityType.emotional;
}

