import 'package:hive/hive.dart';
import 'package:orangewallet/models/credential_models/credentials_model.dart';
part 'credentails_list_model.g.dart';

@HiveType(typeId: 2)
class CredentialsList extends HiveObject {
  @HiveField(0)
  int active;

  @HiveField(1)
  List<CredentialsObject> credentials;

  @HiveField(2)
  String salt;
}
