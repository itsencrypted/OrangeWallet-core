import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/tansaction_data/transaction_data.dart';
import 'package:pollywallet/models/transaction_models/transaction_information.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_api.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:web3dart/web3dart.dart';

class PosWithdrawWidget extends StatefulWidget {
  final txHash;

  const PosWithdrawWidget({Key key, @required this.txHash}) : super(key: key);
  @override
  _PosWithdrawWidget createState() => _PosWithdrawWidget();
}

class _PosWithdrawWidget extends State<PosWithdrawWidget> {
  bool _loading = true;
  PosState status;
  @override
  void initState() {
    WithdrawManagerApi.checkPosStatus(widget.txHash).then((value) {
      setState(() {
        status = value;
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: AppTheme.cardShape,
      elevation: AppTheme.cardElevations,
      child: ExpansionTile(
        title: ListTile(
          title: Text(
            widget.txHash,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.title,
          ),
          subtitle: Text(
            "POS Bridge",
            style: AppTheme.subtitle,
          ),
        ),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                  ),
                  child: _loading
                      ? _loadingSpinner()
                      : status == PosState.FAILEDBURN
                          ? _burnFailed()
                          : status == PosState.FAILEDEXIT
                              ? _exitFailed()
                              : status == PosState.PENDINGBURN
                                  ? _pendingWidget()
                                  : status == PosState.PENDING
                                      ? _exitPending()
                                      : status == PosState.EXITED
                                          ? _exited()
                                          : status == PosState.BURNEDNOTEXITED
                                              ? _startExit()
                                              : _pendingWidget(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadingSpinner() {
    return SizedBox(
      height: 100,
      child: SpinKitFadingFour(
        size: 50,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _pendingWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.97,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinKitCubeGrid(size: 50, color: AppTheme.primaryColor),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Your transaction is not checkpointed yet, please wait...",
                style: AppTheme.subtitle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _burnFailed() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.97,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red, size: 50),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Transaction Failed",
                style: AppTheme.subtitle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _exitFailed() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.97,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red, size: 50),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Exit Failed",
                style: AppTheme.subtitle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _exited() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.97,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_box_outlined, color: Colors.green, size: 50),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Exit Successful",
                style: AppTheme.subtitle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _exitPending() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.97,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpinKitCubeGrid(size: 50, color: AppTheme.primaryColor),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Your exit transaction is not merged yet, please wait...",
              style: AppTheme.subtitle,
            ),
          )
        ],
      ),
    );
  }

  Widget _startExit() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.97,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Your tokens are burned and checkpointed, click below to exit them onto Ethereum",
              style: AppTheme.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: receiveButtonColor.withOpacity(0.6),
                child: Text("Exit to Ethereum"),
                onPressed: _exit),
          ),
        ],
      ),
    );
  }

  _exit() async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx = await WithdrawManagerWeb3.exitPos(widget.txHash);
    if (trx == null) {
      Fluttertoast.showToast(msg: "Something Went Wrong");
    }
    TransactionData data = TransactionData(
        amount: "0",
        type: TransactionType.EXITPOS,
        to: config.rootChainProxy,
        trx: trx);
    Navigator.of(_key.currentContext, rootNavigator: true).pop();
    await Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
    _refresh();
  }

  _refresh() {
    setState(() {
      _loading = true;
    });
    WithdrawManagerApi.checkPosStatus(widget.txHash).then((value) {
      setState(() {
        status = value;
        _loading = false;
      });
    });
  }
}
