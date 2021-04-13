import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orangewallet/screens/bridge/deposit_list.dart';
import 'package:orangewallet/screens/bridge/withdraw_list.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/widgets/colored_tabbar.dart';

class BridgeTransfers extends StatefulWidget {
  @override
  _BridgeTransfersState createState() => _BridgeTransfersState();
}

class _BridgeTransfersState extends State<BridgeTransfers> {
  int tabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              title: Text("Move Tokens"),
              bottom: ColoredTabBar(
                tabBar: TabBar(
                  labelStyle: AppTheme.tabbarTextStyle,
                  unselectedLabelStyle: AppTheme.tabbarTextStyle,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      //gradient: LinearGradient(colors: [Colors.blue, Colors.blue]),
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.white),
                  tabs: [
                    Tab(
                      child: Align(
                        child: Text(
                          'Deposit',
                          style: AppTheme.tabbarTextStyle,
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        child: Text(
                          'Withdraw',
                          style: AppTheme.tabbarTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                borderRadius: AppTheme.cardRadius,
                color: AppTheme.tabbarBGColor,
                tabbarMargin: AppTheme.cardRadius,
                tabbarPadding: AppTheme.paddingHeight / 4,
              )),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("All Tokens", style: AppTheme.subtitle),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                  child: TabBarView(
                    children: [
                      DepositTokenList(),
                      WithdrawTokenList(),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
