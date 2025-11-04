import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/habit.dart';

enum SyncOperation { add, update, delete }

class PendingOperation {
  final String id;
  final SyncOperation operation;
  final Habit? habit;
  final String? habitId;
  final DateTime timestamp;

  PendingOperation({
    required this.id,
    required this.operation,
    this.habit,
    this.habitId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'operation': operation.toString(),
        'habit': habit?.toJson(),
        'habitId': habitId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'],
      operation: SyncOperation.values
          .firstWhere((e) => e.toString() == json['operation']),
      habit: json['habit'] != null ? Habit.fromJson(json['habit']) : null,
      habitId: json['habitId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  List<PendingOperation> _pendingOperations = [];
  List<PendingOperation> get pendingOperations => _pendingOperations;

  static const String _pendingOpsKey = 'pending_operations';
  static const String _lastSyncKey = 'last_sync_time';

  Future<void> initialize() async {
    // Load pending operations
    await _loadPendingOperations();

    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    _connectivityController.add(_isOnline);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        final wasOnline = _isOnline;
        _isOnline = !result.contains(ConnectivityResult.none);
        
        debugPrint('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
        _connectivityController.add(_isOnline);

        // Trigger sync when coming back online
        if (!wasOnline && _isOnline) {
          debugPrint('Connection restored - triggering sync');
        }
      },
    );
  }

  Future<void> _loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final opsJson = prefs.getString(_pendingOpsKey);

      if (opsJson != null) {
        final List<dynamic> decoded = jsonDecode(opsJson);
        _pendingOperations = decoded
            .map((json) => PendingOperation.fromJson(json))
            .toList();
        debugPrint('Loaded ${_pendingOperations.length} pending operations');
      }
    } catch (e) {
      debugPrint('Error loading pending operations: $e');
      _pendingOperations = [];
    }
  }

  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final opsJson = jsonEncode(
        _pendingOperations.map((op) => op.toJson()).toList(),
      );
      await prefs.setString(_pendingOpsKey, opsJson);
      debugPrint('Saved ${_pendingOperations.length} pending operations');
    } catch (e) {
      debugPrint('Error saving pending operations: $e');
    }
  }

  Future<void> queueOperation(SyncOperation operation,
      {Habit? habit, String? habitId}) async {
    final op = PendingOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operation: operation,
      habit: habit,
      habitId: habitId,
      timestamp: DateTime.now(),
    );

    _pendingOperations.add(op);
    await _savePendingOperations();
    debugPrint('Queued ${operation.toString()} operation');
  }

  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
  }

  Future<void> removePendingOperation(String operationId) async {
    _pendingOperations.removeWhere((op) => op.id == operationId);
    await _savePendingOperations();
  }

  Future<void> updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error updating last sync time: $e');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString(_lastSyncKey);
      return timeStr != null ? DateTime.parse(timeStr) : null;
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
      return null;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}
