import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orangewallet/constants.dart';
import 'package:orangewallet/models/send_token_model/send_token_data.dart';
import 'package:orangewallet/models/transaction_data/transaction_data.dart';
import 'package:orangewallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:orangewallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:orangewallet/theme_data.dart';
import 'package:orangewallet/utils/fiat_crypto_conversions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orangewallet/utils/web3_utils/eth_conversions.dart';
import 'package:orangewallet/utils/web3_utils/matic_transactions.dart';
import 'package:orangewallet/widgets/colored_tabbar.dart';
import 'package:web3dart/web3dart.dart';

class SendTokenAmount extends StatefulWidget {
  @override
  _SendTokenAmountState createState() => _SendTokenAmountState();
}

class _SendTokenAmountState extends State<SendTokenAmount>
    with SingleTickerProviderStateMixin {
  SendTransactionCubit data;
  int index = 0;
  TextEditingController _amount = TextEditingController();
  TextEditingController _address =
      TextEditingController(text: "0x9dba0d4072fa279ceab88ac01f72f1d1d63ddb13");
  RegExp reg = RegExp(r'^0x[a-fA-F0-9]{40}$');
  bool showAddress;
  bool showAmount;
  TabController _tabController;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      data = context.read<SendTransactionCubit>();
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      _refreshLoop(tokenListCubit);
    });
    _tabController = TabController(length: 2, vsync: this);

    _amount.addListener(() {
      setState(() {});
    });
    showAddress = showAmount = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SendTransactionCubit, SendTransactionState>(
      builder: (BuildContext context, state) {
        return BlocBuilder<CovalentTokensListMaticCubit,
            CovalentTokensListMaticState>(
          builder: (context, tokenState) {
            if (state is SendTransactionFinal &&
                tokenState is CovalentTokensListMaticLoaded) {
              var token = tokenState.covalentTokenList.data.items
                  .where((element) =>
                      state.data.token.contractAddress ==
                      element.contractAddress)
                  .first;
              var reciever = state.data.receiver;
              _address.text = reciever;
              var balance = EthConversions.weiToEth(
                  BigInt.parse(token.balance), token.contractDecimals);
              return Scaffold(
                appBar: AppBar(
                  title: Text("Paying"),
                ),
                body: SingleChildScrollView(
                  physics: MediaQuery.of(context).viewInsets.bottom == 0
                      ? NeverScrollableScrollPhysics()
                      : null,
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        Card(
                          margin: EdgeInsets.all(AppTheme.paddingHeight12),
                          shape: AppTheme.cardShape,
                          child: Container(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.paddingHeight),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Address",
                                      style: AppTheme.label_medium,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        showAddress
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: AppTheme.warmgray_600,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showAddress = !showAddress;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              showAddress
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppTheme.paddingHeight),
                                      margin: EdgeInsets.symmetric(
                                          vertical: AppTheme.paddingHeight),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.cardRadius)),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            child: Icon(
                                              Icons.paste,
                                              color: Colors.black,
                                            ),
                                            onPressed: () async {
                                              ClipboardData data =
                                                  await Clipboard.getData(
                                                      'text/plain');
                                              _address.text = data.text;
                                            },
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.warmgray_100,
                                                elevation: 0,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius
                                                            .circular(AppTheme
                                                                .cardRadius),
                                                        bottomLeft: Radius
                                                            .circular(AppTheme
                                                                .cardRadius)))),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _address,
                                              keyboardAppearance:
                                                  Brightness.dark,
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              validator: (val) =>
                                                  reg.hasMatch(val)
                                                      ? null
                                                      : "Invalid addresss",
                                              textAlign: TextAlign.center,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              keyboardType: TextInputType.text,
                                              style: AppTheme.body_small,
                                              decoration: InputDecoration(
                                                  fillColor:
                                                      AppTheme.warmgray_100,
                                                  hintText:
                                                      "Enter the reciepients address ",
                                                  filled: true,
                                                  hintStyle:
                                                      AppTheme.body_small,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                      borderRadius:
                                                          BorderRadius.zero)

                                                  //focusedBorder: InputBorder.none,
                                                  //enabledBorder: InputBorder.none,
                                                  ),
                                            ),
                                          ),
                                          TextButton(
                                            child: Image.asset(
                                                "assets/icons/qr_icon.png",
                                                color: AppTheme.darkerText),
                                            onPressed: () async {
                                              var qrResult =
                                                  await BarcodeScanner.scan();
                                              RegExp reg = RegExp(
                                                  r'^0x[0-9a-fA-F]{40}$');
                                              print(qrResult.rawContent);
                                              if (reg.hasMatch(
                                                  qrResult.rawContent)) {
                                                print("Regex");
                                                if (qrResult
                                                        .rawContent.length ==
                                                    42) {
                                                  _address.text =
                                                      qrResult.rawContent;
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg: "Invalid QR",
                                                  );
                                                }
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg: "Invalid QR",
                                                );
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.warmgray_100,
                                                elevation: 0,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius
                                                            .circular(AppTheme
                                                                .cardRadius),
                                                        bottomRight: Radius
                                                            .circular(AppTheme
                                                                .cardRadius)))),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: AppTheme.warmgray_100,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.paddingHeight),
                                child: Row(
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
                              ),
                              showAmount
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppTheme.paddingHeight),
                                      child: Column(
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
                                                    textAlign: TextAlign.center,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    validator: (val) {
                                                      if (index == 0) {
                                                        if ((val == "" ||
                                                                val == null) ||
                                                            (double.tryParse(
                                                                        val) ==
                                                                    null ||
                                                                (double.tryParse(
                                                                        val) <
                                                                    0)))
                                                          return "Invalid Amount";
                                                        else if (double
                                                                .tryParse(val) >
                                                            balance) {
                                                          return "Insufficient balance";
                                                        } else {
                                                          return null;
                                                        }
                                                      } else {
                                                        if ((val == "" ||
                                                                val == null) ||
                                                            (double.tryParse(
                                                                        val) ==
                                                                    null ||
                                                                (double.tryParse(
                                                                            val) <
                                                                        0 ||
                                                                    double.tryParse(
                                                                            val) >
                                                                        FiatCryptoConversions.cryptoToFiat(
                                                                            balance,
                                                                            token.quoteRate))))
                                                          return "Invalid Amount";
                                                        else
                                                          return null;
                                                      }
                                                    },
                                                    keyboardType: TextInputType
                                                        .numberWithOptions(
                                                            decimal: true),
                                                    style: AppTheme.bigLabel,
                                                    decoration: InputDecoration(
                                                        hintText: "Amount",
                                                        fillColor: AppTheme
                                                            .warmgray_100,
                                                        filled: true,
                                                        hintStyle:
                                                            AppTheme.body_small,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        border: OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                            borderRadius: BorderRadius
                                                                .circular(AppTheme
                                                                    .cardRadius))),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    AppTheme.paddingHeight / 2,
                                              ),
                                              Container(
                                                width: 150,
                                                height: 50,
                                                child: ColoredTabBar(
                                                  borderRadius:
                                                      AppTheme.cardRadius,
                                                  color: AppTheme.tabbarBGColor,
                                                  tabbarMargin: 0,
                                                  tabbarPadding:
                                                      AppTheme.paddingHeight12 /
                                                          4,
                                                  tabBar: TabBar(
                                                    controller: _tabController,
                                                    labelStyle: AppTheme
                                                        .tabbarTextStyle,
                                                    unselectedLabelStyle:
                                                        AppTheme
                                                            .tabbarTextStyle,
                                                    indicatorSize:
                                                        TabBarIndicatorSize.tab,
                                                    indicator: BoxDecoration(
                                                        //gradient: LinearGradient(colors: [Colors.blue, Colors.blue]),
                                                        borderRadius: BorderRadius
                                                            .circular(AppTheme
                                                                    .cardRadiusBig /
                                                                2),
                                                        color: AppTheme.white),
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
                                            height: AppTheme.paddingHeight / 2,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              (index == 0)
                                                  ? Text(
                                                      "\$" +
                                                          FiatCryptoConversions.cryptoToFiat(
                                                                  double.tryParse(
                                                                      _amount.text ==
                                                                              ""
                                                                          ? "0"
                                                                          : _amount
                                                                              .text),
                                                                  token
                                                                      .quoteRate)
                                                              .toStringAsFixed(
                                                                  3),
                                                      style:
                                                          AppTheme.body_small,
                                                    )
                                                  : Text(
                                                      FiatCryptoConversions.fiatToCrypto(
                                                                  token
                                                                      .quoteRate,
                                                                  double.tryParse(
                                                                      _amount.text ==
                                                                              ""
                                                                          ? "0"
                                                                          : _amount
                                                                              .text))
                                                              .toStringAsFixed(
                                                                  3) +
                                                          " " +
                                                          token.contractName,
                                                      style:
                                                          AppTheme.body_small,
                                                    ),

                                              // Text Button to enter amount in USD and Matic
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              SizedBox(
                                height: AppTheme.paddingHeight / 2,
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: AppTheme.warmgray_100,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppTheme.paddingHeight),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      balance.toStringAsFixed(2) +
                                          " " +
                                          token.contractName,
                                      style: AppTheme.body_small,
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          if (index == 0) {
                                            setState(() {
                                              _amount.text = balance.toString();
                                            });
                                          } else {
                                            setState(() {
                                              _amount.text =
                                                  FiatCryptoConversions
                                                          .cryptoToFiat(balance,
                                                              token.quoteRate)
                                                      .toString();
                                            });
                                          }
                                        },
                                        child: Text(
                                          "MAX",
                                          style: TextStyle(
                                              color: AppTheme.orange_500),
                                        ))
                                  ],
                                ),
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
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: Container(
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
                      onPressed: () async {
                        try {
                          double amount;
                          if (double.tryParse(_amount.text) == null) {
                            Fluttertoast.showToast(
                                msg: "Invalid amount",
                                toastLength: Toast.LENGTH_LONG);
                            return;
                          }
                          if (index == 0) {
                            amount = double.tryParse(_amount.text);
                          } else {
                            amount = FiatCryptoConversions.fiatToCrypto(
                                token.quoteRate, double.tryParse(_amount.text));
                          }
                          if (validateAddress(_address.text) != null ||
                              amount < 0) {
                            Fluttertoast.showToast(
                              msg: "Invalid inputs",
                            );
                            return;
                          }
                          if (amount > balance) {
                            Fluttertoast.showToast(
                              msg: "Insufficient balance",
                            );
                            return;
                          }

                          data.setData(SendTokenData(
                              token: token,
                              receiver: _address.text,
                              amount: amount.toString()));
                          Transaction trx;
                          if (token.contractAddress == maticAddress)
                            trx = await MaticTransactions.transferMatic(
                                _amount.text, _address.text, context);
                          else
                            trx = await MaticTransactions.transferERC20(
                                _amount.text,
                                _address.text,
                                token.contractAddress,
                                context);
                          TransactionData args = TransactionData(
                              trx: trx,
                              token: token,
                              amount: _amount.text,
                              to: _address.text,
                              type: TransactionType.SEND);

                          Navigator.pushNamed(
                              context, confirmMaticTransactionRoute,
                              arguments: args);
                        } catch (e) {
                          Fluttertoast.showToast(msg: e.text);
                        }
                      },
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      )),
                ),
              );
            } else {
              return Scaffold(
                  appBar: AppBar(
                    title: Text("Send token"),
                  ),
                  body: Center(child: Text("Something went Wrong")));
            }
          },
        );
      },
    );
  }

  _refreshLoop(CovalentTokensListMaticCubit maticCubit) {
    new Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (mounted) {
        maticCubit.refresh();
      }
    });
  }

  String validateAddress(String value) {
    RegExp regex = new RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid Ethereum address';
    else
      return null;
  }
}
