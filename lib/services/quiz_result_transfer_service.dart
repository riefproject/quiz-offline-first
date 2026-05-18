import 'dart:convert';
import 'dart:io';

import '../models/db_models.dart';
import '../models/quiz_result.dart';
import 'hive_service.dart';

class QuizResultTransferService {
  const QuizResultTransferService._();

  static QuizResult buildFromHive(HasilAkhir hasilAkhir) {
    return QuizResult.fromHive(
      hasilAkhir: hasilAkhir,
      jawabanPeserta: HiveService.jawabanPesertaBox.values,
    );
  }

  static String encodeToQrPayload(QuizResult quizResult) {
    final jsonPayload = jsonEncode(quizResult.toJson());
    final compressedBytes = GZipCodec(
      level: ZLibOption.maxLevel,
    ).encode(utf8.encode(jsonPayload));

    return base64Url.encode(compressedBytes).replaceAll('=', '');
  }

  static QuizResult decodeFromQrPayload(String payload) {
    try {
      final normalizedPayload = _normalizeBase64Payload(payload.trim());
      final compressedBytes = base64Url.decode(normalizedPayload);
      final jsonBytes = gzip.decode(compressedBytes);
      final decodedJson = jsonDecode(utf8.decode(jsonBytes));

      if (decodedJson is! Map<String, dynamic>) {
        if (decodedJson is Map) {
          return QuizResult.fromJson(Map<String, dynamic>.from(decodedJson));
        }
        throw const FormatException('QR payload is not a JSON object');
      }

      return QuizResult.fromJson(decodedJson);
    } on FormatException catch (error, stackTrace) {
      throw QuizResultTransferException(
        'QR payload is invalid or incomplete.',
        cause: error,
        stackTrace: stackTrace,
      );
    } on Object catch (error, stackTrace) {
      throw QuizResultTransferException(
        'Failed to decode QR payload.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> saveToHive(QuizResult quizResult) async {
    await HiveService.hasilAkhirBox.put(
      quizResult.hasilAkhir.id,
      quizResult.hasilAkhir,
    );

    await HiveService.jawabanPesertaBox.putAll({
      for (final jawaban in quizResult.jawabanPeserta) jawaban.id: jawaban,
    });
  }

  static String _normalizeBase64Payload(String payload) {
    if (payload.isEmpty) {
      throw const FormatException('QR payload is empty');
    }

    final remainder = payload.length % 4;
    if (remainder == 0) {
      return payload;
    }

    return '$payload${'=' * (4 - remainder)}';
  }
}

class QuizResultTransferException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const QuizResultTransferException(
    this.message, {
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => message;
}
