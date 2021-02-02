import 'package:flutter/material.dart';
import 'package:pollywallet/screens/transaction_list/matic_transaction_list.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/widgets/colored_tabbar.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
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
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.white),
                  tabs: [
                    Tab(
                      child: Align(
                        child: Text(
                          'Matic',
                          style: AppTheme.tabbarTextStyle,
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        child: Text(
                          'Ethereum',
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
          body: TabBarView(
            children: [MaticTransactionList(), Text("ASda")],
          ),
        ));
  }
}
