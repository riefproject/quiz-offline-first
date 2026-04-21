class AppUser {
  final String id;
  final String namaLengkap;

  AppUser({
    required this.id,
    required this.namaLengkap,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? json['id'],
      namaLengkap: json['nama_lengkap'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
    };
  }
}

class Quiz {
  final String id;
  final String judul;
  final String deskripsi;
  final String pembuat;

  Quiz({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.pembuat,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'] ?? json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      pembuat: json['pembuat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'pembuat': pembuat,
    };
  }
}

class Soal {
  final String idKuis;
  final String idSoal;
  final String teks;

  Soal({
    required this.idKuis,
    required this.idSoal,
    required this.teks,
  });

  factory Soal.fromJson(Map<String, dynamic> json) {
    return Soal(
      idKuis: json['id_kuis'],
      idSoal: json['_id'] ?? json['id_soal'],
      teks: json['teks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kuis': idKuis,
      'id_soal': idSoal,
      'teks': teks,
    };
  }
}

class PilihanJawaban {
  final String idPilihan;
  final String idSoal;
  final bool isBenar;

  PilihanJawaban({
    required this.idPilihan,
    required this.idSoal,
    required this.isBenar,
  });

  factory PilihanJawaban.fromJson(Map<String, dynamic> json) {
    return PilihanJawaban(
      idPilihan: json['_id'] ?? json['id_pilihan'],
      idSoal: json['id_soal'],
      isBenar: json['is_benar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pilihan': idPilihan,
      'id_soal': idSoal,
      'is_benar': isBenar,
    };
  }
}

class SesiKuis {
  final String idSesi;
  final String idKuis;
  final DateTime waktuMulai;
  final String status;

  SesiKuis({
    required this.idSesi,
    required this.idKuis,
    required this.waktuMulai,
    required this.status,
  });

  factory SesiKuis.fromJson(Map<String, dynamic> json) {
    return SesiKuis(
      idSesi: json['_id'] ?? json['id_sesi'],
      idKuis: json['id_kuis'],
      waktuMulai: DateTime.parse(json['waktu_mulai']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sesi': idSesi,
      'id_kuis': idKuis,
      'waktu_mulai': waktuMulai.toIso8601String(),
      'status': status,
    };
  }
}

class PesertaSesi {
  final String idPesertaSesi;
  final String idSesi;
  final String idPeserta;
  final DateTime waktuGabung;

  PesertaSesi({
    required this.idPesertaSesi,
    required this.idSesi,
    required this.idPeserta,
    required this.waktuGabung,
  });

  factory PesertaSesi.fromJson(Map<String, dynamic> json) {
    return PesertaSesi(
      idPesertaSesi: json['_id'] ?? json['id_peserta_sesi'],
      idSesi: json['id_sesi'],
      idPeserta: json['id_peserta'],
      waktuGabung: DateTime.parse(json['waktu_gabung']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_peserta_sesi': idPesertaSesi,
      'id_sesi': idSesi,
      'id_peserta': idPeserta,
      'waktu_gabung': waktuGabung.toIso8601String(),
    };
  }
}

class JawabanPeserta {
  final String idJawaban;
  final String idPesertaSesi;
  final String idSoal;
  final String idPilihan;
  final DateTime waktuJawabLokal;
  final bool isSynced;

  JawabanPeserta({
    required this.idJawaban,
    required this.idPesertaSesi,
    required this.idSoal,
    required this.idPilihan,
    required this.waktuJawabLokal,
    this.isSynced = false,
  });

  factory JawabanPeserta.fromJson(Map<String, dynamic> json) {
    return JawabanPeserta(
      idJawaban: json['_id'] ?? json['id_jawaban'],
      idPesertaSesi: json['id_peserta_sesi'],
      idSoal: json['id_soal'],
      idPilihan: json['id_pilihan'],
      waktuJawabLokal: DateTime.parse(json['waktu_jawab_lokal']),
      isSynced: json['is_synced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_jawaban': idJawaban,
      'id_peserta_sesi': idPesertaSesi,
      'id_soal': idSoal,
      'id_pilihan': idPilihan,
      'waktu_jawab_lokal': waktuJawabLokal.toIso8601String(),
      'is_synced': isSynced,
    };
  }
}

class HasilAkhir {
  final String idHasil;
  final String idPesertaSesi;
  final int totalSkor;
  final int peringkat;

  HasilAkhir({
    required this.idHasil,
    required this.idPesertaSesi,
    required this.totalSkor,
    required this.peringkat,
  });

  factory HasilAkhir.fromJson(Map<String, dynamic> json) {
    return HasilAkhir(
      idHasil: json['_id'] ?? json['id_hasil'],
      idPesertaSesi: json['id_peserta_sesi'],
      totalSkor: json['total_skor'],
      peringkat: json['peringkat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_hasil': idHasil,
      'id_peserta_sesi': idPesertaSesi,
      'total_skor': totalSkor,
      'peringkat': peringkat,
    };
  }
}