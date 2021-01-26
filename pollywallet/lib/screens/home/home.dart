import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pollywallet/screens/home/app_bar.dart';
import 'package:pollywallet/screens/settings_screen/settings_tab.dart';
import 'package:pollywallet/screens/wallet_tab/home_tab.dart';
import 'package:pollywallet/theme_data.dart';

import 'navigation_bar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    super.initState();
  }

  int selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: HomeAppBar(),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              HomeTab(),
              Text("Tab2"),
              SettingsTab(),
            ],
          ),
          Positioned(
              bottom: -10,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 170,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      AppTheme.backgroundWhite.withOpacity(0.1),
                      AppTheme.backgroundWhite.withOpacity(0.5),
                      AppTheme.backgroundWhite.withOpacity(0.5),
                      AppTheme.backgroundWhite.withOpacity(0.8),
                      AppTheme.backgroundWhite.withOpacity(1),
                      AppTheme.backgroundWhite.withOpacity(1),
                      AppTheme.backgroundWhite.withOpacity(1)
                    ])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BottomNavBar(
                      onItemSelected: (index) {
                        setState(() {
                          _tabController.animateTo(index);
                        });
                      },
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      selectedIndex: _tabController.index,
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
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
