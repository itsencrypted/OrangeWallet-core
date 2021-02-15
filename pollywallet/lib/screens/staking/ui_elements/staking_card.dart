import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class StackingCard extends StatelessWidget {
  final String iconURL;
  final String maticWalletBalance;
  final String etcWalletBalance;
  final String maticStake;
  final String stakeUSD;
  final String maticRewards;
  final String rewardUSD;
  StackingCard({
    this.iconURL,
    this.maticWalletBalance,
    this.etcWalletBalance,
    this.maticStake,
    this.stakeUSD,
    this.maticRewards,
    this.rewardUSD,
  });

  Widget rewardWidget({String title, String maticBalance, String amountUSD}) {
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
                '\$$amountUSD',
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
                subtitle: Text('Ethereum Network',
                    style: AppTheme.balanceSub.copyWith(
                        color: AppTheme.balanceSub.color.withOpacity(0.4))),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$maticWalletBalance Matic",
                      style: AppTheme.balanceMain,
                    ),
                    Text('$etcWalletBalance ETH',
                        style: AppTheme.balanceSub.copyWith(
                            color: AppTheme.balanceSub.color.withOpacity(0.4)))
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
                        amountUSD: stakeUSD),
                    rewardWidget(
                        title: "Matic Reward",
                        maticBalance: maticRewards,
                        amountUSD: rewardUSD)
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
