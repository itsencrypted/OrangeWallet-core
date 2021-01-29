import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollywallet/screens/bridge/deposit_list.dart';
import 'package:pollywallet/screens/bridge/withdraw_list.dart';
import 'package:pollywallet/theme_data.dart';

class BridgeTransfers extends StatefulWidget {
  @override
  _BridgeTransfersState createState() => _BridgeTransfersState();
}

class _BridgeTransfersState extends State<BridgeTransfers> {
  int tabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Move Tokens"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoSegmentedControl<int>(
                    pressedColor: AppTheme.somewhatYellow.withOpacity(0.9),
                    groupValue: tabIndex,
                    selectedColor: AppTheme.somewhatYellow.withOpacity(0.9),
                    borderColor: AppTheme.somewhatYellow.withOpacity(0.01),
                    unselectedColor: AppTheme.somewhatYellow.withOpacity(0.9),
                    padding: EdgeInsets.all(10),
                    children: {
                      0: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                          elevation: tabIndex == 0 ? 1 : 0,
                          color: tabIndex == 0
                              ? AppTheme.backgroundWhite
                              : AppTheme.somewhatYellow.withOpacity(0.01),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text(
                              "Deposit",
                              style: AppTheme.body1,
                            ),
                          ),
                        ),
                      ),
                      1: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                          elevation: tabIndex == 1 ? 1 : 0,
                          color: tabIndex == 1
                              ? AppTheme.backgroundWhite
                              : AppTheme.somewhatYellow.withOpacity(0.01),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: Text(
                              "Withdraw",
                              style: AppTheme.body1,
                            ),
                          ),
                        ),
                      )
                    },
                    onValueChanged: (val) {
                      setState(() {
                        tabIndex = val;
                      });
                    }),
              ],
            ),
            Expanded(
              child: Card(
                  color: AppTheme.white,
                  shape: AppTheme.cardShape,
                  elevation: AppTheme.cardElevations,
                  child:
                      tabIndex == 0 ? DepositTokenList() : WithdrawTokenList()),
            )
          ],
        ));
  }
}
