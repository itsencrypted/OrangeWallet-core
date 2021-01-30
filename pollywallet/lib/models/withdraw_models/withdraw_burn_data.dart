import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/deposit_models/deposit_model.dart';

class WithdrawBurnDataModel {
  final String amount;
  final Items token;
  final Bridge bridge;

  WithdrawBurnDataModel({this.amount, this.token, this.bridge});
}
