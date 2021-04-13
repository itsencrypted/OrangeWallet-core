import 'package:flutter/services.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/misc/credential_manager.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';
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
    var withdraw = contract.function('withdrawRewards');
    var address = await BoxUtils.getAddress();
    var trx = Transaction.callContract(
        contract: contract,
        function: withdraw,
        maxGas: 425000,
        from: EthereumAddress.fromHex(address),
        parameters: []);

    return trx;
  }

  static Future<Transaction> claimStake(
      String validator, BigInt nonce, bool legacy) async {
    String abi = await rootBundle.loadString(stakingContractAbi);
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "stakingContract"),
        EthereumAddress.fromHex(validator));
    var address = await BoxUtils.getAddress();
    if (legacy) {
      var claim = contract.function('unstakeClaimTokens');
      var trx = Transaction.callContract(
          contract: contract,
          function: claim,
          maxGas: 425000,
          from: EthereumAddress.fromHex(address),
          parameters: []);

      return trx;
    } else {
      var claim = contract.function('unstakeClaimTokens_new');
      var trx = Transaction.callContract(
          contract: contract,
          function: claim,
          maxGas: 425000,
          from: EthereumAddress.fromHex(address),
          parameters: [nonce]);

      return trx;
    }
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

  static Future<dynamic> getUnbondedStakeStatus(
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
    return resp;
  }

  static Future<dynamic> getUnbondedStakeStatusLegacy(
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
    return resp;
  }

  static Future<dynamic> stakeClaimData(String validatorAddress) async {
    var nonce = BigInt.zero;
    try {
      nonce = await getUnbondedStakeNonce(validatorAddress);
      print(nonce);
    } catch (e) {
      var resp = await getUnbondedStakeStatusLegacy(validatorAddress);
      print(resp);
      return;
    }
    if (nonce == BigInt.zero) {
      var resp = await getUnbondedStakeStatusLegacy(validatorAddress);
      print(resp);
      return [resp, nonce, true];
    } else {
      var resp = await getUnbondedStakeStatus(validatorAddress, nonce);
      print(resp);
      return [resp, nonce, false];
    }
  }
}
