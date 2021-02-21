import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/withdraw/plasma_withdraw_widget.dart';
import 'package:pollywallet/screens/withdraw/pos_withdraw_widget.dart';

class WithdrawStatus extends StatefulWidget {
  @override
  _WithdrawStatus createState() => _WithdrawStatus();
}

class _WithdrawStatus extends State<WithdrawStatus> {
  String txHash =
      "0x92ce1445874374d68748507975304e681fee8508ac3f40dfa2fdf39b88cfe765";
  BridgeType bridge = BridgeType.POS;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Withdraw From Matic"),
      ),
      body: Column(
        children: [
          PosWithdrawWidget(
            txHash: txHash,
          ),
          PlasmaWithdrawWidget(
              txHash:
                  "0xc6e8d1cc6f2b9ade925fae8122601ba3e3e8dcbfa96a35eed93912de3604ab07",
              tokenAddress: "0x3f152B63Ec5CA5831061B2DccFb29a874C317502",
              withdrawTx:
                  "0x5fc2ed8cd4046f6fdd1345bb1aee932f886220dbfca658457969ed4ad8960af2",
              confirmTx: ""
              // "0x43b97ea1b8f601b8c6d59c8551b21aa1510a0ea0d047839e0db57b5df0d54ea7",
              )
        ],
      ),
    );
  }
}
