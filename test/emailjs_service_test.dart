import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:AlpenQuiz/services/emailjs_service.dart';
import 'package:logger/logger.dart';
import 'package:AlpenQuiz/services/logger.dart';

void main() {
  setUpAll(() async {
    log = Logger(printer: PrettyPrinter());
    // Inisialisasi dotenv dummy untuk testing
    dotenv.loadFromString(envString: '''
EMAILJS_SERVICE_ID=test_service_id
EMAILJS_TEMPLATE_ID=test_template_id
EMAILJS_PUBLIC_KEY=test_public_key
EMAILJS_PRIVATE_KEY=test_private_key
''');
  });

  group('EmailJsService Tests', () {
    test('sendOtp sukses mengirim payload yang benar (HTTP 200)', () async {
      bool correctPayloadSent = false;

      // Membuat Mock Client
      final mockClient = MockClient((request) async {
        if (request.url.toString() == 'https://api.emailjs.com/api/v1.0/email/send') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          
          // Verifikasi Payload sesuai ekspektasi
          if (body['service_id'] == 'test_service_id' &&
              body['template_id'] == 'test_template_id' &&
              body['user_id'] == 'test_public_key' &&
              body['accessToken'] == 'test_private_key' &&
              body['template_params']['passcode'] == '123456' &&
              body['template_params']['to_email'] == 'budi@test.com') {
            correctPayloadSent = true;
          }
          
          return http.Response('OK', 200);
        }
        return http.Response('Not Found', 404);
      });

      await EmailJsService.sendOtp(
        toEmail: 'budi@test.com',
        otpCode: '123456',
        expiryTime: '15:00',
        client: mockClient,
      );

      expect(correctPayloadSent, true, reason: 'Payload JSON yang dikirimkan harus sesuai standar EmailJS');
    });

    test('sendOtp tidak mengirim accessToken jika EMAILJS_PRIVATE_KEY kosong', () async {
      dotenv.loadFromString(envString: '''
EMAILJS_SERVICE_ID=test_service_id
EMAILJS_TEMPLATE_ID=test_template_id
EMAILJS_PUBLIC_KEY=test_public_key
EMAILJS_PRIVATE_KEY=
''');

      bool accessTokenOmitted = false;

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        
        // Verifikasi bahwa accessToken TIDAK ADA di dalam payload
        if (!body.containsKey('accessToken')) {
          accessTokenOmitted = true;
        }
        
        return http.Response('OK', 200);
      });

      await EmailJsService.sendOtp(
        toEmail: 'budi@test.com',
        otpCode: '123456',
        expiryTime: '15:00',
        client: mockClient,
      );

      expect(accessTokenOmitted, true, reason: 'accessToken tidak boleh dikirim jika env PRIVATE_KEY kosong');
    });

    test('sendOtp melemparkan EmailJsException jika HTTP 403 (Strict Mode)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('API access in strict mode, but no Private Key was provided', 403);
      });

      expect(
        () => EmailJsService.sendOtp(
          toEmail: 'budi@test.com',
          otpCode: '123456',
          expiryTime: '15:00',
          client: mockClient,
        ),
        throwsA(isA<EmailJsException>().having((e) => e.message, 'message', contains('HTTP 403'))),
      );
    });

    test('sendOtp melemparkan EmailJsException jika koneksi terputus', () async {
      final mockClient = MockClient((request) async {
        throw Exception('No internet connection');
      });

      expect(
        () => EmailJsService.sendOtp(
          toEmail: 'budi@test.com',
          otpCode: '123456',
          expiryTime: '15:00',
          client: mockClient,
        ),
        throwsA(isA<EmailJsException>().having((e) => e.message, 'message', contains('Periksa koneksi internet'))),
      );
    });

    test('sendOtp melemparkan EmailJsException jika dotenv kosong', () async {
      // Mengosongkan env variables dengan nilai kosong agar tidak NotInitializedError
      dotenv.loadFromString(envString: '''
EMAILJS_SERVICE_ID=
EMAILJS_TEMPLATE_ID=
EMAILJS_PUBLIC_KEY=
EMAILJS_PRIVATE_KEY=
''');

      expect(
        () => EmailJsService.sendOtp(
          toEmail: 'budi@test.com',
          otpCode: '123456',
          expiryTime: '15:00',
          // Tidak perlu mock client karena akan gagal sebelum HTTP Request jalan
        ),
        throwsA(isA<EmailJsException>().having((e) => e.message, 'message', contains('EmailJS belum dikonfigurasi'))),
      );

      // Kembalikan dotenv seperti semula untuk tes lain (jika ada)
      dotenv.loadFromString(envString: '''
EMAILJS_SERVICE_ID=test_service_id
EMAILJS_TEMPLATE_ID=test_template_id
EMAILJS_PUBLIC_KEY=test_public_key
EMAILJS_PRIVATE_KEY=test_private_key
''');
    });
  });
}
