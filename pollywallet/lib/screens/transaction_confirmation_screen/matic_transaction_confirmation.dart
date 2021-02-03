import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/web3_utils/matic_transactions.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

class MaticTransactionConfirm extends StatefulWidget {
  @override
  _MaticTransactionConfirmState createState() =>
      _MaticTransactionConfirmState();
}

class _MaticTransactionConfirmState extends State<MaticTransactionConfirm> {
  TransactionData args;
  bool _loading = true;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      args = ModalRoute.of(context).settings.arguments;
      print(args.to);
      print(args.amount);
      print(args.type);
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm transaction"),
      ),
      body: _loading
          ? Container()
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
                        child: Text("Matic", style: AppTheme.subtitle),
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
    String hash = await MaticTransactions.sendTransaction(args.trx, context);
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    if (hash == null || hash == "failed") {
      return;
    }
    Navigator.popAndPushNamed(context, transactionStatusMaticRoute,
        arguments: hash);
  }
}
