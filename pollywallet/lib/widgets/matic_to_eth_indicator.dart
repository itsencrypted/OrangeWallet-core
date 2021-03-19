import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/theme_data.dart';

class MaticToEthIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppTheme.primaryColor),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Matic",
                  style: TextStyle(color: AppTheme.whiteTextColor)),
            )),
          ),
        ),
        Image.asset(arrowIcon),
        Image.asset(arrowIcon),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppTheme.black),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Ethereum",
                style: TextStyle(color: AppTheme.whiteTextColor),
              ),
            )),
          ),
        ),
      ],
    );
  }
}
