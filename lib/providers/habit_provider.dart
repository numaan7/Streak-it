import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/offline_sync_service.dart';

class HabitProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  final OfflineSyncService _offlineSync = OfflineSyncService();
  
  List<Habit> _habits = [];
  bool _isLoading = true;
  bool _isOnline = true;
  String? _userId;
  StreamSubscription? _habitsSubscription;
  StreamSubscription? _connectivitySubscription;

  List<Habit> get habits => _habits.where((h) => !h.isArchived).toList();
  List<Habit> get archivedHabits => _habits.where((h) => h.isArchived).toList();
  bool get isLoading => _isLoading;
  bool get isSignedIn => _userId != null;
  bool get isOnline => _isOnline;
  int get pendingSyncCount => _offlineSync.pendingOperations.length;

  HabitProvider() {
    _initializeOfflineSync();
    loadHabits();
  }

  Future<void> _initializeOfflineSync() async {
    await _offlineSync.initialize();
    _isOnline = _offlineSync.isOnline;
    
    // Listen to connectivity changes
    _connectivitySubscription = _offlineSync.connectivityStream.listen(
      (isOnline) async {
        final wasOnline = _isOnline;
        _isOnline = isOnline;
        notifyListeners();

        // Sync when coming back online
        if (!wasOnline && isOnline && _userId != null) {
          debugPrint('Connection restored - syncing pending operations...');
          await _syncPendingOperations();
        }
      },
    );
  }

  Future<void> _syncPendingOperations() async {
    if (_userId == null) return;
    
    try {
      await _firestoreService.syncPendingOperations(_userId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing pending operations: $e');
    }
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
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Manual sync trigger
  Future<void> manualSync() async {
    if (_userId != null && _isOnline) {
      await _syncPendingOperations();
    }
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
    // Always add to local first
    _habits.add(habit);
    await _saveHabitsToLocal();
    notifyListeners();

    // Try to sync to Firestore if online and signed in
    if (_userId != null) {
      try {
        await _firestoreService.addHabit(_userId!, habit);
      } catch (e) {
        debugPrint('Failed to add habit to Firestore (will sync later): $e');
        // Operation is already queued by FirestoreService
      }
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
    
    // Always update local first
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      await _saveHabitsToLocal();
      notifyListeners();
    }

    // Try to sync to Firestore if online and signed in
    if (_userId != null) {
      try {
        await _firestoreService.updateHabit(_userId!, updatedHabit);
      } catch (e) {
        debugPrint('Failed to update habit in Firestore (will sync later): $e');
        // Operation is already queued by FirestoreService
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
    
    // Always delete from local first
    _habits.removeWhere((h) => h.id == habitId);
    await _saveHabitsToLocal();
    notifyListeners();

    // Try to sync to Firestore if online and signed in
    if (_userId != null) {
      try {
        await _firestoreService.deleteHabit(_userId!, habitId);
      } catch (e) {
        debugPrint('Failed to delete habit from Firestore (will sync later): $e');
        // Operation is already queued by FirestoreService
      }
    }
  }

  // Toggle habit completion for today
  Future<void> toggleHabitToday(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.toggleToday();
    
    // Always update local first
    await _saveHabitsToLocal();
    notifyListeners();

    // Try to sync to Firestore if online and signed in
    if (_userId != null) {
      try {
        await _firestoreService.updateHabit(_userId!, habit);
      } catch (e) {
        debugPrint('Failed to update habit in Firestore (will sync later): $e');
        // Operation is already queued by FirestoreService
      }
    }
  }

  // Archive habit
  Future<void> archiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final updatedHabit = _habits[index].copyWith(isArchived: true);
      
      // Always update local first
      _habits[index] = updatedHabit;
      await _saveHabitsToLocal();
      notifyListeners();

      // Try to sync to Firestore if online and signed in
      if (_userId != null) {
        try {
          await _firestoreService.updateHabit(_userId!, updatedHabit);
        } catch (e) {
          debugPrint('Failed to archive habit in Firestore (will sync later): $e');
        }
      }
    }
  }

  // Unarchive habit
  Future<void> unarchiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final updatedHabit = _habits[index].copyWith(isArchived: false);
      
      // Always update local first
      _habits[index] = updatedHabit;
      await _saveHabitsToLocal();
      notifyListeners();

      // Try to sync to Firestore if online and signed in
      if (_userId != null) {
        try {
          await _firestoreService.updateHabit(_userId!, updatedHabit);
        } catch (e) {
          debugPrint('Failed to unarchive habit in Firestore (will sync later): $e');
        }
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
