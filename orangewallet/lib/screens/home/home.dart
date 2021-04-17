import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orangewallet/screens/home/app_bar.dart';
import 'package:orangewallet/screens/settings_screen/settings_tab.dart';
import 'package:orangewallet/screens/staking/staking_tab.dart';
import 'package:orangewallet/screens/wallet_tab/home_tab.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:orangewallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_bar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      tokenListCubit.getTokensList();
      final ethCubit = context.read<CovalentTokensListEthCubit>();
      context.read<DelegationsDataCubit>().setData();
      context.read<ValidatorsdataCubit>().setData();
      ethCubit.getTokensList();
    });
    _tabController = new TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
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
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              HomeTab(),
              StakingTab(),
              SettingsTab(),
            ],
          ),
          Positioned(
              bottom: -33,
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
                          icon: SvgPicture.asset(
                            "assets/icons/wallet_icon.svg",
                            color: _tabController.index == 0
                                ? AppTheme.white
                                : AppTheme.black,
                          ),
                          title: Text(" Wallet"),
                        ),
                        BottomNavBarItem(
                            icon: SvgPicture.asset(
                              "assets/icons/staking_icon.svg",
                              color: _tabController.index == 1
                                  ? AppTheme.white
                                  : AppTheme.black,
                            ),
                            title: Text(
                              " Staking",
                              softWrap: true,
                            ),
                            textAlign: TextAlign.center),
                        BottomNavBarItem(
                            icon: SvgPicture.asset(
                              "assets/icons/settings_icon.svg",
                              color: _tabController.index == 2
                                  ? AppTheme.white
                                  : AppTheme.black,
                            ),
                            title: Text(" Settings",
                                softWrap: true,
                                overflow: TextOverflow.clip,
                                textAlign: TextAlign.center),
                            textAlign: TextAlign.center),
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
