import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:AlpenQuiz/features/auth/password_policy.dart';
import 'package:AlpenQuiz/models/db_models.dart';
import 'package:AlpenQuiz/services/auth_service.dart';
import 'package:AlpenQuiz/services/hive_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Setup Hive local testing directory
    tempDir = Directory('${Directory.current.path}/test_auth_hive');
    Hive.init(tempDir.path);
    Hive.registerAdapter(AppUserAdapter());
    
    // Open user box manually
    await Hive.openBox<AppUser>('usersBox');
  });

  setUp(() async {
    // Clear SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    AuthService.init(prefs);

    // Clear Hive data
    await HiveService.usersBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('AuthService Guest & Session Tests', () {
    test('continueAsGuest creates a valid guest session', () async {
      final session = await AuthService.continueAsGuest(namaLengkap: 'Guest User');
      
      expect(session.isGuest, true);
      expect(session.displayName, 'Guest User');
      expect(session.role, 'guest');
      expect(session.userId.startsWith('guest_'), true);

      // Verify session is active
      final current = AuthService.currentSession;
      expect(current, isNotNull);
      expect(current!.isGuest, true);
      expect(current.displayName, 'Guest User');
    });

    test('logout removes the active session', () async {
      await AuthService.continueAsGuest(namaLengkap: 'Guest User');
      expect(AuthService.currentSession, isNotNull);

      await AuthService.logout();
      expect(AuthService.currentSession, isNull);
    });

    test('updateDisplayName changes the name of active session', () async {
      await AuthService.continueAsGuest(namaLengkap: 'Guest User');
      await AuthService.updateDisplayName('Updated Guest');

      final current = AuthService.currentSession;
      expect(current!.displayName, 'Updated Guest');
    });
  });

  group('AuthService Offline Flow Tests (Login & Reset)', () {
    final testUser = AppUser(
      id: 'usr_12345',
      namaLengkap: 'Test User',
      email: 'test@example.com',
      password: sha256.convert(utf8.encode('Password123!')).toString(),
      isGuest: false,
      isSynced: false,
    );

    setUp(() async {
      // Clear data before each test
      await HiveService.usersBox.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('login with non-existent user throws AuthException', () async {
      expect(
        () => AuthService.login(identifier: 'unknown@example.com', password: 'Password123!'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('Account not found'))),
      );
    });

    test('login with empty credentials throws AuthException', () async {
      expect(
        () => AuthService.login(identifier: '', password: ''),
        throwsA(isA<AuthException>()),
      );
    });

    test('resetPassword with unknown email throws AuthException', () async {
      expect(
        () => AuthService.resetPassword(identifier: 'unknown@example.com', newPassword: 'NewPassword123!'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('No account found'))),
      );
    });

    test('resetPassword validates password strength', () async {
      // Even if user is unknown, password validation happens first usually or second
      expect(
        () => AuthService.resetPassword(identifier: 'test@example.com', newPassword: 'weak'),
        throwsA(isA<AuthException>()), // Password too weak
      );
    });

    test('login with valid local user succeeds offline', () async {
      // 1. Inject a fake user into the local Hive Box
      await HiveService.usersBox.put(testUser.id, testUser);

      // 2. Perform Login
      final loggedInUser = await AuthService.login(
        identifier: 'test@example.com',
        password: 'Password123!',
      );

      // 3. Verify
      expect(loggedInUser.id, 'usr_12345');
      expect(AuthService.currentSession, isNotNull);
      expect(AuthService.currentSession!.userId, 'usr_12345');
    });

    test('verifyPasswordResetOtp throws error for invalid OTP', () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('password_reset_identifier', 'test@example.com');
      prefs.setString('password_reset_otp', '123456');
      prefs.setInt('password_reset_otp_expiry', DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch);

      expect(
        () => AuthService.verifyPasswordResetOtp(identifier: 'test@example.com', otp: '999999'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('Invalid OTP code'))),
      );
    });

    test('verifyPasswordResetOtp throws error for expired OTP', () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('password_reset_identifier', 'test@example.com');
      prefs.setString('password_reset_otp', '123456');
      // Set OTP to have expired 5 minutes ago
      prefs.setInt('password_reset_otp_expiry', DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch);

      expect(
        () => AuthService.verifyPasswordResetOtp(identifier: 'test@example.com', otp: '123456'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('OTP code has expired'))),
      );
    });

    test('verifyPasswordResetOtp succeeds with correct and active OTP', () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('password_reset_identifier', 'test@example.com');
      prefs.setString('password_reset_otp', '123456');
      prefs.setInt('password_reset_otp_expiry', DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch);

      // Jika tidak throw error, berarti test lulus
      await expectLater(
        AuthService.verifyPasswordResetOtp(identifier: 'test@example.com', otp: '123456'),
        completes,
      );
    });

    test('register throws error if name is empty', () async {
      expect(
        () => AuthService.register(namaLengkap: '   ', email: 'test@test.com', password: 'Password123!'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('Full name is required'))),
      );
    });

    test('register throws error if email is missing', () async {
      expect(
        () => AuthService.register(namaLengkap: 'Budi', password: 'Password123!'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('Enter email'))),
      );
    });

    test('register rejects offline registration', () async {
      // Karena unit test kita tidak terhubung ke MongoDB betulan, `tryConnect` akan return false.
      // Ekspektasinya: Harus ditolak dan disuruh online.
      expect(
        () => AuthService.register(namaLengkap: 'Budi', email: 'budi@gmail.com', password: 'Password123!'),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', contains('Registration requires an active internet connection'))),
      );
    });

    test('data normalization works for login identifier', () async {
      // Test bahwa input berantakan tetap bisa login kalau emailnya valid
      await HiveService.usersBox.put(testUser.id, testUser);

      // Login dengan spasi dan huruf besar
      final loggedInUser = await AuthService.login(
        identifier: '   TEST@ExaMple.com  ',
        password: 'Password123!',
      );

      expect(loggedInUser.id, 'usr_12345');
    });
  });

  group('PasswordPolicy Unit Tests', () {
    test('validates password correctly', () {
      expect(PasswordPolicy.validate('weak'), isNotNull);
      expect(PasswordPolicy.validate('OnlyLetters'), isNotNull);
      expect(PasswordPolicy.validate('lowercase123!'), isNotNull);
      expect(PasswordPolicy.validate('UPPERCASE123!'), isNotNull);
      
      // Valid password
      expect(PasswordPolicy.validate('StrongPass123!'), isNull);
    });
  });
}
