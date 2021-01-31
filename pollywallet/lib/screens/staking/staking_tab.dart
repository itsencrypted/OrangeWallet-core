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
        stakingTile(),
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

  Widget stakingTile() {
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
                  placeholder:
                      'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                  image:
                      'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
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
                      "1221231 Matic",
                      style: AppTheme.balanceMain,
                    ),
                    Text(
                      '\$${2314}',
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
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Matic Stake',
                                style: AppTheme.balanceSub.copyWith(
                                    color: AppTheme.balanceSub.color
                                        .withOpacity(0.4)),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '1221231 Matic',
                                style: AppTheme.balanceMain,
                              ),
                              Text(
                                '\$${1212}',
                                style: AppTheme.balanceSub.copyWith(
                                    color: AppTheme.balanceSub.color
                                        .withOpacity(0.6)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Matic Reward',
                                style: AppTheme.balanceSub.copyWith(
                                    color: AppTheme.balanceSub.color
                                        .withOpacity(0.4)),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '553443',
                                style: AppTheme.balanceMain,
                              ),
                              Text(
                                '\$${12.3}',
                                style: AppTheme.balanceSub.copyWith(
                                    color: AppTheme.balanceSub.color
                                        .withOpacity(0.6)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
