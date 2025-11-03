import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific habit
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> requestPermissions() async {
    // Request permissions for iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null) return;

    await initialize();

    final time = habit.reminderTime!;
    final now = DateTime.now();

    // Determine which days to schedule based on frequency
    List<int> daysToSchedule = [];
    
    if (habit.frequency == 'daily') {
      // Schedule for all days
      daysToSchedule = [1, 2, 3, 4, 5, 6, 7];
    } else if (habit.frequency == 'specific_days' && habit.specificDays != null) {
      daysToSchedule = habit.specificDays!;
    } else if (habit.frequency == 'no_repeat') {
      // Schedule only for today or tomorrow if time has passed
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      if (scheduledTime.isAfter(now)) {
        await _scheduleNotificationForDateTime(habit, scheduledTime);
      }
      return;
    }

    // Schedule for each day of the week
    for (final day in daysToSchedule) {
      await _scheduleWeeklyNotification(habit, day, time);
    }
  }

  Future<void> _scheduleWeeklyNotification(
    Habit habit,
    int dayOfWeek,
    TimeOfDay time,
  ) async {
    final now = DateTime.now();
    var scheduledDate = _nextInstanceOfDayAndTime(dayOfWeek, time);

    // If the scheduled time is in the past, schedule for next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Use habit.id + dayOfWeek as unique notification ID
    final notificationId = habit.id.hashCode + dayOfWeek;

    await _notifications.zonedSchedule(
      notificationId,
      '${habit.emoji} ${habit.name}',
      'Time to complete your habit! Keep the streak going 🔥',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Reminders for your daily habits',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Habit Reminder',
          color: habit.color,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: habit.id,
    );
  }

  Future<void> _scheduleNotificationForDateTime(
    Habit habit,
    DateTime scheduledDateTime,
  ) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      '${habit.emoji} ${habit.name}',
      'Time to complete your habit!',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Reminders for your habits',
          importance: Importance.high,
          priority: Priority.high,
          color: habit.color,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: habit.id,
    );
  }

  DateTime _nextInstanceOfDayAndTime(int dayOfWeek, TimeOfDay time) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // dayOfWeek: 1 = Monday, 7 = Sunday
    // DateTime.weekday: 1 = Monday, 7 = Sunday (same convention)
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Schedule morning reminder (shown when phone is unlocked between 5 AM - 12 PM)
  Future<void> scheduleMorningReminder(Habit habit) async {
    if (!habit.showMorningReminder) return;

    await initialize();

    final now = DateTime.now();
    
    // Schedule a daily notification at 6 AM as the morning reminder
    // This will be shown when user unlocks their phone in the morning
    final morningTime = TimeOfDay(hour: 6, minute: 0);
    
    // Determine which days to schedule based on frequency
    List<int> daysToSchedule = [];
    
    if (habit.frequency == 'daily') {
      daysToSchedule = [1, 2, 3, 4, 5, 6, 7];
    } else if (habit.frequency == 'specific_days' && habit.specificDays != null) {
      daysToSchedule = habit.specificDays!;
    } else if (habit.frequency == 'no_repeat') {
      // For no_repeat, only schedule for the creation day
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        morningTime.hour,
        morningTime.minute,
      );
      
      if (scheduledTime.isAfter(now)) {
        await _scheduleMorningNotificationForDateTime(habit, scheduledTime);
      }
      return;
    }

    // Schedule for each day of the week
    for (final day in daysToSchedule) {
      await _scheduleMorningWeeklyNotification(habit, day, morningTime);
    }
  }

  Future<void> _scheduleMorningWeeklyNotification(
    Habit habit,
    int dayOfWeek,
    TimeOfDay time,
  ) async {
    final now = DateTime.now();
    var scheduledDate = _nextInstanceOfDayAndTime(dayOfWeek, time);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    // Use habit.id + 1000 + dayOfWeek for morning reminder unique ID
    final notificationId = habit.id.hashCode + 1000 + dayOfWeek;

    final description = habit.description != null && habit.description!.isNotEmpty
        ? habit.description!
        : 'Don\'t forget to complete this habit today!';

    await _notifications.zonedSchedule(
      notificationId,
      '☀️ Good Morning! ${habit.emoji} ${habit.name}',
      description,
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_reminders',
          'Morning Reminders',
          channelDescription: 'Morning reminders when you wake up',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'Morning Reminder',
          color: habit.color,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: habit.id,
    );
  }

  Future<void> _scheduleMorningNotificationForDateTime(
    Habit habit,
    DateTime scheduledDateTime,
  ) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    final description = habit.description != null && habit.description!.isNotEmpty
        ? habit.description!
        : 'Don\'t forget to complete this habit today!';

    await _notifications.zonedSchedule(
      habit.id.hashCode + 1000,
      '☀️ Good Morning! ${habit.emoji} ${habit.name}',
      description,
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_reminders',
          'Morning Reminders',
          channelDescription: 'Morning reminders when you wake up',
          importance: Importance.high,
          priority: Priority.high,
          color: habit.color,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: habit.id,
    );
  }

  Future<void> cancelHabitReminder(Habit habit) async {
    await initialize();

    if (habit.frequency == 'daily' || habit.frequency == 'specific_days') {
      // Cancel all 7 possible notifications (one for each day)
      for (int day = 1; day <= 7; day++) {
        await _notifications.cancel(habit.id.hashCode + day);
        // Also cancel morning reminders
        await _notifications.cancel(habit.id.hashCode + 1000 + day);
      }
    }
    
    // Also cancel the main notification IDs
    await _notifications.cancel(habit.id.hashCode);
    await _notifications.cancel(habit.id.hashCode + 1000);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
