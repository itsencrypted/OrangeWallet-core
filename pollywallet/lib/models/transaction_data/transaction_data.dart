import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:web3dart/web3dart.dart';

class TransactionData {
  final Transaction trx;
  final String to;
  final String amount;
  final TransactionType type;
  final BigInt gas;
  final Items token;

  TransactionData(
      {this.trx, this.to, this.amount, this.type, this.gas, this.token});
  static Map txTypeString = {
    0: "Approve",
    1: "Deposit POS",
    2: "Deposit Plasma",
    3: "Burn Token",
    4: "Stake",
    5: "Send",
    6: "Exit-POS",
    7: "Confirm-Plasma",
    8: "Exit-Plasma",
    9: "Speed Up",
    10: "Restake"
  };
}

enum TransactionType {
  APPROVE,
  DEPOSITPOS,
  DEPOSITPLASMA,
  WITHDRAW,
  STAKE,
  SEND,
  EXITPOS,
  CONFIRMPLASMA,
  EXITPLASMA,
  SPEEDUP,
  RESTAKE
}
