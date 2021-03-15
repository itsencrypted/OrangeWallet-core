import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/staking_models/delegator_details.dart';
import 'package:pollywallet/models/staking_models/validators.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:pollywallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/staking_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';

class ValidatorAndDelegationProfile extends StatefulWidget {
  @override
  _ValidatorAndDelegationProfileState createState() =>
      _ValidatorAndDelegationProfileState();
}

class _ValidatorAndDelegationProfileState
    extends State<ValidatorAndDelegationProfile> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      final dCubit = context.read<DelegationsDataCubit>();
      final vCubit = context.read<ValidatorsdataCubit>();

      _refreshLoop(tokenListCubit, vCubit, dCubit);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var id = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Validator Information',
            style: AppTheme.listTileTitle,
          ),
        ),
        body: BlocBuilder<CovalentTokensListMaticCubit,
            CovalentTokensListMaticState>(
          builder: (context, covalentMaticState) {
            return BlocBuilder<DelegationsDataCubit, DelegationsDataState>(
                builder: (context, delegationState) {
              return BlocBuilder<ValidatorsdataCubit, ValidatorsDataState>(
                  builder: (context, validatorState) {
                if (validatorState is ValidatorsDataStateLoading ||
                    validatorState is ValidatorsDataStateInitial ||
                    delegationState is DelegationsDataStateInitial ||
                    delegationState is DelegationsDataStateLoading) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitFadingFour(
                          size: 50,
                          color: AppTheme.primaryColor,
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Loading .."),
                        ),
                      ],
                    ),
                  );
                } else if (delegationState is DelegationsDataStateFinal &&
                    validatorState is ValidatorsDataStateFinal &&
                    covalentMaticState is CovalentTokensListMaticLoaded) {
                  ValidatorInfo validator = validatorState.data.result
                      .where((element) => element.id == id)
                      .toList()
                      .first;
                  double qoute = covalentMaticState.covalentTokenList.data.items
                      .where((element) =>
                          element.contractTickerSymbol.toLowerCase() == "matic")
                      .toList()
                      .first
                      .quoteRate;
                  DelegatorInfo delegatorInfo;
                  var len = delegationState.data.result
                      .where((element) => element.bondedValidator == id)
                      .toList()
                      .length;
                  if (len > 0) {
                    delegatorInfo = delegationState.data.result
                        .where((element) => element.bondedValidator == id)
                        .toList()
                        .first;
                  }
                  BigInt reward = BigInt.zero;
                  try {
                    reward = delegatorInfo.shares - delegatorInfo.stake;
                  } catch (e) {}

                  var stake = EthConversions.weiToEth(
                      validator.selfStake + validator.delegatedStake, 18);
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ListView(
                            shrinkWrap: false,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        validator.name.substring(0, 1),
                                        style: TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    validator.name,
                                    style: AppTheme.title,
                                  ),
                                  Text(
                                    validator.contractAddress,
                                    style: AppTheme.subtitle,
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 8),
                                    child: Card(
                                      shape: AppTheme.cardShape,
                                      elevation: AppTheme.cardElevations,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                    validator.uptimePercent
                                                            .toString() +
                                                        " %",
                                                    style: AppTheme.title),
                                                Text(
                                                  "Performance",
                                                  style: AppTheme.subtitle,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                    validator
                                                            .commissionPercent +
                                                        " %",
                                                    style: AppTheme.title),
                                                Text(
                                                  "Commission",
                                                  style: AppTheme.subtitle,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 19),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Total Stake",
                                            style: AppTheme.body2),
                                        Text(stake.toString() + " Matic",
                                            style: AppTheme.body1)
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 19),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Self Stake",
                                            style: AppTheme.body2),
                                        Text(
                                            EthConversions.weiToEth(
                                                        validator.selfStake, 18)
                                                    .toString() +
                                                " Matic",
                                            style: AppTheme.body1)
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0, horizontal: 19),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Total Rewards",
                                            style: AppTheme.body2),
                                        Text(
                                            EthConversions.weiToEth(
                                                        validator.totalReward,
                                                        18)
                                                    .toString() +
                                                " Matic",
                                            style: AppTheme.body1)
                                      ],
                                    ),
                                  ),
                                  delegatorInfo != null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 19),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Your  Stake",
                                                  style: AppTheme.body2),
                                              Text(
                                                  EthConversions.weiToEth(
                                                              delegatorInfo
                                                                  .stake,
                                                              18)
                                                          .toString() +
                                                      " Matic",
                                                  style: AppTheme.body1)
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  delegatorInfo != null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 19),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Your Rewards",
                                                  style: AppTheme.body2),
                                              Text(
                                                  EthConversions.weiToEth(
                                                              delegatorInfo
                                                                  .claimedReward,
                                                              18)
                                                          .toString() +
                                                      " Matic",
                                                  style: AppTheme.body1)
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  SizedBox(
                                    height: 100,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        child: SafeArea(
                          child: Center(
                            child: validator.delegationEnabled
                                ? (delegatorInfo == null
                                    ? RaisedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, delegationAmountRoute,
                                              arguments: id);
                                        },
                                        color: AppTheme.secondaryColor,
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85,
                                            child: Center(
                                                child: Text("Delegate Now"))),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50))),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                              AppTheme.backgroundWhite
                                                  .withOpacity(0.1),
                                              AppTheme.backgroundWhite
                                                  .withOpacity(0.5),
                                              AppTheme.backgroundWhite
                                                  .withOpacity(0.5),
                                              AppTheme.backgroundWhite
                                                  .withOpacity(0.8),
                                              AppTheme.backgroundWhite
                                                  .withOpacity(1),
                                              AppTheme.backgroundWhite
                                                  .withOpacity(1),
                                              AppTheme.backgroundWhite
                                                  .withOpacity(1)
                                            ])),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                RaisedButton(
                                                  onPressed: () {
                                                    _restake(
                                                        reward,
                                                        validator,
                                                        covalentMaticState
                                                            .covalentTokenList
                                                            .data
                                                            .items
                                                            .where((element) =>
                                                                element
                                                                    .contractName
                                                                    .toLowerCase() ==
                                                                "matic")
                                                            .first);
                                                  },
                                                  color:
                                                      AppTheme.secondaryColor,
                                                  child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Center(
                                                        child: Text(
                                                          "Delegate Reward",
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      )),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  50))),
                                                ),
                                                RaisedButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(context,
                                                        delegationAmountRoute,
                                                        arguments: id);
                                                  },
                                                  color:
                                                      AppTheme.secondaryColor,
                                                  child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Center(
                                                          child: Text(
                                                        "Delegate More",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ))),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  50))),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                RaisedButton(
                                                  onPressed: () async {
                                                    _claimRewards(
                                                        reward,
                                                        validator,
                                                        covalentMaticState
                                                            .covalentTokenList
                                                            .data
                                                            .items
                                                            .where((element) =>
                                                                element
                                                                    .contractName
                                                                    .toLowerCase() ==
                                                                "matic")
                                                            .first);
                                                  },
                                                  color: AppTheme.primaryColor,
                                                  child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Center(
                                                          child: Text(
                                                        "Claim Reward",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ))),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  50))),
                                                ),
                                                RaisedButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(context,
                                                        stakeWithDrawAmountRoute,
                                                        arguments: id);
                                                  },
                                                  color: AppTheme.primaryColor,
                                                  child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: Center(
                                                          child: Text(
                                                        "Withdraw Stake",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ))),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  50))),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ))
                                : Container(),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: Icon(Icons.refresh),
                            color: AppTheme.grey,
                            onPressed: () {
                              context.read<DelegationsDataCubit>().setData();
                              context.read<ValidatorsdataCubit>().setData();
                            }),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Something Went wrong."),
                        ),
                      ],
                    ),
                  );
                }
              });
            });
          },
        ));
  }

  _restake(BigInt reward, ValidatorInfo validator, Items token) async {
    if (reward < BigInt.from(10).pow(18)) {
      Fluttertoast.showToast(
          msg: "Rewards too low to redelegate", toastLength: Toast.LENGTH_LONG);
      return;
    }
    GlobalKey<State> key = GlobalKey();
    Dialogs.showLoadingDialog(context, key);
    var trx = await StakingTransactions.restake(validator.contractAddress);
    TransactionData data = TransactionData(
        trx: trx,
        token: token,
        amount: EthConversions.weiToEth(reward, 18).toString(),
        to: validator.contractAddress,
        type: TransactionType.RESTAKE);
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }

  _claimRewards(BigInt reward, ValidatorInfo validator, Items token) async {
    if (reward < BigInt.from(10).pow(18)) {
      Fluttertoast.showToast(
          msg: "Rewards too low to be claimed", toastLength: Toast.LENGTH_LONG);
      return;
    }
    GlobalKey<State> key = GlobalKey();
    Dialogs.showLoadingDialog(context, key);
    var trx =
        await StakingTransactions.withdrawRewards(validator.contractAddress);
    TransactionData data = TransactionData(
        trx: trx,
        token: token,
        amount: EthConversions.weiToEth(reward, 18).toString(),
        to: validator.contractAddress,
        type: TransactionType.RESTAKE);
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }

  _refreshLoop(CovalentTokensListMaticCubit mCubit, ValidatorsdataCubit vCubit,
      DelegationsDataCubit dCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        vCubit.refresh();
        dCubit.refresh();
        mCubit.refresh();
      }
    });
  }
}
