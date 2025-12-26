// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginDataModelAdapter extends TypeAdapter<LoginDataModel> {
  @override
  final typeId = 1;

  @override
  LoginDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginDataModel(
      company: fields[1] as String?,
      pwd: fields[2] as String?,
      user: fields[3] as String?,
      dsn: fields[4] as Dsn?,
      backgroundImage: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginDataModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(1)
      ..write(obj.company)
      ..writeByte(2)
      ..write(obj.pwd)
      ..writeByte(3)
      ..write(obj.user)
      ..writeByte(4)
      ..write(obj.dsn)
      ..writeByte(5)
      ..write(obj.backgroundImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DsnAdapter extends TypeAdapter<Dsn> {
  @override
  final typeId = 2;

  @override
  Dsn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dsn(
      type: fields[1] as String?,
      hostname: fields[2] as String?,
      database: fields[3] as String?,
      username: fields[4] as String?,
      password: fields[5] as String?,
      hostport: (fields[6] as num?)?.toInt(),
      charset: fields[7] as String?,
      prefix: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Dsn obj) {
    writer
      ..writeByte(8)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.hostname)
      ..writeByte(3)
      ..write(obj.database)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(6)
      ..write(obj.hostport)
      ..writeByte(7)
      ..write(obj.charset)
      ..writeByte(8)
      ..write(obj.prefix);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsnAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
