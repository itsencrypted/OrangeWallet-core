import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/deposit_models/deposit_model.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
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
      String amount, String erc20Address) async {
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

  static Future<Transaction> depositEthPos(String amount) async {
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
      String amount, String erc20Address) async {
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

  static Future<Transaction> depositEthPlasma(String amount) async {
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
        maxGas: 925000,
        from: EthereumAddress.fromHex(address),
        value: EtherAmount.inWei(_amt),
        parameters: []);

    return trx;
  }

  static Future<Transaction> approveErc20(
      String erc20Address, String spender) async {
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

  static Future<BigInt> bridgeAllowanceERC20(
      String erc20Address, Bridge bridge) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(erc20Abi);
    var address = await CredentialManager.getAddress();
    print(config.ethEndpoint);
    var spender;
    if (bridge == Bridge.POS) {
      spender = config.erc20PredicatePos;
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

  static Future<BigInt> allowance(String spender, String erc20) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(erc20Abi);
    var address = await CredentialManager.getAddress();
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "erc20"), EthereumAddress.fromHex(erc20));
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

  static Future<Transaction> speedUpTransaction(String txHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    TransactionInformation details = await client.getTransactionByHash(txHash);

    double updatedGas =
        (details.gasPrice.getInWei * BigInt.from(10 + 100)) / BigInt.from(100);
    Transaction tx = Transaction(
      to: details.to,
      from: details.from,
      data: details.input,
      value: details.value,
      nonce: details.nonce,
      gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.wei, updatedGas.toInt()),
      maxGas: details.gas,
    );

    return tx;
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

  static Future<String> sendTransaction(
      Transaction trx,
      BigInt gasPrice,
      TransactionType type,
      TransactionData details,
      BuildContext context) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    final networkId = await BoxUtils.getNetworkConfig();
    String privateKey = await CredentialManager.getPrivateKey(context);
    var address = await CredentialManager.getAddress();
    if (privateKey == null)
      return "failed";
    else {
      try {
        var credentials = await client.credentialsFromPrivateKey(privateKey);
        var txHash = await client.sendTransaction(credentials, trx,
            chainId: config.ethChainId);
        if (type != TransactionType.SPEEDUP) {
          BoxUtils.addPendingTx(txHash, type, trx.to.hex);
        }
        if (details.type.index == 1 || details.type.index == 2) {
          var strx = await client.getTransactionByHash(txHash);
          print(strx.gas);
          print(strx.gasPrice.toString());
          BoxUtils.addDepositTransaction(
              txHash,
              details.token.contractName,
              details.amount,
              DateTime.now().toString(),
              details.token.logoUrl,
              details.token.contractTickerSymbol,
              EthConversions.weiToEthUnTrimmed(
                      (strx.gasPrice.getInWei * BigInt.from(strx.gas)), 18)
                  .toString());
        } else if (details.type == TransactionType.CONFIRMPLASMA) {
          BoxUtils.addPlasmaConfirmHash();
          if (networkId == 0) {
          } else if (networkId == 1) {}
        } else if (details.type == TransactionType.EXITPLASMA) {
          BoxUtils.addPlasmaExitHash();
        } else if (details.type == TransactionType.EXITPOS) {
        } else if (details.type == TransactionType.UNSTAKE) {
          BoxUtils.addUnbondTxData(
            amount: details.amount,
            validatorAddress: details.validatorData.contractAddress,
            userAddress: address,
            name: details.validatorData.name,
            timestring:
                (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          );
        }
        return txHash;
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
            msg: e.toString(), toastLength: Toast.LENGTH_LONG);
        return null;
      }
    }
  }

  static Future<TransactionInformation> getTrx(String txHash) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    var trx = client.getTransactionByHash(txHash);
    return trx;
  }

  static Future<BigInt> erc721TokenId(String erc721Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    var address = await CredentialManager.getAddress();
    String abi = await rootBundle.loadString(erc721Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc721"),
        EthereumAddress.fromHex(erc721Address));
    var func = contract.function('tokenOfOwnerByIndex');
    try {
      var id = await client.call(
        contract: contract,
        function: func,
        params: [EthereumAddress.fromHex(address), BigInt.zero],
      );
      return id[0];
    } catch (e) {
      return null;
    }
  }

  static Future<bool> erc721ApprovalStatusPos(String erc721Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    var address = await CredentialManager.getAddress();
    String abi = await rootBundle.loadString(erc721Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc721"),
        EthereumAddress.fromHex(erc721Address));
    var func = contract.function('isApprovedForAll');
    try {
      var status = await client.call(
        contract: contract,
        function: func,
        params: [
          EthereumAddress.fromHex(address),
          EthereumAddress.fromHex(config.erc721PredicatePos)
        ],
      );
      print(status);
      return status[0];
    } catch (e) {
      return false;
    }
  }

  static Future<bool> erc721ApprovalStatusPlasma(String erc721Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    var address = await CredentialManager.getAddress();
    String abi = await rootBundle.loadString(erc721Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc721"),
        EthereumAddress.fromHex(erc721Address));
    var func = contract.function('isApprovedForAll');
    try {
      var status = await client.call(
        contract: contract,
        function: func,
        params: [
          EthereumAddress.fromHex(address),
          EthereumAddress.fromHex(config.depositManager)
        ],
      );
      print(status);

      return status[0];
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<Transaction> erc721Approve(
      BigInt id, String erc721Address, String spender) async {
    String abi = await rootBundle.loadString(erc721Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc721"),
        EthereumAddress.fromHex(erc721Address));
    var func = contract.function('setApprovalForAll');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      parameters: [EthereumAddress.fromHex(spender), true],
    );
    return trx;
  }

  static Future<Transaction> erc721DepositPlasma(
      BigInt id, String erc721Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String abi = await rootBundle.loadString(depositManagerAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "depositManager"),
        EthereumAddress.fromHex(config.depositManager));
    var func = contract.function('depositERC721');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      parameters: [EthereumAddress.fromHex(erc721Address), id],
    );
    return trx;
  }

  static Future<Transaction> erc721DepositPos(
      BigInt id, String erc721Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    var data = RlpEncode.encode(id);
    var address = await CredentialManager.getAddress();
    String abi = await rootBundle.loadString(rootChainProxyAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "rootchain"),
        EthereumAddress.fromHex(config.rootChainProxy));
    var func = contract.function('depositFor');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      parameters: [
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(erc721Address),
        data
      ],
    );
    return trx;
  }

  static Future<BigInt> balanceOfERC1155(
      BigInt id, String erc1155Address) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
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

  static Future<bool> erc1155ApprovalStatus(
      String erc1155Address, String spender) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    var address = await CredentialManager.getAddress();
    String abi = await rootBundle.loadString(erc1155Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc1155"),
        EthereumAddress.fromHex(erc1155Address));
    var func = contract.function('isApprovedForAll');

    try {
      var status = await client.call(
        contract: contract,
        function: func,
        params: [
          EthereumAddress.fromHex(address),
          EthereumAddress.fromHex(spender)
        ],
      );
      print(status);

      return status[0];
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<Transaction> erc1155Approve(
      String erc1155Address, String spender) async {
    String abi = await rootBundle.loadString(erc1155Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "erc1155"),
        EthereumAddress.fromHex(erc1155Address));
    var func = contract.function('setApprovalForAll');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      parameters: [EthereumAddress.fromHex(spender), true],
    );
    return trx;
  }

  static Future<Transaction> depositErc1155Pos(List<BigInt> tokenIdList,
      List<BigInt> amountList, String erc1155Address) async {
    var config = await NetworkManager.getNetworkObject();
    String abi = await rootBundle.loadString(rootChainProxyAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "rootchainProxy"),
        EthereumAddress.fromHex(config.rootChainProxy));
    var data = RlpEncode.erc1155Params(tokenIdList, amountList);
    var address = await CredentialManager.getAddress();
    var func = contract.function('depositFor');
    var trx = Transaction.callContract(
      contract: contract,
      function: func,
      parameters: [
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(erc1155Address),
        data
      ],
    );
    return trx;
  }

  static Future<String> childToRootPlasmaAddress(String erc20Address) async {
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
    return addr[0].toString();
  }

  static Future<String> childToRootPosAddress(String erc20Address) async {
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
    return addr[0].toString();
  }
}
