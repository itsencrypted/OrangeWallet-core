import 'package:hive/hive.dart';
part 'credentials_model.g.dart';

@HiveType(typeId: 0)
class CredentialsObject extends HiveObject {
  @HiveField(0)
  String mnemonic;

  @HiveField(1)
  String privateKey;

  @HiveField(2)
  String address;
}
