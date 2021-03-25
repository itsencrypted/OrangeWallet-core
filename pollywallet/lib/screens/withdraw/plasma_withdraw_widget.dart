import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pollywallet/constants.dart';
import 'package:pollywallet/models/transaction_data/transaction_data.dart';
import 'package:pollywallet/theme_data.dart';
import 'package:pollywallet/utils/network/network_config.dart';
import 'package:pollywallet/utils/network/network_manager.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_api.dart';
import 'package:pollywallet/utils/withdraw_manager/withdraw_manager_web3.dart';
import 'package:pollywallet/widgets/loading_indicator.dart';
import 'package:web3dart/web3dart.dart';

class PlasmaWithdrawWidget extends StatefulWidget {
  final txHash;
  final withdrawTx;
  final tokenAddress;
  final confirmTx;
  const PlasmaWithdrawWidget(
      {Key key,
      @required this.txHash,
      @required this.tokenAddress,
      @required this.withdrawTx,
      @required this.confirmTx})
      : super(key: key);
  @override
  _PlasmaWithdrawWidget createState() => _PlasmaWithdrawWidget();
}

class _PlasmaWithdrawWidget extends State<PlasmaWithdrawWidget> {
  bool _loading = true;
  PlasmaState status;
  int endTime;
  @override
  void initState() {
    WithdrawManagerApi.checkPlasmaState(
            widget.txHash, widget.withdrawTx, widget.confirmTx)
        .then((value) {
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
            "Plasma Bridge",
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
                        : status == PlasmaState.BURNFAILED
                            ? _burnFailed()
                            : (status == PlasmaState.BURNPENDING ||
                                    status == PlasmaState.BURNED)
                                ? _pendingWidget()
                                : status == PlasmaState.CHECKPOINTED
                                    ? _confirmExit()
                                    : status == PlasmaState.PENDINGCONFIRM
                                        ? _confirmPending()
                                        : status == PlasmaState.BADEXITHASH
                                            ? _badExitHash()
                                            : status ==
                                                    PlasmaState.CONFIRMFAILED
                                                ? _confirmFailed()
                                                : status !=
                                                        PlasmaState
                                                            .CONFIRMEXITABLE
                                                    ? _exitableInTime()
                                                    : status ==
                                                            PlasmaState
                                                                .READYTOEXIT
                                                        ? _startExit()
                                                        : status ==
                                                                PlasmaState
                                                                    .EXITPENDING
                                                            ? _exitPending()
                                                            : status ==
                                                                    PlasmaState
                                                                        .EXITFAILED
                                                                ? _exitFailed()
                                                                : status ==
                                                                        PlasmaState
                                                                            .EXITED
                                                                    ? _exited()
                                                                    : _somethingWentWrong()),
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

  Widget _confirmPending() {
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
                "Your confirm transaction is pending, please wait...",
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

  Widget _badExitHash() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.97,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.grey, size: 50),
              onPressed: _confirm,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Transaction Failed, bad exit hash",
                style: AppTheme.subtitle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _confirmFailed() {
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
                "Confirm Transaction Failed.",
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

  Widget _confirmExit() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.97,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Your tokens are burned and checkpointed, click below to Confirm your exit.",
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
                child: Text("Confirm Exit"),
                onPressed: _confirm),
          ),
        ],
      ),
    );
  }

  Widget _exitableInTime() {
    if (endTime == null) {
      setState(() {
        _loading = true;
      });
      _getExitTime();
      //return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.97,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CountdownTimer(
              endTime: endTime,
              onEnd: _refresh,
              textStyle: AppTheme.title,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "You will be able to exit soon.",
                style: AppTheme.subtitle,
              ),
            )
          ],
        ),
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
              "You can now exit token to ethereum.",
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

  Widget _somethingWentWrong() {
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
                "Something went wrong.",
                style: AppTheme.subtitle,
              ),
            )
          ],
        ),
      ),
    );
  }

  _exit() async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx = await WithdrawManagerWeb3.exitPlasma(widget.tokenAddress);
    if (trx == null) {
      Fluttertoast.showToast(msg: "Something Went Wrong");
      return;
    }
    TransactionData data = TransactionData(
        amount: "0",
        type: TransactionType.EXITPLASMA,
        to: config.withdrawManagerProxy,
        trx: trx);
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }

  _confirm() async {
    GlobalKey<State> _key = GlobalKey<State>();
    Dialogs.showLoadingDialog(context, _key);
    NetworkConfigObject config = await NetworkManager.getNetworkObject();
    Transaction trx =
        await WithdrawManagerWeb3.initiateExitPlasma(widget.txHash);
    if (trx == null) {
      Fluttertoast.showToast(msg: "Something Went Wrong");
      return;
    }
    TransactionData data = TransactionData(
        amount: "0",
        type: TransactionType.CONFIRMPLASMA,
        to: config.erc20PredicatePos,
        trx: trx);
    Navigator.of(_key.currentContext, rootNavigator: true).pop();
    Navigator.pushNamed(context, ethereumTransactionConfirmRoute,
        arguments: data);
  }

  _getExitTime() async {
    int endTime = DateTime.now().millisecondsSinceEpoch +
        int.parse(await WithdrawManagerApi.plasmaExitTime(
            widget.txHash, widget.confirmTx));
    setState(() {
      _loading = true;
      this.endTime = endTime;
    });
  }

  _refresh() {
    setState(() {
      _loading = true;
    });
    WithdrawManagerApi.checkPlasmaState(
            widget.txHash, widget.withdrawTx, widget.confirmTx)
        .then((value) {
      setState(() {
        status = value;
        _loading = false;
      });
    });
  }
}
