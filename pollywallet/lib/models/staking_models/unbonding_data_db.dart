import 'package:hive/hive.dart';
part 'unbonding_data_db.g.dart';

@HiveType(typeId: 5)
class UnbondingDataDb extends HiveObject {
  @HiveField(0)
  String validatorAddress;

  @HiveField(1)
  String name;

  @HiveField(2)
  String timeString;

  @HiveField(3)
  String addressChild;

  @HiveField(4)
  String userAddress;

  @HiveField(5)
  BigInt amount;

  @HiveField(6)
  BigInt slippage;
}
