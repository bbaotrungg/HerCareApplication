import 'package:flutter/material.dart';

enum RecommendationCategory {
  comfort,
  practicalHelp,
  emotionalSupport,
  preparation,
  connection,
}

class CareRecommendation {
  final String id;
  final String naturalThought; // e.g. "Maybe check in with her gently and ask how her day is going."
  final String? gentleContext; // e.g. "Warmth eases pelvic tension if cramping occurs."
  final String contextBasis; // e.g. "Possible cramps today", "Estimated Menstrual Phase", "Saved preference"
  final RecommendationCategory category;
  final IconData icon;

  const CareRecommendation({
    required this.id,
    required this.naturalThought,
    this.gentleContext,
    required this.contextBasis,
    required this.category,
    required this.icon,
  });
}
