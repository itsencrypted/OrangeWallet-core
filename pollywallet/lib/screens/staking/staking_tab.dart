import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class StakingTab extends StatefulWidget {
  @override
  _StakingTabState createState() => _StakingTabState();
}

class _StakingTabState extends State<StakingTab>
    with AutomaticKeepAliveClientMixin<StakingTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(children: [
        stakingTile(
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
            }),
      ]),
    );
  }

  Widget stakingTile(
      {String iconURL,
      String maticWalletBalance,
      String etcWalletBalance,
      String maticStake,
      String stakeInETH,
      String maticRewards,
      String rewardInETH}) {
    Widget rewardWidget(
        {String title, String maticBalance, String ethBalance}) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$title',
                  style: AppTheme.balanceSub.copyWith(
                      color: AppTheme.balanceSub.color.withOpacity(0.4)),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '$maticBalance',
                  style: AppTheme.balanceMain,
                ),
                Text(
                  '\$$ethBalance',
                  style: AppTheme.balanceSub.copyWith(
                      color: AppTheme.balanceSub.color.withOpacity(0.6)),
                ),
              ],
            )
          ],
        ),
      );
    }

    return Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppTheme.bigCardRadius))),
        color: AppTheme.white,
        elevation: AppTheme.cardElevations,
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppTheme.paddingHeight),
                child: Text(
                  'Your Staking Profile',
                  style: AppTheme.listTileTitle,
                ),
              ),
              Container(
                height: 1,
                color: AppTheme.black.withOpacity(0.05),
              ),
              ListTile(
                leading: FadeInImage.assetNetwork(
                  placeholder: 'assets/icons/wallet_icon.png',
                  image: iconURL,
                  width: AppTheme.tokenIconHeight,
                ),
                title: Text('Wallet', style: AppTheme.title),
                subtitle: Text('Ethereum Network', style: AppTheme.subtitle),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$maticWalletBalance Matic",
                      style: AppTheme.balanceMain,
                    ),
                    Text(
                      '\$$etcWalletBalance',
                      style: AppTheme.balanceSub,
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  color: AppTheme.stackingGrey,
                ),
                margin: EdgeInsets.only(
                    bottom: AppTheme.paddingHeight,
                    left: AppTheme.paddingHeight,
                    right: AppTheme.paddingHeight),
                height: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    rewardWidget(
                        title: "Matic Staking",
                        maticBalance: maticStake,
                        ethBalance: stakeInETH),
                    rewardWidget(
                        title: "Matic Reward",
                        maticBalance: maticRewards,
                        ethBalance: rewardInETH)
                  ],
                ),
              )
            ],
          ),
        ));
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
