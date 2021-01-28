import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/send_token_model/send_token_data.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/state_manager/send_token_state/send_token_cubit.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/fiat_crypto_conversions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:web3dart/web3dart.dart';

class SendTokenAmount extends StatefulWidget {
  @override
  _SendTokenAmountState createState() => _SendTokenAmountState();
}

class _SendTokenAmountState extends State<SendTokenAmount> {
  SendTransactionCubit data;
  int index = 0;
  TextEditingController _amount = TextEditingController();
  TextEditingController _address = TextEditingController();
  RegExp reg = RegExp(r'^0x[a-fA-F0-9]{40}$');
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      data = context.read<SendTransactionCubit>();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Paying"),
        ),
        body: BlocBuilder<SendTransactionCubit, SendTransactionState>(
          builder: (BuildContext context, state) {
            if (state is SendTransactionFinal) {
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
                      CupertinoSegmentedControl<int>(
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
                                    : AppTheme.somewhatYellow.withOpacity(0.01),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    "Token",
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
                                    : AppTheme.somewhatYellow.withOpacity(0.01),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 10),
                                  child: Text(
                                    "USD",
                                    style: AppTheme.body1,
                                  ),
                                ),
                              ),
                            )
                          },
                          onValueChanged: (val) {
                            setState(() {
                              index = val;
                            });
                          }),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextFormField(
                          controller: _address,
                          keyboardAppearance: Brightness.dark,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) =>
                              reg.hasMatch(val) ? null : "Invalid addresss",
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.text,
                          style: AppTheme.bigLabel,
                          decoration: InputDecoration(
                              prefix: FlatButton(
                                child: Icon(Icons.paste),
                                onPressed: () async {
                                  ClipboardData data =
                                      await Clipboard.getData('text/plain');
                                  _address.text = data.text;
                                },
                              ),
                              suffix: FlatButton(
                                child: Icon(Icons.qr_code),
                                onPressed: () async {
                                  var qrResult = await BarcodeScanner.scan();
                                  RegExp reg = RegExp(r'^0x[0-9a-fA-F]{40}$');
                                  print(qrResult.rawContent);
                                  if (reg.hasMatch(qrResult.rawContent)) {
                                    print("Regex");
                                    if (qrResult.rawContent.length == 42) {
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) => (double.parse(val) < 0 ||
                                  double.parse(val) > balance)
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
                      index == 0
                          ? Text(
                              FiatCryptoConversions.fiatToCrypto(
                                          state.data.token.quoteRate,
                                          double.parse(_amount.text == ""
                                              ? "0"
                                              : _amount.text))
                                      .toString() +
                                  " " +
                                  state.data.token.contractName,
                              style: AppTheme.bigLabel,
                            )
                          : Text(
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
                              _amount.text = FiatCryptoConversions.cryptoToFiat(
                                      balance, state.data.token.quoteRate)
                                  .toString();
                            });
                          }
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                        onPressed: () async {
                          GlobalKey<State> _key = GlobalKey<State>();
                          double amount;
                          if (index == 0) {
                            amount = double.parse(_amount.text);
                          } else {
                            amount = FiatCryptoConversions.fiatToCrypto(
                                state.data.token.quoteRate,
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
                          Dialogs.showLoadingDialog(context, _key);

                          data.setData(SendTokenData(
                              token: state.data.token,
                              receiver: _address.text,
                              amount: amount.toString()));
                          Transaction trx;
                          if (state.data.token.contractAddress == maticAddress)
                            trx = await MaticTransactions.transferMatic(
                                _address.text, _address.text, context);
                          else
                            trx = await MaticTransactions.transferERC20(
                                _amount.text,
                                _address.text,
                                state.data.token.contractAddress,
                                context);
                          TransactionData args = TransactionData(
                              trx: trx,
                              amount: _amount.text,
                              to: _address.text,
                              type: TransactionType.SEND);
                          Navigator.of(_key.currentContext, rootNavigator: true)
                              .pop();

                          Navigator.pushNamed(context, confirmMaticTransaction,
                              arguments: args);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: ClipOval(
                            child: Material(
                          color: AppTheme.primaryColor,
                          child: SizedBox(
                              height: 56,
                              width: 56,
                              child: Center(
                                child: Icon(Icons.check, color: AppTheme.white),
                              )),
                        )),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Center(child: Text("Something went Wrong"));
            }
          },
        ));
  }

  String validateAddress(String value) {
    RegExp regex = new RegExp(r'^0x[a-fA-F0-9]{40}$');
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid Ethereum address';
    else
      return null;
  }
}
