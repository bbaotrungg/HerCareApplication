import 'package:flutter/material.dart';

enum SymptomIntensity {
  mild,
  moderate,
  severe;

  String get displayName {
    switch (this) {
      case SymptomIntensity.mild:
        return 'Mild';
      case SymptomIntensity.moderate:
        return 'Moderate';
      case SymptomIntensity.severe:
        return 'Severe';
    }
  }

  Color get color {
    switch (this) {
      case SymptomIntensity.mild:
        return const Color(0xFF8FA998); // soft sage
      case SymptomIntensity.moderate:
        return const Color(0xFFD49A6A); // warm amber
      case SymptomIntensity.severe:
        return const Color(0xFFC75D6E); // rose/crimson
    }
  }
}

enum SymptomType {
  cramps,
  bloating,
  fatigue,
  headache,
  backDiscomfort,
  breastTenderness,
  nausea,
  digestiveChanges,
  other;

  String get displayName {
    switch (this) {
      case SymptomType.cramps:
        return 'Abdominal Cramps';
      case SymptomType.bloating:
        return 'Bloating';
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.headache:
        return 'Headache';
      case SymptomType.backDiscomfort:
        return 'Back Discomfort';
      case SymptomType.breastTenderness:
        return 'Breast Tenderness';
      case SymptomType.nausea:
        return 'Nausea';
      case SymptomType.digestiveChanges:
        return 'Digestive Changes';
      case SymptomType.other:
        return 'Other Physical Sensation';
    }
  }

  IconData get icon {
    switch (this) {
      case SymptomType.cramps:
        return Icons.waves;
      case SymptomType.bloating:
        return Icons.bubble_chart_outlined;
      case SymptomType.fatigue:
        return Icons.battery_2_bar_outlined;
      case SymptomType.headache:
        return Icons.psychology_outlined;
      case SymptomType.backDiscomfort:
        return Icons.accessibility_new_outlined;
      case SymptomType.breastTenderness:
        return Icons.favorite_border;
      case SymptomType.nausea:
        return Icons.sentiment_dissatisfied_outlined;
      case SymptomType.digestiveChanges:
        return Icons.restaurant_outlined;
      case SymptomType.other:
        return Icons.healing_outlined;
    }
  }
}

class SymptomEntry {
  final SymptomType type;
  final SymptomIntensity intensity;

  const SymptomEntry({
    required this.type,
    this.intensity = SymptomIntensity.mild,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'intensity': intensity.name,
    };
  }

  factory SymptomEntry.fromMap(Map<String, dynamic> map) {
    return SymptomEntry(
      type: SymptomType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SymptomType.other,
      ),
      intensity: SymptomIntensity.values.firstWhere(
        (e) => e.name == map['intensity'],
        orElse: () => SymptomIntensity.mild,
      ),
    );
  }
}

