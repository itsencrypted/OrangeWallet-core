import 'package:hive/hive.dart';
part 'unbonding_data_db.g.dart';

@HiveType(typeId: 6)
class UnbondingDataDb extends HiveObject {
  @HiveField(0)
  String validatorAddress;

  @HiveField(1)
  String name;

  @HiveField(2)
  String timeString;

  @HiveField(3)
  String userAddress;

  @HiveField(4)
  BigInt amount;

  @HiveField(5)
  BigInt slippage;

  @HiveField(6)
  bool claimed;

  @HiveField(7)
  int validatorId;

  @HiveField(8)
  int notificationId;
}
