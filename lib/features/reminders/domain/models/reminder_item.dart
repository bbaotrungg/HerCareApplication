import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ReminderType {
  dailyCheckIn,
  periodSupplies,
  approachingPeriod,
  custom;

  String get displayName {
    switch (this) {
      case ReminderType.dailyCheckIn:
        return 'Daily Caring Check-in';
      case ReminderType.periodSupplies:
        return 'Check Menstrual Supplies';
      case ReminderType.approachingPeriod:
        return 'Approaching Cycle Window';
      case ReminderType.custom:
        return 'Personal Care Reminder';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderType.dailyCheckIn:
        return Icons.favorite_border;
      case ReminderType.periodSupplies:
        return Icons.inventory_2_outlined;
      case ReminderType.approachingPeriod:
        return Icons.calendar_today_outlined;
      case ReminderType.custom:
        return Icons.alarm_outlined;
    }
  }
}

class ReminderItem {
  final String id;
  final int notificationId;
  final String title;
  final String discreetMessage;
  final ReminderType type;
  final int hour;
  final int minute;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderItem({
    String? id,
    int? notificationId,
    required this.title,
    required this.discreetMessage,
    required this.type,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        notificationId = notificationId ?? (DateTime.now().millisecondsSinceEpoch % 100000),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMin = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMin $period';
  }

  ReminderItem copyWith({
    String? id,
    int? notificationId,
    String? title,
    String? discreetMessage,
    ReminderType? type,
    int? hour,
    int? minute,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderItem(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      discreetMessage: discreetMessage ?? this.discreetMessage,
      type: type ?? this.type,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notification_id': notificationId,
      'title': title,
      'discreet_message': discreetMessage,
      'type': type.name,
      'hour': hour,
      'minute': minute,
      'is_enabled': isEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReminderItem.fromMap(Map<String, dynamic> map) {
    return ReminderItem(
      id: map['id'] as String,
      notificationId: map['notification_id'] as int,
      title: map['title'] as String,
      discreetMessage: map['discreet_message'] as String,
      type: ReminderType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => ReminderType.dailyCheckIn,
      ),
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      isEnabled: (map['is_enabled'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

