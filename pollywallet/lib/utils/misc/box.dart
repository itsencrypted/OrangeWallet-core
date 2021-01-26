import 'package:hive/hive.dart';
import 'package:pollywallet/models/credential_models/credentails_list_model.dart';
import 'package:pollywallet/models/credential_models/credentials_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pollywallet/models/etherscan_models/etherescan_tx_list.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';

import '../../constants.dart';

class BoxUtils {
  static Future<void> initializeHive() async {
    await Hive.initFlutter("PollyWalletHive");
    Hive.registerAdapter(CredentialsObjectAdapter());
    Hive.registerAdapter(CredentialsListAdapter());
  }

  static Future<bool> checkLogin() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    int len = box.length;
    if (len == 0)
      return false;
    else
      return true;
  }

  static Future<bool> setFirstAccount(
      String mnemonic, String privateKey, String address, String salt) async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    int len = box.length;
    var creds = new CredentialsObject()
      ..address = address
      ..privateKey = privateKey
      ..mnemonic = mnemonic;
    var credsList = new CredentialsList()
      ..active = 0
      ..credentials = [creds]
      ..salt = salt;
    if (len == 1) {
      box.putAt(0, credsList);
    } else {
      box.add(credsList);
    }
    print(box.getAt(0).salt);
    print(box.getAt(0).credentials[0].address);
    return true;
  }

  static Future<CredentialsObject> getCredentialBox() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    int active = box.getAt(0).active;
    CredentialsObject creds = box.getAt(0).credentials[active];
    return creds;
  }

  static Future<String> getSalt() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    String salt = box.getAt(0).salt;
    return salt;
  }

  static Future<String> getAddress() async {
    Box<CredentialsList> box =
        await Hive.openBox<CredentialsList>(credentialBox);
    int active = box.getAt(0).active;
    return box.getAt(0).credentials[active].address;
  }

  static Future<int> getNetworkConfig() async {
    Box<int> box = await Hive.openBox<int>(networkBox);
    int id = box.get(networkBox);
    print(id);
    return id;
  }

  static Future<void> setNetworkConfig(int id) async {
    Box<int> box = await Hive.openBox<int>(networkBox);
    box.put(networkBox, id);
    return;
  }

  static Future<void> addPendingTx(String tx, TransactionType type) async {
    var network = await getNetworkConfig();
    var boxName = pendingTxBox + network.toString();
    Box<TransactionDetails> box =
        await Hive.openBox<TransactionDetails>(boxName);
    TransactionDetails txObj = TransactionDetails()
      ..txHash = tx
      ..txType = type
      ..network = network;
    box.put(tx, txObj);
    return;
  }

  static Future<List<String>> getPendingTx(EtherScanTxList merged) async {
    var network = await getNetworkConfig();
    var boxName = pendingTxBox + network.toString();
    Box<List> box = await Hive.openBox<List>(boxName);
    var pendingLs = box.get(boxName);
    var mergedLs = new List<String>();
    merged.result.forEach((element) => mergedLs.add(element.hash));
    var set1 = Set.from(pendingLs);
    var set2 = Set.from(mergedLs);
    var ls = List.from(set1.difference(set2));
    //TODO: Remove merged tx
    return ls;
  }
}
