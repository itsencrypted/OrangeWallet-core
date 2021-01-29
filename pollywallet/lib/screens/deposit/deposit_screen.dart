import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/deposit_models/deposit_model.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/state_manager/deposit_data_state/deposit_data_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/fiat_crypto_conversions.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:web3dart/web3dart.dart';

class DepositScreen extends StatefulWidget {
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  TextEditingController _amount;
  DepositDataCubit data;
  BuildContext context;
  int bridge = 0;
  bool _isInitialized;
  int args; // 0 no bridge , 1 = pos , 2 = plasma , 3 both
  @override
  void didChangeDependencies() {
    if (this._isInitialized == null || !this._isInitialized) {
      // Only execute once

      setState(() {});
      this._isInitialized = true;
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    Future.delayed(Duration.zero, () {});
  }

  @override
  Widget build(BuildContext context) {
    this.data = context.read<DepositDataCubit>();
    this.args = ModalRoute.of(context).settings.arguments;
    bridge = args;
    if (args == 3) {
      bridge = 1;
    }
    int index = 0;
    return Scaffold(
        appBar: AppBar(
          title: Text("Deposit to Matic"),
        ),
        body: BlocBuilder<DepositDataCubit, DepositDataState>(
          builder: (BuildContext context, state) {
            if (state is DepositDataFinal) {
              var balance = EthConversions.weiToEth(
                  BigInt.parse(state.data.token.balance),
                  state.data.token.contractDecimals);
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
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
                                  ((double.parse(val) < 0 ||
                                      double.parse(val) > balance))
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
                                state.data.token.contractName,
                            style: AppTheme.title,
                          ),
                          trailing: FlatButton(
                            onPressed: _sendDepositTransaction,
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
          },
        ));
  }

  _sendDepositTransaction(DepositDataFinal state, BuildContext context) async {
    GlobalKey<State> _key = GlobalKey<State>();

    data.setData(
        DepositModel(token: state.data.token, amount: amount.toString()));
    Transaction trx;

    if (state.data.token.contractAddress.toLowerCase() ==
        ethAddress.toLowerCase())
      //Todo: Deposit Eth
      int i = 0;
    else {
      Bridge brd;
      if (bridge == 1)
        brd = Bridge.POS;
      else
        brd = Bridge.PLASMA;
      bool approval = await EthereumTransactions.allowanceERC20(
          state.data.token.contractAddress, brd);
      //Todo: Check allowance
      //Todo: Send increase allowance page
      //Todo: Send deposit
    }
    TransactionData args = TransactionData(
        trx: trx,
        amount: _amount.text,
        to: state.data.token.contractAddress,
        type: TransactionType.SEND);
    // Navigator.pushNamed(
    //     context, confirmMaticTransactionRoute,
    //     arguments: args);
  }
}
