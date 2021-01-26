import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class CoinListTile extends StatelessWidget {
  final String name;
  final String ticker;
  final String qoute;
  final String amount;

  const CoinListTile({Key key, this.name, this.ticker, this.qoute, this.amount})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        tokenIcon,
        height: AppTheme.tokenIconHeight,
        width: AppTheme.tokenIconHeight,
      ),
      title: Text(name, style: AppTheme.title),
      subtitle: Text(ticker, style: AppTheme.subtitle),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "\$$qoute",
            style: AppTheme.balanceMain,
          ),
          Text(
            amount,
            style: AppTheme.balanceSub,
          )
        ],
      ),
    );
  }
}
