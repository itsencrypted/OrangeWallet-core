import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/rlp_encode.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_api.dart';
import 'package:web3dart/web3dart.dart';

class WithdrawManagerWeb3 {
  static Future<Transaction> burnTx(String amount, String address) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    String abi = await rootBundle.loadString(childERC20Abi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "ChildERC20"),
        EthereumAddress.fromHex(address));
    var withdraw = contract.function('withdraw');
    var tx = Transaction.callContract(
        contract: contract,
        function: withdraw,
        maxGas: 125000,
        parameters: [_amt]);
    return tx;
  }

  static Future<Transaction> exitPos(String burnTxHash) async {
    String abi = await rootBundle.loadString(rootChainProxyAbi);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    String exitPayload = await WithdrawManagerApi.getPayloadForExit(burnTxHash);

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
}
