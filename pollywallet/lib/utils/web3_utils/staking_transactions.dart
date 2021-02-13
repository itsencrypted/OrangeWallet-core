import 'package:flutter/services.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:web3dart/web3dart.dart';

class StakingTransactions {
  static Future<Transaction> buyVoucher(String amount, String validator) async {
    BigInt _amt = EthConversions.ethToWei(amount);

    String abi = await rootBundle.loadString(stakingContract);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "stakingContract"),
        EthereumAddress.fromHex(validator));
    var buyVoucher = contract.function('buyVoucher');
    var address = await BoxUtils.getAddress();
    var trx = Transaction.callContract(
        contract: contract,
        function: buyVoucher,
        maxGas: 425000,
        from: EthereumAddress.fromHex(address),
        parameters: [_amt, BigInt.one]);

    return trx;
  }
}
