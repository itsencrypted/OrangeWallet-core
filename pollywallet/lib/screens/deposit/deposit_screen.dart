import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/covalent_models/covalent_token_list.dart';
import 'package:pollywallet/models/deposit_models/deposit_model.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_ethereum.dart';
import 'package:pollywallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/fiat_crypto_conversions.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/widgets/colored_tabbar.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:web3dart/web3dart.dart';

class DepositScreen extends StatefulWidget {
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  TextEditingController _amount = TextEditingController();
  DepositDataCubit data;
  BuildContext context;
  int bridge = 0;
  bool _isInitialized = false;
  double balance;
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  TabController _controller;
  bool showAmount;

  var ethCubit;
  @override
  initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshLoop(ethCubit);
    });
    showAmount = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ethCubit = context.read<CovalentTokensListEthCubit>();

    this.args = ModalRoute.of(context).settings.arguments;
    // _controller = TabController(length: 2, vsync: this);

    // if (!_isInitialized) {
    //   if (args == 1) {
    //     _controller.animateTo(0);
    //   }
    //   if (args == 2) {
    //     _controller.animateTo(1);
    //   }
    //   _controller.addListener(() {
    //     if (_controller.index == 0) {
    //       bridge = 1;
    //     } else {
    //       bridge = 2;
    //     }
    //   });
    // }
    this.data = context.read<DepositDataCubit>();

    if (args == 3 && bridge == 0) {
      bridge = 1;
    } else if (args != 3) {
      bridge = args;
    }

    return BlocBuilder<DepositDataCubit, DepositDataState>(
        builder: (BuildContext context, state) {
      return BlocBuilder<CovalentTokensListEthCubit,
          CovalentTokensListEthState>(builder: (context, tokenState) {
        if (state is DepositDataFinal &&
            tokenState is CovalentTokensListEthLoaded) {
          var token = tokenState.covalentTokenList.data.items
              .where((element) =>
                  element.contractAddress == state.data.token.contractAddress)
              .first;
          var balance = EthConversions.weiToEth(
              BigInt.parse(token.balance), token.contractDecimals);
          this.balance = balance;
          return Scaffold(
            appBar: AppBar(
              title: Text("Deposit to Matic"),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                Card(
                  margin: EdgeInsets.all(AppTheme.paddingHeight12),
                  shape: AppTheme.cardShape,
                  child: Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              "Amount",
                              style: AppTheme.label_medium,
                            ),
                            trailing: IconButton(
                              icon: Icon(showAmount
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down),
                              onPressed: () {
                                setState(() {
                                  showAmount = !showAmount;
                                });
                              },
                            ),
                          ),
                          showAmount
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      child: TextFormField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        controller: _amount,
                                        keyboardAppearance: Brightness.dark,
                                        textAlign: TextAlign.center,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (val) => (val == "" ||
                                                    val == null) ||
                                                (double.tryParse(val) == null ||
                                                    (double.tryParse(val) < 0 ||
                                                        double.tryParse(val) >
                                                            balance))
                                            ? "Invalid Amount"
                                            : null,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        style: AppTheme.bigLabel,
                                        decoration: InputDecoration(
                                            hintText: "Amount",
                                            fillColor: AppTheme.warmgray_100,
                                            filled: true,
                                            hintStyle: AppTheme.body_small,
                                            contentPadding: EdgeInsets.zero,
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppTheme.cardRadius))),
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppTheme.paddingHeight,
                                    ),
                                    Text(
                                      "\$" +
                                          FiatCryptoConversions.cryptoToFiat(
                                                  double.parse(
                                                      _amount.text == ""
                                                          ? "0"
                                                          : _amount.text),
                                                  token.quoteRate)
                                              .toString(),
                                      style: AppTheme.body_small,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                balance.toStringAsFixed(2) +
                                    " " +
                                    token.contractName,
                                style: AppTheme.body_small,
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _amount.text = balance.toString();
                                    });
                                  },
                                  child: Text(
                                    "MAX",
                                    style:
                                        TextStyle(color: AppTheme.purple_700),
                                  ))
                            ],
                          ),
                        ],
                      )),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    args == 2
                        ? ListTile(
                            leading: ClipOval(
                              clipBehavior: Clip.antiAlias,
                              child: Container(
                                child: Text("!",
                                    style: TextStyle(
                                        fontSize: 50,
                                        color: AppTheme.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            title: Text("Note"),
                            subtitle: Text(
                                "Assets deposited from Plasma Bridge takes upto 7 days for withdrawl."),
                            isThreeLine: true,
                          )
                        : SizedBox(
                            height: AppTheme.buttonHeight_44,
                          ),
                    SizedBox(
                      height: AppTheme.paddingHeight,
                    ),
                    SizedBox(
                      height: AppTheme.buttonHeight_44,
                    ),
                  ],
                )
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              width: MediaQuery.of(context).size.width,
              height: AppTheme.buttonHeight_44,
              margin:
                  EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight12),
              child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: AppTheme.purple_600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius))),
                  onPressed: () {
                    _sendDepositTransaction(state, token, context);
                  },
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  )),
            ),
          );
        }
      });
    });

    return Scaffold(
        appBar: AppBar(
            title: Text("Deposit to Matic"),
            bottom: args == 3
                ? ColoredTabBar(
                    tabBar: TabBar(
                      controller: _controller,
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
                              'POS',
                              style: AppTheme.tabbarTextStyle,
                            ),
                          ),
                        ),
                        Tab(
                          child: Align(
                            child: Text(
                              'Plasma',
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
                  )
                : null),
        body: TabBarView(
          physics: args == 3 ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          controller: _controller,
          children: [
            BlocBuilder<DepositDataCubit, DepositDataState>(
              builder: (BuildContext context, state) {
                return BlocBuilder<CovalentTokensListEthCubit,
                    CovalentTokensListEthState>(builder: (context, tokenState) {
                  if (state is DepositDataFinal &&
                      tokenState is CovalentTokensListEthLoaded) {
                    var token = tokenState.covalentTokenList.data.items
                        .where((element) =>
                            element.contractAddress ==
                            state.data.token.contractAddress)
                        .first;
                    var balance = EthConversions.weiToEth(
                        BigInt.parse(token.balance), token.contractDecimals);
                    this.balance = balance;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "POS bridge",
                          style: AppTheme.title,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextFormField(
                                controller: _amount,
                                keyboardAppearance: Brightness.dark,
                                textAlign: TextAlign.center,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (val) => (val == "" ||
                                            val == null) ||
                                        (double.tryParse(val) == null ||
                                            (double.tryParse(val) < 0 ||
                                                double.tryParse(val) > balance))
                                    ? "Invalid Amount"
                                    : null,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                style: AppTheme.bigLabel,
                                decoration: InputDecoration(
                                  hintText: "Amount",
                                  hintStyle: AppTheme.body1,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Text(
                              "\$" +
                                  FiatCryptoConversions.cryptoToFiat(
                                          double.parse(_amount.text == ""
                                              ? "0"
                                              : _amount.text),
                                          state.data.token.quoteRate)
                                      .toString(),
                              style: AppTheme.bigLabel,
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SafeArea(
                              child: ListTile(
                                leading: FlatButton(
                                  onPressed: () {
                                    if (index == 0) {
                                      setState(() {
                                        _amount.text = balance.toString();
                                      });
                                    } else {
                                      setState(() {
                                        _amount.text =
                                            FiatCryptoConversions.cryptoToFiat(
                                                    balance,
                                                    state.data.token.quoteRate)
                                                .toString();
                                      });
                                    }
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: ClipOval(
                                      child: Material(
                                    color: AppTheme.secondaryColor
                                        .withOpacity(0.3),
                                    child: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: Center(
                                          child: Text(
                                            "Max",
                                            style: AppTheme.title,
                                          ),
                                        )),
                                  )),
                                ),
                                title: Text(
                                  "Balance",
                                  style: AppTheme.subtitle,
                                ),
                                subtitle: Text(
                                  balance.toStringAsFixed(2) +
                                      " " +
                                      state.data.token.contractName,
                                  style: AppTheme.title,
                                ),
                                trailing: FlatButton(
                                  onPressed: () {
                                    _sendDepositTransaction(
                                        state, token, context);
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: ClipOval(
                                      child: Material(
                                    color: AppTheme.primaryColor,
                                    child: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: Center(
                                          child: Icon(Icons.check,
                                              color: AppTheme.white),
                                        )),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  } else {
                    return Center(child: Text("Something went Wrong"));
                  }
                });
              },
            ),
            BlocBuilder<DepositDataCubit, DepositDataState>(
              builder: (BuildContext context, state) {
                return BlocBuilder<CovalentTokensListEthCubit,
                    CovalentTokensListEthState>(builder: (context, tokenState) {
                  if (state is DepositDataFinal &&
                      tokenState is CovalentTokensListEthLoaded) {
                    var token = tokenState.covalentTokenList.data.items
                        .where((element) =>
                            element.contractAddress ==
                            state.data.token.contractAddress)
                        .first;
                    var balance = EthConversions.weiToEth(
                        BigInt.parse(token.balance), token.contractDecimals);
                    this.balance = balance;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Plasma Bridge", style: AppTheme.title),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextFormField(
                                controller: _amount,
                                keyboardAppearance: Brightness.dark,
                                textAlign: TextAlign.center,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (val) => (val == "" ||
                                            val == null) ||
                                        (double.tryParse(val) == null ||
                                            (double.tryParse(val) < 0 ||
                                                double.tryParse(val) > balance))
                                    ? "Invalid Amount"
                                    : null,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                style: AppTheme.bigLabel,
                                decoration: InputDecoration(
                                  hintText: "Amount",
                                  hintStyle: AppTheme.body1,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Text(
                              "\$" +
                                  FiatCryptoConversions.cryptoToFiat(
                                          double.parse(_amount.text == ""
                                              ? "0"
                                              : _amount.text),
                                          state.data.token.quoteRate)
                                      .toString(),
                              style: AppTheme.bigLabel,
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ListTile(
                              leading: ClipOval(
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  child: Text("!",
                                      style: TextStyle(
                                          fontSize: 50,
                                          color: AppTheme.black,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              title: Text("Note"),
                              subtitle: Text(
                                  "Assets deposited from Plasma Bridge takes upto 7 days for withdrawl."),
                              isThreeLine: true,
                            ),
                            SafeArea(
                              child: ListTile(
                                leading: FlatButton(
                                  onPressed: () {
                                    if (index == 0) {
                                      setState(() {
                                        _amount.text = balance.toString();
                                      });
                                    } else {
                                      setState(() {
                                        _amount.text =
                                            FiatCryptoConversions.cryptoToFiat(
                                                    balance,
                                                    state.data.token.quoteRate)
                                                .toString();
                                      });
                                    }
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: ClipOval(
                                      child: Material(
                                    color: AppTheme.secondaryColor
                                        .withOpacity(0.3),
                                    child: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: Center(
                                          child: Text(
                                            "Max",
                                            style: AppTheme.title,
                                          ),
                                        )),
                                  )),
                                ),
                                title: Text(
                                  "Balance",
                                  style: AppTheme.subtitle,
                                ),
                                subtitle: Text(
                                  balance.toStringAsFixed(2) +
                                      " " +
                                      state.data.token.contractName,
                                  style: AppTheme.title,
                                ),
                                trailing: FlatButton(
                                  onPressed: () {
                                    _sendDepositTransaction(
                                        state, token, context);
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  child: ClipOval(
                                      child: Material(
                                    color: AppTheme.primaryColor,
                                    child: SizedBox(
                                        height: 56,
                                        width: 56,
                                        child: Center(
                                          child: Icon(Icons.check,
                                              color: AppTheme.white),
                                        )),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  } else {
                    return Center(child: Text("Something went Wrong"));
                  }
                });
              },
            ),
          ],
        ));
  }

  _sendDepositTransaction(
      DepositDataFinal state, Items tokenState, BuildContext context) async {
    if (double.tryParse(_amount.text) == null ||
        double.tryParse(_amount.text) < 0 ||
        double.tryParse(_amount.text) > balance) {
      Fluttertoast.showToast(
          msg: "Invalid amount", toastLength: Toast.LENGTH_LONG);
      return;
    }
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
      title: Text("AlertDialog"),
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
    if (state.data.token.contractAddress.toLowerCase() ==
        ethAddress.toLowerCase()) {
      data.setData(DepositModel(
          token: state.data.token, amount: _amount.toString(), isEth: true));
      if (bridge == 1) {
        trx = await EthereumTransactions.depositEthPos(_amount.text);
        transactionData = TransactionData(
            to: config.erc20PredicatePos,
            trx: trx,
            amount: _amount.text,
            token: tokenState,
            type: TransactionType.DEPOSITPOS);
      } else {
        trx = await EthereumTransactions.depositEthPlasma(_amount.text);
        transactionData = TransactionData(
            to: config.depositManager,
            trx: trx,
            amount: _amount.text,
            token: tokenState,
            type: TransactionType.DEPOSITPLASMA);
      }
    }
    //Todo: Deposit Eth
    else {
      Bridge brd;
      if (bridge == 1)
        brd = Bridge.POS;
      else
        brd = Bridge.PLASMA;
      BigInt approval = await EthereumTransactions.bridgeAllowanceERC20(
          state.data.token.contractAddress, brd);
      var wei = EthConversions.ethToWei(_amount.text);
      if (approval < wei) {
        bool appr = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
        if (appr) {
          if (bridge == 1) {
            trx = await EthereumTransactions.approveErc20(
              state.data.token.contractAddress,
              config.erc20PredicatePos,
            );
          } else {
            trx = await EthereumTransactions.approveErc20(
              state.data.token.contractAddress,
              config.depositManager,
            );
          }
          transactionData = TransactionData(
              to: state.data.token.contractAddress,
              amount: "0",
              trx: trx,
              type: TransactionType.APPROVE);
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          return;
        }
      } else {
        if (bridge == 1) {
          trx = await EthereumTransactions.depositErc20Pos(
              _amount.text, state.data.token.contractAddress);
          transactionData = TransactionData(
              to: config.erc20PredicatePos,
              amount: _amount.text,
              trx: trx,
              token: tokenState,
              type: TransactionType.DEPOSITPOS);
        } else {
          trx = await EthereumTransactions.depositErc20Plasma(
              _amount.text, state.data.token.contractAddress);
          transactionData = TransactionData(
              to: config.depositManager,
              amount: _amount.text,
              trx: trx,
              token: tokenState,
              type: TransactionType.DEPOSITPLASMA);
        }
      }
    }
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: transactionData);
  }

  _refreshLoop(CovalentTokensListEthCubit cubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        cubit.refresh();
      }
    });
  }
}
