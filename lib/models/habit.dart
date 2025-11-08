import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String name;
  final String? description;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final String? reminder;
  final TimeOfDay? reminderTime; // Time for notification
  final FrequencyType frequency;
  final int targetDays; // for weekly/monthly goals
  final String? category; // Health, Productivity, Mindfulness, etc.
  final Map<String, String> notes; // date -> note mapping
  final bool isArchived;
  final DateTime? archivedAt;
  final TimeSlot? timeSlot; // Morning, Evening, or Anytime

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.completedDates,
    this.reminder,
    this.reminderTime,
    this.frequency = FrequencyType.daily,
    this.targetDays = 7,
    this.category,
    Map<String, String>? notes,
    this.isArchived = false,
    this.archivedAt,
    this.timeSlot,
  }) : notes = notes ?? {};

  // Calculate current streak
  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.map((d) => _normalizeDate(d)).toList()
      ..sort((a, b) => b.compareTo(a));

    final today = _normalizeDate(DateTime.now());
    
    // Check if completed today or yesterday to have an active streak
    if (!sortedDates.contains(today) && 
        !sortedDates.contains(today.subtract(const Duration(days: 1)))) {
      return 0;
    }

    int streak = 0;
    DateTime currentDate = today;

    for (var date in sortedDates) {
      if (date == currentDate || date == currentDate.subtract(const Duration(days: 1))) {
        streak++;
        currentDate = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Calculate longest streak
  int get longestStreak {
    if (completedDates.isEmpty) return 0;

    final sortedDates = completedDates.map((d) => _normalizeDate(d)).toList()
      ..sort();

    int maxStreak = 1;
    int currentStreakCount = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      
      if (diff == 1) {
        currentStreakCount++;
        maxStreak = currentStreakCount > maxStreak ? currentStreakCount : maxStreak;
      } else {
        currentStreakCount = 1;
      }
    }

    return maxStreak;
  }

  // Check if completed today
  bool get isCompletedToday {
    final today = _normalizeDate(DateTime.now());
    return completedDates.any((date) => _normalizeDate(date) == today);
  }

  // Total completions
  int get totalCompletions => completedDates.length;

  // Completion rate (last 30 days)
  double get completionRate {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentCompletions = completedDates.where(
      (date) => date.isAfter(thirtyDaysAgo)
    ).length;
    return (recentCompletions / 30) * 100;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Copy with method
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    String? reminder,
    TimeOfDay? reminderTime,
    FrequencyType? frequency,
    int? targetDays,
    String? category,
    Map<String, String>? notes,
    bool? isArchived,
    DateTime? archivedAt,
    TimeSlot? timeSlot,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      reminder: reminder ?? this.reminder,
      reminderTime: reminderTime ?? this.reminderTime,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      archivedAt: archivedAt ?? this.archivedAt,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'icon': icon.codePoint,
      'createdAt': createdAt.toIso8601String(),
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'reminder': reminder,
      'reminderTime': reminderTime != null 
          ? '${reminderTime!.hour}:${reminderTime!.minute}' 
          : null,
      'frequency': frequency.toString(),
      'targetDays': targetDays,
      'category': category,
      'notes': notes,
      'isArchived': isArchived,
      'archivedAt': archivedAt?.toIso8601String(),
      'timeSlot': timeSlot?.toString(),
    };
  }

  // Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: Color(json['color'] as int),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedDates: (json['completedDates'] as List<dynamic>)
          .map((d) => DateTime.parse(d as String))
          .toList(),
      reminder: json['reminder'] as String?,
      reminderTime: parseTime(json['reminderTime'] as String?),
      frequency: FrequencyType.values.firstWhere(
        (e) => e.toString() == json['frequency'],
        orElse: () => FrequencyType.daily,
      ),
      targetDays: json['targetDays'] as int? ?? 7,
      category: json['category'] as String?,
      notes: Map<String, String>.from(json['notes'] ?? {}),
      isArchived: json['isArchived'] as bool? ?? false,
      archivedAt: json['archivedAt'] != null 
          ? DateTime.parse(json['archivedAt'] as String) 
          : null,
      timeSlot: json['timeSlot'] != null
          ? TimeSlot.values.firstWhere(
              (e) => e.toString() == json['timeSlot'],
              orElse: () => TimeSlot.anytime,
            )
          : null,
    );
  }
}

enum FrequencyType {
  daily,
  weekly,
  custom,
}

enum TimeSlot {
  morning,   // 5 AM - 9 AM
  evening,   // 9 PM - 2 AM
  anytime,   // No specific time
}
