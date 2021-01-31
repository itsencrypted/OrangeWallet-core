import 'package:flutter/material.dart';
import 'package:pollywallet/screens/staking/validators_screen/ui_elements/validator_staked_card.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/widgets/colored_tabbar.dart';

class AllValidators extends StatefulWidget {
  @override
  _AllValidatorsState createState() => _AllValidatorsState();
}

class _AllValidatorsState extends State<AllValidators> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        appBar: AppBar(
            backgroundColor: AppTheme.stackingGrey,
            title: Text(
              'All Validators',
              style: AppTheme.listTileTitle,
            ),
            actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
            bottom: ColoredTabBar(
              tabBar: TabBar(
                labelStyle: AppTheme.tabbarTextStyle,
                unselectedLabelStyle: AppTheme.tabbarTextStyle,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    //gradient: LinearGradient(colors: [Colors.blue, Colors.blue]),
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.white),
                tabs: [
                  Tab(
                    child: Align(
                      child: Text(
                        'Staked',
                        style: AppTheme.tabbarTextStyle,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      child: Text(
                        'Performance',
                        style: AppTheme.tabbarTextStyle,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      child: Text(
                        'Commission',
                        style: AppTheme.tabbarTextStyle,
                      ),
                    ),
                  )
                ],
              ),
              borderRadius: AppTheme.cardRadius,
              color: AppTheme.tabbarBGColor,
              tabbarMargin: AppTheme.cardRadius,
              tabbarPadding: AppTheme.paddingHeight / 4,
            )),
        body: TabBarView(children: [
          ListView.builder(
            itemBuilder: (context, index) {
              return ValidatorsStakedCard(
                commission: '5',
                iconURL:
                    'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                name: 'Decentral.Games',
                performance: "99",
                stakedMatic: "123121312312",
              );
            },
            itemCount: 15,
          ),
          Text('Performance'),
          Text('Commission')
        ]),
      ),
    );
  }
}
