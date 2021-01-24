import 'package:flutter/material.dart';
import 'package:pollywallet/screens/home/home.dart';
import 'package:pollywallet/theme_data.dart';

void main() {
  runApp(PollyWallet());
}

class PollyWallet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PollyWallet',
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        backgroundColor: AppTheme.backgroundWhite,
        textTheme: Typography.blackCupertino,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

