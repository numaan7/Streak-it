import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  List<Habit> _habits = [];
  bool _isLoading = true;
  String? _userId;
  StreamSubscription? _habitsSubscription;

  List<Habit> get habits => _habits.where((h) => !h.isArchived).toList();
  List<Habit> get archivedHabits => _habits.where((h) => h.isArchived).toList();
  bool get isLoading => _isLoading;
  bool get isSignedIn => _userId != null;

  HabitProvider() {
    loadHabits();
  }

  // Initialize with user ID and start listening to Firestore
  Future<void> initializeWithUser(String? userId) async {
    _userId = userId;
    
    // Cancel previous subscription
    await _habitsSubscription?.cancel();
    
    if (userId != null) {
      // Load from Firestore and listen for changes
      _listenToFirestoreChanges(userId);
    } else {
      // Load from local storage when not signed in
      await loadHabits();
    }
  }

  // Listen to Firestore changes
  void _listenToFirestoreChanges(String userId) {
    _isLoading = true;
    notifyListeners();

    _habitsSubscription = _firestoreService.getHabitsStream(userId).listen(
      (habits) {
        _habits = habits;
        _isLoading = false;
        notifyListeners();
        
        // Also save to local storage as backup
        _saveHabitsToLocal();
      },
      onError: (error) {
        debugPrint('Error listening to habits: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel();
    super.dispose();
  }

  // Load habits from local storage (fallback)
  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString('habits');

      if (habitsJson != null) {
        final List<dynamic> decoded = jsonDecode(habitsJson);
        _habits = decoded.map((json) => Habit.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save habits to local storage (backup)
  Future<void> _saveHabitsToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = jsonEncode(_habits.map((h) => h.toJson()).toList());
      await prefs.setString('habits', habitsJson);
    } catch (e) {
      debugPrint('Error saving habits to local: $e');
    }
  }

  // Sync local habits to Firestore when user signs in
  Future<void> syncLocalHabitsToFirestore() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString('habits');

      if (habitsJson != null) {
        final List<dynamic> decoded = jsonDecode(habitsJson);
        final localHabits = decoded.map((json) => Habit.fromJson(json)).toList();
        
        if (localHabits.isNotEmpty) {
          await _firestoreService.batchUpdateHabits(_userId!, localHabits);
        }
      }
    } catch (e) {
      debugPrint('Error syncing local habits: $e');
    }
  }

  // Add new habit
  Future<void> addHabit(Habit habit) async {
    if (_userId != null) {
      await _firestoreService.addHabit(_userId!, habit);
    } else {
      _habits.add(habit);
      await _saveHabitsToLocal();
      notifyListeners();
    }
    
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
    // Cancel old notifications
    await _notificationService.cancelHabitReminder(updatedHabit);
    
    if (_userId != null) {
      await _firestoreService.updateHabit(_userId!, updatedHabit);
    } else {
      final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (index != -1) {
        _habits[index] = updatedHabit;
        await _saveHabitsToLocal();
        notifyListeners();
      }
    }
    
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
    final habit = _habits.firstWhere((h) => h.id == habitId);
    
    // Cancel notifications for this habit
    await _notificationService.cancelHabitReminder(habit);
    
    if (_userId != null) {
      await _firestoreService.deleteHabit(_userId!, habitId);
    } else {
      _habits.removeWhere((h) => h.id == habitId);
      await _saveHabitsToLocal();
      notifyListeners();
    }
  }

  // Toggle habit completion for today
  Future<void> toggleHabitToday(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.toggleToday();
    
    if (_userId != null) {
      await _firestoreService.updateHabit(_userId!, habit);
    } else {
      await _saveHabitsToLocal();
      notifyListeners();
    }
  }

  // Archive habit
  Future<void> archiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final updatedHabit = _habits[index].copyWith(isArchived: true);
      
      if (_userId != null) {
        await _firestoreService.updateHabit(_userId!, updatedHabit);
      } else {
        _habits[index] = updatedHabit;
        await _saveHabitsToLocal();
        notifyListeners();
      }
    }
  }

  // Unarchive habit
  Future<void> unarchiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final updatedHabit = _habits[index].copyWith(isArchived: false);
      
      if (_userId != null) {
        await _firestoreService.updateHabit(_userId!, updatedHabit);
      } else {
        _habits[index] = updatedHabit;
        await _saveHabitsToLocal();
        notifyListeners();
      }
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
