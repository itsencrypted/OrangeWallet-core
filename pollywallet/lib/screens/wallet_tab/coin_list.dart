import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/screens/wallet_tab/coin_list_tile.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';

class CoinListCard extends StatefulWidget {
  final List<Items> tokens;

  const CoinListCard({Key key, @required this.tokens}) : super(key: key);
  @override
  _CoinListCardState createState() => _CoinListCardState();
}

class _CoinListCardState extends State<CoinListCard> {
  int total;
  List<Widget> ls = List<Widget>();
  @override
  void initState() {
    total = widget.tokens.length;
    ls.add(_divider);
    ls.add(_disclaimer);
    ls.addAll(_tiles());
    ls.add(_divider);
    if (total < 5) {
      ls.add(_raisedButton());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevations,
      shape: AppTheme.cardShape,
      color: AppTheme.white,
      child: ExpansionTile(
        title: Text("$total Coins"),
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
  List<Widget> _tiles() {
    var tiles = List<Widget>();
    var index = 0;
    for (Items token in widget.tokens) {
      if (index == 5) {
        break;
      }
      if (token.type == null || token.type != "dust") {
        index++;
        var tile = CoinListTile(
            name: token.contractName,
            ticker: token.contractTickerSymbol,
            qoute: token.quote.toString(),
            iconUrl: token.logoUrl,
            amount: EthConversions.weiToEth(BigInt.parse(token.balance))
                .toString());
        tiles.add(tile);
      }
    }
    return tiles;
  }

  _raisedButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RaisedButton(
          onPressed: _allCoins,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Text("View All Tokens"),
          color: AppTheme.secondaryColor,
        )
      ],
    );
  }

  _allCoins() {
    Navigator.pushNamed(context, coinListRoute);
  }
}
