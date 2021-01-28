import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';

class SendTokenData {
  final Items token;
  final String amount;
  final String receiver;

  SendTokenData({this.token, this.amount, this.receiver});
}
