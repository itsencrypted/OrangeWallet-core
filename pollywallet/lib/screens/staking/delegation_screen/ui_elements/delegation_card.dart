import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class DelegationCard extends StatelessWidget {
  final String title;
  final String commission;
  final String subtitle;
  final String iconURL;
  final String maticWalletBalance;
  final String etcWalletBalance;
  final String maticStake;
  final String stakeInETH;
  final String maticRewards;
  final String rewardInETH;
  DelegationCard({
    this.title,
    this.subtitle,
    this.commission,
    this.iconURL,
    this.maticWalletBalance,
    this.etcWalletBalance,
    this.maticStake,
    this.stakeInETH,
    this.maticRewards,
    this.rewardInETH,
  });

  Widget rewardWidget({String title, String maticBalance, String ethBalance}) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppTheme.cardRadiusBig))),
        color: AppTheme.white,
        elevation: AppTheme.cardElevations,
        child: Container(
          margin: EdgeInsets.all(AppTheme.paddingHeight),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: AppTheme.paddingHeight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppTheme.paddingHeight / 2,
                        right: AppTheme.paddingHeight,
                      ),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/icons/wallet_icon.png',
                        image: iconURL,
                        width: AppTheme.tokenIconHeight,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$title",
                          style: AppTheme.listTileTitle,
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight / 4,
                        ),
                        Text('$subtitle',
                            style: AppTheme.balanceSub.copyWith(
                                color: AppTheme.balanceSub.color
                                    .withOpacity(0.4))),
                        Text('$commission% Commission',
                            style: AppTheme.balanceSub.copyWith(
                                color: AppTheme.balanceSub.color
                                    .withOpacity(0.4))),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  color: AppTheme.stackingGrey,
                ),
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
              ),
              SizedBox(
                height: AppTheme.cardRadius,
              ),
              Row(
                children: [
                  Expanded(
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: AppTheme.borderColorGreyish),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.cardRadiusSmall)),
                          onPressed: () {},
                          child: Text(
                            'Withdraw Reward',
                            style: AppTheme.tabbarTextStyle,
                          ))),
                  SizedBox(
                    width: AppTheme.paddingHeight / 2,
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: AppTheme.buttonColorBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.cardRadiusSmall)),
                      onPressed: () {},
                      child: Text(
                        'Restake Reward',
                        style: AppTheme.textW600White14,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
