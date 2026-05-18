import 'db_models.dart';

class QuizResult {
  static const int schemaVersion = 1;

  final HasilAkhir hasilAkhir;
  final List<JawabanPeserta> jawabanPeserta;

  QuizResult({
    required this.hasilAkhir,
    required List<JawabanPeserta> jawabanPeserta,
  }) : jawabanPeserta = List.unmodifiable(jawabanPeserta);

  factory QuizResult.fromHive({
    required HasilAkhir hasilAkhir,
    required Iterable<JawabanPeserta> jawabanPeserta,
  }) {
    final filteredAnswers = jawabanPeserta
        .where(
          (answer) =>
              answer.idSesi == hasilAkhir.idSesi &&
              answer.idUser == hasilAkhir.idUser,
        )
        .toList(growable: false);

    return QuizResult(
      hasilAkhir: hasilAkhir,
      jawabanPeserta: filteredAnswers,
    );
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    final version = json['v'];
    if (version != schemaVersion) {
      throw FormatException('Unsupported quiz result schema version: $version');
    }

    final hasilAkhirJson = json['r'];
    final jawabanJson = json['a'];

    if (hasilAkhirJson is! Map) {
      throw const FormatException('Invalid result metadata payload');
    }
    if (jawabanJson is! List) {
      throw const FormatException('Invalid answer list payload');
    }

    return QuizResult(
      hasilAkhir: _hasilAkhirFromCompactJson(
        Map<String, dynamic>.from(hasilAkhirJson),
      ),
      jawabanPeserta: jawabanJson
          .map((entry) {
            if (entry is! Map) {
              throw const FormatException('Invalid answer entry payload');
            }
            return _jawabanFromCompactJson(Map<String, dynamic>.from(entry));
          })
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'v': schemaVersion,
        'r': _hasilAkhirToCompactJson(hasilAkhir),
        'a': jawabanPeserta
            .map(_jawabanToCompactJson)
            .toList(growable: false),
      };

  int get answerCount => jawabanPeserta.length;

  static Map<String, dynamic> _hasilAkhirToCompactJson(HasilAkhir hasilAkhir) =>
      {
        'i': hasilAkhir.id,
        's': hasilAkhir.idSesi,
        'u': hasilAkhir.idUser,
        't': hasilAkhir.totalSkor,
        'p': hasilAkhir.peringkat,
      };

  static HasilAkhir _hasilAkhirFromCompactJson(Map<String, dynamic> json) =>
      HasilAkhir(
        id: json['i'] as String,
        idSesi: json['s'] as String,
        idUser: json['u'] as String,
        totalSkor: json['t'] as int,
        peringkat: json['p'] as int,
      );

  static Map<String, dynamic> _jawabanToCompactJson(
    JawabanPeserta jawaban,
  ) =>
      {
        'i': jawaban.id,
        's': jawaban.idSesi,
        'u': jawaban.idUser,
        'q': jawaban.idSoal,
        'c': jawaban.idPilihanJawaban,
        'w': jawaban.waktuMenjawab,
      };

  static JawabanPeserta _jawabanFromCompactJson(Map<String, dynamic> json) =>
      JawabanPeserta(
        id: json['i'] as String,
        idSesi: json['s'] as String,
        idUser: json['u'] as String,
        idSoal: json['q'] as String,
        idPilihanJawaban: json['c'] as String,
        waktuMenjawab: json['w'] as int,
      );
}
