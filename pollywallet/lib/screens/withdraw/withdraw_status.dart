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
                  "0xf358fbd43783cff530be3d2d041c21e7c0ab3a1c2508b56c388fe109ecdf9a0a",
              tokenAddress: "0x2d7882beDcbfDDce29Ba99965dd3cdF7fcB10A1e")
        ],
      ),
    );
  }
}
