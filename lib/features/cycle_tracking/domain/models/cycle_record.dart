import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_utils.dart';

class CycleRecord {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  CycleRecord({
    String? id,
    required DateTime startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        startDate = AppDateUtils.dateOnly(startDate),
        endDate = endDate != null ? AppDateUtils.dateOnly(endDate) : null,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Duration of actual period in days, if end date is recorded
  int? get durationInDays {
    if (endDate == null) return null;
    return AppDateUtils.daysBetween(startDate, endDate!) + 1;
  }

  /// Checks if a given date falls within this confirmed period
  bool containsDate(DateTime date) {
    final d = AppDateUtils.dateOnly(date);
    if (endDate != null) {
      return AppDateUtils.isDateInRange(d, startDate, endDate!);
    }
    // If no end date recorded, start date is confirmed
    return AppDateUtils.isSameDay(d, startDate);
  }

  CycleRecord copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleRecord(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': AppDateUtils.toIsoDateString(startDate),
      'end_date': endDate != null ? AppDateUtils.toIsoDateString(endDate!) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CycleRecord.fromMap(Map<String, dynamic> map) {
    return CycleRecord(
      id: map['id'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

