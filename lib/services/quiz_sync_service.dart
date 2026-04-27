import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/db_models.dart';
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
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _handleNetworkChange,
    );
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
    // Treat as offline only if it explicitly says none
    final hasInternet =
        !results.contains(ConnectivityResult.none) && results.isNotEmpty;
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
        return;
      }

      syncError.value = null; // Clear previous errors

      // Fetch Quizzes from Mongo
      final mongoQuizzes = await MongoDatabase.quizCollection.find().toList();
      for (var qMap in mongoQuizzes) {
        final q = Quiz.fromJson(qMap);
        final localQ = HiveService.quizBox.get(q.id);
        if (localQ == null || localQ.isSynced) {
          await HiveService.quizBox.put(q.id, q);
        }
      }

      // Fetch Soal from Mongo
      final mongoSoals = await MongoDatabase.soalCollection.find().toList();
      for (var sMap in mongoSoals) {
        final s = Soal.fromJson(sMap);
        final localS = HiveService.soalBox.get(s.id);
        if (localS == null || localS.isSynced) {
          await HiveService.soalBox.put(s.id, s);
        }
      }

      // Sync Quizzes
      final unsyncedQuizzes = HiveService.quizBox.values
          .where((q) => !q.isSynced)
          .toList();
      for (var quiz in unsyncedQuizzes) {
        final existing = await MongoDatabase.quizCollection.findOne({
          '_id': quiz.id,
        });
        final quizJson = quiz.toJson();
        quizJson.remove('isSynced');

        if (existing == null) {
          await MongoDatabase.quizCollection.insertOne(quizJson);
        } else {
          await MongoDatabase.quizCollection.updateOne(
            {'_id': quiz.id},
            {r'$set': quizJson},
          );
        }

        await HiveService.quizBox.put(quiz.id, quiz.copyWith(isSynced: true));
      }

      // Sync Soals
      final unsyncedSoals = HiveService.soalBox.values
          .where((s) => !s.isSynced)
          .toList();
      for (var soal in unsyncedSoals) {
        final existing = await MongoDatabase.soalCollection.findOne({
          '_id': soal.id,
        });
        final soalJson = soal.toJson();
        soalJson.remove('isSynced');

        if (existing == null) {
          await MongoDatabase.soalCollection.insertOne(soalJson);
        } else {
          await MongoDatabase.soalCollection.updateOne(
            {'_id': soal.id},
            {r'$set': soalJson},
          );
        }

        await HiveService.soalBox.put(soal.id, soal.copyWith(isSynced: true));
      }

      debugPrint("Sync complete!");
      syncError.value = null;
    } catch (e) {
      debugPrint("Sync failed: $e");
      if (e.toString().contains('No master connection')) {
        syncError.value = null;
      } else {
        syncError.value = "Gagal sinkronisasi: $e";
      }
    } finally {
      _isSyncing = false;
    }
  }
}
