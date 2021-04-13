import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';

enum Bridge {
  POS,
  PLASMA,
}

class DepositModel {
  final Items token;
  final amount;
  final Bridge bridge;
  final String registry;
  final bool isEth;

  DepositModel(
      {this.token, this.amount, this.bridge, this.registry, this.isEth});
}
