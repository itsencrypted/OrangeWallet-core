import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/screens/staking/validators_screen/ui_elements/validator_staked_card.dart';
import 'package:pollywallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/widgets/colored_tabbar.dart';

class AllValidators extends StatefulWidget {
  @override
  _AllValidatorsState createState() => _AllValidatorsState();
}

class _AllValidatorsState extends State<AllValidators> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ValidatorsdataCubit, ValidatorsDataState>(
        builder: (context, state) {
      if (state is ValidatorsDataStateInitial) {
        return Scaffold(
          appBar: AppBar(
            title: Text("All validators"),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SpinKitFadingFour(
                size: 50,
                color: AppTheme.primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Loading..."),
              ),
            ],
          ),
        );
      } else if (state is ValidatorsDataStateFinal) {
        var sorted = state.data.result;
        sorted.sort((a, b) =>
            double.parse(a.uptimePercent) < double.parse(b.uptimePercent)
                ? 1
                : 0);
        var commission = state.data.result;
        commission.sort((a, b) => double.parse(a.commissionPercent) >
                double.parse(b.commissionPercent)
            ? 1
            : 0);
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
                actions: [
                  IconButton(icon: Icon(Icons.search), onPressed: () {})
                ],
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
                  var stake = EthConversions.weiToEth(
                      state.data.result[index].delegatedStake, 18);
                  var name;
                  if (state.data.result[index].name != null) {
                    name = state.data.result[index].name;
                  } else {
                    name =
                        "Validator " + state.data.result[index].id.toString();
                  }
                  return ValidatorsStakedCard(
                    commission: state.data.result[index].commissionPercent,
                    iconURL:
                        'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                    name: name,
                    performance: state.data.result[index].uptimePercent,
                    stakedMatic: stake.toString(),
                  );
                },
                itemCount: state.data.result.length,
              ),
              ListView.builder(
                itemBuilder: (context, index) {
                  var stake =
                      EthConversions.weiToEth(sorted[index].delegatedStake, 18);
                  var name;
                  if (sorted[index].name != null) {
                    name = sorted[index].name;
                  } else {
                    name = "Validator " + sorted[index].id.toString();
                  }
                  return ValidatorsStakedCard(
                    commission: sorted[index].commissionPercent,
                    iconURL:
                        'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                    name: name,
                    performance: sorted[index].uptimePercent,
                    stakedMatic: stake.toString(),
                  );
                },
                itemCount: sorted.length,
              ),
              ListView.builder(
                itemBuilder: (context, index) {
                  var stake =
                      EthConversions.weiToEth(sorted[index].delegatedStake, 18);
                  var name;
                  if (commission[index].name != null) {
                    name = commission[index].name;
                  } else {
                    name = "Validator " + commission[index].id.toString();
                  }
                  return ValidatorsStakedCard(
                    commission: commission[index].commissionPercent,
                    iconURL:
                        'https://cdn3.iconfinder.com/data/icons/unicons-vector-icons-pack/32/external-256.png',
                    name: name,
                    performance: commission[index].uptimePercent,
                    stakedMatic: stake.toString(),
                  );
                },
                itemCount: commission.length,
              ),
            ]),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text("All validators"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    icon: Icon(Icons.refresh),
                    color: AppTheme.grey,
                    onPressed: () {
                      context.read<ValidatorsdataCubit>().setData();
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Something Went wrong."),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
