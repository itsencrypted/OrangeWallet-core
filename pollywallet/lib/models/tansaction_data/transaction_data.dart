import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:web3dart/web3dart.dart';

class TransactionData {
  final Transaction trx;
  final String to;
  final String amount;
  final TransactionType type;

  TransactionData({this.trx, this.to, this.amount, this.type});
  static Map txTypeString = {
    0: "Approve",
    1: "Deposit POS",
    2: "Deposit Plasma",
    3: "Withdraw",
    4: "Stake",
    5: "Send"
  };
}
