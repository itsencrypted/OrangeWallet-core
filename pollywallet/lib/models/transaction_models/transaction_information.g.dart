// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_information.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionDetailsAdapter extends TypeAdapter<TransactionDetails> {
  @override
  final int typeId = 3;

  @override
  TransactionDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionDetails()
      ..txHash = fields[0] as String
      ..txType = fields[1] as TransactionType
      ..network = fields[2] as int;
  }

  @override
  void write(BinaryWriter writer, TransactionDetails obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.txHash)
      ..writeByte(1)
      ..write(obj.txType)
      ..writeByte(2)
      ..write(obj.network);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
