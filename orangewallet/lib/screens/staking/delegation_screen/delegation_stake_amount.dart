import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/models/staking_models/delegator_details.dart';
import 'package:orangewallet/models/staking_models/validators.dart';
import 'package:orangewallet/models/transaction_data/transaction_data.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/state_manager/staking_data/delegation_data_state/delegations_data_cubit.dart';
import 'package:orangewallet/state_manager/staking_data/validator_data/validator_data_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/fiat_crypto_conversions.dart';
import 'package:orangewallet/utils/network/network_config.dart';
import 'package:orangewallet/utils/network/network_manager.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';
import 'package:orangewallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:orangewallet/utils/web3_utils/staking_transactions.dart';
import 'package:orangewallet/widgets/colored_tabbar.dart';
import 'package:orangewallet/widgets/loading_indicator.dart';
import 'package:orangewallet/widgets/no_scaling_animation_fab.dart';
import 'package:web3dart/web3dart.dart';

class DelegationAmount extends StatefulWidget {
  @override
  _DelegationAmountState createState() => _DelegationAmountState();
}

class _DelegationAmountState extends State<DelegationAmount>
    with SingleTickerProviderStateMixin<DelegationAmount> {
  double balance = 0;
  int index = 0;
  bool showAmount;
  ValidatorInfo validator;
  var matic;
  TabController _tabController;
  bool showFab = false;
  TextEditingController _amount = TextEditingController();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      var validatorListCubit = context.read<ValidatorsdataCubit>();
      var delegatorListCubit = context.read<DelegationsDataCubit>();
      var ethListCubit = context.read<CovalentTokensListEthCubit>();
      tokenListCubit.getTokensList();
      _refreshLoop(
          tokenListCubit, ethListCubit, delegatorListCubit, validatorListCubit);
    });
    showAmount = true;
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        showFab = true;
      });
    });
    super.initState();
    _amount.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    _tabController ??= TabController(length: 2, vsync: this);

    var id = ModalRoute.of(context).settings.arguments;
    return BlocBuilder<CovalentTokensListEthCubit, CovalentTokensListEthState>(
      builder: (context, covalentEthState) {
        return BlocBuilder<CovalentTokensListMaticCubit,
            CovalentTokensListMaticState>(
          builder: (context, covalentMaticState) {
            return BlocBuilder<DelegationsDataCubit, DelegationsDataState>(
                builder: (context, delegationState) {
              return BlocBuilder<ValidatorsdataCubit, ValidatorsDataState>(
                  builder: (context, validatorState) {
                if (validatorState is ValidatorsDataStateLoading ||
                    validatorState is ValidatorsDataStateInitial ||
                    delegationState is DelegationsDataStateInitial ||
                    delegationState is DelegationsDataStateLoading ||
                    covalentMaticState is CovalentTokensListMaticLoading ||
                    covalentEthState is CovalentTokensListMaticLoading) {
                  return Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      title: Text(
                        'Amount to Delegate',
                        style: AppTheme.listTileTitle,
                      ),
                    ),
                    body: Center(
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
                    ),
                  );
                } else if (delegationState is DelegationsDataStateFinal &&
                    validatorState is ValidatorsDataStateFinal &&
                    covalentMaticState is CovalentTokensListMaticLoaded &&
                    covalentEthState is CovalentTokensListEthLoaded) {
                  if (covalentEthState.covalentTokenList.data.items
                          .where((element) =>
                              element.contractTickerSymbol.toLowerCase() ==
                              "matic")
                          .toList()
                          .length >
                      0) {
                    balance = EthConversions.weiToEth(
                        BigInt.parse(covalentEthState
                            .covalentTokenList.data.items
                            .where((element) =>
                                element.contractTickerSymbol.toLowerCase() ==
                                "matic")
                            .first
                            .balance),
                        18);
                  }

                  var matic = covalentMaticState.covalentTokenList.data.items
                      .where((element) =>
                          element.contractTickerSymbol.toLowerCase() == "matic")
                      .first;
                  print("id");
                  print(validatorState.data.result
                      .where((element) => element.id == id)
                      .toList()[0]
                      .contractAddress);
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
                  return Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      title: Text(
                        'Amount to Delegate',
                        style: AppTheme.listTileTitle,
                      ),
                    ),
                    body: Center(
                      child: SingleChildScrollView(
                        physics: MediaQuery.of(context).viewInsets.bottom == 0
                            ? NeverScrollableScrollPhysics()
                            : null,
                        child: Column(
                          mainAxisAlignment:
                              MediaQuery.of(context).viewInsets.bottom == 0
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).viewInsets.bottom == 0
                                      ? 0
                                      : MediaQuery.of(context).size.height *
                                          0.07,
                            ),
                            Card(
                              margin: EdgeInsets.all(AppTheme.paddingHeight12),
                              shape: AppTheme.cardShape,
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.paddingHeight),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Amount",
                                            style: AppTheme.label_medium,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              showAmount
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: AppTheme.warmgray_600,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                showAmount = !showAmount;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      showAmount
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        child: TextFormField(
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          controller: _amount,
                                                          keyboardAppearance:
                                                              Brightness.dark,
                                                          textAlign:
                                                              TextAlign.center,
                                                          autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          validator: (val) {
                                                            if (index == 0) {
                                                              if ((val == "" ||
                                                                      val ==
                                                                          null) ||
                                                                  (double.tryParse(
                                                                              val) ==
                                                                          null ||
                                                                      (double.tryParse(val) <
                                                                              0 ||
                                                                          double.tryParse(val) >
                                                                              balance)))
                                                                return "Invalid Amount";
                                                              else
                                                                return null;
                                                            } else {
                                                              if ((val == "" ||
                                                                      val ==
                                                                          null) ||
                                                                  (double.tryParse(
                                                                              val) ==
                                                                          null ||
                                                                      (double.tryParse(val) <
                                                                              0 ||
                                                                          double.tryParse(val) >
                                                                              FiatCryptoConversions.cryptoToFiat(balance, matic.quoteRate))))
                                                                return "Invalid Amount";
                                                              else
                                                                return null;
                                                            }
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .numberWithOptions(
                                                                      decimal:
                                                                          true),
                                                          style:
                                                              AppTheme.bigLabel,
                                                          decoration: InputDecoration(
                                                              hintText:
                                                                  "Amount",
                                                              fillColor: AppTheme
                                                                  .warmgray_100,
                                                              filled: true,
                                                              hintStyle: AppTheme
                                                                  .body_small,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border: OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppTheme
                                                                              .cardRadius))),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: AppTheme
                                                              .paddingHeight /
                                                          2,
                                                    ),
                                                    Container(
                                                      width: 150,
                                                      height: 50,
                                                      child: ColoredTabBar(
                                                        borderRadius:
                                                            AppTheme.cardRadius,
                                                        color: AppTheme
                                                            .tabbarBGColor,
                                                        tabbarMargin: 0,
                                                        tabbarPadding: AppTheme
                                                                .paddingHeight12 /
                                                            4,
                                                        tabBar: TabBar(
                                                          controller:
                                                              _tabController,
                                                          labelStyle: AppTheme
                                                              .tabbarTextStyle,
                                                          unselectedLabelStyle:
                                                              AppTheme
                                                                  .tabbarTextStyle,
                                                          indicatorSize:
                                                              TabBarIndicatorSize
                                                                  .tab,
                                                          indicator:
                                                              BoxDecoration(
                                                                  //gradient: LinearGradient(colors: [Colors.blue, Colors.blue]),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppTheme.cardRadiusBig /
                                                                              2),
                                                                  color: AppTheme
                                                                      .white),
                                                          tabs: [
                                                            Tab(
                                                              child: Align(
                                                                child: Text(
                                                                  'Matic',
                                                                  style: AppTheme
                                                                      .body_xsmall
                                                                      .copyWith(
                                                                          color:
                                                                              Colors.black),
                                                                ),
                                                              ),
                                                            ),
                                                            Tab(
                                                              child: Align(
                                                                child: Text(
                                                                  'USD',
                                                                  style: AppTheme
                                                                      .body_xsmall
                                                                      .copyWith(
                                                                          color:
                                                                              Colors.black),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                          onTap: (value) {
                                                            setState(() {
                                                              index = value;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      AppTheme.paddingHeight,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    (index == 0)
                                                        ? Text(
                                                            "\$" +
                                                                FiatCryptoConversions.cryptoToFiat(
                                                                        double.tryParse(_amount.text ==
                                                                                ""
                                                                            ? "0"
                                                                            : _amount
                                                                                .text),
                                                                        matic
                                                                            .quoteRate)
                                                                    .toStringAsFixed(
                                                                        3),
                                                            style: AppTheme
                                                                .body_small,
                                                          )
                                                        : Text(
                                                            FiatCryptoConversions.fiatToCrypto(
                                                                        matic
                                                                            .quoteRate,
                                                                        double.tryParse(_amount.text ==
                                                                                ""
                                                                            ? "0"
                                                                            : _amount
                                                                                .text))
                                                                    .toStringAsFixed(
                                                                        3) +
                                                                " " +
                                                                matic
                                                                    .contractName,
                                                            style: AppTheme
                                                                .body_small,
                                                          ),
                                                    TextButton(
                                                        onPressed: () {
                                                          if (index == 0)
                                                            setState(() {
                                                              index = 1;
                                                              _tabController
                                                                  .animateTo(1);
                                                            });
                                                          else
                                                            setState(() {
                                                              index = 0;
                                                              _tabController
                                                                  .animateTo(0);
                                                            });
                                                        },
                                                        child: Text(
                                                          (index == 0)
                                                              ? "Enter amount in USD"
                                                              : "Enter amount in MATIC",
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: AppTheme
                                                                  .orange_500),
                                                        ))
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      SizedBox(
                                        height: AppTheme.paddingHeight,
                                      ),
                                      Divider(
                                        thickness: 1,
                                        height: 1,
                                        color: AppTheme.warmgray_100,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            balance.toStringAsFixed(2) +
                                                " " +
                                                matic.contractName,
                                            style: AppTheme.body_small,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _amount.text =
                                                      balance.toString();
                                                });
                                              },
                                              child: Text(
                                                "MAX",
                                                style: TextStyle(
                                                    color: AppTheme.orange_500),
                                              ))
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            SizedBox(),
                            SizedBox(
                              height: AppTheme.buttonHeight_44,
                            )
                          ],
                        ),
                      ),
                    ),
                    floatingActionButtonAnimator: NoScalingAnimation(),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerFloat,
                    floatingActionButton: showFab
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: AppTheme.buttonHeight_44,
                            margin: EdgeInsets.symmetric(
                                horizontal: AppTheme.paddingHeight12),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: AppTheme.orange_500,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.buttonRadius))),
                                onPressed: () {
                                  _delegate(validator.contractAddress, matic);
                                },
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )),
                          )
                        : Container(),
                  );
                } else {
                  return Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      title: Text(
                        'Amount to Delegate',
                        style: AppTheme.listTileTitle,
                      ),
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
                                context.read<DelegationsDataCubit>().setData();
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
            });
          },
        );
      },
    );
  }

  _delegate(String spender, Items token) async {
    if (double.tryParse(_amount.text) == null) {
      Fluttertoast.showToast(
          msg: "Invalid amount", toastLength: Toast.LENGTH_LONG);
      return;
    }
    var amount;
    if (index == 1) {
      amount = FiatCryptoConversions.fiatToCrypto(
              token.quoteRate, double.tryParse(_amount.text))
          .toString();
    } else {
      amount = _amount.text;
    }
    if (double.tryParse(amount) == null || double.tryParse(amount) < 1) {
      Fluttertoast.showToast(
          msg: "Invalid amount", toastLength: Toast.LENGTH_LONG);
      return;
    }
    if (double.tryParse(amount) > balance) {
      Fluttertoast.showToast(
          msg: "Insufficient balance", toastLength: Toast.LENGTH_LONG);
      return;
    }
    print(spender);
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Insufficient approval"),
      shape: AppTheme.cardShape,
      content: Text(
          "You haven't given sufficient approval, would you like to approve now?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    GlobalKey<State> _key = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx;
    TransactionData transactionData;
    BigInt approval = await EthereumTransactions.allowance(
        config.stakeManagerProxy, config.maticToken);
    var wei = EthConversions.ethToWei(amount);
    print(approval);
    if (approval < wei) {
      bool appr = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      if (appr) {
        trx = await EthereumTransactions.approveErc20(
          config.maticToken,
          config.stakeManagerProxy,
        );
        transactionData = TransactionData(
            to: config.maticToken,
            amount: "0",
            trx: trx,
            token: token,
            type: TransactionType.APPROVE);
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    } else {
      trx = await StakingTransactions.buyVoucher(amount, spender);
      transactionData = TransactionData(
          to: spender,
          amount: amount,
          trx: trx,
          token: token,
          type: TransactionType.STAKE);
    }
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: transactionData);
  }

  _refreshLoop(
      CovalentTokensListMaticCubit cubit,
      CovalentTokensListEthCubit ethCubit,
      DelegationsDataCubit dCubit,
      ValidatorsdataCubit vCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
        ethCubit.refresh();
        dCubit.refresh();
        vCubit.refresh();
      }
    });
  }
}
