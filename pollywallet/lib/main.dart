import 'package:flutter/material.dart';
import 'package:pollywallet/screens/home/home.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(PollyWallet());
}

class PollyWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor:
            AppTheme.backgroundWhite, // navigation bar color
        statusBarColor: AppTheme.backgroundWhite,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarDividerColor: AppTheme.backgroundWhite,
        systemNavigationBarIconBrightness: Brightness.light // status bar color
        ));
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PollyWallet',
        theme: ThemeData(
          platform: TargetPlatform.iOS,
          backgroundColor: AppTheme.backgroundWhite,
          textTheme: Typography.blackCupertino,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Home(),
      ),
    );
  }
}
