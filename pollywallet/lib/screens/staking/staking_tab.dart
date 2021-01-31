import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/screens/staking/ui_elements/staking_card.dart';
import 'package:pollywallet/screens/staking/ui_elements/warning_card.dart';
import 'package:pollywallet/theme_data.dart';

class StakingTab extends StatefulWidget {
  @override
  _StakingTabState createState() => _StakingTabState();
}

class _StakingTabState extends State<StakingTab>
    with AutomaticKeepAliveClientMixin<StakingTab> {
  bool showWarning;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showWarning = true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(children: [
        if (showWarning)
          WarningCard(
            onClose: () {
              setState(() {
                showWarning = false;
              });
            },
          ),
        StackingCard(
            iconURL:
                'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
            maticWalletBalance: '12434124',
            etcWalletBalance: '123',
            maticStake: '12431242',
            stakeInETH: '421',
            maticRewards: '21412',
            rewardInETH: '31'),
        listTile(
            title: '0 Delegation',
            onTap: () {
              print('Delegation');
            }),
        listTile(
            title: '122 Validators',
            onTap: () {
              print('Validators');
              Navigator.of(context).pushNamed(allValidatorsRoute);
            }),
      ]),
    );
  }

  Widget listTile(
      {String title,
      String trailingText,
      @required Function onTap,
      bool showTrailingIcon = true}) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.cardRadius))),
      color: AppTheme.white,
      elevation: AppTheme.cardElevations,
      child: ListTile(
        tileColor: AppTheme.white,
        onTap: onTap,
        title: Text(
          title,
          style: AppTheme.listTileTitle,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) Text(trailingText),
            if (showTrailingIcon) Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
