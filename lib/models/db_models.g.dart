// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      namaLengkap: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaLengkap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizAdapter extends TypeAdapter<Quiz> {
  @override
  final int typeId = 1;

  @override
  Quiz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quiz(
      id: fields[0] as String,
      judul: fields[1] as String,
      deskripsi: fields[2] as String,
      pembuat: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Quiz obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.judul)
      ..writeByte(2)
      ..write(obj.deskripsi)
      ..writeByte(3)
      ..write(obj.pembuat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SoalAdapter extends TypeAdapter<Soal> {
  @override
  final int typeId = 2;

  @override
  Soal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Soal(
      id: fields[0] as String,
      idQuiz: fields[1] as String,
      teksSoal: fields[2] as String,
      idPilihan: (fields[3] as List).cast<String>(),
      idJawabanBenar: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Soal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idQuiz)
      ..writeByte(2)
      ..write(obj.teksSoal)
      ..writeByte(3)
      ..write(obj.idPilihan)
      ..writeByte(4)
      ..write(obj.idJawabanBenar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PilihanJawabanAdapter extends TypeAdapter<PilihanJawaban> {
  @override
  final int typeId = 3;

  @override
  PilihanJawaban read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PilihanJawaban(
      id: fields[0] as String,
      teksPilihan: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PilihanJawaban obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.teksPilihan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PilihanJawabanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SesiKuisAdapter extends TypeAdapter<SesiKuis> {
  @override
  final int typeId = 4;

  @override
  SesiKuis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SesiKuis(
      id: fields[0] as String,
      idQuiz: fields[1] as String,
      waktuMulai: fields[2] as DateTime,
      waktuSelesai: fields[3] as DateTime?,
      status: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SesiKuis obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idQuiz)
      ..writeByte(2)
      ..write(obj.waktuMulai)
      ..writeByte(3)
      ..write(obj.waktuSelesai)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SesiKuisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PesertaSesiAdapter extends TypeAdapter<PesertaSesi> {
  @override
  final int typeId = 5;

  @override
  PesertaSesi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PesertaSesi(
      id: fields[0] as String,
      idSesi: fields[1] as String,
      idUser: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PesertaSesi obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idSesi)
      ..writeByte(2)
      ..write(obj.idUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PesertaSesiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JawabanPesertaAdapter extends TypeAdapter<JawabanPeserta> {
  @override
  final int typeId = 6;

  @override
  JawabanPeserta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JawabanPeserta(
      id: fields[0] as String,
      idSesi: fields[1] as String,
      idUser: fields[2] as String,
      idSoal: fields[3] as String,
      idPilihanJawaban: fields[4] as String,
      waktuMenjawab: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, JawabanPeserta obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idSesi)
      ..writeByte(2)
      ..write(obj.idUser)
      ..writeByte(3)
      ..write(obj.idSoal)
      ..writeByte(4)
      ..write(obj.idPilihanJawaban)
      ..writeByte(5)
      ..write(obj.waktuMenjawab);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JawabanPesertaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HasilAkhirAdapter extends TypeAdapter<HasilAkhir> {
  @override
  final int typeId = 7;

  @override
  HasilAkhir read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HasilAkhir(
      id: fields[0] as String,
      idSesi: fields[1] as String,
      idUser: fields[2] as String,
      totalSkor: fields[3] as int,
      peringkat: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HasilAkhir obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idSesi)
      ..writeByte(2)
      ..write(obj.idUser)
      ..writeByte(3)
      ..write(obj.totalSkor)
      ..writeByte(4)
      ..write(obj.peringkat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HasilAkhirAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
