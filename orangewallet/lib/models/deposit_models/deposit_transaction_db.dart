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

  @HiveField(4)
  String timeString;

  @HiveField(5)
  String ticker;

  @HiveField(6)
  String imageUrl;

  @HiveField(7)
  String fee;
}
