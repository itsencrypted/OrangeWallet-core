import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/transaction_data/transaction_data.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:orangewallet/utils/misc/notification_helper.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:orangewallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:web3dart/crypto.dart';
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
    if (erc20Address.toString().toLowerCase() == maticAddress.toLowerCase()) {
      EtherAmount balance =
          await client.getBalance(EthereumAddress.fromHex(address));
      return balance.getValueInUnitBI(EtherUnit.wei);
    }
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
      Transaction trx, TransactionData data, BuildContext context) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.endpoint, http.Client());
    String privateKey = await CredentialManager.getPrivateKey(context);
    if (privateKey == null)
      return "failed";
    else {
      try {
        var credentials = await client.credentialsFromPrivateKey(privateKey);
        var rootTokenPos = EthereumTransactions.childToRootPosAddress(data.to);
        var rootTokenPlasma =
            EthereumTransactions.childToRootPlasmaAddress(data.to);
        var txHash = await client.sendTransaction(credentials, trx,
            chainId: config.chainId);
        int networkId = await BoxUtils.getNetworkConfig();
        print(txHash);
        if (data.type == TransactionType.BURNPLASMA ||
            data.type == TransactionType.BURNPOS) {
          var rng = new Random();
          var notifId = rng.nextInt(1000);
          String rootAddress;
          BridgeType bridge;
          if (data.type == TransactionType.BURNPLASMA) {
            rootAddress = await rootTokenPlasma;
            bridge = BridgeType.PLASMA;
            if (networkId == 0) {
              NotificationHelper.timedNotification(
                  notifId,
                  "Ready for exit",
                  "Your ${data.token.contractName} is ready for confirmation.",
                  30,
                  context);
            } else if (networkId == 1) {
              NotificationHelper.timedNotification(
                  notifId,
                  "Ready for exit",
                  "Your ${data.token.contractName} is ready for confirmation.",
                  45,
                  context);
            }
          }
          if (data.type == TransactionType.BURNPOS) {
            if (networkId == 0) {
              NotificationHelper.timedNotification(
                  notifId,
                  "Ready for exit",
                  "Your ${data.token.contractName} is ready for exit.",
                  30,
                  context);
            } else if (networkId == 1) {
              NotificationHelper.timedNotification(
                  notifId,
                  "Ready for exit",
                  "Your ${data.token.contractName} is ready for exit.",
                  45,
                  context);
            }

            rootAddress = await rootTokenPos;
            bridge = BridgeType.POS;
          }
          var userAddres = await CredentialManager.getAddress();
          var strx = await client.getTransactionByHash(txHash);

          BoxUtils.addWithdrawTransaction(
              timestring: DateTime.now().millisecondsSinceEpoch.toString(),
              burnTxHash: txHash,
              type: data.type,
              addressRootToken: rootAddress,
              addressChildToken: data.to,
              amount: data.amount,
              userAddress: userAddres,
              name: data.token.contractName,
              imageUrl: data.token.logoUrl,
              notificationId: notifId,
              bridge: bridge,
              fee: EthConversions.weiToEthUnTrimmed(
                      (strx.gasPrice.getInWei * BigInt.from(strx.gas)), 18)
                  .toString());
        }

        return txHash;
      } catch (e) {
        if (e.toString() ==
            "RPCError: got code -32000 with msg \"insufficient funds for gas * price + value\".") {
          Fluttertoast.showToast(
              msg: "You dont have sufficient MATIC to make transaction",
              toastLength: Toast.LENGTH_LONG);
          return null;
        }
        Fluttertoast.showToast(
            msg: e.toString(), toastLength: Toast.LENGTH_LONG);
        return null;
      }
    }
  }

  static Future<Transaction> transferERC721(
      BigInt id, String erc721Address, String recipient) async {
    String abi = await rootBundle.loadString(erc721Abi);
    String address = await CredentialManager.getAddress();
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc1155"),
        EthereumAddress.fromHex(erc721Address));
    var func = contract.function('transferFrom');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      parameters: [
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(recipient),
        id
      ],
    );
    return trx;
  }

  static Future<BigInt> balanceOfERC1155(
      BigInt id, String erc1155Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.endpoint, http.Client());
    var address = await CredentialManager.getAddress();
    String abi = await rootBundle.loadString(erc1155Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc1155"),
        EthereumAddress.fromHex(erc1155Address));
    var func = contract.function('balanceOf');

    try {
      var status = await client.call(
        contract: contract,
        function: func,
        params: [EthereumAddress.fromHex(address), id],
      );
      print(status);

      return status[0];
    } catch (e) {
      print(e);
      return BigInt.zero;
    }
  }

  static Future<Transaction> transferErc1155(
      BigInt id, BigInt amount, String erc1155Address, String recipient) async {
    String abi = await rootBundle.loadString(erc1155Abi);
    String address = await CredentialManager.getAddress();
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc1155"),
        EthereumAddress.fromHex(erc1155Address));
    var func = contract.function('safeTransferFrom');
    var data = hexToBytes("0x00");
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      parameters: [
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(recipient),
        id,
        amount,
        data
      ],
    );
    return trx;
  }

  static Future<BigInt> getGasPrice() async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.endpoint, http.Client());
    var price = await client.getGasPrice();
    return price.getInWei;
  }
}
