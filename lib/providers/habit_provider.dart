import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<Habit> _habits = [];
  bool _isLoading = true;

  List<Habit> get habits => _habits.where((h) => !h.isArchived).toList();
  List<Habit> get archivedHabits => _habits.where((h) => h.isArchived).toList();
  bool get isLoading => _isLoading;

  HabitProvider() {
    loadHabits();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Load habits from local storage (fallback)
  Future<void> loadHabits() async {
    debugPrint('╔═══════════════════════════════════════════╗');
    debugPrint('║   LOAD OPERATION STARTED                  ║');
    debugPrint('╚═══════════════════════════════════════════╝');
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString('habits');

      if (habitsJson != null) {
        debugPrint('✅ Data found in SharedPreferences');
        debugPrint('📝 JSON length: ${habitsJson.length} characters');
        debugPrint('📄 First 200 chars: ${habitsJson.substring(0, habitsJson.length > 200 ? 200 : habitsJson.length)}...');
        
        final List<dynamic> decoded = jsonDecode(habitsJson);
        debugPrint('📋 Decoded ${decoded.length} items from JSON');
        
        _habits = decoded.map((json) => Habit.fromJson(json)).toList();
        debugPrint('✅ Converted to ${_habits.length} Habit objects');
        debugPrint('');
        debugPrint('📋 LOADED HABITS:');
        for (int i = 0; i < _habits.length; i++) {
          debugPrint('   ${i + 1}. ${_habits[i].name}');
          debugPrint('      ID: ${_habits[i].id}');
          debugPrint('      Archived: ${_habits[i].isArchived}');
        }
      } else {
        debugPrint('⚠️ No saved habits found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('❌❌❌ ERROR LOADING HABITS: $e');
      debugPrint('Stack: ${StackTrace.current}');
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('╔═══════════════════════════════════════════╗');
    debugPrint('║   LOAD OPERATION COMPLETE                 ║');
    debugPrint('╚═══════════════════════════════════════════╝');
  }

  // Save habits to local storage
  Future<void> _saveHabitsToLocal() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('💾 SAVE OPERATION STARTED');
      debugPrint('📋 Habits in memory: ${_habits.length}');
      for (int i = 0; i < _habits.length; i++) {
        debugPrint('   ${i + 1}. ${_habits[i].name} (ID: ${_habits[i].id})');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final habitsList = _habits.map((h) => h.toJson()).toList();
      final habitsJson = jsonEncode(habitsList);
      
      debugPrint('📝 JSON to save (${habitsJson.length} chars):');
      debugPrint('   ${habitsJson.substring(0, habitsJson.length > 200 ? 200 : habitsJson.length)}...');
      
      final result = await prefs.setString('habits', habitsJson);
      debugPrint('✅ SharedPreferences.setString returned: $result');
      
      // Verify the save by reading it back
      final savedData = prefs.getString('habits');
      if (savedData != null) {
        final savedList = jsonDecode(savedData) as List;
        debugPrint('✅ VERIFICATION SUCCESS: ${savedList.length} habits confirmed saved');
        debugPrint('   Saved habit IDs: ${savedList.map((h) => h['id']).join(', ')}');
      } else {
        debugPrint('❌❌❌ VERIFICATION FAILED: No data found after save!');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      debugPrint('❌❌❌ ERROR IN SAVE: $e');
      debugPrint('Stack: ${StackTrace.current}');
    }
  }

  // Add new habit
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabitsToLocal();
    notifyListeners();
    
    // Schedule notification if reminder time is set
    if (habit.reminderTime != null) {
      await _notificationService.scheduleHabitReminder(habit);
    }
    
    // Schedule morning reminder if enabled
    if (habit.showMorningReminder) {
      await _notificationService.scheduleMorningReminder(habit);
    }
  }

  // Update existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║   UPDATE OPERATION STARTED                 ║');
    debugPrint('╚════════════════════════════════════════════╝');
    debugPrint('✏️ Updating habit: ${updatedHabit.name}');
    debugPrint('🆔 Looking for ID: ${updatedHabit.id}');
    debugPrint('📋 Current habits in memory: ${_habits.length}');
    
    for (int i = 0; i < _habits.length; i++) {
      debugPrint('   ${i + 1}. ${_habits[i].name} (ID: ${_habits[i].id})');
      if (_habits[i].id == updatedHabit.id) {
        debugPrint('      ✅ THIS IS THE MATCH!');
      }
    }
    
    // Cancel old notifications
    await _notificationService.cancelHabitReminder(updatedHabit);
    
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    debugPrint('📍 Index found: $index');
    
    if (index != -1) {
      debugPrint('✅ Replacing habit at index $index');
      debugPrint('   Old: ${_habits[index].name}');
      debugPrint('   New: ${updatedHabit.name}');
      
      _habits[index] = updatedHabit;
      
      debugPrint('🔄 Calling save...');
      await _saveHabitsToLocal();
      
      debugPrint('� Calling notifyListeners...');
      notifyListeners();
      
      debugPrint('✅ UPDATE COMPLETE');
    } else {
      debugPrint('❌❌❌ HABIT NOT FOUND IN LIST!');
      debugPrint('❌ Searched for ID: ${updatedHabit.id}');
      debugPrint('❌ Available IDs: ${_habits.map((h) => h.id).join(", ")}');
    }
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║   UPDATE OPERATION END                     ║');
    debugPrint('╚════════════════════════════════════════════╝');
    
    // Schedule new notification if reminder time is set
    if (updatedHabit.reminderTime != null) {
      await _notificationService.scheduleHabitReminder(updatedHabit);
    }
    
    // Schedule morning reminder if enabled
    if (updatedHabit.showMorningReminder) {
      await _notificationService.scheduleMorningReminder(updatedHabit);
    }
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║   DELETE OPERATION STARTED                 ║');
    debugPrint('╚════════════════════════════════════════════╝');
    debugPrint('🗑️ Deleting habit with ID: $habitId');
    debugPrint('📊 Habits before delete: ${_habits.length}');
    
    for (int i = 0; i < _habits.length; i++) {
      debugPrint('   ${i + 1}. ${_habits[i].name} (ID: ${_habits[i].id})');
      if (_habits[i].id == habitId) {
        debugPrint('      ✅ THIS WILL BE DELETED!');
      }
    }
    
    try {
      final habit = _habits.firstWhere((h) => h.id == habitId);
      debugPrint('✅ Found habit to delete: ${habit.name}');
      
      // Cancel notifications for this habit
      await _notificationService.cancelHabitReminder(habit);
      
      _habits.removeWhere((h) => h.id == habitId);
      debugPrint('📊 Habits after delete: ${_habits.length}');
      
      debugPrint('🔄 Calling save...');
      await _saveHabitsToLocal();
      
      debugPrint('� Calling notifyListeners...');
      notifyListeners();
      
      debugPrint('✅ DELETE COMPLETE');
    } catch (e) {
      debugPrint('❌❌❌ Error deleting habit: $e');
      debugPrint('Stack: ${StackTrace.current}');
    }
    debugPrint('╔════════════════════════════════════════════╗');
    debugPrint('║   DELETE OPERATION END                     ║');
    debugPrint('╚════════════════════════════════════════════╝');
  }

  // Toggle habit completion for today
  Future<void> toggleHabitToday(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.toggleToday();
    
    await _saveHabitsToLocal();
    notifyListeners();
  }

  // Archive habit
  Future<void> archiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final updatedHabit = _habits[index].copyWith(isArchived: true);
      _habits[index] = updatedHabit;
      await _saveHabitsToLocal();
      notifyListeners();
    }
  }

  // Unarchive habit
  Future<void> unarchiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final updatedHabit = _habits[index].copyWith(isArchived: false);
      _habits[index] = updatedHabit;
      await _saveHabitsToLocal();
      notifyListeners();
    }
  }

  // Get habit by id
  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  // Statistics
  int get totalHabits => habits.length;
  int get totalCompletionsToday =>
      habits.where((h) => h.isCompletedToday).length;
  
  double get overallCompletionRate {
    if (habits.isEmpty) return 0.0;
    final rates = habits.map((h) => h.completionRate).toList();
    return rates.reduce((a, b) => a + b) / rates.length;
  }

  int get totalActiveStreaks {
    return habits.fold(0, (sum, habit) => sum + habit.currentStreak);
  }
}
