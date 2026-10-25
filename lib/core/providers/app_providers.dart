import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/app_database.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/notifications/notification_service.dart';
import '../../features/care/domain/models/care_recommendation.dart';
import '../../features/care/domain/services/recommendation_engine.dart';
import '../../features/cycle_tracking/domain/models/cycle_estimate.dart';
import '../../features/cycle_tracking/domain/models/cycle_record.dart';
import '../../features/cycle_tracking/domain/services/cycle_calculation_engine.dart';
import '../../features/notes/domain/models/care_preference.dart';
import '../../features/notes/domain/models/personal_note.dart';
import '../../features/reminders/domain/models/reminder_item.dart';
import '../../features/settings/domain/models/app_settings.dart';
import '../../features/symptoms/domain/models/daily_observation.dart';
import '../../features/symptoms/domain/models/daily_symptom_mood_estimate.dart';
import '../../features/symptoms/domain/services/symptom_mood_estimation_engine.dart';

// --- Database & Utility Providers ---
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);
final cycleEngineProvider = Provider<CycleCalculationEngine>((ref) => const CycleCalculationEngine());
final symptomMoodEngineProvider =
    Provider<SymptomMoodEstimationEngine>((ref) => const SymptomMoodEstimationEngine());
final recommendationEngineProvider =
    Provider<RecommendationEngine>((ref) => const RecommendationEngine());
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);

// --- Selected Date Notifier ---
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

