import 'package:hive/hive.dart';
part 'deposit_transaction_db.g.dart';

@HiveType(typeId: 4)
class DepositTransaction extends HiveObject {
  @HiveField(0)
  String txHash;

  @HiveField(1)
  String amount;

  @HiveField(2)
  bool merged;

  @HiveField(3)
  String name;
}
