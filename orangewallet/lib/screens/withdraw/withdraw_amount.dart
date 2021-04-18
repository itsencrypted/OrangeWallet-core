import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/covalent_models/covalent_token_list.dart';
import 'package:orangewallet/models/transaction_data/transaction_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orangewallet/screens/staking/ui_elements/warning_card.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/state_manager/withdraw_burn_state/withdraw_burn_data_cubit.dart';
import 'package:orangewallet/utils/fiat_crypto_conversions.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';
import 'package:orangewallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:orangewallet/widgets/colored_tabbar.dart';
import 'package:orangewallet/widgets/loading_indicator.dart';
import 'package:orangewallet/widgets/matic_to_eth_indicator.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen>
    with SingleTickerProviderStateMixin<WithdrawScreen> {
  TextEditingController _amount = TextEditingController();
  WithdrawBurnDataCubit data;
  BuildContext context;
  int bridge = 0;
  double balance = 0;
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  bool showAmount;
  TabController _tabController;
  bool showWarning = true;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      tokenListCubit.getTokensList();

      _refreshLoop(tokenListCubit);
    });
    showAmount = true;
    _amount.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _tabController ??= TabController(length: 2, vsync: this);

    this.data = context.read<WithdrawBurnDataCubit>();
    this.args = ModalRoute.of(context).settings.arguments;

    if (args == 3 && bridge == 0) {
      bridge = 1;
    } else if (args != 3) {
      bridge = args;
    }

    return BlocBuilder<WithdrawBurnDataCubit, WithdrawBurnDataState>(
      builder: (BuildContext context, state) {
        return BlocBuilder<CovalentTokensListMaticCubit,
            CovalentTokensListMaticState>(builder: (context, tokenState) {
          if (state is WithdrawBurnDataFinal &&
              tokenState is CovalentTokensListMaticLoaded) {
            var token = tokenState.covalentTokenList.data.items
                .where((element) =>
                    element.contractAddress == state.data.token.contractAddress)
                .first;
            var balance = EthConversions.weiToEth(
                BigInt.parse(token.balance), token.contractDecimals);
            this.balance = balance;

            return Scaffold(
              appBar: AppBar(
                title: Text("Withdraw from Matic"),
              ),
              body: SingleChildScrollView(
                physics: MediaQuery.of(context).viewInsets.bottom == 0
                    ? NeverScrollableScrollPhysics()
                    : null,
                child: Container(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height,
                  child: Column(
                    mainAxisAlignment:
                        MediaQuery.of(context).viewInsets.bottom == 0
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom == 0
                            ? 0
                            : MediaQuery.of(context).size.height * 0.07,
                      ),
                      Column(
                        children: [
                          Container(
                            child: MaticToEthIndicator(),
                            margin:
                                EdgeInsets.all(AppTheme.paddingHeight20 / 2),
                          ),
                          Card(
                            margin: EdgeInsets.all(AppTheme.paddingHeight12),
                            shape: AppTheme.cardShape,
                            child: Container(
                                padding: EdgeInsets.all(16),
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
                                                mainAxisSize: MainAxisSize.min,
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
                                                                            FiatCryptoConversions.cryptoToFiat(balance,
                                                                                token.quoteRate))))
                                                              return "Invalid Amount";
                                                            else
                                                              return null;
                                                          }
                                                        },
                                                        keyboardType: TextInputType
                                                            .numberWithOptions(
                                                                decimal: true),
                                                        style:
                                                            AppTheme.bigLabel,
                                                        decoration: InputDecoration(
                                                            hintText: "Amount",
                                                            fillColor: AppTheme
                                                                .warmgray_100,
                                                            filled: true,
                                                            hintStyle: AppTheme
                                                                .body_small,
                                                            contentPadding:
                                                                EdgeInsets.zero,
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
                                                    width:
                                                        AppTheme.paddingHeight /
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
                                                                    BorderRadius
                                                                        .circular(
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
                                                                        color: Colors
                                                                            .black),
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
                                                                        color: Colors
                                                                            .black),
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
                                                height: AppTheme.paddingHeight,
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
                                                                      token
                                                                          .quoteRate)
                                                                  .toStringAsFixed(
                                                                      3),
                                                          style: AppTheme
                                                              .body_small,
                                                        )
                                                      : Text(
                                                          FiatCryptoConversions.fiatToCrypto(
                                                                      token
                                                                          .quoteRate,
                                                                      double.tryParse(_amount.text ==
                                                                              ""
                                                                          ? "0"
                                                                          : _amount
                                                                              .text))
                                                                  .toStringAsFixed(
                                                                      3) +
                                                              " " +
                                                              token
                                                                  .contractName,
                                                          style: AppTheme
                                                              .body_small,
                                                        ),
                                                  // TextButton(
                                                  //     onPressed: () {
                                                  //       if (index == 0)
                                                  //         setState(() {
                                                  //           index = 1;
                                                  //           _tabController
                                                  //               .animateTo(1);
                                                  //         });
                                                  //       else
                                                  //         setState(() {
                                                  //           index = 0;
                                                  //           _tabController
                                                  //               .animateTo(0);
                                                  //         });
                                                  //     },
                                                  //     child: Text(
                                                  //       (index == 0)
                                                  //           ? "Enter amount in USD"
                                                  //           : "Enter amount in MATIC",
                                                  //       style: TextStyle(
                                                  //           decoration:
                                                  //               TextDecoration
                                                  //                   .underline,
                                                  //           color: AppTheme
                                                  //               .orange_500),
                                                  //     ))
                                                  TextButton(
                                                      onPressed: () {
                                                        if (index == 0) {
                                                          setState(() {
                                                            _amount.text =
                                                                balance
                                                                    .toString();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            _amount
                                                                .text = FiatCryptoConversions
                                                                    .cryptoToFiat(
                                                                        balance,
                                                                        token
                                                                            .quoteRate)
                                                                .toString();
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        "MAX",
                                                        style: TextStyle(
                                                            color: AppTheme
                                                                .orange_500),
                                                      ))
                                                ],
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppTheme.buttonHeight_44 + 23,
                      )
                    ],
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bridge == 2
                      ? MediaQuery.of(context).viewInsets.bottom == 0
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: AppTheme.paddingHeight / 2),
                              child: WarningCard(
                                onClose: null,
                                warningText:
                                    "Assets deposited from Plasma Bridge takes upto 7 days for withdrawl.",
                              ),
                            )
                          : SizedBox(
                              height: AppTheme.buttonHeight_44,
                            )
                      : Container(),
                  Container(
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
                          _sendWithDrawTransaction(state, token, context);
                        },
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        )),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("Something went Wrong"));
          }
        });
      },
    );
  }

  _sendWithDrawTransaction(
      WithdrawBurnDataFinal state, Items token, BuildContext context) async {
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
    if (double.tryParse(amount) > balance) {
      Fluttertoast.showToast(
          msg: "Invalid amount", toastLength: Toast.LENGTH_LONG);
      return;
    }
    if (double.tryParse(amount) > balance) {
      Fluttertoast.showToast(
          msg: "Insufficent balance", toastLength: Toast.LENGTH_LONG);
      return;
    }
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    TransactionData transactionData;
    var trx = await WithdrawManagerWeb3.burnTx(
        amount, state.data.token.contractAddress);
    var type;
    if (bridge == 1) {
      type = TransactionType.BURNPOS;
    } else if (bridge == 2) {
      type = TransactionType.BURNPLASMA;
    } else {
      return;
    }

    transactionData = TransactionData(
        amount: amount,
        to: state.data.token.contractAddress,
        trx: trx,
        token: state.data.token,
        type: type);
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, confirmMaticTransactionRoute,
        arguments: transactionData);
  }

  _refreshLoop(CovalentTokensListMaticCubit cubit) {
    new Timer.periodic(Duration(seconds: 15), (Timer t) {
      if (mounted) {
        cubit.refresh();
      }
    });
  }
}
