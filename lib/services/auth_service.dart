import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../features/auth/password_policy.dart';
import '../models/db_models.dart';
import 'hive_service.dart';
import 'mongodb_service.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthSession {
  final String userId;
  final String displayName;
  final bool isGuest;
  final String role;
  final String? joinCode;

  const AuthSession({
    required this.userId,
    required this.displayName,
    required this.isGuest,
    required this.role,
    this.joinCode,
  });
}

class AuthService {
  static late SharedPreferences _prefs;

  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // --- Gunakan SharedPreferences untuk stabilitas session ---
  static const String _sessionUserIdKey = 'current_user_id';
  static const String _sessionDisplayNameKey = 'current_user_name';
  static const String _sessionIsGuestKey = 'current_user_is_guest';
  static const String _sessionRoleKey = 'current_user_role';
  static const String _sessionJoinCodeKey = 'current_join_code';
  static const String _passwordResetIdentifierKey = 'password_reset_identifier';
  static const String _passwordResetOtpKey = 'password_reset_otp';
  static const String _onboardingSeenKey = 'has_seen_onboarding';

  static bool get hasSeenOnboarding {
    return _prefs.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingSeenKey, true);
  }

  static AuthSession? get currentSession {
    final userId = _prefs.getString(_sessionUserIdKey);
    final displayName = _prefs.getString(_sessionDisplayNameKey);
    if (userId == null || displayName == null) return null;

    return AuthSession(
      userId: userId,
      displayName: displayName,
      isGuest: _prefs.getBool(_sessionIsGuestKey) ?? false,
      role: _prefs.getString(_sessionRoleKey) ?? 'player',
      joinCode: _prefs.getString(_sessionJoinCodeKey),
    );
  }

  static Future<AppUser> register({
    required String namaLengkap,
    String? email,
    String? nomorHp,
    required String password,
  }) async {
    final normalizedName = namaLengkap.trim();
    final normalizedEmail = _normalizeEmail(email);
    final normalizedPhone = _normalizePhone(nomorHp);
    final normalizedPassword = password.trim();

    if (normalizedName.isEmpty) {
      throw AuthException('Full name is required.');
    }
    final passwordError = PasswordPolicy.validate(normalizedPassword);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }
    if (normalizedEmail == null && normalizedPhone == null) {
      throw AuthException('Enter email or phone number for account recovery.');
    }

    if (!(await MongoDatabase.tryConnect())) {
      throw AuthException('Registration requires an active internet connection.');
    }

    final existingUser = await _findUserByIdentifier(
      email: normalizedEmail,
      phone: normalizedPhone,
    );
    if (existingUser != null) {
      throw AuthException('An account with this email or phone number already exists.');
    }

    final hashedPassword = _hashPassword(normalizedPassword);

    final user = AppUser(
      id: _generateUserId(),
      namaLengkap: normalizedName,
      email: normalizedEmail,
      nomorHp: normalizedPhone,
      password: hashedPassword,
      isGuest: false,
      isSynced: false,
    );

    final syncedUser = await _persistUser(user);
    await _saveSession(
      userId: syncedUser.id,
      displayName: syncedUser.namaLengkap,
      isGuest: false,
      role: 'account',
    );
    return syncedUser;
  }

  static Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    final normalizedIdentifier = identifier.trim();
    if (normalizedIdentifier.isEmpty || password.trim().isEmpty) {
      throw AuthException('Please enter your email/phone number and password.');
    }

    final localUser = _findLocalUser(normalizedIdentifier);
    AppUser? user = localUser;

    if (user == null && await MongoDatabase.tryConnect()) {
      user = await _findRemoteUser(normalizedIdentifier);
      if (user != null) {
        await HiveService.usersBox.put(user.id, user);
      }
    }

    if (user == null) {
      throw AuthException('Account not found.');
    }
    
    final hashedPassword = _hashPassword(password.trim());
    if ((user.password ?? '') != hashedPassword) {
      throw AuthException('Incorrect password.');
    }

    if (!user.isSynced) {
      user = await _persistUser(user);
    }

    await _saveSession(
      userId: user.id,
      displayName: user.namaLengkap,
      isGuest: false,
      role: 'account',
    );
    return user;
  }

  static Future<AppUser> resetPassword({
    required String identifier,
    required String newPassword,
  }) async {
    final normalizedIdentifier = identifier.trim();
    final password = newPassword.trim();

    if (normalizedIdentifier.isEmpty) {
      throw AuthException('Enter email or phone number to recover your account.');
    }
    final passwordError = PasswordPolicy.validate(password);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }

    final user = await _findUserByIdentifier(identifier: normalizedIdentifier);
    if (user == null) {
      throw AuthException('No account found with this information.');
    }

    final hashedPassword = _hashPassword(password);
    final updatedUser = user.copyWith(password: hashedPassword, isSynced: false);
    return _persistUser(updatedUser);
  }

  static Future<String> requestPasswordResetOtp({
    required String identifier,
  }) async {
    final normalizedIdentifier = identifier.trim();
    if (normalizedIdentifier.isEmpty) {
      throw AuthException('Enter email or phone number to recover your account.');
    }

    final user = await _findUserByIdentifier(identifier: normalizedIdentifier);
    if (user == null) {
      throw AuthException('No account found with this information.');
    }

    final otp = _generateOtp();
    await _prefs.setString(_passwordResetIdentifierKey, normalizedIdentifier);
    await _prefs.setString(_passwordResetOtpKey, otp);
    return otp;
  }

  static Future<void> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
  }) async {
    final savedIdentifier = _prefs.getString(_passwordResetIdentifierKey);
    final savedOtp = _prefs.getString(_passwordResetOtpKey);

    if (savedIdentifier == null || savedOtp == null) {
      throw AuthException('OTP code has not been generated. Please restart the process.');
    }
    if (savedIdentifier != identifier.trim()) {
      throw AuthException('Recovery information does not match. Please restart the process.');
    }
    if (savedOtp != otp.trim()) {
      throw AuthException('Invalid OTP code.');
    }
  }

  static Future<AppUser> resetPasswordWithOtp({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    await verifyPasswordResetOtp(identifier: identifier, otp: otp);
    final user = await resetPassword(
      identifier: identifier,
      newPassword: newPassword,
    );
    await _prefs.remove(_passwordResetIdentifierKey);
    await _prefs.remove(_passwordResetOtpKey);
    return user;
  }

  static Future<AuthSession> continueAsGuest({
    required String namaLengkap,
    String? joinCode,
  }) async {
    final normalizedName = namaLengkap.trim();
    final normalizedCode = joinCode?.trim();

    if (normalizedName.isEmpty) {
      throw AuthException('Guest full name is required.');
    }

    final session = AuthSession(
      userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: normalizedName,
      isGuest: true,
      role: 'guest',
      joinCode: normalizedCode?.isEmpty == true ? null : normalizedCode,
    );

    await _saveSession(
      userId: session.userId,
      displayName: session.displayName,
      isGuest: true,
      role: session.role,
      joinCode: session.joinCode,
    );
    return session;
  }

  static Future<void> updateDisplayName(String newName) async {
    final session = currentSession;
    if (session == null) throw AuthException('No active session.');

    final normalized = newName.trim();
    if (normalized.isEmpty) throw AuthException('Name cannot be empty.');

    await _prefs.setString(_sessionDisplayNameKey, normalized);

    if (!session.isGuest) {
      final localUser = HiveService.usersBox.get(session.userId);
      if (localUser != null) {
        final updatedUser = localUser.copyWith(namaLengkap: normalized, isSynced: false);
        await HiveService.usersBox.put(session.userId, updatedUser);
        try {
          if (await MongoDatabase.tryConnect()) {
            final existingRecord = await MongoDatabase.usersCollection.findOne(where.eq('id', session.userId));
            if (existingRecord != null) {
              await MongoDatabase.usersCollection.updateOne(
                where.eq('id', session.userId),
                modify.set('namaLengkap', normalized),
              );
              await HiveService.usersBox.put(session.userId, updatedUser.copyWith(isSynced: true));
            }
          }
        } catch (_) {}
      }
    }
  }

  static Future<void> logout() async {
    await _prefs.remove(_sessionUserIdKey);
    await _prefs.remove(_sessionDisplayNameKey);
    await _prefs.remove(_sessionIsGuestKey);
    await _prefs.remove(_sessionRoleKey);
    await _prefs.remove(_sessionJoinCodeKey);
  }

  static AppUser? _findLocalUser(String identifier) {
    final normalizedEmail = _normalizeEmail(identifier);
    final normalizedPhone = _normalizePhone(identifier);

    for (final user in HiveService.usersBox.values) {
      final matchesEmail = normalizedEmail != null && user.email == normalizedEmail;
      final matchesPhone = normalizedPhone != null && user.nomorHp == normalizedPhone;
      if (matchesEmail || matchesPhone) {
        return user;
      }
    }
    return null;
  }

  static Future<AppUser?> _findUserByIdentifier({
    String? identifier,
    String? email,
    String? phone,
  }) async {
    final localIdentifier = identifier ?? email ?? phone;
    if (localIdentifier != null) {
      final localUser = _findLocalUser(localIdentifier);
      if (localUser != null) return localUser;
    }

    if (!(await MongoDatabase.tryConnect())) return null;

    if (identifier != null) {
      return _findRemoteUser(identifier);
    }

    final filters = <Map<String, Object?>>[];
    if (email != null) {
      filters.add({'email': email});
    }
    if (phone != null) {
      filters.add({'nomor_hp': phone});
    }
    if (filters.isEmpty) return null;

    try {
      final document = await MongoDatabase.usersCollection.findOne({
        r'$or': filters,
      });
      if (document == null) return null;

      final user = AppUser.fromJson(document);
      await HiveService.usersBox.put(user.id, user);
      return user;
    } catch (e) {
      print('Error _findUserByIdentifier remote: $e');
      return null;
    }
  }

  static Future<AppUser?> _findRemoteUser(String identifier) async {
    final normalizedEmail = _normalizeEmail(identifier);
    final normalizedPhone = _normalizePhone(identifier);

    final filters = <Map<String, Object?>>[];
    if (normalizedEmail != null) {
      filters.add({'email': normalizedEmail});
    }
    if (normalizedPhone != null) {
      filters.add({'nomor_hp': normalizedPhone});
    }
    if (filters.isEmpty) return null;

    try {
      final document = await MongoDatabase.usersCollection.findOne({
        r'$or': filters,
      });
      return document == null ? null : AppUser.fromJson(document);
    } catch (e) {
      print('Error _findRemoteUser: $e');
      return null;
    }
  }

  static Future<AppUser> _persistUser(AppUser user) async {
    var storedUser = user;

    if (await MongoDatabase.tryConnect()) {
      await MongoDatabase.usersCollection.replaceOne(
        where.eq('_id', user.id),
        user.toJson(),
        upsert: true,
      );
      storedUser = user.copyWith(isSynced: true);
    }

    await HiveService.usersBox.put(storedUser.id, storedUser);
    return storedUser;
  }

  static Future<void> _saveSession({
    required String userId,
    required String displayName,
    required bool isGuest,
    required String role,
    String? joinCode,
  }) async {
    await _prefs.setString(_sessionUserIdKey, userId);
    await _prefs.setString(_sessionDisplayNameKey, displayName);
    await _prefs.setBool(_sessionIsGuestKey, isGuest);
    await _prefs.setString(_sessionRoleKey, role);
    if (joinCode != null && joinCode.isNotEmpty) {
      await _prefs.setString(_sessionJoinCodeKey, joinCode);
    } else {
      await _prefs.remove(_sessionJoinCodeKey);
    }
  }

  static String? _normalizeEmail(String? value) {
    final trimmed = value?.trim().toLowerCase();
    if (trimmed == null || trimmed.isEmpty || !trimmed.contains('@')) {
      return null;
    }
    return trimmed;
  }

  static String? _normalizePhone(String? value) {
    if (value == null) return null;
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return null;
    return digits;
  }

  static String _generateUserId() {
    final random = Random();
    final suffix = random.nextInt(999999).toString().padLeft(6, '0');
    return 'usr_${DateTime.now().millisecondsSinceEpoch}_$suffix';
  }

  static String _generateOtp() {
    final random = Random();
    return List.generate(8, (_) => random.nextInt(10)).join();
  }
}
