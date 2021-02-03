import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/deposit_models/deposit_model.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/rlp_encode.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

class EthereumTransactions {
  static Future<Transaction> depositErc20Pos(
      String amount, String erc20Address, BuildContext context) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    var amt = RlpEncode.encode(_amt);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();

    String abi = await rootBundle.loadString(rootChainProxyAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "rootchainproxy"),
        EthereumAddress.fromHex(config.rootChainProxy));
    var depositEther = contract.function('depositFor');
    var address = await BoxUtils.getAddress();

    var trx = Transaction.callContract(
        contract: contract,
        function: depositEther,
        maxGas: 125000,
        parameters: [
          EthereumAddress.fromHex(address),
          EthereumAddress.fromHex(erc20Address),
          amt
        ]);

    return trx;
  }

  static Future<Transaction> depositEthPos(
      String amount, BuildContext context) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();

    String abi = await rootBundle.loadString(rootChainProxyAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "rootchainproxy"),
        EthereumAddress.fromHex(config.rootChainProxy));
    var depositEther = contract.function('depositEtherFor');
    var address = await BoxUtils.getAddress();
    var trx = Transaction.callContract(
        contract: contract,
        function: depositEther,
        from: EthereumAddress.fromHex(address),
        maxGas: 125000,
        value: EtherAmount.inWei(_amt),
        parameters: [EthereumAddress.fromHex(address)]);
    return trx;
  }

  static Future<Transaction> depositErc20Plasma(
      String amount, String erc20Address, BuildContext context) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();

    String abi = await rootBundle.loadString(depositManagerAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "depositManger"),
        EthereumAddress.fromHex(config.depositManager));
    var depositEther = contract.function('depositERC20');
    var address = await BoxUtils.getAddress();
    var _amt = EthConversions.ethToWei(amount);
    //var amt = RlpEncode.encode(_amt);

    var trx = Transaction.callContract(
        contract: contract,
        function: depositEther,
        maxGas: 225000,
        from: EthereumAddress.fromHex(address),
        parameters: [EthereumAddress.fromHex(erc20Address), _amt]);
    return trx;
  }

  static Future<Transaction> depositEthPlasma(
      String amount, BuildContext context) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();

    String abi = await rootBundle.loadString(rootChainAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "depositManger"),
        EthereumAddress.fromHex(config.depositManager));
    var depositEther = contract.function('depositEther');
    var address = await BoxUtils.getAddress();
    var trx = Transaction.callContract(
        contract: contract,
        function: depositEther,
        maxGas: 125000,
        from: EthereumAddress.fromHex(address),
        value: EtherAmount.inWei(_amt),
        parameters: []);

    return trx;
  }

  static Future<Transaction> approveErc20(
      String erc20Address, String spender, BuildContext context) async {
    String abi = await rootBundle.loadString(erc20Abi);
    print(erc20Address);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc20"),
        EthereumAddress.fromHex(erc20Address));
    var approve = contract.function('approve');

    var trx = Transaction.callContract(
        contract: contract,
        function: approve,
        maxGas: 210000,
        parameters: [EthereumAddress.fromHex(spender), BigInt.parse(uintMax)]);
    return trx;
  }

  static Future<BigInt> balanceOf(String erc20Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    var address = await CredentialManager.getAddress();
    if (erc20Address.toString().toLowerCase() == ethAddress.toLowerCase()) {
      EtherAmount balance =
          await client.getBalance(EthereumAddress.fromHex(address));
      return balance.getValueInUnitBI(EtherUnit.wei);
    }
    String abi = await rootBundle.loadString(erc20Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc20"),
        EthereumAddress.fromHex(erc20Address));
    var func = contract.function('balanceOf');
    var balance = await client.call(
      contract: contract,
      function: func,
      params: [EthereumAddress.fromHex(address)],
    );
    return balance[0];
  }

  static Future<BigInt> allowanceERC20(
      String erc20Address, Bridge bridge) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(erc20Abi);
    var address = await CredentialManager.getAddress();
    print(config.ethEndpoint);
    var spender;
    if (bridge == Bridge.POS) {
      spender = config.erc20Predicate;
    } else {
      spender = config.depositManager;
    }
    print(spender);
    print(erc20Address);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc20"),
        EthereumAddress.fromHex(erc20Address));
    var func = contract.function('allowance');
    var balance = await client.call(
      contract: contract,
      function: func,
      params: [
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(spender)
      ],
    );
    print(balance);
    return balance[0];
  }

  static Future<String> speedUpTransaction(String txHash, int gasPercent,
      TransactionType type, BuildContext context) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    TransactionInformation details = await client.getTransactionByHash(txHash);
    String privateKey = await CredentialManager.getPrivateKey(context);
    if (privateKey == null)
      return "failed";
    else {
      double updatedGas =
          (details.gasPrice.getInWei * BigInt.from(gasPercent + 100)) /
              BigInt.from(100);
      var credentials = await client.credentialsFromPrivateKey(privateKey);
      Transaction tx = Transaction(
        to: details.to,
        from: details.from,
        data: details.input,
        value: details.value,
        nonce: details.nonce,
        gasPrice:
            EtherAmount.fromUnitAndValue(EtherUnit.wei, updatedGas.toInt()),
        maxGas: 2100,
      );

      var transaction = await client.sendTransaction(credentials, tx);
      return transaction;
    }
  }

  static Future<TransactionReceipt> txStatus(String txHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    print(config.ethEndpoint);
    print(config.ethWebsocket);
    final client =
        Web3Client(config.ethEndpoint, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(config.ethWebsocket).cast<String>();
    });
    final client2 = Web3Client(config.ethEndpoint, http.Client());
    TransactionReceipt transactionReceipt;
    StreamSubscription streamSubscription;

    streamSubscription = client.addedBlocks().listen(null);
    streamSubscription.onData((data) async {
      var tx = await client2.getTransactionReceipt(txHash);
      print(tx);
      if (tx != null) {
        transactionReceipt = tx;
        streamSubscription.cancel();
      }
    });
    await streamSubscription.asFuture();
    print("cancel");
    return transactionReceipt;
  }

  static Future<bool> checkPlasmaMapping(String erc20Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(plasmaRegistryAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "registry"),
        EthereumAddress.fromHex(config.plasmaRegistry));
    var func = contract.function('rootToChildToken');
    var addr = await client.call(
      contract: contract,
      function: func,
      params: [EthereumAddress.fromHex(erc20Address)],
    );
    print(erc20Address);
    print(addr);
    if (addr[0].toString() == "0x0000000000000000000000000000000000000000") {
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> childToRootPlasma(String erc20Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(plasmaRegistryAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "registry"),
        EthereumAddress.fromHex(config.plasmaRegistry));
    var func = contract.function('childToRootToken');
    var addr = await client.call(
      contract: contract,
      function: func,
      params: [EthereumAddress.fromHex(erc20Address)],
    );
    print(erc20Address);
    print(addr);
    if (addr[0].toString() == "0x0000000000000000000000000000000000000000") {
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> checkPosMapping(String erc20Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(rootChainProxyAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "proxy"),
        EthereumAddress.fromHex(config.rootChainProxy));
    var func = contract.function('rootToChildToken');
    print(erc20Address);

    var addr = await client.call(
      contract: contract,
      function: func,
      params: [EthereumAddress.fromHex(erc20Address)],
    );
    print(addr);
    if (addr[0].toString() == "0x0000000000000000000000000000000000000000") {
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> childToRootPos(String erc20Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(rootChainProxyAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "proxy"),
        EthereumAddress.fromHex(config.rootChainProxy));
    var func = contract.function('childToRootToken');
    print(erc20Address);

    var addr = await client.call(
      contract: contract,
      function: func,
      params: [EthereumAddress.fromHex(erc20Address)],
    );
    print(addr);
    if (addr[0].toString() == "0x0000000000000000000000000000000000000000") {
      return false;
    } else {
      return true;
    }
  }

  static Future<BigInt> getGasPrice() async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    var price = await client.getGasPrice();
    return price.getInWei;
  }

  static Future<String> sendTransaction(Transaction trx, BigInt gasPrice,
      TransactionType type, BuildContext context) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String privateKey = await CredentialManager.getPrivateKey(context);
    if (privateKey == null)
      return "failed";
    else {
      try {
        var credentials = await client.credentialsFromPrivateKey(privateKey);
        var txHash = await client.sendTransaction(credentials, trx,
            chainId: config.ethChainId);
        BoxUtils.addPendingTx(txHash, type, trx.to.hex);
        return txHash;
      } catch (e) {
        Fluttertoast.showToast(
            msg: e.toString(), toastLength: Toast.LENGTH_LONG);
        return null;
      }
    }
  }
}
