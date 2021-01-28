import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      args = ModalRoute.of(context).settings.arguments;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm transaction"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Network:",
                style: AppTheme.title,
              ),
              Text("Matic", style: AppTheme.subtitle),
              Text(
                "To:",
                style: AppTheme.title,
              ),
              Text(
                args.to,
                style: AppTheme.subtitle,
              ),
              Text(
                "Amount:",
                style: AppTheme.title,
              ),
              Text(
                args.amount,
                style: AppTheme.subtitle,
              ),
              Text(
                "Type:",
                style: AppTheme.title,
              ),
              Text(
                TransactionData.txTypeString[args.type],
                style: AppTheme.subtitle,
              ),
            ],
          ),
          SafeArea(
              child: Row(
            children: [ConfirmationSlider(onConfirmation: () => _sendTx())],
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
    // push tx status
  }
}
