import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;
  final StorageService _storageService;
  final NotificationService _notificationService = NotificationService();

  HabitProvider(this._storageService) {
    // Don't auto-load, let splash screen handle it
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  // Load habits from storage
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    _habits = await _storageService.loadHabits();
    
    _isLoading = false;
    notifyListeners();
  }

  // Add new habit
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _storageService.saveHabits(_habits);
    
    // Schedule notification if reminder time is set
    if (habit.reminderTime != null) {
      final habitId = habit.id.hashCode;
      await _notificationService.scheduleHabitReminder(
        id: habitId,
        habitId: habit.id,
        habitName: habit.name,
        time: habit.reminderTime!,
        habitEmoji: _getHabitEmoji(habit),
        description: habit.description,
      );
    }
    
    notifyListeners();
  }

  String _getHabitEmoji(Habit habit) {
    // Map icon to emoji
    final iconMap = {
      'favorite': '❤️',
      'fitness_center': '💪',
      'self_improvement': '🧘',
      'local_drink': '💧',
      'menu_book': '📚',
      'directions_run': '🏃',
      'spa': '🌸',
      'nightlight': '🌙',
      'wb_sunny': '☀️',
      'restaurant': '🍽️',
      'music_note': '🎵',
      'palette': '🎨',
      'code': '💻',
      'camera_alt': '📷',
      'savings': '💰',
      'school': '🎓',
      'cleaning_services': '🧹',
      'pets': '🐾',
      'forest': '🌲',
      'water_drop': '💧',
    };
    return iconMap[habit.icon.toString()] ?? '🔥';
  }

  // Update habit
  Future<void> updateHabit(String id, Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final oldHabit = _habits[index];
      _habits[index] = updatedHabit;
      await _storageService.saveHabits(_habits);
      
      // Update notification
      final habitId = id.hashCode;
      if (updatedHabit.reminderTime != null) {
        await _notificationService.scheduleHabitReminder(
          id: habitId,
          habitId: updatedHabit.id,
          habitName: updatedHabit.name,
          time: updatedHabit.reminderTime!,
          habitEmoji: _getHabitEmoji(updatedHabit),
          description: updatedHabit.description,
        );
      } else {
        // Cancel if reminder was removed
        await _notificationService.cancelHabitReminder(habitId);
      }
      
      notifyListeners();
    }
  }

  // Delete habit
  Future<void> deleteHabit(String id) async {
    final habitId = id.hashCode;
    await _notificationService.cancelHabitReminder(habitId);
    _habits.removeWhere((h) => h.id == id);
    await _storageService.saveHabits(_habits);
    notifyListeners();
  }

  // Toggle habit completion for today
  Future<void> toggleHabitCompletion(String id) async {
    final habitIndex = _habits.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final today = _normalizeDate(DateTime.now());
    
    List<DateTime> updatedDates = List.from(habit.completedDates);
    
    if (habit.isCompletedToday) {
      // Remove today's completion
      updatedDates.removeWhere((date) => _normalizeDate(date) == today);
    } else {
      // Add today's completion
      updatedDates.add(DateTime.now());
    }

    final updatedHabit = habit.copyWith(completedDates: updatedDates);
    _habits[habitIndex] = updatedHabit;
    
    await _storageService.saveHabits(_habits);
    notifyListeners();
  }

  // Get habits sorted by current streak
  List<Habit> get habitsSortedByStreak {
    final sortedHabits = List<Habit>.from(_habits);
    sortedHabits.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    return sortedHabits;
  }

  // Get active habits (with current streak > 0)
  List<Habit> get activeHabits {
    return _habits.where((h) => h.currentStreak > 0).toList();
  }

  // Get total streaks
  int get totalActiveStreaks {
    return _habits.fold(0, (sum, habit) => sum + habit.currentStreak);
  }

  // Get completion rate today
  double get todayCompletionRate {
    if (_habits.isEmpty) return 0;
    final completedToday = _habits.where((h) => h.isCompletedToday).length;
    return (completedToday / _habits.length) * 100;
  }

  // Archive/Unarchive habit
  Future<void> toggleArchiveHabit(String id) async {
    final habitIndex = _habits.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final updatedHabit = habit.copyWith(
      isArchived: !habit.isArchived,
      archivedAt: !habit.isArchived ? DateTime.now() : null,
    );
    
    _habits[habitIndex] = updatedHabit;
    await _storageService.saveHabits(_habits);
    notifyListeners();
  }

  // Add note to a habit completion
  Future<void> addNoteToCompletion(String id, DateTime date, String note) async {
    final habitIndex = _habits.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];
    final dateKey = _normalizeDate(date).toIso8601String();
    final updatedNotes = Map<String, String>.from(habit.notes);
    updatedNotes[dateKey] = note;
    
    final updatedHabit = habit.copyWith(notes: updatedNotes);
    _habits[habitIndex] = updatedHabit;
    
    await _storageService.saveHabits(_habits);
    notifyListeners();
  }

  // Reorder habits
  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final habit = _habits.removeAt(oldIndex);
    _habits.insert(newIndex, habit);
    await _storageService.saveHabits(_habits);
    notifyListeners();
  }

  // Complete habit from notification
  Future<void> completeHabitFromNotification(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId, orElse: () => _habits.first);
    if (habit.id == habitId) {
      await toggleHabitCompletion(habitId);
    }
  }

  // Snooze habit notification
  Future<void> snoozeHabitNotification(String habitId, int minutes) async {
    final habit = _habits.firstWhere((h) => h.id == habitId, orElse: () => _habits.first);
    if (habit.id == habitId) {
      final notificationId = habitId.hashCode;
      await _notificationService.snoozeNotification(
        id: notificationId,
        habitId: habitId,
        habitName: habit.name,
        minutes: minutes,
        habitEmoji: _getHabitEmoji(habit),
        description: habit.description,
      );
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
