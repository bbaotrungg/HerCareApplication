import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_utils.dart';
import 'emotional_state.dart';
import 'symptom_type.dart';

enum ObservationSource {
  reportedByPartner,
  observedAndDiscussed;

  String get displayName {
    switch (this) {
      case ObservationSource.reportedByPartner:
        return 'Voluntarily shared by partner';
      case ObservationSource.observedAndDiscussed:
        return 'Observed & discussed with her';
    }
  }
}

class DailyObservation {
  final String id;
  final DateTime date;
  final List<SymptomEntry> symptoms;
  final List<EmotionalState> emotionalStates;
  final String? note;
  final ObservationSource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyObservation({
    String? id,
    required DateTime date,
    List<SymptomEntry>? symptoms,
    List<EmotionalState>? emotionalStates,
    this.note,
    this.source = ObservationSource.reportedByPartner,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        date = AppDateUtils.dateOnly(date),
        symptoms = symptoms ?? const [],
        emotionalStates = emotionalStates ?? const [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DailyObservation copyWith({
    String? id,
    DateTime? date,
    List<SymptomEntry>? symptoms,
    List<EmotionalState>? emotionalStates,
    String? note,
    ObservationSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyObservation(
      id: id ?? this.id,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      emotionalStates: emotionalStates ?? this.emotionalStates,
      note: note ?? this.note,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': AppDateUtils.toIsoDateString(date),
      'symptoms_json': jsonEncode(symptoms.map((s) => s.toMap()).toList()),
      'emotions_json': jsonEncode(emotionalStates.map((e) => e.name).toList()),
      'note': note,
      'source': source.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DailyObservation.fromMap(Map<String, dynamic> map) {
    List<SymptomEntry> parsedSymptoms = [];
    if (map['symptoms_json'] != null) {
      try {
        final decoded = jsonDecode(map['symptoms_json'] as String) as List;
        parsedSymptoms = decoded
            .map((item) => SymptomEntry.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    List<EmotionalState> parsedEmotions = [];
    if (map['emotions_json'] != null) {
      try {
        final decoded = jsonDecode(map['emotions_json'] as String) as List;
        parsedEmotions = decoded
            .map((name) => EmotionalState.values.firstWhere(
                  (e) => e.name == name,
                  orElse: () => EmotionalState.comfortable,
                ))
            .toList();
      } catch (_) {}
    }

    return DailyObservation(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      symptoms: parsedSymptoms,
      emotionalStates: parsedEmotions,
      note: map['note'] as String?,
      source: ObservationSource.values.firstWhere(
        (s) => s.name == map['source'],
        orElse: () => ObservationSource.reportedByPartner,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

