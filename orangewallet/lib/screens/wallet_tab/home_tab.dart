import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/screens/wallet_tab/coin_list.dart';
import 'package:orangewallet/screens/wallet_tab/fiat_on_ramp_card.dart';
import 'package:orangewallet/screens/wallet_tab/nft_list.dart';
import 'package:orangewallet/screens/wallet_tab/top_balance.dart';
import 'package:orangewallet/screens/wallet_tab/transfer_asset_card.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/misc/box.dart';
import 'package:orangewallet/utils/misc/notification_helper.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  int counter = 0;
  CovalentTokensListMaticState state;
  bool verified = true;
  var pushed = false;
  var amount = 0.0;
  @override
  void initState() {
    BoxUtils.getNewMnemonicBox().then((value) {
      print(value);
      setState(() {
        if (value == null) {
          verified = false;
        } else {
          verified = value;
        }
      });
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      tokenListCubit.getTokensList();
      final ethCubit = context.read<CovalentTokensListEthCubit>();
      ethCubit.getTokensList();
      NotificationHelper.checkForActionsCount().then((value) {
        setState(() {
          counter = value;
        });
      });
      _refreshLoop(tokenListCubit);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CovalentTokensListMaticCubit,
        CovalentTokensListMaticState>(
      builder: (context, state) {
        if (state is CovalentTokensListMaticInitial) {
          return SpinKitFadingFour(
            size: 40,
            color: AppTheme.primaryColor,
          );
        } else if (state is CovalentTokensListMaticLoading) {
          return SpinKitFadingFour(
            size: 40,
            color: AppTheme.primaryColor,
          );
        } else if (state is CovalentTokensListMaticLoaded) {
          this.state = state;
          var amt = 0.0;
          if (state.covalentTokenList.data.items.length > 0) {
            state.covalentTokenList.data.items.forEach((element) {
              amt += element.quote == null ? 0 : element.quote;
            });
          }
          amount = amt;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 50),
                  child: TopBalance(amt.toStringAsFixed(2)),
                ),
                FiatOnRampCard(),
                TransferAssetCard(),
                CoinListCard(
                  tokens: state.covalentTokenList.data.items,
                ),
                state.covalentTokenList.data.items
                            .where((element) => element.nftData != null)
                            .length !=
                        0
                    ? NftListCard(
                        tokens: state.covalentTokenList.data.items,
                      )
                    : Container(),
                Card(
                  shape: AppTheme.cardShape,
                  elevation: AppTheme.cardElevations,
                  child: SizedBox(
                    height: 55,
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pushNamed(context, notificationsScreenRoute);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pending Actions",
                              style: AppTheme.label_medium,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.orange_500),
                                    child: Center(
                                        child: Text(
                                      counter.toString(),
                                      style: TextStyle(color: AppTheme.white),
                                    )),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                  color: AppTheme.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  shape: AppTheme.cardShape,
                  elevation: AppTheme.cardElevations,
                  child: SizedBox(
                    height: 55,
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.pushNamed(context, transactionListRoute);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Transactions List",
                              style: AppTheme.label_medium,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: AppTheme.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                )
              ]),
            ),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Something went wrong"),
              RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  color: sendButtonColor.withOpacity(0.6),
                  child: Text("Refresh"),
                  onPressed: _initializeAgain),
            ],
          );
        }
      },
    );
  }

  _initializeAgain() {
    final tokenListCubit = context.read<CovalentTokensListMaticCubit>();
    tokenListCubit.getTokensList();
    final ethCubit = context.read<CovalentTokensListEthCubit>();
    ethCubit.getTokensList();
  }

  Future<void> _refresh() async {
    final tokenListCubit = context.read<CovalentTokensListMaticCubit>();
    Future tokenListFuture = tokenListCubit.refresh();
    final ethCubit = context.read<CovalentTokensListEthCubit>();
    Future ethTokenListFuture = ethCubit.refresh();
    await tokenListFuture;
    await ethTokenListFuture;
    setState(() {});
  }

  _refreshLoop(CovalentTokensListMaticCubit cubit) {
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (!verified && amount > 0 && pushed == false) {
        pushed = true;
        Navigator.pushNamed(context, verifyMnemonic);
      }
    });
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
        NotificationHelper.checkForActionsCount().then((value) {
          setState(() {
            counter = value;
          });
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
