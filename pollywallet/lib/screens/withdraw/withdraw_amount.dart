import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/state_manager/covalent_states/covalent_token_list_cubit_matic.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/state_manager/withdraw_burn_state/withdraw_burn_data_cubit.dart';
import 'package:pollywallet/utils/fiat_crypto_conversions.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  TextEditingController _amount = TextEditingController();
  WithdrawBurnDataCubit data;
  BuildContext context;
  int bridge = 0;
  double balance = 0;
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  int index = 0;
  bool showAmount;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      var tokenListCubit = context.read<CovalentTokensListMaticCubit>();
      tokenListCubit.getTokensList();

      _refreshLoop(tokenListCubit);
    });
    showAmount = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (val) => (val == "" ||
                                                      val == null) ||
                                                  (double.tryParse(val) ==
                                                          null ||
                                                      (double.tryParse(val) <
                                                              0 ||
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
                                                          AppTheme
                                                              .cardRadius))),
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
                      bridge == 2
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
                  ),
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
                      _sendWithDrawTransaction(state, context);
                    },
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    )),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    args == 3
                        ? CupertinoSegmentedControl<int>(
                            pressedColor:
                                AppTheme.somewhatYellow.withOpacity(0.9),
                            groupValue: index,
                            selectedColor:
                                AppTheme.somewhatYellow.withOpacity(0.9),
                            borderColor:
                                AppTheme.somewhatYellow.withOpacity(0.01),
                            unselectedColor:
                                AppTheme.somewhatYellow.withOpacity(0.9),
                            padding: EdgeInsets.all(10),
                            children: {
                              0: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3))),
                                  elevation: index == 0 ? 1 : 0,
                                  color: index == 0
                                      ? AppTheme.backgroundWhite
                                      : AppTheme.somewhatYellow
                                          .withOpacity(0.01),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Text(
                                      "POS",
                                      style: AppTheme.body1,
                                    ),
                                  ),
                                ),
                              ),
                              1: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(3))),
                                  elevation: index == 1 ? 1 : 0,
                                  color: index == 1
                                      ? AppTheme.backgroundWhite
                                      : AppTheme.somewhatYellow
                                          .withOpacity(0.01),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10),
                                    child: Text(
                                      "PLASMA",
                                      style: AppTheme.body1,
                                    ),
                                  ),
                                ),
                              )
                            },
                            onValueChanged: (val) {
                              setState(() {
                                index = val;
                                if (val == 0) {
                                  bridge = 1;
                                } else {
                                  bridge = 2;
                                }
                              });
                            })
                        : args == 1
                            ? Text("POS Bridge", style: AppTheme.headline)
                            : args == 2
                                ? Text(
                                    "Plasma Bridge",
                                    style: AppTheme.headline,
                                  )
                                : Container(),
                  ],
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (val) => (val == "" || val == null) ||
                                (double.tryParse(val) == null ||
                                    (double.tryParse(val) < 0 ||
                                        double.tryParse(val) > balance))
                            ? "Invalid Amount"
                            : null,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
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
                                  double.tryParse(
                                      _amount.text == "" ? "0" : _amount.text),
                                  token.quoteRate)
                              .toString(),
                      style: AppTheme.bigLabel,
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    bridge == 2
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
                        : Container(),
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
                          balance.toStringAsFixed(2) + " " + token.contractName,
                          style: AppTheme.title,
                        ),
                        trailing: FlatButton(
                          onPressed: () {
                            _sendWithDrawTransaction(state, context);
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
                                  child:
                                      Icon(Icons.check, color: AppTheme.white),
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
    );
  }

  _sendWithDrawTransaction(
      WithdrawBurnDataFinal state, BuildContext context) async {
    if (double.tryParse(_amount.text) == null ||
        double.tryParse(_amount.text) < 0 ||
        double.tryParse(_amount.text) > balance) {
      Fluttertoast.showToast(
          msg: "Invalid amount", toastLength: Toast.LENGTH_LONG);
      return;
    }
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    TransactionData transactionData;
    var trx = await WithdrawManagerWeb3.burnTx(
        _amount.text, state.data.token.contractAddress);
    var type;
    if (bridge == 1) {
      type = TransactionType.BURNPOS;
    } else if (bridge == 2) {
      type = TransactionType.BURNPLASMA;
    } else {
      return;
    }

    transactionData = TransactionData(
        amount: _amount.text,
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
