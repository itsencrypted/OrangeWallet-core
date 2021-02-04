import 'package:hive/hive.dart';
import 'package:pollywallet/models/credential_models/credentails_list_model.dart';
import 'package:pollywallet/models/credential_models/credentials_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pollywallet/models/etherscan_models/etherescan_tx_list.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/screens/transaction_list/ethereum_transaction_list.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';

import '../../constants.dart';

class BoxUtils {
  static Future<void> initializeHive() async {
    await Hive.initFlutter("PollyWalletHive");
    Hive.registerAdapter(CredentialsObjectAdapter());
    Hive.registerAdapter(CredentialsListAdapter());
    Hive.registerAdapter(TransactionDetailsAdapter());
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

  static Future<void> addPendingTx(
      String tx, TransactionType type, String to) async {
    var network = await getNetworkConfig();
    var boxName = pendingTxBox + network.toString();
    Box<TransactionDetails> box =
        await Hive.openBox<TransactionDetails>(boxName);
    TransactionDetails txObj = TransactionDetails()
      ..txHash = tx
      ..txType = type.index
      ..network = network
      ..to = to;
    box.put(tx, txObj);
    await box.close();
    return;
  }

  static Future<List<TransactionDetails>> getPendingTx(
      EtherScanTxList merged) async {
    var network = await getNetworkConfig();
    var boxName = pendingTxBox + network.toString();
    Box<TransactionDetails> box =
        await Hive.openBox<TransactionDetails>(boxName);
    var currentPending = List<TransactionDetails>();
    Map<String, TransactionDetails> map = {};
    box.values.forEach((element) {
      bool flag = false;
      for (int i = 0; i < merged.result.length; i++) {
        if (merged.result[i].hash == element.txHash) {
          flag = true;
          break;
        }
      }
      if (!flag) {
        map.putIfAbsent(element.txHash, () => element);
        currentPending.add(element);
      }
    });
    var keys = map.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      try {
        await EthereumTransactions.getTrx(keys[i]);
      } catch (e) {
        print(e.toString());
        map.remove(keys[i]);
      }
    }
    await box.clear();
    box.putAll(map);
    return currentPending;
  }
}
