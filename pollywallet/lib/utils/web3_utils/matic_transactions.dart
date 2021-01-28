import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'eth_conversions.dart';
import 'package:web_socket_channel/io.dart';

class MaticTransactions {
  static Future<Transaction> transferMatic(
      String amount, String recipient, BuildContext context) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    print(_amt);
    var trx = Transaction(
        to: EthereumAddress.fromHex(recipient),
        maxGas: 21000,
        value: EtherAmount.fromUnitAndValue(EtherUnit.wei, _amt));
    return trx;
  }

  static Future<Transaction> transferERC20(String amount, String recipient,
      String erc20Address, BuildContext context) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    print(_amt);

    String abi = await rootBundle.loadString(erc20Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "ERC20"),
        EthereumAddress.fromHex(erc20Address));
    var transfer = contract.function('transfer');
    var trx = Transaction.callContract(
        contract: contract,
        function: transfer,
        maxGas: 210000,
        parameters: [EthereumAddress.fromHex(recipient.trim()), _amt]);
    return trx;
  }

  static Future<BigInt> balanceOf(String erc20Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.endpoint, http.Client());
    String abi = await rootBundle.loadString(erc20Abi);
    var address = await CredentialManager.getAddress();
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

  static Future<TransactionReceipt> txStatus(String txHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client =
        Web3Client(config.endpoint, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(config.maticWebsocket).cast<String>();
    });
    TransactionReceipt transactionReceipt;
    StreamSubscription streamSubscription;
    streamSubscription = client.addedBlocks().listen((event) async {
      var tx = await client.getTransactionReceipt(txHash);
      if (tx != null) {
        transactionReceipt = tx;
        await streamSubscription.cancel();
      }
    });
    await streamSubscription.asFuture();
    return transactionReceipt;
  }

  static Future<String> sendTransaction(
      Transaction trx, BuildContext context) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.endpoint, http.Client());
    String privateKey = await CredentialManager.getPrivateKey(context);
    if (privateKey == null)
      return "failed";
    else {
      var credentials = await client.credentialsFromPrivateKey(privateKey);
      var txHash = await client.sendTransaction(credentials, trx,
          chainId: config.chainId);
      print(txHash);
      return txHash;
    }
  }
}
