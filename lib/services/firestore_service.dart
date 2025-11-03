import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/habit.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get habits collection for a user
  CollectionReference _habitsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('habits');
  }

  // Stream of habits for a user
  Stream<List<Habit>> getHabitsStream(String userId) {
    return _habitsCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure the document ID is included
        return Habit.fromJson(data);
      }).toList();
    });
  }

  // Get habits once
  Future<List<Habit>> getHabits(String userId) async {
    try {
      final snapshot = await _habitsCollection(userId).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Habit.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting habits: $e');
      return [];
    }
  }

  // Add habit
  Future<void> addHabit(String userId, Habit habit) async {
    try {
      final habitData = habit.toJson();
      habitData.remove('id'); // Remove id, Firestore will generate one
      
      await _habitsCollection(userId).doc(habit.id).set(habitData);
    } catch (e) {
      debugPrint('Error adding habit: $e');
      rethrow;
    }
  }

  // Update habit
  Future<void> updateHabit(String userId, Habit habit) async {
    try {
      final habitData = habit.toJson();
      habitData.remove('id');
      
      await _habitsCollection(userId).doc(habit.id).update(habitData);
    } catch (e) {
      debugPrint('Error updating habit: $e');
      rethrow;
    }
  }

  // Delete habit
  Future<void> deleteHabit(String userId, String habitId) async {
    try {
      await _habitsCollection(userId).doc(habitId).delete();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  // Batch update habits (for syncing)
  Future<void> batchUpdateHabits(String userId, List<Habit> habits) async {
    try {
      final batch = _firestore.batch();

      for (var habit in habits) {
        final habitData = habit.toJson();
        habitData.remove('id');
        
        final docRef = _habitsCollection(userId).doc(habit.id);
        batch.set(docRef, habitData, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error batch updating habits: $e');
      rethrow;
    }
  }

  // Delete all habits for a user
  Future<void> deleteAllHabits(String userId) async {
    try {
      final snapshot = await _habitsCollection(userId).get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting all habits: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }
}
