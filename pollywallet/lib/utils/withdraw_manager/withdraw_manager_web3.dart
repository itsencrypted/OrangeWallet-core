import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/rlp_encode.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_api.dart';
import 'package:web3dart/web3dart.dart';

class WithdrawManagerWeb3 {
  static Future<Transaction> burnTx(String amount, String address) async {
    if (address == "0x0000000000000000000000000000000000001010") {
      BigInt _amt = EthConversions.ethToWei(amount);
      String abi = await rootBundle.loadString(mrc20Abi);

      final contract = DeployedContract(
          ContractAbi.fromJson(abi, "mrc20"), EthereumAddress.fromHex(address));
      var withdraw = contract.function('withdraw');
      var tx = Transaction.callContract(
          contract: contract,
          function: withdraw,
          maxGas: 925000,
          value: EtherAmount.inWei(_amt),
          parameters: [_amt]);
      return tx;
    }
    BigInt _amt = EthConversions.ethToWei(amount);
    String abi = await rootBundle.loadString(childERC20Abi);

    final contract = DeployedContract(ContractAbi.fromJson(abi, "ChildERC20"),
        EthereumAddress.fromHex(address));
    var withdraw = contract.function('withdraw');
    var tx = Transaction.callContract(
        contract: contract,
        function: withdraw,
        maxGas: 925000,
        parameters: [_amt]);
    return tx;
  }

  static Future<Transaction> burnErc721(String address, String tokenId) async {
    String abi = await rootBundle.loadString(erc721ChildAbi);

    final contract = DeployedContract(ContractAbi.fromJson(abi, "ChildERC721"),
        EthereumAddress.fromHex(address));
    var withdraw = contract.function('withdraw');
    var tx = Transaction.callContract(
        contract: contract,
        function: withdraw,
        maxGas: 925000,
        parameters: [BigInt.parse(tokenId)]);
    return tx;
  }

  static Future<Transaction> exitPos(String burnTxHash) async {
    String abi = await rootBundle.loadString(rootChainProxyAbi);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String exitPayload =
        await WithdrawManagerApi.getPayloadForExitPos(burnTxHash);
    if (exitPayload == null) {
      Fluttertoast.showToast(msg: "Something went wrong");
      return null;
    }

    var uint8List = RlpEncode.encodeHex(exitPayload);
    if (exitPayload == null) {
      return null;
    }
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "rootchainproxy"),
        EthereumAddress.fromHex(config.rootChainProxy));
    var exit = contract.function('exit');
    var tx = Transaction.callContract(
        contract: contract,
        function: exit,
        maxGas: 925000,
        parameters: [uint8List]);
    return tx;
  }

  static Future<Transaction> initiateExitPlasma(String burnTxHash) async {
    String abi = await rootBundle.loadString(erc20PredicateAbi);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String exitPayload =
        await WithdrawManagerApi.getPayloadForExitPlasma(burnTxHash);

    var uint8List = RlpEncode.encodeHex(exitPayload);
    if (exitPayload == null) {
      Fluttertoast.showToast(msg: "Something went wrong");

      return null;
    }
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "erc20predicate"),
        EthereumAddress.fromHex(config.erc20PredicatePlasma));
    var exit = contract.function('startExitWithBurntTokens');
    var tx = Transaction.callContract(
        contract: contract,
        function: exit,
        maxGas: 925000,
        parameters: [uint8List]);
    return tx;
  }

  static Future<Transaction> exitPlasma(String token) async {
    String abi = await rootBundle.loadString(withdrawManagerAbi);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();

    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "withdrawmanager"),
        EthereumAddress.fromHex(config.withdrawManagerProxy));
    var exit = contract.function('processExits');
    var tx = Transaction.callContract(
        contract: contract,
        function: exit,
        maxGas: 925000,
        parameters: [EthereumAddress.fromHex(token)]);
    return tx;
  }

  static Future<Transaction> burnERC1155(
      String address, List<BigInt> tokenIds, List<BigInt> amounts) async {
    String abi = await rootBundle.loadString(erc1155ChildAbi);

    final contract = DeployedContract(ContractAbi.fromJson(abi, "childERC1155"),
        EthereumAddress.fromHex(address));
    var withdraw = contract.function('withdrawBatch');
    var tx = Transaction.callContract(
        contract: contract,
        function: withdraw,
        maxGas: 925000,
        parameters: [tokenIds, amounts]);
    return tx;
  }
}
