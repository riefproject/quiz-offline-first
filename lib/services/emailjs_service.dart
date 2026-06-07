import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'logger.dart';

/// Layanan pengiriman email melalui EmailJS API.
///
/// Digunakan untuk mengirim kode OTP reset password ke email pengguna.
class EmailJsService {
  static const String _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  static String get _serviceId => dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static String get _templateId => dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static String get _publicKey => dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';
  static String get _privateKey => dotenv.env['EMAILJS_PRIVATE_KEY'] ?? '';

  /// Mengirim kode OTP ke alamat email [toEmail].
  ///
  /// Parameter [templateParams] adalah map variabel yang akan diinjeksi
  /// ke dalam template EmailJS (misal: `passcode`, `time`, `to_email`).
  ///
  /// Melempar [EmailJsException] jika pengiriman gagal.
  static Future<void> sendOtp({
    required String toEmail,
    required String otpCode,
    required String expiryTime,
    http.Client? client,
  }) async {
    if (_serviceId.isEmpty || _templateId.isEmpty || _publicKey.isEmpty) {
      throw EmailJsException(
        'EmailJS belum dikonfigurasi. Pastikan EMAILJS_SERVICE_ID, '
        'EMAILJS_TEMPLATE_ID, dan EMAILJS_PUBLIC_KEY ada di file .env',
      );
    }

    final bodyParams = <String, dynamic>{
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': {
        'passcode': otpCode,
        'time': expiryTime,
        'to_email': toEmail,
      },
    };

    if (_privateKey.isNotEmpty) {
      bodyParams['accessToken'] = _privateKey;
    }

    final body = jsonEncode(bodyParams);

    try {
      final uri = Uri.parse(_apiUrl);
      final headers = {'Content-Type': 'application/json'};
      
      final response = client != null
          ? await client.post(uri, headers: headers, body: body)
          : await http.post(uri, headers: headers, body: body);

      if (response.statusCode != 200) {
        log.e('EmailJS error: ${response.statusCode} — ${response.body}');
        throw EmailJsException(
          'Gagal mengirim email OTP (HTTP ${response.statusCode}): ${response.body}',
        );
      }

      log.i('OTP berhasil dikirim ke $toEmail');
    } catch (e) {
      if (e is EmailJsException) rethrow;
      log.e('EmailJS network error: $e');
      throw EmailJsException(
        'Tidak dapat mengirim email. Periksa koneksi internet Anda.',
      );
    }
  }
}

class EmailJsException implements Exception {
  final String message;

  EmailJsException(this.message);

  @override
  String toString() => message;
}
