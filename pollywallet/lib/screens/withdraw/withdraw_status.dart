import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
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
        ],
      ),
    );
  }
}
