import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:py_4/services/mongodb_service.dart';
import 'package:py_4/models/db_models.dart';

void main() {
  // Setup: Dijalankan sekali sebelum semua test dimulai
  setUpAll(() async {
    final envContent = File('.env').readAsStringSync();
    
    // Cari baris MONGO_URI dan ekstrak URL nya (agar test tidak butuh load dotenv)
    final uriLine = envContent.split('\n').firstWhere(
      (line) => line.startsWith('MONGO_URI='),
      orElse: () => throw Exception('MONGO_URI tidak ditemukan di .env'),
    );
    String originalUri = uriLine.split('=').sublist(1).join('=').trim();
    
    String testUri;
    if (originalUri.contains('?')) {
      final parts = originalUri.split('?');
      if (parts[0].endsWith('/')) {
        parts[0] = '${parts[0]}Kahoof_test';
      } else {
        parts[0] = '${parts[0]}_test';
      }
      testUri = '${parts[0]}?${parts[1]}';
    } else {
      if (originalUri.endsWith('/')) {
        testUri = '${originalUri}Kahoof_test';
      } else {
        testUri = '${originalUri}_test';
      }
    }

    MongoDatabase.testUri = testUri;
    
    await MongoDatabase.connect();
  });

  group('MongoDB Service Unit Tests', () {
    test('Database harus terkoneksi dan merespon', () {
      final db = MongoDatabase.db;
      expect(db.state, equals(State.open));
    });

    test('Operasi CRUD Collection Users', () async {
      final usersCollection = MongoDatabase.usersCollection;
      const String testId = 'test_unit_id_123';
      
      // 1. Data Dummy
      final testUser = AppUser(
        id: testId,
        namaLengkap: 'Tester via Unit Test',
      );

      // 2. Clear data existing (jika ada sisa error sebelumnya)
      await usersCollection.deleteOne({'id': testId});

      // 3. Create (Insert)
      final writeResult = await usersCollection.insertOne(testUser.toJson());
      expect(writeResult.isSuccess, isTrue, reason: 'Gagal memasukkan data user');

      // 4. Read (Find)
      final foundUser = await usersCollection.findOne(where.eq('id', testId));
      expect(foundUser, isNotNull, reason: 'Data user tidak ditemukan di database');
      expect(foundUser?['nama_lengkap'], equals('Tester via Unit Test'));

      // 5. Update (Modify)
      await usersCollection.updateOne(
        where.eq('id', testId),
        modify.set('nama_lengkap', 'Tester via Unit Test Updated'),
      );
      final updatedUser = await usersCollection.findOne(where.eq('id', testId));
      expect(updatedUser?['nama_lengkap'], equals('Tester via Unit Test Updated'));

      // 6. Delete (Remove)
      final deleteResult = await usersCollection.deleteOne(where.eq('id', testId));
      expect(deleteResult.isSuccess, isTrue);
      
      // Verifikasi Delete
      final checkDeleted = await usersCollection.findOne(where.eq('id', testId));
      expect(checkDeleted, isNull);
    });
  });

  tearDownAll(() async {
    // Hapus seluruh database testing untuk mencegah kebocoran data (cleanup database test)
    await MongoDatabase.db.drop(); 
    await MongoDatabase.close();
  });
}
