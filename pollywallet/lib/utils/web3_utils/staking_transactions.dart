import 'package:flutter/services.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:web3dart/web3dart.dart';

class StakingTransactions {
  static Future<Transaction> buyVoucher(String amount, String validator) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    BigInt slippage = BigInt.from((_amt * BigInt.from(10)) / BigInt.from(100));
    String abi = await rootBundle.loadString(stakingContractAbi);
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
        parameters: [_amt, slippage]);

    return trx;
  }

  static Future<Transaction> sellVoucher(
      String amount, String validator) async {
    BigInt _amt = EthConversions.ethToWei(amount);
    BigInt slippage = _amt * BigInt.from(10);
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "stakingContract"),
        EthereumAddress.fromHex(validator));
    var buyVoucher = contract.function('sellVoucher');
    var address = await BoxUtils.getAddress();
    var trx = Transaction.callContract(
        contract: contract,
        function: buyVoucher,
        maxGas: 425000,
        from: EthereumAddress.fromHex(address),
        parameters: [_amt, slippage]);

    return trx;
  }

  static Future<Transaction> restake(String validator) async {
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "stakingContract"),
        EthereumAddress.fromHex(validator));
    var restake = contract.function('restake');
    var address = await BoxUtils.getAddress();
    var trx = Transaction.callContract(
        contract: contract,
        function: restake,
        maxGas: 425000,
        from: EthereumAddress.fromHex(address),
        parameters: []);

    return trx;
  }

  static Future<Transaction> withdrawRewards(String validator) async {
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "stakingContract"),
        EthereumAddress.fromHex(validator));
    var restake = contract.function('withdrawRewards');
    var address = await BoxUtils.getAddress();
    var trx = Transaction.callContract(
        contract: contract,
        function: restake,
        maxGas: 425000,
        from: EthereumAddress.fromHex(address),
        parameters: []);

    return trx;
  }
}
