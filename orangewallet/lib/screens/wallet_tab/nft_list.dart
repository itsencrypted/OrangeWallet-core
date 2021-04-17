import 'package:flutter/material.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/screens/wallet_tab/coin_list_tile.dart';
import 'package:orangewallet/screens/wallet_tab/nft_tile.dart';
import 'package:orangewallet/theme_data.dart';

class NftListCard extends StatelessWidget {
  final List<Items> tokens;

  NftListCard({Key key, @required this.tokens}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int total;
    List<Widget> ls = List<Widget>();
    total = tokens.where((element) => element.nftData != null).length;
    ls.add(_divider);
    ls.add(_disclaimer);
    ls.addAll(_tiles());
    ls.add(_divider);
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
        "Showing owned collectibles only",
        style: AppTheme.subtitle,
      ));
  List<Widget> _tiles() {
    var tiles = List<Widget>();
    var ls = tokens.where((element) => element.nftData != null);
    var index = 0;
    for (Items token in ls) {
      if (index == 5) {
        break;
      }
      if (token.type == null || token.balance != "0") {
        index++;
        var tile = NftListTile(
          tokenData: token,
        );
        tiles.add(tile);
      }
    }
    return tiles;
  }

  _raisedButton(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RaisedButton(
          onPressed: () {
            _allCoins(context);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Text(
            "View All Tokens",
            style: AppTheme.body2White,
          ),
          color: AppTheme.secondaryColor,
        )
      ],
    );
  }

  _allCoins(context) {
    Navigator.pushNamed(context, nftTokenList);
  }
}
