import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/theme_data.dart';

class AppLandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Container(
        color: AppTheme.white,
        child: Padding(
          padding: EdgeInsets.all(AppTheme.paddingHeight12),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    orangeIcon,
                    height: MediaQuery.of(context).size.width / 4,
                    width: MediaQuery.of(context).size.width / 4,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: AppTheme.buttonHeight_44,
                  margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingHeight12),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: AppTheme.orange_500,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.buttonRadius))),
                    onPressed: () {
                      Navigator.of(context).pushNamed(createWalletRoute);
                    },
                    child: Text(
                      'Create a new account',
                      style: AppTheme.label_medium
                          .copyWith(color: AppTheme.lightgray_700),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppTheme.paddingHeight / 2,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: AppTheme.buttonHeight_44,
                  margin: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingHeight12),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: AppTheme.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.buttonRadius))),
                    onPressed: () {
                      Navigator.of(context).pushNamed(importWalletRoute);
                    },
                    child: Text(
                      'I have a wallet',
                      style: AppTheme.label_medium,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
