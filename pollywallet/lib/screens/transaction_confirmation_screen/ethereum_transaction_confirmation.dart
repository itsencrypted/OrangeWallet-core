import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/eth_conversions.dart';
import 'package:pollywallet/utils/web3_utils/ethereum_transactions.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class EthTransactionConfirmation extends StatefulWidget {
  @override
  _EthTransactionConfirmationState createState() =>
      _EthTransactionConfirmationState();
}

class _EthTransactionConfirmationState
    extends State<EthTransactionConfirmation> {
  TransactionData args;
  bool _loading = true;
  BigInt gasPrice;
  BigInt fast;
  BigInt slow;
  BigInt normal;
  BigInt selectedGas;
  int speed = 1; //0 - slow, 1 - normal, 2- fast
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      args = ModalRoute.of(context).settings.arguments;
      EthereumTransactions.getGasPrice().then((value) {
        setState(() {
          gasPrice = value;
          fast = gasPrice + BigInt.from((gasPrice ~/ BigInt.from(10)).toInt());
          slow = gasPrice - BigInt.from((gasPrice ~/ BigInt.from(10)).toInt());
          normal = gasPrice;
          _loading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.2;
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm transaction"),
      ),
      body: _loading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitFadingFour(
                  size: 50,
                  color: AppTheme.primaryColor,
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Network:",
                        style: AppTheme.title,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Ethereum", style: AppTheme.subtitle),
                      ),
                      Text(
                        "To:",
                        style: AppTheme.title,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          args.to,
                          style: AppTheme.subtitle,
                        ),
                      ),
                      Text(
                        "Amount:",
                        style: AppTheme.title,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          args.amount,
                          style: AppTheme.subtitle,
                        ),
                      ),
                      Text(
                        "Type:",
                        style: AppTheme.title,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          TransactionData.txTypeString[args.type.index],
                          style: AppTheme.subtitle,
                        ),
                      ),
                      Text(
                        "Select speed:",
                        style: AppTheme.title,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlatButton(
                                onPressed: () {
                                  setState(() {
                                    speed = 0;
                                    selectedGas = slow;
                                  });
                                },
                                child: Card(
                                  shape: AppTheme.cardShape,
                                  elevation: AppTheme.cardElevations,
                                  color: speed == 0
                                      ? AppTheme.secondaryColor
                                      : Colors.grey,
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Slow\n${EthConversions.weiToGwei(slow)} Gwei",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            FlatButton(
                                onPressed: () {
                                  setState(() {
                                    speed = 1;
                                    selectedGas = normal;
                                  });
                                },
                                child: Card(
                                  shape: AppTheme.cardShape,
                                  elevation: AppTheme.cardElevations,
                                  color: speed == 1
                                      ? AppTheme.secondaryColor
                                      : Colors.grey,
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Normal\n${EthConversions.weiToGwei(normal)} Gwei",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            FlatButton(
                                onPressed: () {
                                  setState(() {
                                    speed = 2;
                                    selectedGas = fast;
                                  });
                                },
                                child: Card(
                                  shape: AppTheme.cardShape,
                                  elevation: AppTheme.cardElevations,
                                  color: speed == 2
                                      ? AppTheme.secondaryColor
                                      : Colors.grey,
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Fast\n${EthConversions.weiToGwei(fast)} Gwei",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SafeArea(
                        child:
                            ConfirmationSlider(onConfirmation: () => _sendTx()))
                  ],
                ))
              ],
            ),
    );
  }

  _sendTx() async {
    final GlobalKey<State> _keyLoader = new GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _keyLoader);
    String hash = await EthereumTransactions.sendTransaction(
        args.trx, selectedGas, context);
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    print(hash);
    Navigator.popAndPushNamed(context, ethereumTransactionStatus,
        arguments: hash);
  }
}
