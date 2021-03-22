// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unbonding_data_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnbondingDataDbAdapter extends TypeAdapter<UnbondingDataDb> {
  @override
  final int typeId = 5;

  @override
  UnbondingDataDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnbondingDataDb()
      ..validatorAddress = fields[0] as String
      ..name = fields[1] as String
      ..timeString = fields[2] as String
      ..addressChild = fields[3] as String
      ..userAddress = fields[4] as String
      ..amount = fields[5] as BigInt
      ..slippage = fields[6] as BigInt;
  }

  @override
  void write(BinaryWriter writer, UnbondingDataDb obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.validatorAddress)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.timeString)
      ..writeByte(3)
      ..write(obj.addressChild)
      ..writeByte(4)
      ..write(obj.userAddress)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.slippage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnbondingDataDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
