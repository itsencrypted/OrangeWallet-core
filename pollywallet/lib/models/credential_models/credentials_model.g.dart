// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialsObjectAdapter extends TypeAdapter<CredentialsObject> {
  @override
  final int typeId = 0;

  @override
  CredentialsObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialsObject()
      ..mnemonic = fields[0] as String
      ..privateKey = fields[1] as String
      ..address = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, CredentialsObject obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.mnemonic)
      ..writeByte(1)
      ..write(obj.privateKey)
      ..writeByte(2)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
