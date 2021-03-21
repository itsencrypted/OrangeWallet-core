import 'package:flutter/services.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/utils/misc/credential_manager.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

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
      BigInt stake, BigInt shares, String validator) async {
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
        parameters: [stake, stake * BigInt.from(10)]);

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

  static Future<BigInt> getStakingReward(String validatorAddress) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "staking"),
        EthereumAddress.fromHex(validatorAddress));
    var func = contract.function('getLiquidRewards');
    var address = await CredentialManager.getAddress();
    var resp = await client.call(
      contract: contract,
      function: func,
      params: [EthereumAddress.fromHex(address)],
    );
    BigInt reward = resp[0];
    return reward;
  }

  static Future<BigInt> getUnbondedStakeNonce(String validatorAddress) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "staking"),
        EthereumAddress.fromHex(validatorAddress));
    //var func2 = contract.functions('')
    var func2 = contract.function('unbondNonces');
    var address = await CredentialManager.getAddress();
    var resp = await client.call(
      contract: contract,
      function: func2,
      params: [EthereumAddress.fromHex(address)],
    );
    BigInt reward = resp[0];
    return reward;
  }

  static Future<BigInt> getUnbondedStakeStatus(
      String validatorAddress, BigInt nonce) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "staking"),
        EthereumAddress.fromHex(validatorAddress));
    //var func2 = contract.functions('')
    var func2 = contract.function('unbonds_new');
    var address = await CredentialManager.getAddress();
    var resp = await client.call(
      contract: contract,
      function: func2,
      params: [EthereumAddress.fromHex(address), nonce],
    );
    BigInt reward = resp[0];
    return reward;
  }

  static Future<BigInt> getUnbondedStakeStatusLegacy(
      String validatorAddress) async {
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    final client = Web3Client(config.ethEndpoint, http.Client());
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "staking"),
        EthereumAddress.fromHex(validatorAddress));
    //var func2 = contract.functions('')
    var func2 = contract.function('unbonds');
    var address = await CredentialManager.getAddress();
    var resp = await client.call(
      contract: contract,
      function: func2,
      params: [EthereumAddress.fromHex(address)],
    );
    BigInt reward = resp[0];
    return reward;
  }
}
