import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class CoinListTileWithCard extends StatelessWidget {
  final String name;
  final String ticker;
  final String qoute;
  final String amount;
  final String iconUrl;
  const CoinListTileWithCard(
      {Key key, this.name, this.ticker, this.qoute, this.amount, this.iconUrl})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Card(
        shape: AppTheme.cardShape,
        elevation: AppTheme.cardElevations,
        color: AppTheme.white,
        child: Center(
          child: ListTile(
            leading: FadeInImage.assetNetwork(
              image: iconUrl,
              placeholder: tokenIcon,
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
          ),
        ),
      ),
    );
  }
}
