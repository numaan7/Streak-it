import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class StorageService {
  static const String _habitsKey = 'habits';
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save habits
  Future<bool> saveHabits(List<Habit> habits) async {
    try {
      final habitsJson = habits.map((h) => h.toJson()).toList();
      final jsonString = jsonEncode(habitsJson);
      return await _prefs!.setString(_habitsKey, jsonString);
    } catch (e) {
      print('Error saving habits: $e');
      return false;
    }
  }

  // Load habits
  Future<List<Habit>> loadHabits() async {
    try {
      final jsonString = _prefs!.getString(_habitsKey);
      if (jsonString == null) return [];

      final List<dynamic> habitsJson = jsonDecode(jsonString);
      return habitsJson.map((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      print('Error loading habits: $e');
      return [];
    }
  }

  // Clear all data
  Future<bool> clearAllData() async {
    return await _prefs!.clear();
  }
}
