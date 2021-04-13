// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_transaction_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DepositTransactionAdapter extends TypeAdapter<DepositTransaction> {
  @override
  final int typeId = 4;

  @override
  DepositTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DepositTransaction()
      ..txHash = fields[0] as String
      ..amount = fields[1] as String
      ..merged = fields[2] as bool
      ..name = fields[3] as String
      ..timeString = fields[4] as String
      ..ticker = fields[5] as String
      ..imageUrl = fields[6] as String
      ..fee = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, DepositTransaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.txHash)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.merged)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.timeString)
      ..writeByte(5)
      ..write(obj.ticker)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.fee);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepositTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
