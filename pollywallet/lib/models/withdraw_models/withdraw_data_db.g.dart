// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_data_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WithdrawDataDbAdapter extends TypeAdapter<WithdrawDataDb> {
  @override
  final int typeId = 5;

  @override
  WithdrawDataDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WithdrawDataDb()
      ..burnHash = fields[0] as String
      ..amount = fields[1] as String
      ..bridge = fields[2] as int
      ..name = fields[3] as String
      ..timeString = fields[4] as String
      ..addressRoot = fields[5] as String
      ..addressChild = fields[6] as String
      ..fee = fields[7] as String
      ..confirmHash = fields[8] as String
      ..exitHash = fields[9] as String
      ..userAddress = fields[10] as String
      ..imageUrl = fields[11] as String;
  }

  @override
  void write(BinaryWriter writer, WithdrawDataDb obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.burnHash)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.bridge)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.timeString)
      ..writeByte(5)
      ..write(obj.addressRoot)
      ..writeByte(6)
      ..write(obj.addressChild)
      ..writeByte(7)
      ..write(obj.fee)
      ..writeByte(8)
      ..write(obj.confirmHash)
      ..writeByte(9)
      ..write(obj.exitHash)
      ..writeByte(10)
      ..write(obj.userAddress)
      ..writeByte(11)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawDataDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