// --- Cycle Records AsyncNotifier ---
class CycleRecordsNotifier extends AsyncNotifier<List<CycleRecord>> {
  @override
  Future<List<CycleRecord>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getAllCycleRecords();
  }

  Future<void> addOrUpdate(CycleRecord record) async {
    final db = ref.read(databaseProvider);
    await db.saveCycleRecord(record);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteCycleRecord(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadRecords() async {
    ref.invalidateSelf();
    await future;
  }
}

final cycleRecordsProvider =
    AsyncNotifierProvider<CycleRecordsNotifier, List<CycleRecord>>(CycleRecordsNotifier.new);

// --- Cycle Estimate Computed Provider ---
final cycleEstimateProvider = Provider<CycleEstimate>((ref) {
  final recordsAsync = ref.watch(cycleRecordsProvider);
  final engine = ref.watch(cycleEngineProvider);

  return recordsAsync.when(
    data: (records) => engine.calculate(records: records),
    loading: () => engine.calculate(records: []),
    error: (_, _) => engine.calculate(records: []),
  );
});

// --- Daily Symptom & Mood Estimate Computed Provider ---
final dailySymptomMoodEstimateProvider = Provider<DailySymptomMoodEstimate>((ref) {
  final cycleEstimate = ref.watch(cycleEstimateProvider);
  final language = ref.watch(appLanguageProvider);
  final engine = ref.watch(symptomMoodEngineProvider);

  return engine.estimate(cycleEstimate: cycleEstimate, language: language);
});

// --- Daily Observations AsyncNotifier (Optional Manual Logs) ---
class DailyObservationsNotifier extends AsyncNotifier<List<DailyObservation>> {
  @override
  Future<List<DailyObservation>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getAllObservations();
  }

  Future<void> save(DailyObservation obs) async {
    final db = ref.read(databaseProvider);
    await db.saveObservation(obs);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteObservation(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadObservations() async {
    ref.invalidateSelf();
    await future;
  }
}

final dailyObservationsProvider =
    AsyncNotifierProvider<DailyObservationsNotifier, List<DailyObservation>>(
        DailyObservationsNotifier.new);

// --- Personal Notes AsyncNotifier ---
class PersonalNotesNotifier extends AsyncNotifier<List<PersonalNote>> {
  @override
  Future<List<PersonalNote>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getAllNotes();
  }

  Future<void> save(PersonalNote note) async {
    final db = ref.read(databaseProvider);
    await db.saveNote(note);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteNote(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadNotes() async {
    ref.invalidateSelf();
    await future;
  }
}

final personalNotesProvider =
    AsyncNotifierProvider<PersonalNotesNotifier, List<PersonalNote>>(
        PersonalNotesNotifier.new);

// --- Care Preferences AsyncNotifier ---
class CarePreferencesNotifier extends AsyncNotifier<List<CarePreference>> {
  @override
  Future<List<CarePreference>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getAllPreferences();
  }

  Future<void> save(CarePreference pref) async {
    final db = ref.read(databaseProvider);
    await db.savePreference(pref);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id) async {
    final db = ref.read(databaseProvider);
    await db.deletePreference(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadPreferences() async {
    ref.invalidateSelf();
    await future;
  }
}

final carePreferencesProvider =
    AsyncNotifierProvider<CarePreferencesNotifier, List<CarePreference>>(
        CarePreferencesNotifier.new);

// --- Reminders AsyncNotifier ---
class RemindersNotifier extends AsyncNotifier<List<ReminderItem>> {
  @override
  Future<List<ReminderItem>> build() async {
    final db = ref.watch(databaseProvider);
    final list = await db.getAllReminders();
    if (list.isEmpty) {
      final defaultReminders = [
        ReminderItem(
          title: 'Daily Caring Check-in',
          discreetMessage: 'Thoughtful moment: check in on her comfort today.',
          type: ReminderType.dailyCheckIn,
          hour: 9,
          minute: 0,
          isEnabled: false,
        ),
        ReminderItem(
          title: 'Menstrual Supplies Check',
          discreetMessage: 'Discreet check: see if bathroom supplies need replenishing.',
          type: ReminderType.periodSupplies,
          hour: 18,
          minute: 30,
          isEnabled: false,
        ),
      ];
      for (final r in defaultReminders) {
        await db.saveReminder(r);
      }
      return defaultReminders;
    }
    return list;
  }

  Future<void> toggleReminder(ReminderItem reminder, bool enabled) async {
    final db = ref.read(databaseProvider);
    final notifications = ref.read(notificationServiceProvider);
    final updated = reminder.copyWith(isEnabled: enabled);
    await db.saveReminder(updated);
    if (enabled) {
      await notifications.requestPermissions();
      await notifications.scheduleDiscreetReminder(updated);
    } else {
      await notifications.cancelReminder(updated.notificationId);
    }
    ref.invalidateSelf();
    await future;
  }

  Future<void> save(ReminderItem item) async {
    final db = ref.read(databaseProvider);
    final notifications = ref.read(notificationServiceProvider);
    await db.saveReminder(item);
    if (item.isEnabled) {
      await notifications.scheduleDiscreetReminder(item);
    }
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String id, int notificationId) async {
    final db = ref.read(databaseProvider);
    final notifications = ref.read(notificationServiceProvider);
    await notifications.cancelReminder(notificationId);
    await db.deleteReminder(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadReminders() async {
    ref.invalidateSelf();
    await future;
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, List<ReminderItem>>(
        RemindersNotifier.new);

// --- Care Recommendations Computed Provider ---
final careRecommendationsProvider = Provider<List<CareRecommendation>>((ref) {
  final estimate = ref.watch(cycleEstimateProvider);
  final symptomMoodEstimate = ref.watch(dailySymptomMoodEstimateProvider);
  final preferences = ref.watch(carePreferencesProvider).value ?? [];
  final language = ref.watch(appLanguageProvider);
  final engine = ref.watch(recommendationEngineProvider);

  return engine.generateRecommendations(
    symptomMoodEstimate: symptomMoodEstimate,
    cycleEstimate: estimate,
    preferences: preferences,
    language: language,
  );
});

// --- App Language & Localizations Providers ---
final appLanguageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(appSettingsProvider).language;
});

final appLocalizationsProvider = Provider<AppLocalizations>((ref) {
  final language = ref.watch(appLanguageProvider);
  return AppLocalizations.ofLanguage(language);
});

// --- App Settings Notifier ---
class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _keyTheme = 'setting_theme';
  static const _keyLanguage = 'setting_language_code';
  static const _keyPartnerName = 'setting_partner_name';
  static const _keyOnboardingDone = 'setting_onboarding_done';

  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_keyTheme) ?? 0;
      final langCode = prefs.getString(_keyLanguage);
      final language = AppLanguage.fromCode(langCode);
      final partnerName = prefs.getString(_keyPartnerName) ?? '';
      final onboardingDone = prefs.getBool(_keyOnboardingDone) ?? false;

      state = AppSettings(
        themeMode: ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)],
        language: language,
        partnerName: partnerName,
        onboardingCompleted: onboardingDone,
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language.code);
  }

  Future<void> setPartnerName(String name) async {
    state = state.copyWith(partnerName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPartnerName, name);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  Future<void> resetAllSettings() async {
    state = const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
