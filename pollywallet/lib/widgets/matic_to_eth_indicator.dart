import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class MaticToEthIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: AppTheme.cardShape,
      elevation: AppTheme.cardElevations + 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  "Matic Network",
                  style: AppTheme.subtitle,
                  textAlign: TextAlign.center,
                )),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Ethereum Network",
                      style: AppTheme.subtitle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
