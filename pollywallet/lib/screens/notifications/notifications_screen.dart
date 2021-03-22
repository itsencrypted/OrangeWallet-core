import 'package:flutter/material.dart';
import 'package:pollywallet/screens/notifications/staking_notifications_list.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/misc/box.dart';
import 'package:pollywallet/widgets/colored_tabbar.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              title: Text("Notfications"),
              bottom: ColoredTabBar(
                tabBar: TabBar(
                  labelStyle: AppTheme.tabbarTextStyle,
                  unselectedLabelStyle: AppTheme.tabbarTextStyle,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.white),
                  tabs: [
                    Tab(
                      child: Align(
                        child: Text(
                          'Withdraw',
                          style: AppTheme.tabbarTextStyle,
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        child: Text(
                          'Stake',
                          style: AppTheme.tabbarTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
                borderRadius: AppTheme.cardRadius,
                color: AppTheme.tabbarBGColor,
                tabbarMargin: AppTheme.cardRadius,
                tabbarPadding: AppTheme.paddingHeight / 4,
              )),
          body: TabBarView(
            children: [Text("ADSa"), StakingNotificationsList()],
          )),
    );
  }
}
