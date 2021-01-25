import 'package:flutter/material.dart';
import 'package:pollywallet/screens/home/app_bar.dart';
import 'package:pollywallet/theme_data.dart';

import 'navigation_bar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: HomeAppBar(),
      body: Container(),
      bottomNavigationBar: Container(
        child: BottomNavBar(
          onItemSelected: (index) {
            setState(() {
              selectedTab = index;
            });
          },
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          selectedIndex: selectedTab,
          showElevation: true,
          items: [
            BottomNavBarItem(
              icon: ImageIcon(
                AssetImage("assets/icons/wallet_icon.png"),
              ),
              title: Text("Wallet"),
            ),
            BottomNavBarItem(
                icon: ImageIcon(
                  AssetImage("assets/icons/staking_icon.png"),
                ),
                title: Text("Staking")),
            BottomNavBarItem(
                icon: ImageIcon(
                  AssetImage("assets/icons/settings_icon.png"),
                ),
                title: Text("Settings")),
          ],
        ),
      ),
    );
  }
}
