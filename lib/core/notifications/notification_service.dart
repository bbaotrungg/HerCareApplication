import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/reminders/domain/models/reminder_item.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification service initialization error (expected in some test environments): $e');
    }
  }

  /// Explicitly requests notification permission on Android 13+ (API 33+)
  Future<bool> requestPermissions() async {
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        final granted = await androidPlatform.requestNotificationsPermission();
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  /// Schedules a discreet notification
  Future<void> scheduleDiscreetReminder(ReminderItem reminder) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Android notification details - discreet, high priority, private lock screen visibility
      const androidDetails = AndroidNotificationDetails(
        'hercare_reminders',
        'HerCare Reminders',
        channelDescription: 'Thoughtful, discreet daily check-ins and care reminders',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.private,
        showWhen: true,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.discreetMessage,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Could not schedule notification (handled gracefully): $e');
    }
  }

  /// Cancels a scheduled notification
  Future<void> cancelReminder(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(id: notificationId);
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }

  /// Cancels all notifications
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Cancel all notifications error: $e');
    }
  }
}

