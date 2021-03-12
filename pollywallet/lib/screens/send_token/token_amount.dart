import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/send_token_model/send_token_data.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/fiat_crypto_conversions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';
import 'package:pollywallet/widgets/colored_tabbar.dart';
import 'package:web3dart/web3dart.dart';

class SendTokenAmount extends StatefulWidget {
  @override
  _SendTokenAmountState createState() => _SendTokenAmountState();
}

class _SendTokenAmountState extends State<SendTokenAmount>
    with SingleTickerProviderStateMixin {
  SendTransactionCubit data;
  int index = 0;
  TabController _controller;
  TextEditingController _amount = TextEditingController();
  TextEditingController _address =
      TextEditingController(text: "0x97F5aE30eEdd5C3c531C97E41386618b1831Cb7b");
  RegExp reg = RegExp(r'^0x[a-fA-F0-9]{40}$');
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      data = context.read<SendTransactionCubit>();
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      _refreshLoop(tokenListCubit);
    });
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      setState(() {
        index = _controller.index;
        _amount.text = "";
      });
    });
    _amount.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Paying"),
            bottom: ColoredTabBar(
              tabBar: TabBar(
                controller: _controller,
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
                        'Token',
                        style: AppTheme.tabbarTextStyle,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      child: Text(
                        'USD',
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
        body: BlocBuilder<SendTransactionCubit, SendTransactionState>(
          builder: (BuildContext context, state) {
            return BlocBuilder<CovalentTokensListMaticCubit,
                CovalentTokensListMaticState>(builder: (context, tokenState) {
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
                return TabBarView(
                  controller: _controller,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: TextFormField(
                                controller: _address,
                                keyboardAppearance: Brightness.dark,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (val) => reg.hasMatch(val)
                                    ? null
                                    : "Invalid addresss",
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                style: AppTheme.bigLabel,
                                decoration: InputDecoration(
                                    prefix: FlatButton(
                                      child: Icon(Icons.paste),
                                      onPressed: () async {
                                        ClipboardData data =
                                            await Clipboard.getData(
                                                'text/plain');
                                        _address.text = data.text;
                                      },
                                    ),
                                    suffix: FlatButton(
                                      child: Icon(Icons.qr_code),
                                      onPressed: () async {
                                        var qrResult =
                                            await BarcodeScanner.scan();
                                        RegExp reg =
                                            RegExp(r'^0x[0-9a-fA-F]{40}$');
                                        print(qrResult.rawContent);
                                        if (reg.hasMatch(qrResult.rawContent)) {
                                          print("Regex");
                                          if (qrResult.rawContent.length ==
                                              42) {
                                            _address.text = qrResult.rawContent;
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
                                    ),
                                    hintText: "Address",
                                    hintStyle: AppTheme.body1,
                                    focusColor: AppTheme.secondaryColor
                                    //focusedBorder: InputBorder.none,
                                    //enabledBorder: InputBorder.none,
                                    ),
                              ),
                            ),
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
                                          token.quoteRate)
                                      .toString(),
                              style: AppTheme.bigLabel,
                            )
                          ],
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
                                                balance, token.quoteRate)
                                            .toString();
                                  });
                                }
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: ClipOval(
                                  child: Material(
                                color: AppTheme.secondaryColor.withOpacity(0.3),
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
                                  token.contractName,
                              style: AppTheme.title,
                            ),
                            trailing: FlatButton(
                              onPressed: () async {
                                double amount;
                                if (double.tryParse(_amount.text) == null) {
                                  Fluttertoast.showToast(
                                      msg: "Invalid amount",
                                      toastLength: Toast.LENGTH_LONG);
                                  return;
                                }
                                if (index == 0) {
                                  amount = double.parse(_amount.text);
                                } else {
                                  amount = FiatCryptoConversions.fiatToCrypto(
                                      token.quoteRate,
                                      double.parse(_amount.text));
                                }
                                if (validateAddress(_address.text) != null ||
                                    amount < 0 ||
                                    amount > balance) {
                                  Fluttertoast.showToast(
                                    msg: "Invalid inputs",
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
                                    amount: _amount.text,
                                    to: _address.text,
                                    type: TransactionType.SEND);

                                Navigator.pushNamed(
                                    context, confirmMaticTransactionRoute,
                                    arguments: args);
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
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: TextFormField(
                                controller: _address,
                                keyboardAppearance: Brightness.dark,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (val) => reg.hasMatch(val)
                                    ? null
                                    : "Invalid addresss",
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                style: AppTheme.bigLabel,
                                decoration: InputDecoration(
                                    prefix: FlatButton(
                                      child: Icon(Icons.paste),
                                      onPressed: () async {
                                        ClipboardData data =
                                            await Clipboard.getData(
                                                'text/plain');
                                        _address.text = data.text;
                                      },
                                    ),
                                    suffix: FlatButton(
                                      child: Icon(Icons.qr_code),
                                      onPressed: () async {
                                        var qrResult =
                                            await BarcodeScanner.scan();
                                        RegExp reg =
                                            RegExp(r'^0x[0-9a-fA-F]{40}$');
                                        print(qrResult.rawContent);
                                        if (reg.hasMatch(qrResult.rawContent)) {
                                          print("Regex");
                                          if (qrResult.rawContent.length ==
                                              42) {
                                            _address.text = qrResult.rawContent;
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
                                    ),
                                    hintText: "Address",
                                    hintStyle: AppTheme.body1,
                                    focusColor: AppTheme.secondaryColor
                                    //focusedBorder: InputBorder.none,
                                    //enabledBorder: InputBorder.none,
                                    ),
                              ),
                            ),
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
                                                double.tryParse(val) >
                                                    FiatCryptoConversions
                                                        .cryptoToFiat(balance,
                                                            token.quoteRate)))
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
                              FiatCryptoConversions.fiatToCrypto(
                                          token.quoteRate,
                                          double.tryParse(_amount.text == ""
                                              ? "0"
                                              : _amount.text))
                                      .toString() +
                                  " " +
                                  token.contractName,
                              style: AppTheme.bigLabel,
                            )
                          ],
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
                                                balance, token.quoteRate)
                                            .toString();
                                  });
                                }
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              child: ClipOval(
                                  child: Material(
                                color: AppTheme.secondaryColor.withOpacity(0.3),
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
                                  token.contractName,
                              style: AppTheme.title,
                            ),
                            trailing: FlatButton(
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
                                    amount = double.parse(_amount.text);
                                  } else {
                                    amount = FiatCryptoConversions.fiatToCrypto(
                                        token.quoteRate,
                                        double.parse(_amount.text));
                                  }
                                  if (validateAddress(_address.text) != null ||
                                      amount < 0 ||
                                      amount > balance) {
                                    Fluttertoast.showToast(
                                      msg: "Invalid inputs",
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
                        )
                      ],
                    ),
                  ],
                );
              } else {
                return Center(child: Text("Something went Wrong"));
              }
            });
          },
        ));
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
