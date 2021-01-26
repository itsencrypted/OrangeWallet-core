import 'package:flutter/material.dart';
import 'package:pollywallet/screens/wallet_tab/top_balance.dart';
import 'package:pollywallet/screens/wallet_tab/transfer_asset_card.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(children: [
        TopBalance("256.53"),
        TransferAssetCard(),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
