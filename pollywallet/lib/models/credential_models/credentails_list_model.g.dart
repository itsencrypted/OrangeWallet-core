// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentails_list_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialsListAdapter extends TypeAdapter<CredentialsList> {
  @override
  final int typeId = 2;

  @override
  CredentialsList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialsList()
      ..active = fields[0] as int
      ..credentials = (fields[1] as List)?.cast<CredentialsObject>()
      ..salt = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, CredentialsList obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.active)
      ..writeByte(1)
      ..write(obj.credentials)
      ..writeByte(2)
      ..write(obj.salt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialsListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
