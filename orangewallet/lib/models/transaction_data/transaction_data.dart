import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/models/staking_models/validators.dart';
import 'package:web3dart/web3dart.dart';

class TransactionData {
  final Transaction trx;
  final String to;
  final String amount;
  final TransactionType type;
  final BigInt gas;
  final Items token;
  final ValidatorInfo validatorData;
  final List<dynamic> extraData;

  TransactionData(
      {this.trx,
      this.to,
      this.amount,
      this.type,
      this.gas,
      this.token,
      this.extraData,
      this.validatorData});
  static Map txTypeString = {
    0: "Approve",
    1: "Deposit  via POS",
    2: "Deposit via Plasma",
    3: "Burn Token (Plasma)",
    4: "Stake",
    5: "Send",
    6: "Exit (POS)",
    7: "Confirm-Plasma",
    8: "Exit (Plasma)",
    9: "Speed Up",
    10: "Restake",
    11: "Unstake",
    12: "Burn Token (Plasma)",
    13: "Claim Stake"
  };
}

enum TransactionType {
  APPROVE,
  DEPOSITPOS,
  DEPOSITPLASMA,
  BURNPLASMA,
  STAKE,
  SEND,
  EXITPOS,
  CONFIRMPLASMA,
  EXITPLASMA,
  SPEEDUP,
  RESTAKE,
  UNSTAKE,
  BURNPOS,
  CLAIMSTAKE
}
