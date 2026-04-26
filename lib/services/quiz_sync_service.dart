import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';
import 'mongodb_service.dart';

class QuizSyncService {
  static final QuizSyncService _instance = QuizSyncService._internal();
  factory QuizSyncService() => _instance;
  QuizSyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  ValueNotifier<String?> syncError = ValueNotifier<String?>(null);

  void initialize() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_handleNetworkChange);
    // Attempt initial sync and status check
    _checkInitialConnectivity();
  }
  
  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _handleNetworkChange(results);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  void _handleNetworkChange(List<ConnectivityResult> results) {
    // Treat as offline only if it explicitly says none, to handle Linux/desktop better
    final hasInternet = !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    isOnline.value = hasInternet;
    
    if (hasInternet) {
      syncNow();
    }
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final isMongoConnected = await MongoDatabase.tryConnect();
      if (!isMongoConnected) {
        _isSyncing = false;
        syncError.value = "Gagal terhubung ke MongoDB (Cek URI atau Whitelist IP)";
        return;
      }
      
      syncError.value = null; // Clear previous errors

      // Sync Quizzes
      final unsyncedQuizzes = HiveService.quizBox.values.where((q) => !q.isSynced).toList();
      for (var quiz in unsyncedQuizzes) {
        final existing = await MongoDatabase.quizCollection.findOne({'_id': quiz.id});
        final quizJson = quiz.toJson();
        quizJson.remove('isSynced');
        
        if (existing == null) {
          await MongoDatabase.quizCollection.insertOne(quizJson);
        } else {
          await MongoDatabase.quizCollection.updateOne({'_id': quiz.id}, {r'$set': quizJson});
        }
        
        await HiveService.quizBox.put(quiz.id, quiz.copyWith(isSynced: true));
      }

      // Sync Soals
      final unsyncedSoals = HiveService.soalBox.values.where((s) => !s.isSynced).toList();
      for (var soal in unsyncedSoals) {
        final existing = await MongoDatabase.soalCollection.findOne({'_id': soal.id});
        final soalJson = soal.toJson();
        soalJson.remove('isSynced');
        
        if (existing == null) {
          await MongoDatabase.soalCollection.insertOne(soalJson);
        } else {
          await MongoDatabase.soalCollection.updateOne({'_id': soal.id}, {r'$set': soalJson});
        }

        await HiveService.soalBox.put(soal.id, soal.copyWith(isSynced: true));
      }
      
      debugPrint("Sync complete!");
      syncError.value = null;
    } catch (e) {
      debugPrint("Sync failed: $e");
      syncError.value = "Gagal sinkronisasi: $e";
    } finally {
      _isSyncing = false;
    }
  }
}
