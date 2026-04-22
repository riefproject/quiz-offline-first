import 'package:hive/hive.dart';

part 'db_models.g.dart';

@HiveType(typeId: 0)
class AppUser extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String namaLengkap;

  AppUser({required this.id, required this.namaLengkap});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['_id'] as String,
    namaLengkap: json['nama_lengkap'] as String,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'nama_lengkap': namaLengkap,
  };
}

@HiveType(typeId: 1)
class Quiz extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String judul;
  @HiveField(2)
  final String deskripsi;
  @HiveField(3)
  final String pembuat;

  Quiz({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.pembuat,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    id: json['_id'] as String,
    judul: json['judul'] as String,
    deskripsi: json['deskripsi'] as String,
    pembuat: json['pembuat'] as String,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'judul': judul,
    'deskripsi': deskripsi,
    'pembuat': pembuat,
  };
}

@HiveType(typeId: 2)
class Soal extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String idQuiz;
  @HiveField(2)
  final String teksSoal;
  @HiveField(3)
  final List<String> idPilihan;
  @HiveField(4)
  final String idJawabanBenar;

  Soal({
    required this.id,
    required this.idQuiz,
    required this.teksSoal,
    required this.idPilihan,
    required this.idJawabanBenar,
  });

  factory Soal.fromJson(Map<String, dynamic> json) => Soal(
    id: json['_id'] as String,
    idQuiz: json['id_quiz'] as String,
    teksSoal: json['teks_soal'] as String,
    idPilihan: List<String>.from(json['id_pilihan']),
    idJawabanBenar: json['id_jawaban_benar'] as String,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'id_quiz': idQuiz,
    'teks_soal': teksSoal,
    'id_pilihan': idPilihan,
    'id_jawaban_benar': idJawabanBenar,
  };
}

@HiveType(typeId: 3)
class PilihanJawaban extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String teksPilihan;

  PilihanJawaban({required this.id, required this.teksPilihan});

  factory PilihanJawaban.fromJson(Map<String, dynamic> json) => PilihanJawaban(
    id: json['_id'] as String,
    teksPilihan: json['teks_pilihan'] as String,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'teks_pilihan': teksPilihan,
  };
}

@HiveType(typeId: 4)
class SesiKuis extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String idQuiz;
  @HiveField(2)
  final DateTime waktuMulai;
  @HiveField(3)
  final DateTime? waktuSelesai;
  @HiveField(4)
  final String status;

  SesiKuis({
    required this.id,
    required this.idQuiz,
    required this.waktuMulai,
    this.waktuSelesai,
    required this.status,
  });

  factory SesiKuis.fromJson(Map<String, dynamic> json) => SesiKuis(
    id: json['_id'] as String,
    idQuiz: json['id_quiz'] as String,
    waktuMulai: DateTime.parse(json['waktu_mulai']),
    waktuSelesai: json['waktu_selesai'] != null ? DateTime.parse(json['waktu_selesai']) : null,
    status: json['status'] as String,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'id_quiz': idQuiz,
    'waktu_mulai': waktuMulai.toIso8601String(),
    'waktu_selesai': waktuSelesai?.toIso8601String(),
    'status': status,
  };
}

@HiveType(typeId: 5)
class PesertaSesi extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String idSesi;
  @HiveField(2)
  final String idUser;

  PesertaSesi({required this.id, required this.idSesi, required this.idUser});

  factory PesertaSesi.fromJson(Map<String, dynamic> json) => PesertaSesi(
    id: json['_id'] as String,
    idSesi: json['id_sesi'] as String,
    idUser: json['id_user'] as String,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'id_sesi': idSesi,
    'id_user': idUser,
  };
}

@HiveType(typeId: 6)
class JawabanPeserta extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String idSesi;
  @HiveField(2)
  final String idUser;
  @HiveField(3)
  final String idSoal;
  @HiveField(4)
  final String idPilihanJawaban;
  @HiveField(5)
  final int waktuMenjawab;

  JawabanPeserta({
    required this.id,
    required this.idSesi,
    required this.idUser,
    required this.idSoal,
    required this.idPilihanJawaban,
    required this.waktuMenjawab,
  });

  factory JawabanPeserta.fromJson(Map<String, dynamic> json) => JawabanPeserta(
    id: json['_id'] as String,
    idSesi: json['id_sesi'] as String,
    idUser: json['id_user'] as String,
    idSoal: json['id_soal'] as String,
    idPilihanJawaban: json['id_pilihan_jawaban'] as String,
    waktuMenjawab: json['waktu_menjawab'] as int,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'id_sesi': idSesi,
    'id_user': idUser,
    'id_soal': idSoal,
    'id_pilihan_jawaban': idPilihanJawaban,
    'waktu_menjawab': waktuMenjawab,
  };
}

@HiveType(typeId: 7)
class HasilAkhir extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String idSesi;
  @HiveField(2)
  final String idUser;
  @HiveField(3)
  final int totalSkor;
  @HiveField(4)
  final int peringkat;

  HasilAkhir({
    required this.id,
    required this.idSesi,
    required this.idUser,
    required this.totalSkor,
    required this.peringkat,
  });

  factory HasilAkhir.fromJson(Map<String, dynamic> json) => HasilAkhir(
    id: json['_id'] as String,
    idSesi: json['id_sesi'] as String,
    idUser: json['id_user'] as String,
    totalSkor: json['total_skor'] as int,
    peringkat: json['peringkat'] as int,
  );
  Map<String, dynamic> toJson() => {
    '_id': id,
    'id_sesi': idSesi,
    'id_user': idUser,
    'total_skor': totalSkor,
    'peringkat': peringkat,
  };
}