import 'package:flutter/services.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:web3dart/web3dart.dart';

class WithdrawManager {
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
}
