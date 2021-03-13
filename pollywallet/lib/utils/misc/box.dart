import 'package:hive/hive.dart';
import 'package:pollywallet/models/credential_models/credentails_list_model.dart';
import 'package:pollywallet/models/credential_models/credentials_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pollywallet/models/deposit_models/deposit_transaction_db.dart';
import 'package:pollywallet/models/etherscan_models/etherescan_tx_list.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';

import '../../constants.dart';

class BoxUtils {
  static Future<void> initializeHive() async {
    await Hive.initFlutter("PollyWalletHive");
    Hive.registerAdapter(CredentialsObjectAdapter());
    Hive.registerAdapter(CredentialsListAdapter());
    Hive.registerAdapter(TransactionDetailsAdapter());
    Hive.registerAdapter(DepositTransactionAdapter());
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
    return true;
  }

  static Future<bool> addAccount(
    String privateKey,
    String address,
  ) async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    var mnemonic = box.getAt(0).credentials[0].mnemonic;
    var creds = new CredentialsObject()
      ..address = address
      ..privateKey = privateKey
      ..mnemonic = mnemonic;
    List<CredentialsObject> list = box.getAt(0).credentials;
    list.add(creds);
    CredentialsList credsList = box.getAt(0);
    credsList.credentials = list;
    box.putAt(0, credsList);
    return true;
  }

  static Future<int> getAccountCount() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    return box.getAt(0).credentials.length;
  }

  static Future<bool> setAccount(int id) async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    CredentialsList obj = box.getAt(0);
    obj.active = id;
    box.putAt(0, obj);
    return true;
  }

  static Future<CredentialsObject> getCredentialBox() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    int active = box.getAt(0).active;
    CredentialsObject creds = box.getAt(0).credentials[active];
    return creds;
  }

  static Future<Box<CredentialsList>> getCredentialsListBox() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    return box;
  }

  static Future<int> getActiveId() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    return box.getAt(0).active;
  }

  static Future<List<CredentialsObject>> getCredentialsList() async {
    var box = await Hive.openBox<CredentialsList>(credentialBox);
    List<CredentialsObject> creds = box.getAt(0).credentials;
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

  static Future<Box<int>> getNetworkIdBox() async {
    Box<int> box = await Hive.openBox<int>(networkBox);
    return box;
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

  static Future<void> addDepositTransaction(
      String txhash, String name, String amount) async {
    var network = await getNetworkConfig();
    var boxName = depositTransactionDbBox + network.toString();
    Box<DepositTransaction> box =
        await Hive.openBox<DepositTransaction>(boxName);
    DepositTransaction txObj = DepositTransaction()
      ..txHash = txhash
      ..amount = amount
      ..merged = false
      ..name = name;
    box.put(txhash, txObj);
    await box.close();
    return;
  }

  static Future<void> updateDepositStatus(String txhash) async {
    var network = await getNetworkConfig();
    var boxName = depositTransactionDbBox + network.toString();
    Box<DepositTransaction> box =
        await Hive.openBox<DepositTransaction>(boxName);

    DepositTransaction txObj = box.get(txhash);
    txObj.merged = true;
    txObj.save();
    await box.close();
    return;
  }

  static Future<Box<DepositTransaction>> getDepositTransactionsList() async {
    var network = await getNetworkConfig();
    var boxName = depositTransactionDbBox + network.toString();
    Box<DepositTransaction> box =
        await Hive.openBox<DepositTransaction>(boxName);

    return box;
  }

  static Future<List<TransactionDetails>> getPendingTx(
      EtherScanTxList merged) async {
    var network = await getNetworkConfig();
    var boxName = pendingTxBox + network.toString();
    Box<TransactionDetails> box =
        await Hive.openBox<TransactionDetails>(boxName);
    var currentPending = [];
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

  static Future<void> clear() async {
    var creds = await Hive.openBox<CredentialsList>(credentialBox);
    Box<TransactionDetails> trx1 =
        await Hive.openBox<TransactionDetails>(pendingTxBox + "0");
    Box<TransactionDetails> trx2 =
        await Hive.openBox<TransactionDetails>(pendingTxBox + "1");
    creds.clear();
    trx1.clear();
    trx2.clear();
  }
}
