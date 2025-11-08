import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Callbacks for notification actions
  static Function(String habitId)? onCompleteFromNotification;
  static Function(String habitId, int minutes)? onSnoozeFromNotification;
  static Function(String habitId)? onOpenHabitFromNotification;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings with notification icon
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@drawable/app_icon');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    debugPrint('Notification action: ${response.actionId}, payload: $payload');

    // Handle different actions
    switch (response.actionId) {
      case 'complete':
        onCompleteFromNotification?.call(payload);
        break;
      case 'snooze_15':
        onSnoozeFromNotification?.call(payload, 15);
        break;
      case 'snooze_1h':
        onSnoozeFromNotification?.call(payload, 60);
        break;
      case 'snooze_3h':
        onSnoozeFromNotification?.call(payload, 180);
        break;
      default:
        // Default tap - open habit
        onOpenHabitFromNotification?.call(payload);
    }
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleHabitReminder({
    required int id,
    required String habitId,
    required String habitName,
    required TimeOfDay time,
    String? habitEmoji,
    String? description,
  }) async {
    await initialize();
    
    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      debugPrint('Notification permission denied');
      return;
    }

    // Cancel existing notification for this habit
    await _notifications.cancel(id);

    // Schedule daily notification
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

    // Google Tasks-style notification with action buttons
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/app_icon',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: const Color(0xFFFF6B35),
      styleInformation: BigTextStyleInformation(
        description ?? 'Tap to mark as complete or snooze for later',
        htmlFormatBigText: true,
        contentTitle: '${habitEmoji ?? '🔥'} Time for $habitName!',
        htmlFormatContentTitle: true,
      ),
      actions: [
        const AndroidNotificationAction(
          'complete',
          '✓ Complete',
          icon: DrawableResourceAndroidBitmap('@drawable/app_icon'),
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_15',
          '🕐 15 min',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_1h',
          '🕐 1 hour',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_3h',
          '🕐 3 hours',
          showsUserInterface: false,
        ),
      ],
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      ongoing: false,
      autoCancel: true,
      fullScreenIntent: false,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'habitReminder',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '${habitEmoji ?? '🔥'} Time for $habitName!',
      description ?? 'Keep your streak going! Complete this habit now.',
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: habitId, // Pass habit ID as payload
    );

    debugPrint('Scheduled Google Tasks-style notification for $habitName at ${time.hour}:${time.minute}');
  }

  Future<void> snoozeNotification({
    required int id,
    required String habitId,
    required String habitName,
    required int minutes,
    String? habitEmoji,
    String? description,
  }) async {
    await initialize();

    // Cancel existing notification
    await _notifications.cancel(id);

    // Schedule for later
    final scheduledDate = DateTime.now().add(Duration(minutes: minutes));
    final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Daily reminders for your habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/app_icon',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: const Color(0xFFFF6B35),
      styleInformation: BigTextStyleInformation(
        description ?? 'Snoozed reminder - time to complete your habit!',
        htmlFormatBigText: true,
        contentTitle: '${habitEmoji ?? '🔥'} $habitName (Snoozed)',
        htmlFormatContentTitle: true,
      ),
      actions: [
        const AndroidNotificationAction(
          'complete',
          '✓ Complete',
          icon: DrawableResourceAndroidBitmap('@drawable/app_icon'),
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_15',
          '🕐 15 min',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_1h',
          '🕐 1 hour',
          showsUserInterface: false,
        ),
      ],
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      ongoing: false,
      autoCancel: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '${habitEmoji ?? '🔥'} $habitName (Reminder)',
      description ?? 'Your snoozed reminder is ready!',
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: habitId,
    );

    debugPrint('Snoozed notification for $habitName for $minutes minutes');
  }

  Future<void> cancelHabitReminder(int id) async {
    await _notifications.cancel(id);
    debugPrint('Cancelled notification $id');
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    debugPrint('Cancelled all notifications');
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      'Instant Notifications',
      channelDescription: 'Immediate notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/app_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
