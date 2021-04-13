import 'package:flutter/material.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/theme_data.dart';

class EthToMaticIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: AppTheme.cardShape,
      elevation: AppTheme.cardElevations + 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.paddingHeight),
              child: Center(
                child: Text(
                  "Ethereum Network",
                  style: AppTheme.subtitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.warmGrey_900),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  arrowIcon,
                  color: AppTheme.white,
                ),
                Image.asset(
                  arrowIcon,
                  color: AppTheme.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.paddingHeight),
              child: Center(
                  child: Text(
                "Matic Network",
                style: AppTheme.subtitle,
                textAlign: TextAlign.center,
              )),
            ),
          ),
        ],
      ),
    );
  }
}
