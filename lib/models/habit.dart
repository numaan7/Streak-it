import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String name;
  final String? description;
  final String emoji;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final String frequency; // daily, weekly, specific_days, no_repeat
  final int targetDays; // for weekly habits
  final Color color;
  final String? category;
  final Map<String, String> notes; // date -> note
  final List<int>? specificDays; // List of weekday numbers (1=Monday, 7=Sunday)
  final TimeOfDay? reminderTime; // Time for reminder
  final bool showMorningReminder; // Show notification on phone unlock in morning (5 AM - 12 PM)
  bool isArchived;

  Habit({
    String? id,
    required this.name,
    this.description,
    this.emoji = '🎯',
    DateTime? createdAt,
    List<DateTime>? completedDates,
    this.frequency = 'daily',
    this.targetDays = 7,
    required this.color,
    this.category,
    Map<String, String>? notes,
    this.specificDays,
    this.reminderTime,
    this.showMorningReminder = false,
    this.isArchived = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        completedDates = completedDates ?? [],
        notes = notes ?? {};

  // Check if habit is scheduled for a specific date
  bool isScheduledFor(DateTime date) {
    switch (frequency) {
      case 'daily':
        return true;
      case 'no_repeat':
        return _isSameDay(date, createdAt);
      case 'specific_days':
        if (specificDays == null || specificDays!.isEmpty) return false;
        final weekday = date.weekday; // 1=Monday, 7=Sunday
        return specificDays!.contains(weekday);
      default:
        return true;
    }
  }

  // Check if habit is completed today
  bool get isCompletedToday {
    final now = DateTime.now();
    return completedDates.any((date) =>
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
  }

  // Check if habit is scheduled for today
  bool get isScheduledToday {
    return isScheduledFor(DateTime.now());
  }

  // Calculate current streak
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = _normalizeDate(DateTime.now());

    // If not completed today, start from yesterday
    if (!isCompletedToday) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (var date in sortedDates) {
      final normalizedDate = _normalizeDate(date);
      if (_isSameDay(normalizedDate, checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (normalizedDate.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  // Calculate longest streak
  int get longestStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(completedDates)
      ..sort((a, b) => a.compareTo(b));

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prevDate = _normalizeDate(sortedDates[i - 1]);
      final currentDate = _normalizeDate(sortedDates[i]);
      final difference = currentDate.difference(prevDate).inDays;

      if (difference == 1) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else if (difference > 1) {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  // Calculate completion rate (last 30 days)
  double get completionRate {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    int daysInRange = 0;
    int completedInRange = 0;

    for (int i = 0; i < 30; i++) {
      final checkDate = now.subtract(Duration(days: i));
      if (checkDate.isAfter(createdAt) || _isSameDay(checkDate, createdAt)) {
        daysInRange++;
        if (completedDates.any((date) => _isSameDay(date, checkDate))) {
          completedInRange++;
        }
      }
    }

    return daysInRange > 0 ? completedInRange / daysInRange : 0.0;
  }

  // Total completions
  int get totalCompletions => completedDates.length;

  // Helper methods
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check if completed on a specific date
  bool isCompletedOnDate(DateTime date) {
    return completedDates.any((completedDate) => _isSameDay(completedDate, date));
  }

  // Toggle completion for today
  void toggleToday() {
    final now = DateTime.now();
    final todayNormalized = _normalizeDate(now);

    if (isCompletedToday) {
      completedDates.removeWhere((date) => _isSameDay(date, now));
    } else {
      completedDates.add(todayNormalized);
    }
  }

  // Add note for a specific date
  void addNote(DateTime date, String note) {
    final key = _normalizeDate(date).toIso8601String();
    notes[key] = note;
  }

  // Get note for a specific date
  String? getNote(DateTime date) {
    final key = _normalizeDate(date).toIso8601String();
    return notes[key];
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'frequency': frequency,
      'targetDays': targetDays,
      'color': color.value,
      'category': category,
      'notes': notes,
      'specificDays': specificDays,
      'reminderTime': reminderTime != null
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
      'showMorningReminder': showMorningReminder,
      'isArchived': isArchived,
    };
  }

  // Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    TimeOfDay? reminderTime;
    if (json['reminderTime'] != null) {
      final timeData = json['reminderTime'] as Map<String, dynamic>;
      reminderTime = TimeOfDay(
        hour: timeData['hour'] as int,
        minute: timeData['minute'] as int,
      );
    }

    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'] ?? '🎯',
      createdAt: DateTime.parse(json['createdAt']),
      completedDates: (json['completedDates'] as List?)
          ?.map((d) => DateTime.parse(d as String))
          .toList(),
      frequency: json['frequency'] ?? 'daily',
      targetDays: json['targetDays'] ?? 7,
      color: Color(json['color']),
      category: json['category'],
      notes: json['notes'] != null 
          ? Map<String, String>.from(json['notes'])
          : {},
      specificDays: json['specificDays'] != null
          ? List<int>.from(json['specificDays'])
          : null,
      reminderTime: reminderTime,
      showMorningReminder: json['showMorningReminder'] ?? false,
      isArchived: json['isArchived'] ?? false,
    );
  }

  // Copy with method
  Habit copyWith({
    String? name,
    String? description,
    String? emoji,
    List<DateTime>? completedDates,
    String? frequency,
    int? targetDays,
    Color? color,
    String? category,
    Map<String, String>? notes,
    List<int>? specificDays,
    TimeOfDay? reminderTime,
    bool? showMorningReminder,
    bool? isArchived,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt,
      completedDates: completedDates ?? List.from(this.completedDates),
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      color: color ?? this.color,
      category: category ?? this.category,
      notes: notes ?? Map.from(this.notes),
      specificDays: specificDays ?? this.specificDays,
      reminderTime: reminderTime ?? this.reminderTime,
      showMorningReminder: showMorningReminder ?? this.showMorningReminder,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
