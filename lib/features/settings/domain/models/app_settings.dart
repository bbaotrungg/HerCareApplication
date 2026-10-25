import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';

class AppSettings {
  final ThemeMode themeMode;
  final AppLanguage language;
  final String partnerName;
  final bool notificationsEnabled;
  final int dailyCheckInHour;
  final int dailyCheckInMinute;
  final bool supplyReminderEnabled;
  final bool cycleEstimateReminderEnabled;
  final bool onboardingCompleted;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.en,
    this.partnerName = '',
    this.notificationsEnabled = false,
    this.dailyCheckInHour = 9,
    this.dailyCheckInMinute = 0,
    this.supplyReminderEnabled = true,
    this.cycleEstimateReminderEnabled = false,
    this.onboardingCompleted = false,
  });

  String get greetingName => partnerName.trim().isEmpty ? 'Partner' : partnerName.trim();

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    String? partnerName,
    bool? notificationsEnabled,
    int? dailyCheckInHour,
    int? dailyCheckInMinute,
    bool? supplyReminderEnabled,
    bool? cycleEstimateReminderEnabled,
    bool? onboardingCompleted,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      partnerName: partnerName ?? this.partnerName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyCheckInHour: dailyCheckInHour ?? this.dailyCheckInHour,
      dailyCheckInMinute: dailyCheckInMinute ?? this.dailyCheckInMinute,
      supplyReminderEnabled: supplyReminderEnabled ?? this.supplyReminderEnabled,
      cycleEstimateReminderEnabled:
          cycleEstimateReminderEnabled ?? this.cycleEstimateReminderEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

