import 'package:flutter/material.dart';
import 'package:orangewallet/theme_data.dart';

class ValidatorsStakedCard extends StatelessWidget {
  final String name;
  final String stakedMatic;
  final String performance;
  final String commission;
  ValidatorsStakedCard(
      {this.commission, this.name, this.performance, this.stakedMatic});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: AppTheme.cardRadius, vertical: AppTheme.cardRadius / 2),
      elevation: AppTheme.cardElevations,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppTheme.cardRadiusBig))),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppTheme.paddingHeight20,
            vertical: AppTheme.paddingHeight20),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$name",
                      style: AppTheme.listTileTitle,
                    ),
                    Text(
                      '$stakedMatic MATIC Staked',
                      style: AppTheme.balanceSub,
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: AppTheme.paddingHeight20,
                  bottom: AppTheme.paddingHeight / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance',
                    style: AppTheme.bodyW40016.copyWith(
                        color: AppTheme.bodyW40016.color.withOpacity(0.6)),
                  ),
                  Text(
                    '$performance%',
                    style:
                        AppTheme.bodyW40016.copyWith(color: Color(0xFF2F9671)),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commission',
                  style: AppTheme.bodyW40016.copyWith(
                      color: AppTheme.bodyW40016.color.withOpacity(0.6)),
                ),
                Text(
                  '$commission%',
                  style: AppTheme.bodyW40016,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
