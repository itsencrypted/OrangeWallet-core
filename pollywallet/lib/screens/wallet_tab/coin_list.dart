import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class CoinListCard extends StatefulWidget {
  @override
  _CoinListCardState createState() => _CoinListCardState();
}

class _CoinListCardState extends State<CoinListCard> {
  List<Widget> ls = List<Widget>();
  @override
  void initState() {
    ls.add(_divider);
    ls.add(_disclaimer);
    ls.addAll([_listTile]);
    ls.add(_divider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevations,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.cardRadius))),
      color: AppTheme.white,
      child: ExpansionTile(
        title: Text("5 Coins"),
        trailing: Icon(Icons.arrow_forward),
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: 8.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ls,
            ),
          )
        ],
      ),
    );
  }

  Widget _divider = Divider(color: AppTheme.lightText);
  Widget _disclaimer = Container(
      margin: EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Text(
        "Showing coins with balance only",
        style: AppTheme.subtitle,
      ));
  Widget _listTile = ListTile(
    leading: Image.asset(
      tokenIcon,
      height: AppTheme.tokenIconHeight,
      width: AppTheme.tokenIconHeight,
    ),
    title: Text("Tether US", style: AppTheme.title),
    subtitle: Text("USDT", style: AppTheme.subtitle),
    trailing: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "\$1234.2",
          style: AppTheme.balanceMain,
        ),
        Text(
          "1244312",
          style: AppTheme.balanceSub,
        )
      ],
    ),
  );
}
