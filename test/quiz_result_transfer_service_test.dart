import 'package:flutter_test/flutter_test.dart';
import 'package:AlpenQuiz/models/db_models.dart';
import 'package:AlpenQuiz/models/quiz_result.dart';
import 'package:AlpenQuiz/services/quiz_result_transfer_service.dart';

void main() {
  group('QuizResultTransferService', () {
    final hasilAkhir = HasilAkhir(
      id: 'hasil_001',
      idSesi: 'sesi_123',
      idUser: 'murid_456',
      totalSkor: 95,
      peringkat: 1,
    );

    final jawaban = [
      JawabanPeserta(
        id: 'jawab_1',
        idSesi: 'sesi_123',
        idUser: 'murid_456',
        idSoal: 'soal_1',
        idPilihanJawaban: 'opsi_a',
        waktuMenjawab: 12,
      ),
      JawabanPeserta(
        id: 'jawab_2',
        idSesi: 'sesi_123',
        idUser: 'murid_456',
        idSoal: 'soal_2',
        idPilihanJawaban: 'opsi_c',
        waktuMenjawab: 9,
      ),
    ];

    test('encodes and decodes quiz result payload', () {
      final quizResult = QuizResult(
        hasilAkhir: hasilAkhir,
        jawabanPeserta: jawaban,
      );

      final payload = QuizResultTransferService.encodeToQrPayload(quizResult);
      final decoded = QuizResultTransferService.decodeFromQrPayload(payload);

      expect(payload, isNotEmpty);
      expect(decoded.hasilAkhir.id, equals(hasilAkhir.id));
      expect(decoded.hasilAkhir.idSesi, equals(hasilAkhir.idSesi));
      expect(decoded.hasilAkhir.idUser, equals(hasilAkhir.idUser));
      expect(decoded.hasilAkhir.totalSkor, equals(hasilAkhir.totalSkor));
      expect(decoded.hasilAkhir.peringkat, equals(hasilAkhir.peringkat));
      expect(decoded.answerCount, equals(2));
      expect(decoded.jawabanPeserta.first.idSoal, equals('soal_1'));
      expect(decoded.jawabanPeserta.last.idPilihanJawaban, equals('opsi_c'));
    });

    test('throws a typed exception for invalid payload', () {
      expect(
        () => QuizResultTransferService.decodeFromQrPayload('invalid-qr-data'),
        throwsA(isA<QuizResultTransferException>()),
      );
    });
  });
}
