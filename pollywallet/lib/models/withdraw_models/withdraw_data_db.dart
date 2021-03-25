import 'package:hive/hive.dart';
import 'package:pollywallet/constants.dart';
part 'withdraw_data_db.g.dart';

@HiveType(typeId: 5)
class WithdrawDataDb extends HiveObject {
  @HiveField(0)
  String burnHash;

  @HiveField(1)
  String amount;

  @HiveField(2)
  int bridge;

  @HiveField(3)
  String name;

  @HiveField(4)
  String timeString;

  @HiveField(5)
  String addressRoot;

  @HiveField(6)
  String addressChild;

  @HiveField(7)
  String fee;

  @HiveField(8)
  String confirmHash;

  @HiveField(9)
  String exitHash;

  @HiveField(10)
  String userAddress;

  @HiveField(11)
  String imageUrl;

  @HiveField(12)
  int notificationId;
  @HiveField(13)
  bool exited;
}
