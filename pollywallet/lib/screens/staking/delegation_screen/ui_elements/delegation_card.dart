import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class DelegationCard extends StatelessWidget {
  final String title;
  final String commission;
  final String subtitle;
  final String iconURL;
  final String maticStake;
  final String stakeInUsd;
  final String maticRewards;
  final String rewardInUsd;
  DelegationCard({
    this.title,
    this.subtitle,
    this.commission,
    this.iconURL,
    this.maticStake,
    this.stakeInUsd,
    this.maticRewards,
    this.rewardInUsd,
  });

  Widget rewardWidget({String title, String matic, String usd}) {
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
                '$matic',
                style: AppTheme.balanceMain,
              ),
              Text(
                '\$$usd',
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
                        matic: maticStake,
                        usd: stakeInUsd),
                    rewardWidget(
                        title: "Matic Reward",
                        matic: maticRewards,
                        usd: rewardInUsd)
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
                      color: AppTheme.primaryColor,
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
