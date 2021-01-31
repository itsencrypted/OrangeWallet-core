import 'package:flutter/material.dart';
import 'package:pollywallet/theme_data.dart';

class WarningCard extends StatelessWidget {
  final Function onClose;
  WarningCard({this.onClose});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.warningCardColor,
      elevation: AppTheme.cardElevations,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppTheme.cardRadiusMedium))),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppTheme.paddingHeight,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Warning',
                  style: AppTheme.titleWhite,
                ),
                IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.white,
                    onPressed: onClose)
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: AppTheme.paddingHeight, bottom: AppTheme.paddingHeight),
            child: Text(
              'Staking works on Ethereum Mainnet. There will be high transaction fee and slow transaction speed.',
              style: AppTheme.body2White,
              maxLines: 100,
            ),
          )
        ],
      ),
    );
  }
}
