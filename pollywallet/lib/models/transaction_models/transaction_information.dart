import 'package:hive/hive.dart';
part 'transaction_information.g.dart';

@HiveType(typeId: 3)
class TransactionDetails extends HiveObject {
  @HiveField(0)
  String txHash;

  @HiveField(1)
  int txType;

  @HiveField(2)
  int network;
  @HiveField(3)
  String to; //0 testnet 1 mainnet

}

enum TransactionType {
  APPROVE,
  DEPOSITPOS,
  DEPOSITPLASMA,
  WITHDRAW,
  STAKE,
  SEND,
  EXITPOS,
  CONFIRMPLASMA,
  EXITPLASMA,
  SPEEDUP,
  RESTAKE
}
