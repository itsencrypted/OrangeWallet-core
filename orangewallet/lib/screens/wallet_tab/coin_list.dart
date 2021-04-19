import 'package:flutter/material.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/screens/wallet_tab/coin_list_tile.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';

class CoinListCard extends StatelessWidget {
  final List<Items> tokens;
  CoinListCard({Key key, @required this.tokens}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total;
    List<Widget> ls = List<Widget>();
    total = tokens.where((element) => element.nftData == null).length;
    ls.add(_divider);
    ls.add(_disclaimer);
    ls.addAll(_tiles());
    //ls.add(_divider);
    if (total > 5) {
      ls.add(_raisedButton(context));
    }
    return Card(
      elevation: AppTheme.cardElevations,
      shape: AppTheme.cardShape,
      color: AppTheme.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            "$total Coins",
            style: AppTheme.label_medium,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 15,
            color: AppTheme.grey,
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 0, right: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ls,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _divider = Padding(
    padding: EdgeInsets.symmetric(
      horizontal: 0,
    ),
    child: Divider(thickness: 1, color: AppTheme.lightDividerColor),
  );
  Widget _disclaimer = Container(
      margin: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Text(
        "Showing coins with balance only",
        style: AppTheme.subtitle,
      ));
  List<Widget> _tiles() {
    var tiles = List<Widget>();
    var ls = tokens.where((element) => element.nftData == null);
    var index = 0;
    for (Items token in ls) {
      if (index == 5) {
        break;
      }
      if (token.type == null ||
          double.tryParse(token.balance) != null ||
          double.tryParse(token.balance) != 0.0) {
        index++;
        var tile = CoinListTile(
          tokenData: token,
        );
        tiles.add(tile);
        tiles.add(_divider);
      }
    }
    return tiles;
  }

  _raisedButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RaisedButton(
          onPressed: () {
            Navigator.pushNamed(context, coinListRoute);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Text("View All Tokens",
              style: TextStyle(color: AppTheme.warmGrey_900)),
          color: AppTheme.warmgray_100,
        )
      ],
    );
  }
}
