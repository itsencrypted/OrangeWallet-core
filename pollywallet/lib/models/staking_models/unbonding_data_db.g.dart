// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unbonding_data_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnbondingDataDbAdapter extends TypeAdapter<UnbondingDataDb> {
  @override
  final int typeId = 6;

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
      ..userAddress = fields[3] as String
      ..amount = fields[4] as BigInt
      ..slippage = fields[5] as BigInt
      ..claimed = fields[6] as bool
      ..validatorId = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, UnbondingDataDb obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.validatorAddress)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.timeString)
      ..writeByte(3)
      ..write(obj.userAddress)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.slippage)
      ..writeByte(6)
      ..write(obj.claimed)
      ..writeByte(7)
      ..write(obj.validatorId);
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
