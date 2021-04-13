import 'package:flutter/material.dart';
import 'package:orangewallet/screens/transaction_list/deposit_list.dart';
import 'package:orangewallet/screens/transaction_list/ethereum_transaction_list.dart';
import 'package:orangewallet/screens/transaction_list/matic_transaction_list.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/widgets/colored_tabbar.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: Text("Transactions List"),
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
                    Tab(
                      child: Align(
                        child: Text(
                          'Deposits',
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TabBarView(
              children: [
                MaticTransactionList(),
                EthereumTransactionList(),
                DepositStatusList()
              ],
            ),
          ),
        ));
  }
}
